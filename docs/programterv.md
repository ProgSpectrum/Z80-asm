# Gördeszkás játék — programterv

Ez a dokumentum a fejlesztés előtti technikai és tervezési összefoglaló. A játékmenet részletei a [jatekmenet.md](jatekmenet.md) fájlban vannak.

**Célplatform:** ZX Spectrum **48K**  
**Nyelv:** Z80 assembly (SjASMPlus)  
**Kimenet:** `.tap` (Fuse emulátorban tesztelés)

---

## 1. Projekt célja

Egy oldalnézetes, reflexalapú gördeszkás játék megvalósítása, amely:

- az alsó harmadban jeleníti meg a játékteret;
- a középső harmadban vizuálisan kommunikálja a sebességet;
- a felső harmadban mutatja a pontszámot, rekordot és pályaszámot;
- két akciótípust kezel (ugrás, lehajlás) — **Fel / Le** billentyűkkel;
- **3 élet** rendszert alkalmaz, **kombó**-val (+1 élet 5-ös kombónál);
- egyszerre legfeljebb **egy** akadály (úti VAGY fej fölötti, nem mindkettő);
- fokozatos nehezítést alkalmaz (sebesség + sűrűség).

---

## 2. Funkcionális követelmények

### 2.1 Karakter és animáció

| # | Követelmény | Prioritás |
|---|-------------|-----------|
| K1 | Karakter oldalnézet, ~35% bal oldali pozíció, jobbra néz | kötelező |
| K2 | Három állapot: gördülés, ugrás, lehajlás | kötelező |
| K3 | Sikeres akció után rövid „fej felénk” animáció | kötelező |
| K4 | Karikatúra arányok — nagy fej | kötelező |
| K5 | Bukás / ütközés animáció vagy állapot | kötelező |

### 2.2 Akadályok

| # | Követelmény | Prioritás |
|---|-------------|-----------|
| A1 | Úti akadályok: kő, kátyú, macska, kígyó, egyéb | kötelező (legalább 3–4 típus az elején) |
| A2 | Fej fölötti akadályok: ág, madár, egyéb | kötelező (legalább 2 típus az elején) |
| A3 | Akadályok jobbról érkeznek, balra mozognak | kötelező |
| A4 | Ütközésdetektálás ugrás / lehajlás állapot alapján | kötelező |
| A5 | Akadálykészlet bővíthető (új típusok később) | kívánatos |
| A6 | Egyszerre max. 1 aktív akadály — GROUND **vagy** AIR, soha mindkettő | kötelező |

### 2.3 Nehezítés és pontozás

| # | Követelmény | Prioritás |
|---|-------------|-----------|
| N1 | Globális sebesség növekszik az idővel | kötelező |
| N2 | Akadályok közötti távolság csökken (sűrűsödés) | kötelező |
| N3 | Pontszám növelése sikeres elkerüléskor | kötelező |
| N4 | Rekord tárolása (játék session vagy tartós) | kötelező |
| N5 | Pályaszám növelése (idő- vagy távolság alapú) | kötelező |
| N6 | Kombó számláló: sikeres lánc növeli, hiba nullázza | kötelező |
| N7 | Kombó pontszorzó vagy extra pont sikeres láncokra | kötelező |
| N8 | 5-ös kombó → +1 élet visszaállítás | kötelező |

### 2.4 Életek és game over

| # | Követelmény | Prioritás |
|---|-------------|-----------|
| E1 | Alapértelmezés: **3 élet** egy pályán | kötelező |
| E2 | Ütközés → −1 élet, kombó reset, játék folytatódik | kötelező |
| E3 | 0 élet → game over (nem azonnali első hibánál) | kötelező |
| E4 | Életek megjelenítése a felső HUD-ban | kötelező |
| E5 | 5-ös kombó → +1 élet (ha van mit visszaállítani) | kötelező |

### 2.5 Képernyő és UI

| # | Követelmény | Prioritás |
|---|-------------|-----------|
| U1 | Három vízszintes sáv: info / sebesség / játék | kötelező |
| U2 | Felső sáv: pontszám, rekord, pályaszám, életek, kombó | kötelező |
| U3 | Középső sáv: sebesség animáció (nem csak szám) | kötelező |
| U4 | Alsó sáv: út + karakter + akadályok | kötelező |
| U5 | Kezdőképernyő és game over képernyő | kötelező |

### 2.6 Vezérlés

| # | Követelmény | Prioritás |
|---|-------------|-----------|
| V1 | **Fel** billentyű = ugrás | kötelező |
| V2 | **Le** billentyű = lehajlás | kötelező |
| V3 | Csak ez a két gomb — nincs egyéb akciógomb | kötelező |
| V4 | Kempston joystick (Fel/Le tengely vagy 2 gomb) | kívánatos |

---

## 3. Nem-funkcionális követelmények (48K korlátok)

| # | Követelmény |
|---|-------------|
| R1 | Működjön 48K Spectrumon, emulátorban és valódi gépen |
| R2 | Elfogadható képkockasebesség — cél: ~25 FPS vagy folyamatos, nem villogó kép |
| R3 | Memória: bitmap + attribútum + kód + adat < 48K |
| R4 | Nincs szükség háttértöltésre (tape) játék közben |
| R5 | ROM rutinok használata ahol lehet (szöveg, hang) |

---

## 4. Architektúra — javasolt modulok

```
main.asm          — init, főciklus, állapotgép
input.asm         — Fel / Le billentyű (és opcionális Kempston)
player.asm        — karakter állapot, animáció, hitbox
obstacles.asm     — akadály spawn, mozgás, típusok
collision.asm     — ütközésellenőrzés
scroll.asm        — út / háttér görgetés
speed.asm         — sebesség és sűrűség skálázás
hud.asm           — pontszám, rekord, pályaszám, életek, kombó
speed_fx.asm      — középső sáv sebesség animáció
sprites.asm       — karakter és akadály grafika (adat)
sound.asm         — effektek (opcionális első verzióban)
```

### Fő állapotgép (javaslat)

```
MENU → PLAYING → (GAME_OVER | PAUSE) → MENU
```

### Játékciklus (PLAYING)

1. Input feldolgozás  
2. Játékos állapot frissítés (animáció időzítés)  
3. Akadályok mozgatása / új spawn  
4. Ütközésellenőrzés  
5. Pontszám / nehezítés frissítés  
6. Rajzolás (háttér + szereplők + HUD)  
7. Várakozás következő képkockára  

---

## 5. Grafikai terv — technikai kérdések

> Részletes Spectrum képernyő és grafika dokumentáció: [kepernyo-grafika.md](kepernyo-grafika.md)

| Kérdés | Lehetőségek | Döntés szükséges |
|--------|-------------|------------------|
| Rajzolási mód | Tile-alapú vs. sprite bitmap vs. hibrid | **igen** |
| Karakter méret | 2×2 karakter cella? Egyedi bitmap? | **igen** |
| Akadályok | Megosztott tile-ok vs. külön sprite-ok típusonként | **igen** |
| Út animáció | Scrolling tile map vs. egyszerű ismétlődő minta | **igen** |
| Színek | Fix paletta karakterenként / attribútum zónák | **igen** |
| „Fej felénk” | Külön sprite frame vs. cserélhető fej-rész | **igen** |
| Középső sáv FX | Horizontális vonalak, felhők, „sebesség csíkok” | **igen** |

### Képernyő felosztás (pixelbecslés, 192 sor magasság)

| Sáv | Sorok (kb.) | Funkció |
|-----|-------------|---------|
| Felső | 0–63 (64 sor) | HUD szöveg / egyszerű grafika |
| Középső | 64–127 (64 sor) | Sebesség animáció |
| Alsó | 128–191 (64 sor) | Játéktér |

*Megjegyzés: a Spectrum szöveges sora 24, de bitmap módban 192 pixel magas a képernyő — a felosztás bitmap sorokban értendő.*

---

## 6. Akadályrendszer — technikai feladatok

### 6.1 Adatstruktúra (javaslat)

Minden akadályhoz:

- típus azonosító (kő, macska, ág, …)
- X pozíció (fixpontos: egész + tört)
- aktív / inaktív jelző
- szélesség, magasság (hitbox)
- kategória: `GROUND` (ugrós) vagy `AIR` (lehajlós)

### 6.2 Spawn logika

- Időzítő alapú: `next_spawn = base_interval / difficulty`
- Véletlenszerű típusválasztás súlyozással
- Minimum távolság két akadály között (ütközés elkerülése a generálásnál)
- **Döntés:** egyszerre max. 1 akadály — spawn logika váltogat GROUND / AIR között, soha nem párosít

### 6.3 Ütközés (hitbox)

- Játékos: téglalap, állapottól függő magasság (lehajlásnál alacsonyabb)
- Akadály: típusonként fix vagy animált hitbox
- **Nyitott:** pixelpontos vs. egyszerű téglalap — elég-e a téglalap?

---

## 7. Sebesség és nehezítés — javasolt modell

| Paraméter | Kezdő érték | Növekedés |
|-----------|-------------|-----------|
| `scroll_speed` | lassú | lineáris vagy lépcsős növekedés idővel |
| `spawn_rate` | ritka | csökkenő intervallum |
| `max_obstacles` | 2–3 aktív | növekvő limit (memória és játékmenet függvényében) |
| `level_number` | 1 | X másodpercenként vagy Y pontonként |

**Nyitott kérdések:**

- Van felső határ a sebességre?
- A pályaszám csak megjelenítés, vagy új akadálytípusokat is nyit?
- Nehezítés szakaszos (hullámok) vagy folyamatos?

---

## 8. Input és időzítés

| Feladat | Megjegyzés |
|---------|------------|
| Billentyű debounce | Ugrás ne ismétlődjön túl gyorsan — minimális „a levegőben” idő |
| Lehajlás időtartama | Fix hossz vs. gombnyomás tartása |
| Frame timing | Interrupt (50 Hz) vs. számláló alapú várakozás |
| Akció buffer | Elfogadunk-e 1 képkockás előreütést (input buffer)? |

---

## 9. Hang (opcionális fázisok)

| Fázis | Tartalom |
|-------|----------|
| v0.1 | Néma játék — csak vizuál |
| v0.2 | Egyszerű BEEP effektek (ugrás, siker, bukás) |
| v0.3 | Háttérzaj / motorhang (ha marad memória és CPU idő) |

---

## 10. Adatmegőrzés

| Adat | Hol tároljuk? |
|------|---------------|
| Rekord | Egyszerű memória cím (session) vagy utolsó rekord betöltéskor |
| Beállítások | Nincs első verzióban |

**Nyitott:** elég-e a rekord csak az aktuális sessionre, vagy kell „high score table”?

---

## 11. Fejlesztési ütemterv — javasolt fázisok

### Fázis 0 — Prototípus (MVP)

- [ ] Fix alsó sáv, görgető út (egyszerű csíkok)
- [ ] Karakter megjelenítés egy pozícióban
- [ ] Egy akadálytípus (kő) spawn + mozgás
- [ ] Ugrás működik, ütközés detektálás
- [ ] 3 élet + hiba esetén folytatás (nem azonnali game over)
- [ ] Game over ha 0 élet + újraindítás
- [ ] Egyszerű pontszám + kombó számláló

**Cél:** „működik-e az alap loop?” — 1–2 nap

### Fázis 1 — Teljes akciókészlet

- [ ] Lehajlás + fej fölötti akadály
- [ ] Több úti és levegőbeli típus (legalább 2–2)
- [ ] Sikeres akció „fej felénk” animáció
- [ ] Bukás animáció

### Fázis 2 — HUD és sebesség sáv

- [ ] Felső harmad: pontszám, rekord, pályaszám
- [ ] Középső harmad: sebesség animáció
- [ ] Nehezítés: sebesség + sűrűség skálázás
- [ ] 5-ös kombó → +1 élet visszaállítás

### Fázis 3 — Finomítás

- [ ] További akadálytípusok és variációk
- [ ] Hang effektek
- [ ] Kempston joystick
- [ ] Kezdőképernyő, instrukciók
- [ ] Grafikai finomítás, színek

### Fázis 4 — Polish

- [ ] Valódi Spectrum gépen teszt
- [ ] Memória- és sebesség optimalizálás
- [ ] Végső TAP csomagolás, cím képernyő

---

## 12. Döntések és nyitott kérdések

### Már eldöntve

| Téma | Döntés |
|------|--------|
| Vezérlés | Csak **Fel** (ugrás) és **Le** (lehajlás) billentyű |
| Akadály párosítás | **Nem** — egyszerre max. 1 akadály (úti vagy fej fölötti) |
| Kombó | **Igen** — láncolt sikeres akciók, hiba nullázza |
| Életek | **3** alapból; hiba = −1 élet; **0 élet = game over** |
| Kombó jutalom | **5-ös kombó** → +1 élet vissza |

### Még nyitott (kódolás előtt érdemes tisztázni)

1. Pályaváltáskor újratöltődnek-e a 3 élet?
2. Max. életszám korlát (pl. 3 felett nem mehet kombó jutalom)?
3. A 5-ös kombó ad-e extra pontot is, vagy csak életet?
4. Van-e előjelezés az akadályok előtt (pl. felkiáltásjel)?
5. Lehajlás: gomb tartása vagy automatikus fix időtartam?
6. Bukás animáció hossza game over előtt / életvesztéskor?

### Grafika

6. Milyen stílus — több szín, kevés szín, nagy pixelek (retro cartoon)?
7. Hány különböző akadály kell az első játszható verzióban?
8. Az út és háttér mennyire részletes legyen?

### Technika

9. Tile-alapú vagy szabad bitmap renderelés?
10. Elfogadható-e a kép részleges frissítése (csak alsó sáv) a sebességért?
11. Kell-e zenék vagy elég a hang effekt?
12. Rekord perzisztens legyen (betöltéskor megmarad)?

### Vezérlés / technika

13. Kempston az első verzióban kötelező?
14. Spectrum billentyűkódok: Fel = `7` (P), Le = `6` (O) — vagy cursor keys?

---

## 13. Kockázatok és kihívások (48K)

| Kockázat | Hatás | Enyhítés |
|----------|-------|----------|
| Teljes képernyő frissítés lassú | szaggatás | Csak változó régiók rajzolása |
| Sok sprite → sok memória | overflow | Tile újrafelhasználás, kevés típus az elején |
| Akadály + animáció + HUD | CPU túlterhelés | Egyszerű hitbox, fix képkocka logika |
| Színes karikatúra | attribútum konfliktusok | Színezési zónák előre tervezve |
| „Fej felénk” animáció | extra sprite adat | 1–2 extra frame, rövid időtartam |

---

## 14. Elfogadási kritériumok (első játszható verzió)

- [ ] A karakter a megfelelő pozícióban áll, oldalnézetben
- [ ] Ugrással el lehet kerülni legalább egy úti akadályt
- [ ] Lehajlással el lehet kerülni legalább egy fej fölötti akadályt
- [ ] A sebesség érezhetően nő az idő múlásával
- [ ] Az akadályok sűrűsödnek
- [ ] Pontszám és rekord látható a felső sávban
- [ ] A középső sáv jelzi vizuálisan a tempót
- [ ] 3 élet, életvesztés után folytatódik a játék
- [ ] 5-ös kombó visszaad egy életet
- [ ] Game over csak 0 életnél; utána újra lehet kezdeni
- [ ] Fuse 48K emulátorban stabilan fut

---

## 15. Következő lépés

1. A fenti **nyitott kérdések** átbeszélése és döntések rögzítése  
2. Papírvázlat / pixelrajz: karakter + 2–3 akadály + képernyő elrendezés  
3. Fázis 0 prototípus megvalósítása  
4. Iteráció a játékmenet dokumentum alapján

---

*Dokumentum verzió: 1.1 — élet + kombó + vezérlés döntések rögzítve*
