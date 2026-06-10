# Gördeszkás karakter — grafikai terv

A játékmenet: [jatekmenet.md](jatekmenet.md). Képernyő technika: [kepernyo-grafika.md](kepernyo-grafika.md).

---

## 1. Méret és hely a képernyőn

### Játéktér (alsó harmad)

| Paraméter | Érték |
|-----------|-------|
| Spectrum harmad | 2. (alsó) |
| Karaktersorok | 16 – 23 (8 sor) |
| Pixel magasság | 64 px |
| Út + akadályok | Ebben a sávban |

### Gördeszkás sprite

| Paraméter | Érték |
|-----------|-------|
| Szélesség | **3 karakter cella** = **24 pixel** |
| Magasság | **6 karakter cella** = **48 pixel** |
| Összesen | 18 darab **8×8** tile |
| Bitmap adat (1 bit/pixel) | 144 bájt / frame (maszk nélkül) |

A karakter **nem tölti ki** a teljes 8 soros játékteret (64 px): 48 px magas, **16 pixel** marad fölötte (ég/vonal/távolság az akadályoknak).

### Pozíció

- Vízszintesen: bal szél ~**35%** → kb. **11. oszlop** (0-alapú karakterrács).
- Függőlegesen: a sprite **alja** illeszkedik az út felső széléhez vagy kissé alá (gördeszka a talajon).

---

## 2. Belső rács — testrészek

A 3×6 cella felosztása (oldalnézet, jobbra néz):

```
        oszlop 0    oszlop 1    oszlop 2
        (hát)       (közép)     (elöl/arány)

sor 0  ┌─────────┬─────────┬─────────┐
       │  FEJ    │  FEJ    │  FEJ    │  \
sor 1  │  FEJ    │  FEJ    │  FEJ    │   │ 3×3 cella
sor 2  │  FEJ    │  FEJ    │  FEJ    │  /  = 24×24 px
       ├─────────┼─────────┼─────────┤
sor 3  │  test   │  test   │  kar    │  \
sor 4  │  test   │  test   │  láb    │   │ 3×3 cella
sor 5  │  kerék  │ deszka  │  kerék  │  /  = test + gördeszka
       └─────────┴─────────┴─────────┘
```

| Zóna | Cellák | Pixel | Leírás |
|------|--------|-------|--------|
| **Fej** | sor 0–2, oszlop 0–2 | 24×24 | Karikatúra: teljes szélességben nagy fej |
| **Test** | sor 3–4, főleg oszlop 1 | ~8×16 | **Vékony** törzs, félig guggoló (crouch) |
| **Kar/láb** | sor 3–4, oszlop 0/2 | változó | Kar előre, láb hajlítva |
| **Gördeszka** | sor 5, oszlop 0–2 | 24×8 | Vízszintes deszka + két kerék |

**Arány:** a fej a teljes magasság **felét** (3/6 sor) foglalja — erős karikatúra hatás.

---

## 3. Tervezési workflow — nagy méret vagy végleges?

### Ajánlás: **egyenesen a végleges méretre** (3×6 cella, 24×48 px)

| Megközelítés | Értékelés |
|--------------|-----------|
| **Végleges 8×8 rács** (ajánlott) | A Spectrum **ez** a felbontás — nincs skálázás, nincs minőségvesztés |
| Papír vázlat bármilyen méretben | OK **csak arányokhoz** (fej vs. test), utána átültetés cellákra |
| Nagy digitális rajz → lekicsinyítés | **Kerülendő** — pixel art összeesik, részletek elvesznek |
| 2× zoom szerkesztőben (pl. 48×96 nézet) | OK, ha **1 pixel = 1 Spectrum pixel** exportáláskor |

**Gyakorlati munkafolyamat:**

1. Papíron vagy vektorban durva **siluett** (fej méret, guggolás) — 2 perc.
2. **3×6 doboz** rajzolása, cellánként 8×8 pont.
3. Pixelenként kitöltés **végleges méretben** (Multipaint, LibreSprite 24×48 canvas, vagy ASCII → asm).
4. Egy **referencia frame** (gördülés) kész → más állapotok variációi.
5. Implementáció: 18 db 8 bájtos tile / frame.

**Miért nem nagyobb előbb?** 24×48 már elég nagy a karikatúra részlethez; a fej 24×24 pixeles — ezen belül szem, orr, áll jól kirajzolható. Nagyítás csak önbizalmat ad, de plusz egy átméretezési lépés hibalehetőség.

---

## 4. Állapotok (animáció frame-ek)

| Állapot | Frame szám | Változás a gördüléshez képest |
|---------|------------|-------------------------------|
| **Gördülés** | 1 (+ opc. 2 váltó láb) | Alap — félig guggoló, fej profil |
| **Ugrás** | 2–3 | Teljes sprite **Y −8..−16 px** (1–2 cella); lábak kinyújtva |
| **Lehajlás** | 1–2 | Fej zóna **lejjebb** (3×3 összenyomva ~2 sorba), test vízszintesebb |
| **Fej felénk** | 1 | Csak **fej cellák** (sor 0–2) cserélve — arc elölről, test marad |
| **Bukás** | 2 | Elfordulás / elesés — későbbi fázis |

**„Fej felénk” optimalizálás:** csak a felső **9 cella** (72 bájt) külön frame — nem kell az egész 144 bájt.

---

## 5. Grafikai terv — GÖRDÜLÉS (oldalnézet, v1)

Jelölés: `#` = fekete pixel, `.` = fehér (üres).

Minden blokk egy **8×8** karakter cella. Olvashatóság: soronként 8 karakter.

### Sor 0 (fej — felső harmad)

**C0R0 — hát / haj**
```
........
...##...
..#####.
.######.
.####...
..##....
........
........
```

**C1R0 — fej teteje**
```
........
..####..
.######.
.######.
.#####..
..###...
........
........
```

**C2R0 — homlok / arc felső**
```
........
...####.
..#####.
.######.
..####..
...##...
........
........
```

### Sor 1 (fej — középső)

**C0R1**
```
........
..####..
.#####..
.####...
.###....
..##....
........
........
```

**C1R1**
```
........
.######.
########
########
.######.
..####..
...##...
........
```

**C2R1 — szem, profil**
```
........
..#####.
.#######
.####..#
.#######
..#####.
...###..
....#...
```

### Sor 2 (fej — áll / nyak)

**C0R2 — nyak hátul**
```
........
..##....
.###....
.##.....
........
........
........
........
```

**C1R2 — áll**
```
........
..####..
.######.
.####...
..##....
........
........
........
```

**C2R2 — orr / száj profil**
```
....#...
...###..
..####..
..###...
...##...
....#...
........
........
```

### Sor 3 (test — felső)

**C0R3 — hát**
```
........
..##....
.###....
.##.....
.##.....
..#.....
........
........
```

**C1R3 — vékony törzs**
```
........
...##...
...##...
...##...
...##...
...##...
...#....
........
```

**C2R3 — kar előre**
```
........
....##..
...###..
..####..
...###..
....##..
.....#..
........
```

### Sor 4 (test — alsó, guggolás)

**C0R4 — hátsó láb**
```
........
..##....
.##.....
.##.....
..#.....
........
........
........
```

**C1R4 — lábak középen**
```
........
...##...
..####..
..####..
...##...
...##...
...#....
........
```

**C2R4 — elülső láb**
```
........
....#...
...##...
..###...
...##...
....#...
........
........
```

### Sor 5 (gördeszka)

**C0R5 — hátsó kerék**
```
........
........
..####..
.######.
.######.
..####..
..##....
........
```

**C1R5 — deszka**
```
........
........
..####..
########
########
########
..####..
........
```

**C2R5 — első kerék**
```
........
........
....##..
...####.
...####.
....##..
.....#..
........
```

### Összeállított siluett (24 széles, tömörített nézet)

Minden sor = 24 pixel. A `#` a test/fej/deszka kitöltött része.

```
Fej+test sorok 0-7 (részlet):
        0         1         2
        01234567  01234567  01234567
   0    ...##...  ..####..  ...####.
   4    .######.  ########  .####..#
   8    ..####..  .######.  ..####..
  12    ..##....  ...##...  ..####..
  16    ..##....  ..####..  ...##...
  20    ..####..  ########  ...####.
  24    ..##....  ...##...  ....#...
  28    (üres)    ...##...  (üres)
```

---

## 6. Grafikai terv — FEJ FELÉNK (rövid reakció)

Csak a **C0R0 – C2R2** cellák cseréje. A test és gördeszka változatlan.

**C2R0 – C2R2 elölnézet (egyszerűsített):**

**C1R0 — fej teteje**
```
........
.######.
########
########
.######.
..####..
........
........
```

**C1R1 — két szem**
```
........
.######.
#.#..#.#
#.#..#.#
.######.
..####..
........
........
```

**C2R1 — arc**
```
........
..####..
.######.
.######.
.######.
..####..
...##...
....#...
```

**C1R2 — száj mosoly**
```
........
..####..
.######.
.##..##.
.######.
..####..
........
........
```

*(A C0 oszlop és C2R0, C2R2 profil cellák üresíthetők vagy hajjal kitölthetők — finomítás prototípusnál.)*

---

## 7. Grafikai terv — LEHAJLÁS (vázlat)

- Fej zóna: a 3×3 cella **összezsugorodik** vizuálisan — a felső 1–2 sorban „lapított” fej.
- Test: vízszintesebb, **Y irányban terjül** a középső oszlopban.
- Gördeszka: változatlan (sor 5).
- Hitbox: **alacsonyabb** — kb. 4 cella magasság (32 px) az ütközéshez.

*(Részletes pixel tile a prototípus után, ha a gördülés frame bevált.)*

---

## 8. Grafikai terv — UGRÁS (vázlat)

- Teljes 24×48 sprite **8–16 pixellel feljebb** rajzolva (útpadló felett).
- Lábak (sor 4): kinyújtva hátra-előre — „kick” póz.
- Deszka (sor 5): rövid távolság a „talaj” vonaltól.

---

## 9. Implementációs megjegyzések

| Téma | Javaslat |
|------|----------|
| Adatformátum | 18 × 8 bájt / frame, bit 7 = bal szélső pixel |
| Maszk | v1-ben opcionális — fehér háttéren elég XOR vagy save-under |
| Rajzolás | 3×6 cella ciklussal, `char_to_addr` + 8 scanline / cella |
| Pre-shifted | 24 px széles → **8 eltolás nem kötelező**, ha X pozíció 8-as rácsra igazított |
| Fix Y | Alsó harmadban fix baseline; ugrásnál Y offset változó |

---

## 10. Nyitott finomítások

1. Gördülés 2. frame kell-e (váltó láb animáció)?
2. Fej felénk: mennyi ideig (képkocka szám)?
3. Lehajlásnál a fej 3×3-ból 3×2 lesz, vagy egész sprite 5 sor magas?
4. Sapka / haj részlet elég, vagy kell arc részletesebben?

---

## 11. Kapcsolódó vizualizáció

Interaktív pixelrács: nyisd meg a **`skater-sprite-design`** canvas-t az IDE-ben (gördülés + fej felénk előnézet).

---

*Dokumentum verzió: 1.0 — 3×6 karakter méret, fekete–fehér v1*
