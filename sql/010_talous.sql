-- VPS-pilotti, migraatio 010: talous-kokoelma pelaajakohtaisille kustannuksille
-- Aja SQL Editorissa yhtenä ajona. Toistettava.
--
-- Pelaajakohtaiset kustannukset (palkka, kulut) ovat luottamuksellisia.
-- Ne tallentuvat omaan kokoelmaansa 'talous', jonka näkevät ja jota muuttavat
-- vain urheilutoimi ja toiminnanjohtaja. Valmennus, analyytikko ja hallitus eivät näe sitä.
-- Hallitus näkee vain julkaistun raportin koosteet (ei pelaajia, ei palkkoja).

------------------------------------------------------------
-- 1. Sallitaan uusi kokoelma
------------------------------------------------------------
alter table dokumentti drop constraint if exists dokumentti_kokoelma_sallittu;
alter table dokumentti add constraint dokumentti_kokoelma_sallittu check (kokoelma in (
  'mittarit','toimenpiteet','paikat','kortit','kaudet','pelaajat',
  'skenaariot','asetukset','vahvuus','wyscout','hallitusraportti','talous'));

------------------------------------------------------------
-- 2. Säännöt uusiksi: talous on rajattu, muu ennallaan
------------------------------------------------------------
drop policy if exists "lukeminen" on dokumentti;
create policy "lukeminen" on dokumentti for select to authenticated
  using (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja'))
    or (oma_rooli() = 'hallitus' and kokoelma in ('mittarit','toimenpiteet','hallitusraportti'))
  );

drop policy if exists "lisays" on dokumentti;
create policy "lisays" on dokumentti for insert to authenticated
  with check (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja'))
  );

drop policy if exists "muutos" on dokumentti;
create policy "muutos" on dokumentti for update to authenticated
  using (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja'))
  )
  with check (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja'))
  );

drop policy if exists "poisto" on dokumentti;
create policy "poisto" on dokumentti for delete to authenticated
  using (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja'))
  );

------------------------------------------------------------
-- 3. Pelaajabudjetti ja sarjapaikan arvo asetuksiin (eivät ole luottamuksellisia:
--    budjetti on julkaistu). Muutettavissa Talous-näkymässä.
------------------------------------------------------------
insert into dokumentti (kokoelma, id, data, muokkaaja)
values ('asetukset', 'talous', jsonb_build_object(
  'budjetti', 700000, 'budjettikausi', 2026, 'sarjapaikka', 600000,
  'lahde', 'Pelaajabudjetti 2026: seura (julkaistu Veikkausliigan budjettivertailussa). Sarjapaikan arvo: arvio 500–800 k€, tarkistettava.'), 'migraatio 010')
on conflict (kokoelma, id) do nothing;

-- Tarkistus: rajattu kokoelma on mukana
select pg_get_constraintdef(oid) from pg_constraint where conname = 'dokumentti_kokoelma_sallittu';
