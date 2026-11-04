-- VPS-pilotti, migraatio 006: käyttäjähallinta työkalussa ja tavoitteiden lukuarvot
-- Aja SQL Editorissa yhtenä ajona. Toistettava.

------------------------------------------------------------
-- 1. Käyttäjähallinta: vain urheilutoimi voi listata käyttäjät ja antaa rooleja.
--    security definer: funktio saa lukea auth.users-taulua, jota selain ei näe.
--    Jokainen funktio tarkistaa ensin, että kutsuja on urheilutoimi.
------------------------------------------------------------
create or replace function listaa_kayttajat()
  returns table (user_id uuid, email text, rooli text, viimeksi timestamptz)
  language plpgsql stable security definer set search_path = public, auth as $$
begin
  if oma_rooli() is distinct from 'urheilutoimi' then
    raise exception 'Vain urheilutoimenjohtaja voi hallita käyttäjiä';
  end if;
  return query
    select u.id, u.email::text, r.rooli, u.last_sign_in_at
    from auth.users u left join kayttaja_rooli r on r.user_id = u.id
    order by r.rooli nulls last, u.email;
end $$;

create or replace function aseta_rooli(p_email text, p_rooli text)
  returns void language plpgsql security definer set search_path = public, auth as $$
declare v_id uuid;
begin
  if oma_rooli() is distinct from 'urheilutoimi' then
    raise exception 'Vain urheilutoimenjohtaja voi hallita käyttäjiä';
  end if;
  select id into v_id from auth.users where lower(email) = lower(trim(p_email));
  if v_id is null then
    raise exception 'Käyttäjää % ei löydy. Luo käyttäjätili ensin Supabasessa (Authentication → Users → Add user).', p_email;
  end if;
  if v_id = auth.uid() and p_rooli <> 'urheilutoimi' then
    raise exception 'Et voi vaihtaa omaa rooliasi. Pyydä toista urheilutoimen käyttäjää tekemään muutos.';
  end if;
  insert into kayttaja_rooli (user_id, rooli) values (v_id, p_rooli)
  on conflict (user_id) do update set rooli = excluded.rooli;
end $$;

create or replace function poista_rooli(p_email text)
  returns void language plpgsql security definer set search_path = public, auth as $$
declare v_id uuid;
begin
  if oma_rooli() is distinct from 'urheilutoimi' then
    raise exception 'Vain urheilutoimenjohtaja voi hallita käyttäjiä';
  end if;
  select id into v_id from auth.users where lower(email) = lower(trim(p_email));
  if v_id = auth.uid() then
    raise exception 'Et voi poistaa omaa rooliasi.';
  end if;
  delete from kayttaja_rooli where user_id = v_id;
end $$;

-- PostgreSQL antaa funktioiden suoritusoikeuden oletuksena kaikille (PUBLIC).
-- Rajataan kaikki funktiot kirjautuneille.
revoke execute on function listaa_kayttajat(), aseta_rooli(text, text), poista_rooli(text),
                           oma_rooli(), paivita_dokumentti(text, text, jsonb, text) from public, anon;
grant  execute on function listaa_kayttajat(), aseta_rooli(text, text), poista_rooli(text),
                           oma_rooli(), paivita_dokumentti(text, text, jsonb, text) to authenticated;

------------------------------------------------------------
-- 2. Tavoitteiden lukuarvot graafeja varten (tavoite_luku).
--    Tekstimuotoinen tavoite (esim. "30 %") säilyy ennallaan.
--    Europeleille ja Huuhkajapolulle ei ole yhtä lukua, joten ne jäävät ilman.
------------------------------------------------------------
update dokumentti set data = data || jsonb_build_object('tavoite_luku', v.luku)
from (values ('myynti', 1), ('kasvatit', 30), ('nuoret', 15), ('katsojat', 4000),
             ('pelaajamaara', 1200), ('pysyvyys', 75), ('sarjatasot', 100)) as v(id, luku)
where dokumentti.kokoelma = 'mittarit' and dokumentti.id = v.id
  and not (dokumentti.data ? 'tavoite_luku');

-- Tarkistus
select id, data->>'mittari' as mittari, data->>'tavoite_2030' as teksti, data->>'tavoite_luku' as luku
from dokumentti where kokoelma = 'mittarit' order by (data->>'jarj')::int;
