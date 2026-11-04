-- VPS-pilotti, migraatio 008: pelaajapolun mittarien laskentasääntö
-- Lasketaan eri pelaajat vuodessa (sama pelaaja kerran, vaikka hän olisi useassa tapahtumassa).
-- Toistettava.

update dokumentti set data = data || jsonb_build_object('lahde', v.lahde)
from (values
  ('huuhkajaturnaus',  'Eri pelaajat vuodessa. Huuhkajaturnaus 14-vuotiaille pojille. Seura kirjaa Palloliiton kutsuista.'),
  ('helmariturnaus',   'Eri pelaajat vuodessa. Helmariturnaus 14-vuotiaille tytöille. Seura kirjaa Palloliiton kutsuista.'),
  ('tahtitarha',       'Eri pelaajat vuodessa. Tähtitarha 15-vuotiaille. Seura kirjaa Palloliiton kutsuista.'),
  ('maajoukkue_pojat', 'Eri pelaajat vuodessa, U15–U21 ja A-maajoukkue. Seura kirjaa Palloliiton kutsuista.'),
  ('maajoukkue_tytot', 'Eri pelaajat vuodessa, U15–U21 ja A-maajoukkue. Seura kirjaa Palloliiton kutsuista.')
) as v(id, lahde)
where dokumentti.kokoelma = 'mittarit' and dokumentti.id = v.id;

select id, data->>'mittari' as mittari, data->>'lahde' as maaritelma
from dokumentti where kokoelma = 'mittarit' and id in ('huuhkajaturnaus','helmariturnaus','tahtitarha','maajoukkue_pojat','maajoukkue_tytot')
order by (data->>'jarj')::int;
