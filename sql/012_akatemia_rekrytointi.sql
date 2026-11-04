-- VPS-pilotti, migraatio 012: akatemian valmius ja rekrytoinnin kohdelista
-- Aja SQL Editorissa yhtenä ajona migraation 010 jälkeen. Toistettava.
--
-- akatemia    = 15–21-vuotiaat omat pelaajat ja valmennuspäällikön arvio valmiudesta (omistaja: valmennus)
-- rekrytointi = ulkopuoliset ehdokkaat pelipaikoittain (omistaja: analyytikko)
-- Molemmat näkyvät urheilutoimelle, valmennukselle, analyytikolle ja toiminnanjohtajalle.
-- Hallitus ei näe niitä: hallitusraportti sisältää vain määrät ilman nimiä.
-- Rivitason säännöt (migraatio 010) kattavat uudet kokoelmat sellaisinaan, joten vain sallittu lista päivitetään.

alter table dokumentti drop constraint if exists dokumentti_kokoelma_sallittu;
alter table dokumentti add constraint dokumentti_kokoelma_sallittu check (kokoelma in (
  'mittarit','toimenpiteet','paikat','kortit','kaudet','pelaajat',
  'skenaariot','asetukset','vahvuus','wyscout','hallitusraportti','talous',
  'akatemia','rekrytointi'));

-- Relaationäkymät SQL-kyselyihin (noudattavat katsojan oikeuksia)
create or replace view akatemiapelaaja with (security_invoker = true) as
select id,
       data->>'nimi'                          as nimi,
       nullif(data->>'synt','')::int          as synt,
       nullif(data->>'taso','')::int          as korkein_taso,
       data->>'taso_sarja'                    as korkein_sarja,
       nullif(data->>'taso_osuus','')::numeric as osuus_pct,
       data->>'paikka'                        as pelipaikka,
       coalesce(data->>'valmius', 'Arvioimatta') as valmius,
       data->>'askel'                         as seuraava_askel
from dokumentti where kokoelma = 'akatemia';

create or replace view rekrytointikohde with (security_invoker = true) as
select id,
       data->>'nimi'   as nimi,
       data->>'seura'  as seura,
       data->>'sarja'  as sarja,
       data->>'paikka' as pelipaikka,
       coalesce(data->>'tila', 'Seurannassa') as tila,
       nullif(data->>'sopimus','')::int as sopimus_paattyy,
       nullif(data->>'arvo','')::numeric as markkina_arvo
from dokumentti where kokoelma = 'rekrytointi';

grant select on akatemiapelaaja, rekrytointikohde to authenticated;

select pg_get_constraintdef(oid) from pg_constraint where conname = 'dokumentti_kokoelma_sallittu';
