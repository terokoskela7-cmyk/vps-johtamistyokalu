-- VPS-pilotti, migraatio 009: pelaajapolun mittarien historia 2020–2026
-- Lähde: Portaat-aineisto (PalloID-viennit, 4.11.2026 ajo). Lasketaan eri pelaajat vuodessa.
-- Seura = pelaajan oma seurajoukkue samalla kaudella (PalloID). VPS = joukkue, jonka nimi alkaa "VPS".
-- Yhteistyöseurojen pelaajia (WFA) ei lasketa VPS:lle; ne kirjataan lähdetietoon erikseen.
-- Maajoukkue = maaottelut, EM-/MM-karsinnat, UEFA Development ja A-maajoukkue; pelkkä FIFA TDS -leiri ei lasketa.
-- Tähtitarha ei ole PalloID-aineistossa: luvut Palloliiton julkaisemista nimilistoista, puuttuvat vuodet täydennetään.
-- Toistettava. Uudet luvut korvaavat saman vuoden aiemman kirjauksen.

update dokumentti
set data = data
  || jsonb_build_object('toteumat', coalesce(data->'toteumat', '{}'::jsonb) || v.toteumat)
  || jsonb_build_object('lahde', v.lahde)
from (values
  ('huuhkajaturnaus', '{"2020":6,"2021":6,"2022":7,"2023":7,"2024":3,"2025":5,"2026":7}'::jsonb,
   'Eri pelaajat vuodessa, 14-vuotiaat pojat. Portaat/PalloID: Huuhkaja-tapahtuma 2020–2022, Huuhkajaturnaus 2023–. Seura PalloID-kauden mukaan; Palloliiton nimilistoissa VPS:n nimellä 2023: 8, 2024: 3, 2025: 6, 2026: 5.'),
  ('helmariturnaus', '{"2020":0,"2021":0,"2022":7,"2023":0,"2024":0,"2025":0,"2026":0}'::jsonb,
   'Eri pelaajat vuodessa, 14-vuotiaat tytöt. Portaat/PalloID. VPS:n tyttöjen 14 v pelaavat 2023 alkaen WFA:ssa: WFA:n pelaajia 2023: 9, 2024: 2, 2025: 4, 2026: 4 (ei lasketa VPS:lle).'),
  ('maajoukkue_pojat', '{"2021":1,"2022":3,"2023":1,"2024":5,"2025":4,"2026":3}'::jsonb,
   'Eri pelaajat vuodessa, U15–U21 ja A-maajoukkue (ei pelkkä FIFA TDS -leiri). Portaat/PalloID, seura kauden mukaan.'),
  ('maajoukkue_tytot', '{"2021":0,"2022":0,"2023":0,"2024":0,"2025":0,"2026":0}'::jsonb,
   'Eri pelaajat vuodessa, U15–U19 ja A-maajoukkue (ei pelkkä FIFA TDS -leiri). Portaat/PalloID. WFA:n pelaajia 2023: 1, 2024: 2, 2025: 3, 2026: 1 (ei lasketa VPS:lle).'),
  ('tahtitarha', '{"2022":3,"2023":3,"2025":1}'::jsonb,
   'Eri pelaajat vuodessa, 15-vuotiaat pojat. Palloliiton julkaisemat nimilistat (2022 VPS:n uutinen). 2024 ja 2026 tarkistetaan; kirjaa ne käsin.')
) as v(id, toteumat, lahde)
where dokumentti.kokoelma = 'mittarit' and dokumentti.id = v.id;

-- Tarkistus
select id, data->>'mittari' as mittari, data->'toteumat' as toteumat
from dokumentti where kokoelma = 'mittarit' and id in ('huuhkajaturnaus','helmariturnaus','tahtitarha','maajoukkue_pojat','maajoukkue_tytot')
order by (data->>'jarj')::int;
