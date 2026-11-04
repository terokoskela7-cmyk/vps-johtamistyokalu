# VPS-pilotti Supabaseen – käyttöönotto

Kesto noin 30 minuuttia. Tee vaiheet järjestyksessä.

## 1. Uusi projekti (5 min)
1. Supabase → oma organisaatio → **New project**. Nimi `vps-pilotti`, alue **EU** (esim. North EU / Stockholm tai Central EU / Frankfurt). Älä käytä harjoitusprojektia.
2. Tallenna tietokannan salasana salasanojen hallintaan. Sitä ei tarvita työkalussa.

## 2. Tietokanta (5 min)
SQL Editor → aja tiedostot yksi kerrallaan, kukin omana ajonaan:
1. `001_rakenne.sql` – taulu, roolit, säännöt, näkymät
2. Datatiedostot `002_data.sql` ja `003_taso_data.sql` eivät ole tässä repossa, koska ne sisältävät henkilötietoja. Ne säilytetään vain seuran omassa tallennustilassa.
3. `005_oikeudet.sql` – rajapinnan oikeudet kirjautuneille
4. `006_kayttajahallinta_ja_tavoitteet.sql` – käyttäjähallinta työkalussa ja tavoitteiden lukuarvot graafeja varten
5. `007_pelaajapolun_mittarit.sql` – Palloliiton tapahtumien mittarit (Huuhkaja- ja Helmariturnaus, maajoukkueet, Tähtitarha)
6. `008_pelaajapolun_maaritelmat.sql` – laskentasääntö: eri pelaajat vuodessa, ikävaiheet
7. `009_pelaajapolun_historia.sql` – pelaajapolun toteumat 2020–2026 Portaat-aineistosta
8. `010_talous.sql` – suojattu talous-kokoelma (pelaajakohtaiset kustannukset vain urheilutoimelle ja toimitusjohtajalle) ja pelaajabudjetti
9. Pelaajien markkina-arvot: seuran sisäinen tiedosto `011_arvot_data.sql`, toimitetaan erikseen (ei tässä repossa)
10. `012_akatemia_rekrytointi.sql` – kokoelmat akatemia (valmennuspäällikkö) ja rekrytointi (analyytikko) sekä niiden SQL-näkymät
11. Akatemian esitäyttö: seuran sisäinen tiedosto `013_akatemia_data.sql` (alaikäisten nimiä), toimitetaan erikseen
12. `014_hallitus_taysi.sql` – rooli Hallitus (täysi): toimitusjohtajan oikeudet hallituksen jäsenelle
13. Akatemian Kakkos-luvut: seuran sisäinen tiedosto `015_akatemia_kakkonen.sql`, toimitetaan erikseen
14. `016_wfa_valinnat.sql` – WFA:n pelaajat mukaan Huuhkaja- ja Helmariturnauksen valintoihin

Kaikki tiedostot ovat toistettavia: uudelleenajo ei riko mitään.

## 3. Kirjautuminen (10 min)
Supabase ei anna muokata sähköpostipohjia ennen omaa SMTP-palvelinta. Siksi pilotti alkaa salasanalla, ja kirjautumiskoodi otetaan käyttöön SMTP:n kanssa.

1. **Authentication → Sign In / Providers → Email**: pidä Email päällä. Kytke **Allow new users to sign up** pois, jotta vain lisäämäsi käyttäjät pääsevät sisään.
2. **Authentication → Users → Add user → Create new user**: oma sähköpostisi, vahva salasana ja rasti **Auto Confirm User**.
3. Aja `004_kayttajat.sql`. Se antaa sinulle roolin `urheilutoimi`.

Myöhemmin, ennen kuin muut VPS:n käyttäjät otetaan mukaan:
- **Authentication → Emails → SMTP Settings**: seuran oma sähköpostipalvelin tai esimerkiksi Resend. Ilman sitä Supabase lähettää viestejä vain organisaation jäsenille ja muutaman tunnissa.
- Sen jälkeen **Templates → Magic link or OTP**: lisää viestiin rivi `Kirjautumiskoodisi: {{ .Token }}`. Silloin käyttäjät voivat kirjautua koodilla ilman salasanaa.

## 4. Työkalu (5 min)
1. Avaa työkalu osoitteessa https://terokoskela7-cmyk.github.io/vps-johtamistyokalu/ (Chrome tai Edge).
2. Ensimmäisellä kerralla se kysyy projektin osoitteen ja julkisen avaimen: **Project Settings → API** → Project URL ja `anon public` / publishable key. Julkinen avain on tarkoitettu selaimeen; data on suojattu rivitason säännöillä.
3. Kirjoita sähköposti ja salasana → Kirjaudu.

## 5. Tarkistus
- Hallitus-näkymä näyttää samat luvut kuin Claude-artifaktissa.
- Muuta yksi toteuma Strategia-näkymässä ja aja SQL Editorissa:
  `select mittari_id, vuosi, arvo from mittari_toteuma order by 1, 2;`
- Paina Hallitus-näkymässä **Julkaise hallitukselle**.

## Roolit
| Rooli | Näkee | Kirjaa |
| --- | --- | --- |
| 4.11.2026 | WFA:n pelaajat lasketaan VPS:lle Huuhkaja- ja Helmariturnauksessa | 016 |
| 4.11.2026 | Rooli Hallitus (täysi) | 014 |
| 4.11.2026 | Rekrytointi: varjokenttä (oma pelaaja, akatemian seuraaja ja kohteet pelipaikoittain, kohteen raahaus), pelipaikan profiili, kohteen tietopaketti ja päätöskortti urheilujohtajan päätöksestä | – |
| 4.11.2026 | Akatemia ja polku -näkymä (valmius, seuraava askel, seuraajat kentälle), Rekrytointi-näkymä (kohdelista, ehdokashaku Wyscout-mittareilla, ehdokasviennit muista sarjoista), talouteen agentit, bonukset, jälleenmyyntiosuudet ja kassavirta 3 v | 012, 013 |
| 4.11.2026 | Talous ja arvo -näkymä: joukkueen arvo, hallittu arvo, x ja y (myös valmennus ja ympäristö), myyntipotentiaaliset nuoret, pelaajakohtainen kannattavuus, arvon määrittely; koosteet hallitusraporttiin | 010, 011 |
| 4.11.2026 | Pelijärjestelmät 4-3-3, 4-2-3-1, 3-4-3, 3-4-2-1, 3-5-2, 5-3-2; pelipaikkojen vapaa siirto kentällä; aloittajatarve järjestelmästä; kortin Arvo-näkymä | – |
| urheilutoimi, valmennus, analyytikko | kaiken | kaiken |
| toimitusjohtaja (tunnus `toiminnanjohtaja`) | kaiken, myös pelaajakohtaiset kustannukset | kaiken paitsi pelaajien ja mittarien poistot |
| hallitus | strategian ja julkaistun raportin, ei pelaajia | ei mitään |

## SQL-näkymät harjoitteluun
`pelaaja`, `mittari_toteuma`, `toimenpide`, `paatoskortti` – noudattavat käyttäjän oikeuksia (`security_invoker`).

## Muutoshistoria
| Päivä | Muutos | Migraatio |
| --- | --- | --- |
| 4.11.2026 | Ehdotusmerkintä: Portaat-luvut näkyvät merkinnällä ⚑, kunnes seura kuittaa ne mittarin muokkauksesta | 009 |
| 4.11.2026 | Pelaajapolun historia 2020–2026 Portaat-aineistosta; mittarigraafit näyttävät koko historian ja katkaisevat viivan puuttuvan vuoden kohdalla | 009 |
| 4.11.2026 | Sarjat ja pysyvyys: värit erottuvat myös värisokeille, puuttuva ylin taso merkitty, nelikentän selite kuvan alle, putken osuudet näkyviin | – |
| 4.11.2026 | Pelaajapolun mittareiden laskentasääntö | 008 |
| 4.11.2026 | Pelaajapolun mittarit: Huuhkajaturnaus, Helmariturnaus, maajoukkueet pojat ja tytöt, Tähtitarha | 007 |
| 4.11.2026 | Mittarin lisäys, muokkaus ja poisto Strategia-näkymässä | – |
| 4.11.2026 | Mittarigraafit 2024–2030 Strategia- ja Hallitus-näkymissä | 006 (tavoitteiden lukuarvot) |
| 4.11.2026 | Käyttäjät ja roolit -näkymä urheilutoimelle | 006 |
| 4.11.2026 | Ensimmäinen Supabase-versio | 001, 004, 005 |
