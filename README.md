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
| urheilutoimi, valmennus, analyytikko | kaiken | kaiken |
| toiminnanjohtaja | kaiken | kaiken paitsi poistot |
| hallitus | strategian ja julkaistun raportin, ei pelaajia | ei mitään |

## SQL-näkymät harjoitteluun
`pelaaja`, `mittari_toteuma`, `toimenpide`, `paatoskortti` – noudattavat käyttäjän oikeuksia (`security_invoker`).

## Muutoshistoria
| Päivä | Muutos | Migraatio |
| --- | --- | --- |
| 4.11.2026 | Mittarin lisäys, muokkaus ja poisto Strategia-näkymässä | – |
| 4.11.2026 | Mittarigraafit 2024–2030 Strategia- ja Hallitus-näkymissä | 006 (tavoitteiden lukuarvot) |
| 4.11.2026 | Käyttäjät ja roolit -näkymä urheilutoimelle | 006 |
| 4.11.2026 | Ensimmäinen Supabase-versio | 001, 004, 005 |
