-- VPS-pilotti, migraatio 018: tietoturvatarkastuksen korjaukset (Supabase Postgres -parhaat käytännöt)
-- Aja SQL Editorissa yhtenä ajona migraation 014 jälkeen. Toistettava. Oikeudet eivät muutu.
--
-- 1. Säännöt kutsuvat roolifunktiota kerran kyselyä kohden, ei jokaisella rivillä: (select oma_rooli()).
-- 2. Urheilujohtajan päätös rekrytoinnissa suojataan tietokannassa, ei vain selaimessa.
-- 3. Muokkaajan sähköposti tulee kirjautumisesta, ei selaimen ilmoittamana.
-- 4. Kirjautumattomalta (anon) poistetaan oikeudet myös myöhemmin luotuihin näkymiin.

------------------------------------------------------------
-- 1. Rivitason säännöt, sama sisältö kuin 014:ssä, rooli haetaan kerran
------------------------------------------------------------
drop policy if exists "oma rooli" on kayttaja_rooli;
create policy "oma rooli" on kayttaja_rooli for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "lukeminen" on dokumentti;
create policy "lukeminen" on dokumentti for select to authenticated
  using (
    (kokoelma <> 'talous' and (select oma_rooli()) in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and (select oma_rooli()) in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
    or ((select oma_rooli()) = 'hallitus' and kokoelma in ('mittarit','toimenpiteet','hallitusraportti'))
  );

drop policy if exists "lisays" on dokumentti;
create policy "lisays" on dokumentti for insert to authenticated
  with check (
    (kokoelma <> 'talous' and (select oma_rooli()) in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and (select oma_rooli()) in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
  );

drop policy if exists "muutos" on dokumentti;
create policy "muutos" on dokumentti for update to authenticated
  using (
    (kokoelma <> 'talous' and (select oma_rooli()) in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and (select oma_rooli()) in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
  )
  with check (
    (kokoelma <> 'talous' and (select oma_rooli()) in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and (select oma_rooli()) in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
  );

drop policy if exists "poisto" on dokumentti;
create policy "poisto" on dokumentti for delete to authenticated
  using (
    (kokoelma <> 'talous' and (select oma_rooli()) in ('urheilutoimi','valmennus','analyytikko'))
    or (kokoelma = 'talous' and (select oma_rooli()) in ('urheilutoimi','toiminnanjohtaja'))
  );

------------------------------------------------------------
-- 2 ja 3. Tallennuksen tarkistus: muokkaaja ja urheilujohtajan päätös
------------------------------------------------------------
create or replace function oma_email() returns text
  language sql stable security definer set search_path = public, auth as $$
  select email::text from auth.users where id = auth.uid()
$$;

create or replace function tarkista_tallennus() returns trigger
  language plpgsql security invoker set search_path = public as $$
declare
  k text[] := array['utj_paatos','utj_perustelu','utj_pvm'];
  vanha jsonb := case when tg_op = 'UPDATE' then old.data else '{}'::jsonb end;
  f text;
begin
  -- SQL Editor ja palvelutili (ei kirjautunutta käyttäjää) saavat ajaa migraatioita
  if auth.uid() is null then return new; end if;
  new.muokkaaja := coalesce(oma_email(), new.muokkaaja);
  if new.kokoelma = 'rekrytointi' and oma_rooli() is distinct from 'urheilutoimi' then
    foreach f in array k loop
      if (new.data -> f) is distinct from (vanha -> f) then
        raise exception 'Vain urheilujohtaja voi kirjata päätöksen (%).', f;
      end if;
    end loop;
  end if;
  return new;
end $$;

drop trigger if exists tarkista_tallennus on dokumentti;
create trigger tarkista_tallennus before insert or update on dokumentti
  for each row execute function tarkista_tallennus();

revoke execute on function oma_email(), tarkista_tallennus() from public, anon;
grant  execute on function oma_email() to authenticated;

------------------------------------------------------------
-- 4. Kirjautumaton käyttäjä ei näe mitään
------------------------------------------------------------
revoke all on dokumentti, kayttaja_rooli, pelaaja, mittari_toteuma, toimenpide, paatoskortti,
              akatemiapelaaja, rekrytointikohde from anon;

-- Tarkistus: säännöt ja anon-oikeudet (anon-rivejä ei pitäisi tulla)
select policyname, cmd from pg_policies where tablename in ('dokumentti','kayttaja_rooli') order by 1;
select table_name, privilege_type from information_schema.role_table_grants
where table_schema = 'public' and grantee = 'anon';
