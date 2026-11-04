-- VPS-pilotti, migraatio 017: Tähtitarha 2023–2026 PalloID-aineistosta
-- Lähde: PalloID-vienti Tähtitarha 2023–2026 (4.11.2026), eri pelaajat vuodessa.
-- Seura = pelaajan oma seurajoukkue samalla kaudella (P14–P16-sarjat, PalloID). VPS = joukkue "VPS J".
-- Tähtitarha on PalloID:n mukaan 14-vuotiaiden tapahtuma (ikäluokka = kausi − 14), sama ikäluokka kuin Huuhkajaturnaus.
-- 2022 jää Palloliiton nimilistan (VPS:n uutinen) mukaiseksi, koska PalloID-aineisto alkaa 2023.
-- WFA:n pelaajia ei Tähtitarhassa 2023–2026 ollut. Aja migraation 009 jälkeen. Toistettava.

update dokumentti
set data = data
  || jsonb_build_object('toteumat', coalesce(data->'toteumat', '{}'::jsonb) || '{"2022":3,"2023":3,"2024":2,"2025":1,"2026":3}'::jsonb)
  || jsonb_build_object('lahde', 'Eri pelaajat vuodessa, 14-vuotiaat pojat (ikäluokka = kausi − 14). 2023–2026 PalloID (Tähtitarha, 86–88 valittua vuodessa); 2022 Palloliiton nimilista. VPS:n Tähtitarha-pelaajista 7 / 9 oli samana vuonna myös Huuhkajaturnauksessa. Koko maa: VPS 13. eniten pelaajia 2023–2026 (9), HJK 29, KäPa 26, Ilves 25.')
  || jsonb_build_object('tarkistus', 'Portaat-ehdotus 4.11.2026 (PalloID) – seura tarkistaa luvut')
where kokoelma = 'mittarit' and id = 'tahtitarha';

select id, data->'toteumat' as toteumat, data->>'lahde' as lahde
from dokumentti where kokoelma = 'mittarit' and id = 'tahtitarha';
