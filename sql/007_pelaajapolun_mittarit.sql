-- VPS-pilotti, migraatio 007: pelaajapolun mittarit (Palloliiton tapahtumat)
-- Korvaa mittarin "VPS-pelaajia Huuhkajapolun tapahtumissa kaikissa ikäluokissa"
-- viidellä tarkemmalla mittarilla. Pojat (Huuhkaja) ja tytöt (Helmari) erikseen.
-- Tavoitteet jätetään tyhjiksi: valmennuspäällikkö kirjaa ne työkalun muokkauslomakkeella.
-- Toistettava: olemassa olevia, jo muokattuja mittareita ei korvata.

delete from dokumentti
where kokoelma = 'mittarit' and id = 'huuhkajapolku'
  and coalesce(data->'toteumat', '{}'::jsonb) = '{}'::jsonb;   -- poistetaan vain, jos toteumia ei ole

insert into dokumentti (kokoelma, id, data, muokkaaja)
select 'mittarit', v.id, jsonb_build_object(
         'mittari', v.nimi,
         'osa', 'Laadukas pelaajakehitys',
         'yksikko', 'pelaajaa',
         'valitavoite', '',
         'tavoite_2030', 'Päätetään',
         'omistaja', 'Valmennuspäällikkö (ehdotus)',
         'lahde', 'Seura kirjaa Palloliiton kutsuista ja valinnoista vuosittain',
         'jarj', v.jarj,
         'toteumat', '{}'::jsonb),
       'migraatio 007'
from (values
  ('huuhkajaturnaus',  'Huuhkajaturnaukseen valitut VPS-pelaajat (pojat)', 9),
  ('helmariturnaus',   'Helmariturnaukseen valitut VPS-pelaajat (tytöt)', 10),
  ('maajoukkue_pojat', 'Poikien maajoukkueisiin valitut VPS-pelaajat', 11),
  ('maajoukkue_tytot', 'Tyttöjen maajoukkueisiin valitut VPS-pelaajat', 12),
  ('tahtitarha',       'Tähtitarhaan valitut VPS-pelaajat', 13)
) as v(id, nimi, jarj)
on conflict (kokoelma, id) do nothing;

-- Tarkistus
select id, data->>'mittari' as mittari, data->>'jarj' as jarj
from dokumentti where kokoelma = 'mittarit' order by (data->>'jarj')::int;
