-- VPS-pilotti, migraatio 021: mittari "Kasvattajaraha maaotteluista"
-- Lähde: Palloliiton Kasvattajarahat 2025 -koonti (maaottelut) ja Kasvattajarahamääräykset 2025:
--   3.2 b maksu syntyy, kun pelaaja on kokoonpanossa virallisessa maaottelussa (sen vuoden loppuun, jolloin hän täyttää 23)
--   4.2 maksaja Palloliitto · 5.2 b €/ottelu tasoittain (esim. U15 40 €, U19 80 €, U21 karsinta 200 €, A karsinta 500 €)
--   5.7 jako kasvattajaseuroille kasvatusvuosien suhteessa; vuodet ilman kotimaista seuraa jäävät rahastoon
-- VPS = Vaasan Palloseura + Vaasan Palloseuran Juniorit. Yhteistyöseura WFA kirjataan lähdetietoon erikseen.
-- Välitavoite = Veikkausliigaseurojen mediaani 2025 (seura + juniorijärjestö). Ehdotus: seura päättää.
-- Aja migraation 019 jälkeen. Toistettava: toteumat yhdistetään, muuta ei korvata jos mittari on jo olemassa.

insert into dokumentti (kokoelma, id, data, muokkaaja)
values ('mittarit', 'kasvattajaraha', jsonb_build_object(
  'mittari', 'Kasvattajaraha maaotteluista (VPS ja VPS-j)',
  'osa', 'Laadukas pelaajakehitys',
  'yksikko', '€',
  'valitavoite', 'Veikkausliigaseurojen mediaani (2 871 € vuonna 2025)',
  'valitavoite_luku', 2871,
  'tavoite_2030', 'Veikkausliigan mediaani tai yli (ehdotus)',
  'omistaja', 'Valmennuspäällikkö (ehdotus)',
  'lahde', 'Palloliitto: Kasvattajarahat 2025 -koonti (maaottelut; määräykset 3.2 b, 4.2, 5.2 b, 5.7). 2025: VPS 195,71 € + VPS-j 462,86 € = 658,57 €; 6 pelaajaa. Veikkausliigaseurat 2025 (seura + juniorit): HJK 31 184, Ilves 14 231, KuPS 6 760, TPS 4 636, SJK 3 832, Gnistan 3 139, Inter 2 604, Lahti 1 134, Jaro 1 003, AC Oulu 1 002, Mariehamn 693, VPS 659 € (12./12). Yhteistyöseura WFA 590 € (ei laskettu VPS:lle).',
  'tarkistus', 'Portaat-ehdotus 6.11.2026 – seura tarkistaa luvut',
  'jarj', 14,
  'toteumat', '{"2025": 659}'::jsonb), 'migraatio 021')
on conflict (kokoelma, id) do update
  set data = dokumentti.data || jsonb_build_object('toteumat', coalesce(dokumentti.data->'toteumat', '{}'::jsonb) || '{"2025": 659}'::jsonb),
      muokattu = now(), muokkaaja = 'migraatio 021';

select id, data->>'mittari' as mittari, data->'toteumat' as toteumat from dokumentti where kokoelma = 'mittarit' and id = 'kasvattajaraha';
