-- VPS-pilotti, migraatio 004: käyttäjien roolit
-- 1. Lisää ensin käyttäjä: Authentication → Users → Add user → Send invitation (tai Create new user).
-- 2. Vaihda alla sähköposti ja rooli, ja aja. Yksi rivi per käyttäjä.
--    Roolit: urheilutoimi, valmennus, analyytikko, toiminnanjohtaja, hallitus

insert into kayttaja_rooli (user_id, rooli)
select id, 'urheilutoimi' from auth.users where email = 'oma.osoite@esimerkki.fi'
on conflict (user_id) do update set rooli = excluded.rooli;

-- Esimerkki hallituksen jäsenestä:
-- insert into kayttaja_rooli (user_id, rooli)
-- select id, 'hallitus' from auth.users where email = 'hallitus@esimerkki.fi'
-- on conflict (user_id) do update set rooli = excluded.rooli;

-- Tarkistus: kuka on missäkin roolissa
select u.email, r.rooli from kayttaja_rooli r join auth.users u on u.id = r.user_id order by r.rooli;
