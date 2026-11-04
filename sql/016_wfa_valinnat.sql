-- VPS-pilotti, migraatio 016: WFA:n pelaajat mukaan Huuhkaja- ja Helmariturnauksen valintoihin
-- Linjaus 4.11.2026: WFA:n pelaajat lasketaan VPS:n tilastoihin Huuhkaja- ja Helmaripolulla
-- (VPS:n tytöt pelaavat 14-vuotiaina WFA:ssa vuodesta 2023). Maajoukkuemittarit pysyvät ennallaan.
-- Lähde: Portaat/PalloID, eri pelaajat vuodessa (VPS tai WFA). Aja migraation 009 jälkeen. Toistettava.
-- Luvut merkitään ehdotukseksi, kunnes seura kuittaa ne mittarin muokkauksesta.

update dokumentti
set data = data
  || jsonb_build_object('toteumat', coalesce(data->'toteumat', '{}'::jsonb) || v.toteumat)
  || jsonb_build_object('lahde', v.lahde)
  || jsonb_build_object('tarkistus', 'Portaat-ehdotus 4.11.2026, WFA mukana – seura tarkistaa luvut')
from (values
  ('huuhkajaturnaus', '{"2020":6,"2021":6,"2022":14,"2023":7,"2024":3,"2025":5,"2026":7}'::jsonb,
   'Eri pelaajat vuodessa, 14-vuotiaat pojat, VPS ja WFA. Portaat/PalloID: Huuhkaja-tapahtuma 2020–2022, Huuhkajaturnaus 2023–. WFA:n pelaajia 2022: 7 (muut vuodet VPS). Tarkista 2022: VPS 7 + WFA 7.'),
  ('helmariturnaus', '{"2020":0,"2021":0,"2022":7,"2023":9,"2024":2,"2025":4,"2026":4}'::jsonb,
   'Eri pelaajat vuodessa, 14-vuotiaat tytöt, VPS ja WFA. Portaat/PalloID. 2022 VPS:n nimellä, 2023 alkaen WFA:ssa (2023: 9, 2024: 2, 2025: 4, 2026: 4).')
) as v(id, toteumat, lahde)
where dokumentti.kokoelma = 'mittarit' and dokumentti.id = v.id;

select id, data->'toteumat' as toteumat from dokumentti
where kokoelma = 'mittarit' and id in ('huuhkajaturnaus','helmariturnaus');
