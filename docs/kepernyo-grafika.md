# ZX Spectrum 48K — képernyő és grafika technikai dokumentáció

Ez a dokumentum a gördeszkás játék grafikai rétegének tervezési alapja. A játékmenet leírása: [jatekmenet.md](jatekmenet.md), az általános programterv: [programterv.md](programterv.md).

**Célplatform:** ZX Spectrum 48K, standard ULA kijelző (256×192, színes attribútumok).

---

## 1. Alapadatok

| Paraméter | Érték |
|-----------|-------|
| Felbontás | 256 × 192 pixel |
| Karakterrács | 32 oszlop × 24 sor (8×8 pixeles cellák) |
| Bitmap terület | 6144 bájt (`#4000` – `#57FF`) |
| Attribútum terület | 768 bájt (`#5800` – `#5AFF`) |
| Teljes képernyő memória | **6912 bájt** |
| Színek cellánként | 2 szín / 8×8 blokk (INK + PAPER) |
| Frissítési ráta | 50 Hz (PAL, 312 sor / kép, ~20 480 CPU ciklus / képkocka) |

A Spectrum **nem** rendelkezik hardveres sprite- vagy scroll-egységgel. Minden pixel, mozgás és „scroll” **szoftveres**.

---

## 2. Képernyőmemória térképe

```
#4000 ┌─────────────────────────────────────┐
      │  BITMAP — 1. harmad (sor 0–7)      │  2048 bájt
#47FF └─────────────────────────────────────┘
#4800 ┌─────────────────────────────────────┐
      │  BITMAP — 2. harmad (sor 8–15)      │  2048 bájt
#4FFF └─────────────────────────────────────┘
#5000 ┌─────────────────────────────────────┐
      │  BITMAP — 3. harmad (sor 16–23)     │  2048 bájt
#57FF └─────────────────────────────────────┘
#5800 ┌─────────────────────────────────────┐
      │  ATTRIBÚTUMOK (32×24 cella)        │  768 bájt
#5AFF └─────────────────────────────────────┘
```

### 2.1 Bitmap — nem lineáris!

A pixelmemória **nem** soronként lineárisan nő. A képernyő három **harmadra** (third) van osztva, mindegyik 8 karaktersor (64 pixel) magas:

| Harmad | Karaktersorok | Bitmap cím tartomány |
|--------|---------------|----------------------|
| 0 (felső) | 0 – 7 | `#4000` – `#47FF` |
| 1 (középső) | 8 – 15 | `#4800` – `#4FFF` |
| 2 (alsó) | 16 – 23 | `#5000` – `#57FF` |

Egy memóriacím bitmezője (karakter cella bal felső sarkára, scanline 0):

```
0 1 0 T T S S S  R R R C C C C C
      │   │       │     └── oszlop (0–31)
      │   └── scanline a cellán belül (0–7)
      └── harmad (0–2)
```

**Következmény:** `POKE 16384+i` sorrendben **nem** tölti ki vizuálisan a képernyőt soronként — a címek „ugrálnak” a harmadok között.

### 2.2 Attribútumok — lineárisak

Az attribútum terület **lineáris**: +32 bájt = eggyel lejjebb lévő cella, ugyanabban az oszlopban.

Attribútum bájt formátuma:

```
F B P P P I I I
│ │ └── PAPER (háttérszín, 0–7)
│ └── BRIGHT (1 = világosabb)
└── FLASH (1 = villogás — játékban kerülendő!)
```

| Mező | Bit | Jelentés |
|------|-----|----------|
| INK | 0–2 | „Tinta” szín (1-es bitek) |
| PAPER | 3–5 | Háttér szín (0-s bitek) |
| BRIGHT | 6 | Világos árnyalat |
| FLASH | 7 | Villogás |

**Attribute clash:** egy 8×8 pixeles cellában csak **egy** INK és **egy** PAPER szín lehet. Ha két színes objektum átfedi egymást ugyanabban a cellában, a színek „összecsúsznak” — ez a Spectrum leghírhedtebb grafikai korlátja.

---

## 3. Cím számítás — alap rutinok

Ezekre minden rajzoló, sprite és scroll rutin épül.

### 3.1 Karakter koordináta → bitmap cím (scanline 0)

B = Y (0–23), C = X (0–31) → HL = bitmap cím:

```asm
; B = sor (0-23), C = oszlop (0-31)
; Kimenet: HL = bitmap cím (cella bal felső sarka)
char_to_addr:
        ld   a, b
        and  #18            ; harmad bitek
        or   #40            ; fix #40 prefix
        ld   h, a
        ld   a, b
        and  #07            ; sor a harmadon belül
        rrca
        rrca
        rrca
        or   c
        ld   l, a
        ret
```

### 3.2 Scanline lépés egy cellán belül

Ha HL egy cella **scanline 0** címére mutat, ugyanazon cella scanline *n* címére lépés:

```
HL + (n × #100)   ; gyors: n× INC H
```

Példa: scanline 3 → `INC H` × 3.

### 3.3 Következő karaktersor (scanline 0)

+32 bájt **nem** a vizuálisan következő sort adja! Harmadhatáron átlépéskor +2048 bájt kell (következő harmad azonos pozíciója).

### 3.4 Attribútum cím

Karakter (B=sor, C=oszlop) → attribútum:

```asm
; B = sor (0-23), C = oszlop (0-31)
; Kimenet: HL = attribútum cím
attr_addr:
        ld   a, b
        rrca
        rrca
        rrca                    ; sor × 32 kezdő része
        ld   h, a
        and  #03
        or   #58                  ; #5800 base
        ld   h, a
        ld   a, c
        add  a
        add  a
        add  a
        add  a
        add  a
        ld   l, a
        ret
```

*(Több optimalizált változat létezik; fejlesztés közben egy fix, tesztelt rutint érdemes választani.)*

---

## 4. A játék képernyőfelosztása és a Spectrum harmadak

A játékötlet három vízszintes sávja **szinte pontosan** illeszkedik a Spectrum három bitmap harmadjához:

| Játék sáv | Spectrum harmad | Karaktersorok | Pixel sorok | Funkció |
|-----------|-----------------|---------------|-------------|---------|
| **Felső** | 0 | 0 – 7 | 0 – 63 | HUD: pont, rekord, pálya, élet, kombó |
| **Középső** | 1 | 8 – 15 | 64 – 127 | Sebesség animáció |
| **Alsó** | 2 | 16 – 23 | 128 – 191 | Játéktér: út, karakter, akadályok |

**Előny:** a három zóna **függetlenül frissíthető**. A HUD változásakor nem kell az alsó játéktérhez hozzányúlni, és fordítva.

### Karakter pozíció (35% balról)

```
256 × 0,35 ≈ 90 pixel → 90 / 8 ≈ oszlop 11
```

A gördeszkás bal széle kb. **11. oszlopnál** (0-alapú), jobbra néz.

---

## 5. Szöveg és kiírás (HUD)

### 5.1 ROM rutinok (egyszerű, gyors fejlesztéshez)

| Rutin | Cím | Funkció |
|-------|-----|---------|
| CHAN_OPEN | `#1601` | Csatorna megnyitása (2 = képernyő) |
| PRINT | `#203C` | Null-terminated string kiírás |
| PRINT_AT | `#23DD` | Pozicionált szöveg (B=sor, C=oszlop) |

**Előny:** azonnal működő szöveg, attribútumok beállíthatók `#D7C0` SYSTEM változóval vagy attribútum írással.

**Hátrány:** a ROM betűíró **felülírja** a bitmap területet is az adott cellákban; nem ideális animált grafikai HUD fölött, de a **felső harmadban** (szinte csak szöveg) jól használható.

### 5.2 Ajánlott HUD megközelítés

| Elem | Módszer |
|------|---------|
| Pontszám, rekord, pálya | ROM `PRINT_AT` vagy saját 8×8 font |
| Életek | UDG ikonok (pl. szív) **vagy** ASCII karakterek |
| Kombó | Szöveg: „x5” — csak változáskor frissíteni |
| Színek | Előre beírt attribútum sáv a felső 1–2 sorban |

**Optimalizálás:** ne minden képkockában írjuk újra a HUD-ot — csak ha az érték változott (dirty flag).

### 5.3 Saját font / UDG

- **UDG (User Defined Graphics):** 8 darab 8×8 minta a rendszerterületen (`CHARS` pointer, `#3C00` alapértelmezett).
- **Saját teljes font:** 96 vagy 128 karakter × 8 bájt a kóddal együtt.
- **Tile-alapú számok:** 0–9 mint kis sprite-ok — gyorsabb nagy számokhoz.

Játékhoz ajánlott: **vegyes** — ROM szöveg a statikus címkékhez („SCORE”), saját UDG ikonok az életekhez.

---

## 6. Képernyőfrissítés

### 6.1 A 50 Hz keret

A Spectrum 50 Hz-es TV frissítést használ. Egy képkocka ≈ **20 480 Z80 ciklus** (3,5 MHz).

| Megközelítés | Leírás |
|--------------|--------|
| **Teljes képernyő újrarajz** | ~6912 bájt írás — **túl lassú** játékhoz |
| **Régió-alapú frissítés** | Csak az alsó harmad, vagy csak a változó téglalapok |
| **Dirty rectangle** | Csak az előző és aktuális sprite pozíció környéke |
| **Interrupt szinkron** | 50 Hz IM2/IM1: egyenletes képkocka időzítés |

**Ajánlás:** 50 Hz-es főciklus (HALT + interrupt vagy ROM interrupt), és **csak a szükséges régiók** újrarajzolása.

### 6.2 Mi frissül milyen gyakran?

| Zóna | Frissítési gyakoriság | Terület mérete |
|------|----------------------|----------------|
| Felső HUD | Csak értékváltozáskor | ~1–3 sor szöveg |
| Középső FX | Minden képkocka (vagy minden 2.) | 2048 bájt bitmap max. |
| Alsó játék | Minden képkocka | Részleges: ~512–1024 bájt tipikusan |

### 6.3 Dupla buffer

Teljes második képernyőpuffer (6912 bájt) **nem fér el** 48K-ban a játékkód és adatok mellett.

**Alternatívák:**

| Technika | Memória | Használat |
|----------|---------|-----------|
| **Save-under buffer** | Sprite méretű (pl. 16×24 bájt) | Háttér mentés sprite alá, visszaállítás, újrarajz |
| **Background tile strip** | Út minta ismétlődő sávja | Csak az út sávját állítjuk vissza |
| **XOR sprite** | Minimális | Egyszerű, de színes háttérnél rossz |

**Ajánlás a játékhoz:** save-under + maszkolt sprite az alsó harmadban.

### 6.4 Villogás (FLASH) és BRIGHT

- **FLASH bit:** kerülendő játéktérben — a ULA váltogatja a színeket, zavaró és nehezebb szinkronban tartani.
- **BRIGHT:** használható kiemeléshez (kombó „x5!”, élet ikon), de spórolni kell vele a „szép” megjelenésért.

---

## 7. Scrollozás

A Spectrumon **nincs** hardveres scroll. Minden scroll **szoftveres**.

### 7.1 Scroll típusok

| Típus | CPU költség | Játékhoz |
|-------|-------------|----------|
| **Teljes bitmap scroll** (pixel/byte shift) | Nagyon magas | Nem ajánlott |
| **Harmad-scroll** (2048 bájt másolás) | Magas | Csak ha muszáj |
| **Tile / minta scroll** | Közepes | Út szegély vonalak, középső sáv FX |
| **Sprite mozgatás** (háttér fix) | Alacsony | **Ajánlott** akadályokhoz |
| **Végtelenített út illúzió** | Alacsony | Ismétlődő útpattern + mozgó vonalak |

### 7.2 Ajánlott scroll stratégia — gördeszkás játék

```
┌────────────────────────────────────────────┐
│  HUD — STATIKUS (ritka frissítés)          │
├────────────────────────────────────────────┤
│  Sebesség sáv — VÍZSZINTES MINTA SCROLL    │
│  (csíkok, felhők balra tolása)             │
├────────────────────────────────────────────┤
│  Út — ISMÉTLŐDŐ HÁTTÉR + VONALAK          │
│  Karakter — FIX X (~oszlop 11)             │
│  Akadályok — X pozíció csökkentése         │
└────────────────────────────────────────────┘
```

**A világ nem „gördül”, hanem:**

1. Az **útpattern** lehet statikus bitmap + animált vonalak (scroll offset változó).
2. Az **akadályok** X koordinátája csökken minden képkockában.
3. A **középső sáv** vízszintes csíkjai egy `scroll_offset` változóval balra tolódnak — a sebesség vizuális jele.

Ez **sokkal olcsóbb**, mint a teljes alsó harmad bit-shift scrollja, és illik a „karakter fix, világ jön” játékmenethez.

### 7.3 Út animáció — konkrét technika

| Réteg | Megvalósítás |
|-------|--------------|
| Út szín | Attribútum: pl. PAPER=7 (fehér/szürke), INK=0 (fekete vonalak) |
| Út vonalak | 1–2 pixel magas vízszintes vonalak, `offset` minden frame-ben +1 mod N |
| Útpadló textúra | 8×8 vagy 16×8 tile ismétlés, nem kell scrollozni — az akadály mozgás adja az érzetet |
| Távolabbi háttér (középső sáv) | Egyszerű sziluettek, lassabb scroll sebesség (parallax) |

### 7.4 Középső sáv — sebesség FX

Olcsó, hatásos technikák (CPU barát):

- Víszintes **1 pixel magas vonalak** balra tolása (`scroll_offset` alapján újrarajz).
- **BRIGHT** csík pulzálás a sebesség növekedésével.
- **Attribútum színezés** váltás (nem bitmap) — nagyon gyors, de durvább hatás.
- Felhő / épület sziluett **lassú** scroll (parallax: `offset / 2`).

---

## 8. Sprite kezelés

### 8.1 Sprite formátumok

| Formátum | Méret | Előny | Hátrány |
|----------|-------|-------|---------|
| **8×8 egybefüggő** | 8 bájt | Gyors, cella-igazított | Durva, kevés részlet |
| **16×16 maszkolt** | 32+32 bájt/frame | Jó minőség | Több memória, lassabb |
| **16×16 pre-shifted** | 8×(16+2) bájt | Gyors vízszintes pozíció | Sok memória (8 vízszintes offset) |
| **Többrétegű** | test + fej külön | „Fej felénk” csak fejcsere | Két sprite összerakás |

### 8.2 Maszkolt sprite rajzolás (ajánlott)

```
háttér AND maszk
eredmény OR sprite
```

```asm
; Egyszerűsített elv (egy bájt):
ld  a, (hl)          ; háttér
and (ix+0)           ; maszk
or  (iy+0)           ; sprite adat
ld  (hl), a
```

**Save-under:** rajzolás előtt `(hl)` értékek elmentése egy bufferbe; törléskor visszaírjuk.

### 8.3 Pre-shifted sprite

A Spectrum bitek **byte-határon** vannak — ha a sprite nem 8-as többszörös X pozíción van, biteltolás kell.

**Megoldás:** minden sprite-hoz **8 vízszintes változat** előre kiszámítva (0–7 pixel eltolás). Gyorsabb futás, **8× memória** ár.

**Játékhoz:** az akadályok és a karakter **8 pixeles rácsra igazítva** mozoghat (X pozíció 8-cal csökken) — ezzel elkerülhető a pre-shift, vagy csak a karakternél használjuk.

### 8.4 Attribute clash kezelése

| Stratégia | Alkalmazás |
|-----------|------------|
| **Színezési zónák** | Út = szürke PAPER, karakter = saját cellák saját INK-je |
| **8×8 rácsra igazítás** | Sprite-ok cellahatáron, kevesebb átfedés |
| **Kiemelt színek** | Karakter feje: BRIGHT sárga; test: barna — külön cellák |
| **Minimalizált átfedés** | Akadály és karakter ne foglalja ugyanazt a 8×8 cellát |
| **Tudatos „retro” stílus** | A clash része a hangulatnak — elfogadható karikatúra játéknál |

**„Fej felénk” animáció:** külön **fej sprite frame** (4–6 bájt magas, 16 széles) cseréje — nem kell az egész testet újrarajzolni.

### 8.5 Animáció frame-ek

| Szereplő | Frame-ek | Megjegyzés |
|----------|----------|------------|
| Gördülés | 2 (váltó láb) | Opcionális, spórolható 1 frame-mel |
| Ugrás | 3 (fel – csúcs – le) | Fix ív, Y offset táblából |
| Lehajlás | 2 (le – fel) | Alacsonyabb hitbox |
| Bukás | 2–3 | Rotáció / elesés |
| Fej felénk | 1 extra fej frame | Rövid ideig, majd vissza |
| Macska / madár | 2 | Váltakozó láb/szárny |

---

## 9. Rajzolási pipeline — javasolt képkocka sorrend

```
1. Input olvasás (Fel / Le)
2. Játéklogika (mozgás, ütközés, pont, élet, kombó)
3. Akadály X pozíciók frissítése
4. Középső sáv scroll offset növelése
5. Rajzolás:
   a. Alsó harmad: út vonalak frissítése (ha kell)
   b. Akadályok: előző pozíció törlése (save-under vissza)
   c. Akadályok: új pozíció rajz
   d. Karakter: törlés + rajz (állapot szerinti frame)
   e. Felső HUD: csak ha dirty
   f. Középső sáv: scroll pattern rajz
6. HALT (következő 50 Hz interrupt)
```

---

## 10. Memória költségvetés (becslés)

| Terület | Becsült méret |
|---------|---------------|
| Kód (Z80) | 8 – 16 KB |
| Karakter sprite-ok (összes frame) | 0,5 – 1 KB |
| Akadály sprite-ok (6–8 típus) | 0,5 – 1 KB |
| Pre-shifted változatok (opcionális) | +4 – 8 KB |
| Save-under buffer | 64 – 128 bájt |
| Út / háttér tile adat | 0,25 – 0,5 KB |
| Akadály / játék állapot | < 0,5 KB |
| Stack + SYSTEM | ~0,5 KB |
| **Szabad (48K)** | ~28 – 36 KB |

A **pre-shifted** sprite-ok a legnagyobb memória-ráeső — érdemes csak a karakternél használni, az akadályoknál 8-pixel rács.

---

## 11. SjASMPlus specifikus eszközök

| Direktíva / eszköz | Használat |
|--------------------|-----------|
| `DEVICE ZXSPECTRUM48` | 48K cél |
| `SAVESNA` | Snapshot mentés fejlesztéshez (gyors teszt Fuse-ban) |
| `EMPTYTAP` / `SAVETAP` | TAP generálás |
| `INCBIN` | Előre szerkesztett grafika betöltése |
| Lua scripting | Opcionális: tile adat generálás build időben |

Grafika készítés workflow:

1. **Multipaint / SevenUp / ZX Paint** — Spectrum-kompatibilis szerkesztés.
2. Export `.bin` vagy `.scr` (6912 bájt képernyő dump).
3. `INCBIN` vagy konvertálás sprite adattá.
4. Attribútumok külön táblában vagy a `.scr` második feléből.

---

## 12. Ajánlott grafikai döntések — összefoglaló

| Téma | Javaslat | Indok |
|------|----------|-------|
| Képernyő felosztás | 3 Spectrum harmad = 3 játék sáv | Független frissítés, kevesebb CPU |
| HUD | ROM szöveg + UDG ikonok | Gyors, olcsó |
| Út / háttér | Statikus pattern + scroll offset vonalak | Nem kell teljes scroll |
| Akadály mozgás | X csökkentés, 8-pixel rács | Olcsó, clash kezelhető |
| Karakter | 16×24 maszkolt, save-under | Jó megjelenés, fix X |
| „Fej felénk” | Külön fej frame csere | Kevés extra rajzolás |
| Középső sáv FX | Víszintes vonal scroll + parallax | Sebesség érzet olcsón |
| Frissítés | Részleges, dirty flag HUD | 50 FPS közeli élmény |
| Színek | Fix paletta, BRIGHT kiemelés | Kevesebb clash |
| FLASH | Nem használjuk | Zavaró játékban |

---

## 13. Nyitott grafikai kérdések

Ezeket érdemes a prototípus előtt véglegesíteni:

1. **Karakter méret:** 16×16 elég, vagy 16×24 kell a nagy fej miatt?
2. **Színpaletta:** hány szín aktív egyszerre (pl. max 4–5 INK)?
3. **Út stílus:** városi aszfalt, vidéki út, vagy absztrakt „csíkos” retro?
4. **Középső sáv:** tényleges tájkép (épületek, felhő) vagy absztrakt sebesség vonalak?
5. **Pre-shifted:** karakternél igen/nem — memória vs. simaság?
6. **Akadály méret:** 8×8 elég (macska, kő), vagy 16×16 kell?
7. **Grafika eszköz:** melyik editorral készülnek a sprite-ok?

---

## 14. Források és további olvasnivaló

- [ZX Spectrum screen memory layout (Break Into Program)](http://www.breakintoprogram.co.uk/hardware/computers/zx-spectrum/screen-memory-layout)
- [ZX Spectrum screen routines (Espamática)](https://espamatica.com/zx-spectrum-screen/)
- [Sprite Graphics Tutorial (Chuntey)](https://chuntey.wordpress.com/2010/03/22/sprite-graphics-tutorial/)
- [SjASMPlus dokumentáció](https://z00m128.github.io/sjasmplus/documentation.html) — `SAVESNA`, `DEVICE`, `INCBIN`
- Fuse debugger: memória dump `#4000`–`#5AFF` vizuális ellenőrzéshez

---

## 15. Következő lépés

1. Nyitott kérdések (13. fejezet) átbeszélése  
2. Papír/pixel vázlat: karakter + út + 2 akadály a **alsó harmadban**  
3. Színpaletta és attribútum térkép fixálása  
4. Fázis 0 grafikai prototípus: statikus út + egy mozgó kő + karakter 3 frame  

---

*Dokumentum verzió: 1.0 — Spectrum 48K képernyő technikai tervezés*
