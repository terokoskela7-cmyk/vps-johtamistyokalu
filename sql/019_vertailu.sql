-- VPS-pilotti, migraatio 019: kokoelma vertailu (Pohjoismaat ja Veikkausliiga -vertailu Pelaajaryhmä-näkymään)
-- Aja migraation 018 jälkeen SQL Editorissa yhtenä ajona. Toistettava.
-- Vertailu näkyy samoille rooleille kuin muu seuran data (ei hallituksen suppealle roolille). Säännöt eivät muutu.
-- Varsinainen data tulee seuran sisäisestä tiedostosta 020_wyscout_2026_data.sql (lisensoitua Wyscout-dataa, ei tässä repossa).

alter table dokumentti drop constraint if exists dokumentti_kokoelma_sallittu;
alter table dokumentti add constraint dokumentti_kokoelma_sallittu check (kokoelma in (
  'mittarit','toimenpiteet','paikat','kortit','kaudet','pelaajat',
  'skenaariot','asetukset','vahvuus','wyscout','hallitusraportti','talous',
  'akatemia','rekrytointi','vertailu'));

select pg_get_constraintdef(oid) from pg_constraint where conname = 'dokumentti_kokoelma_sallittu';
