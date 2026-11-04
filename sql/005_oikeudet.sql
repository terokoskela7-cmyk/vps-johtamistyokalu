-- VPS-pilotti, migraatio 005: rajapinnan oikeudet
-- Uusissa Supabase-projekteissa taulut eivät näy rajapinnalle automaattisesti.
-- Annetaan kirjautuneille käyttäjille oikeus tauluihin; rivitason säännöt rajaavat, mitä kukin näkee.
-- Kirjautumattomat (anon) eivät saa mitään.

grant usage on schema public to authenticated;

grant select                         on kayttaja_rooli to authenticated;
grant select, insert, update, delete on dokumentti     to authenticated;
grant select on pelaaja, mittari_toteuma, toimenpide, paatoskortti to authenticated;

grant execute on function oma_rooli()                               to authenticated;
grant execute on function paivita_dokumentti(text, text, jsonb, text) to authenticated;

revoke all on kayttaja_rooli, dokumentti, pelaaja, mittari_toteuma, toimenpide, paatoskortti from anon;
revoke execute on function paivita_dokumentti(text, text, jsonb, text) from anon;

-- Tarkistus: oikeudet tauluittain
select table_name, grantee, string_agg(privilege_type, ', ' order by privilege_type) as oikeudet
from information_schema.role_table_grants
where table_schema = 'public' and grantee in ('authenticated', 'anon')
group by 1, 2 order by 1, 2;
