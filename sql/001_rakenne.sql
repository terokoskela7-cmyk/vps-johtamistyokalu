-- VPS-pilotti, migraatio 001: rakenne, roolit ja rivitason säännöt
-- Aja uudessa, tyhjässä Supabase-projektissa SQL Editorissa yhtenä ajona.
-- Skripti on toistettava: sen voi ajaa uudelleen ilman virheitä.

------------------------------------------------------------
-- 1. Dokumenttitaulu: sama rakenne kuin nykyisessä työkalussa
--    (kokoelma + tunniste + sisältö). Vaiheessa 2 normalisoidaan.
------------------------------------------------------------
create table if not exists dokumentti (
  kokoelma  text        not null,
  id        text        not null,
  data      jsonb       not null default '{}'::jsonb,
  muokattu  timestamptz not null default now(),
  muokkaaja text,
  primary key (kokoelma, id),
  constraint dokumentti_kokoelma_sallittu check (kokoelma in (
    'mittarit','toimenpiteet','paikat','kortit','kaudet','pelaajat',
    'skenaariot','asetukset','vahvuus','wyscout','hallitusraportti'))
);

------------------------------------------------------------
-- 2. Roolit: kuka kirjautunut käyttäjä on missäkin roolissa
------------------------------------------------------------
create table if not exists kayttaja_rooli (
  user_id   uuid primary key references auth.users(id) on delete cascade,
  rooli     text not null check (rooli in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus')),
  lisatty   timestamptz not null default now()
);

-- Oman roolin haku. security definer: funktio saa lukea roolitaulua,
-- vaikka käyttäjä itse näkee siitä vain oman rivinsä.
create or replace function oma_rooli() returns text
  language sql stable security definer set search_path = public as $$
  select rooli from kayttaja_rooli where user_id = auth.uid()
$$;

------------------------------------------------------------
-- 3. Rivitason säännöt (RLS)
------------------------------------------------------------
alter table dokumentti     enable row level security;
alter table kayttaja_rooli enable row level security;

drop policy if exists "oma rooli" on kayttaja_rooli;
create policy "oma rooli" on kayttaja_rooli for select to authenticated
  using (user_id = auth.uid());

-- Urheilutoimi, valmennus, analyytikko ja toiminnanjohtaja lukevat kaiken.
-- Hallitus lukee vain strategian ja julkaistun nimettömän raportin.
drop policy if exists "lukeminen" on dokumentti;
create policy "lukeminen" on dokumentti for select to authenticated
  using (
    oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja')
    or (oma_rooli() = 'hallitus' and kokoelma in ('mittarit','toimenpiteet','hallitusraportti'))
  );

drop policy if exists "lisays" on dokumentti;
create policy "lisays" on dokumentti for insert to authenticated
  with check (oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'));

drop policy if exists "muutos" on dokumentti;
create policy "muutos" on dokumentti for update to authenticated
  using      (oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'))
  with check (oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'));

drop policy if exists "poisto" on dokumentti;
create policy "poisto" on dokumentti for delete to authenticated
  using (oma_rooli() in ('urheilutoimi','valmennus','analyytikko'));

------------------------------------------------------------
-- 4. Osittainen päivitys: yhdistää muutetut kentät olemassa olevaan
--    sisältöön (data || muutos). Luo rivin, jos sitä ei ole.
--    security invoker: säännöt koskevat myös tätä funktiota.
------------------------------------------------------------
create or replace function paivita_dokumentti(p_kokoelma text, p_id text, p_muutos jsonb, p_muokkaaja text default null)
  returns void language sql security invoker set search_path = public as $$
  insert into dokumentti (kokoelma, id, data, muokattu, muokkaaja)
  values (p_kokoelma, p_id, p_muutos, now(), p_muokkaaja)
  on conflict (kokoelma, id) do update
    set data = dokumentti.data || excluded.data,
        muokattu = now(),
        muokkaaja = excluded.muokkaaja
$$;

------------------------------------------------------------
-- 5. Reaaliaikaiset päivitykset: muutokset näkyvät muille heti
------------------------------------------------------------
do $$ begin
  alter publication supabase_realtime add table dokumentti;
exception when duplicate_object then null; when undefined_object then null;
end $$;

------------------------------------------------------------
-- 6. Relaationäkymät raportointiin ja SQL-kyselyihin.
--    security_invoker = true: näkymä noudattaa katsojan oikeuksia,
--    joten hallitus ei näe pelaajanäkymästä mitään.
------------------------------------------------------------
create or replace view pelaaja with (security_invoker = true) as
select id,
       data->>'nimi'                     as nimi,
       nullif(data->>'synt','')::int              as synt,
       data->>'paikka'                   as pelipaikka,
       data->>'slot'                     as kenttapaikka,
       coalesce((data->>'oma')::boolean, false)   as oma,
       coalesce((data->>'laina')::boolean, false) as laina,
       nullif(data->>'sopimus','')::int           as sopimus_paattyy,
       nullif(data->>'minuutit_pct','')::numeric  as minuutit_pct,
       data->>'rooli'                    as rooli,
       coalesce((data->>'tarkistettu')::boolean, false) as tarkistettu
from dokumentti where kokoelma = 'pelaajat';

create or replace view mittari_toteuma with (security_invoker = true) as
select d.id            as mittari_id,
       d.data->>'mittari' as mittari,
       d.data->>'osa'     as strategian_osa,
       t.key::int      as vuosi,
       nullif(t.value,'')::numeric as arvo,
       d.data->>'tavoite_2030' as tavoite_2030
from dokumentti d, jsonb_each_text(d.data->'toteumat') t
where d.kokoelma = 'mittarit' and nullif(t.value,'') is not null;

create or replace view toimenpide with (security_invoker = true) as
select id,
       data->>'toimenpide'    as toimenpide,
       data->>'mahdollistaja' as mahdollistaja,
       data->>'aikataulu'     as aikataulu,
       coalesce(data->>'tila', 'Tieto puuttuu') as tila,
       data->>'vastuu'        as vastuu
from dokumentti where kokoelma = 'toimenpiteet';

create or replace view paatoskortti with (security_invoker = true) as
select id,
       data->>'tyyppi'     as tyyppi,
       data->>'pelaaja'    as pelaaja,
       data->>'pelipaikka' as pelipaikka,
       nullif(data->>'kausi','')::int as kausi,
       data->>'pvm'        as pvm,
       data->>'perustelu'  as perustelu,
       coalesce(data->>'jalkiarvio', 'Odottaa') as jalkiarvio
from dokumentti where kokoelma = 'kortit';
