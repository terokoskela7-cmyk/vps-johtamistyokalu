-- VPS-pilotti, migraatio 014: rooli "hallitus_taysi" (hallituksen jäsen, täysi oikeus)
-- Aja SQL Editorissa yhtenä ajona migraatioiden 010 ja 012 jälkeen. Toistettava.
--
-- Hallitus (täysi) = samat oikeudet kuin toimitusjohtajalla:
--   näkee kaiken, myös pelaajanimet ja pelaajakohtaiset kustannukset; voi muokata;
--   ei voi poistaa pelaajia eikä mittareita, ei hallitse käyttäjiä, ei kirjaa urheilujohtajan päätöstä.
-- Tavallinen "hallitus"-rooli näkee edelleen vain strategian ja julkaistun nimettömän raportin.

------------------------------------------------------------
-- 1. Sallitut roolit
------------------------------------------------------------
alter table kayttaja_rooli drop constraint if exists kayttaja_rooli_rooli_check;
alter table kayttaja_rooli add constraint kayttaja_rooli_rooli_check check (rooli in (
  'urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus','hallitus_taysi'));

------------------------------------------------------------
-- 2. Rivitason säännöt: hallitus_taysi kirjoittajien joukkoon ja talous-kokoelmaan
------------------------------------------------------------
drop policy if exists "lukeminen" on dokumentti;
create policy "lukeminen" on dokumentti for select to authenticated
  using (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
    or (oma_rooli() = 'hallitus' and kokoelma in ('mittarit','toimenpiteet','hallitusraportti'))
  );

drop policy if exists "lisays" on dokumentti;
create policy "lisays" on dokumentti for insert to authenticated
  with check (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
  );

drop policy if exists "muutos" on dokumentti;
create policy "muutos" on dokumentti for update to authenticated
  using (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
  )
  with check (
    (kokoelma <> 'talous' and oma_rooli() in ('urheilutoimi','valmennus','analyytikko','toiminnanjohtaja','hallitus_taysi'))
    or (kokoelma = 'talous' and oma_rooli() in ('urheilutoimi','toiminnanjohtaja','hallitus_taysi'))
  );

-- Poisto ennallaan: hallitus_taysi ei poista pelaajia eikä mittareita (talous: urheilutoimi ja toimitusjohtaja)

-- Tarkistus
select pg_get_constraintdef(oid) from pg_constraint where conname = 'kayttaja_rooli_rooli_check';
