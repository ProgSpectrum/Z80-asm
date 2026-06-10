# Kommunikációs napló — Z80-asm / ZX Spectrum projekt

Ez a fájl a felhasználó kéréseit és az asszisztens válaszait tartalmazza (gondolkodás nélkül).  
**Frissítve:** 2026-06-10 23:47

*Megjegyzés:* Az 1–3. bejegyzés időpontja **becsült** (nincs transcript időbélyeg); a 4–11. bejegyzés git commit és fájlmódosítás alapján. Időzóna: **+0200** (helyi).

---

## 1. üzenetváltás — 2026-06-10 21:20 *(becsült)*

**Kérés:** Tudsz-e Z80 ASM nyelven programot írni ZX Spectrum számítógépre?

**Válasz:** Igen, tudok Z80 assemblyt ZX Spectrumre írni. Ismertetve: Z80 utasítások, 48K/128K hardver, ROM rutinok, képernyőmemória, SjASM/Pasmo szintaxis. Példa Hello World (`org #8000`, CHAN_OPEN, PRINT). Ask módban csak tanácsadás; Agent módban megírható a projektbe. Érdemes megadni: assembler, 48K/128K, cél, betöltési cím.

---

## 2. üzenetváltás — 2026-06-10 21:25 *(becsült)*

**Kérés:** Milyen segédprogramokra van szükség a program kipróbálásához, teszteléséhez, futtatásához?

**Válasz:** Minimális setup: **assembler** (SjASMPlus ajánlott) + **emulátor** (Fuse). Opcionális: debugger, fájlformátumok (.tap, .z80, .sna), grafikus eszközök (Multipaint), SD-betöltő valódi gépre. Windowsra: SjASMPlus → build → Fuse. Példa: `sjasmplus main.asm` → `program.tap` → Fuse File → Open.

---

## 3. üzenetváltás — 2026-06-10 21:30 *(becsült)*

**Kérés:** Fel tudod telepíteni a szükséges toolokat a project könyvtárba? Legyen `tools`, `src`, `bin` (`.tap` / `.tzx` / `.z80` kimenet).

**Válasz:** Ask módban nem telepíthető; Agent módban megcsinálható. Javasolt struktúra: `tools/sjasmplus/`, `tools/fuse/`, `src/main.asm`, `bin/`, `build.bat`. SjASMPlus portable a `tools/`-ba, Fuse rendszerszinten vagy szintén `tools/`-ba.

---

## 4. üzenetváltás — 2026-06-10 21:45

**Kérés:** 48K Spectrumra kódolunk. Kell a Fuse is.

**Válasz:** Felállítva a 48K fejlesztői környezet:
- **SjASMPlus** 1.23.1 → `tools/sjasmplus/sjasmplus.exe`
- **Fuse** 1.8.0 → `tools/fuse/fuse.exe`
- `src/main.asm` — Hello Spectrum 48K példa
- `build.bat`, `run.bat` (Fuse 48K, auto-load TAP)
- `bin/program.tap` build kimenet
- `.gitignore` a bin fájlokra

Használat: `build.bat` → `run.bat`.

---

## 5. üzenetváltás — 2026-06-10 22:48

**Kérés:** Tervezzük meg a programot — gördeszkás játék, akadályok (ugrás/lehajlás), nehezítés, három sávos képernyő (HUD / sebesség / játék). Készíts játékmenet leírást és programtervet.

**Válasz:** Két dokumentum elkészült:
- [`docs/jatekmenet.md`](jatekmenet.md) — játékmenet, technika nélkül
- [`docs/programterv.md`](programterv.md) — követelmények, modulok, fázisok, nyitott kérdések

---

## 6. üzenetváltás — 2026-06-10 23:05

**Kérés:** Játékmenet kiegészítések: csak Fel/Le billentyű; egyszerre ne legyen alul és felül akadály; kombó rendszer; 3 élet pályánként; 5-ös kombó → +1 élet; game over ha elfogynak az életek.

**Válasz:** Frissítve mindkét dokumentum:
- Vezérlés: Fel = ugrás, Le = lehajlás
- Max. 1 akadály egyszerre (úti VAGY fej fölötti)
- 3 élet, hiba = −1, 0 = game over
- Kombó: siker növeli, hiba nullázza, 5-ös kombó +1 élet
- HUD: életek + kombó is látható

---

## 7. üzenetváltás — 2026-06-10 23:12

**Kérés:** Térjünk át a grafikára. Tájékozódj a Spectrum képernyőmemóriáról, frissítésről, scrollozásról, sprite-okról; készíts külön technikai dokumentációt.

**Válasz:** Elkészült [`docs/kepernyo-grafika.md`](kepernyo-grafika.md):
- Memóriatérkép (#4000–#5AFF), 3 harmad, attribútumok, clash
- Cím-számító rutinok, HUD kiírás, frissítési stratégiák
- Scroll és sprite technikák, játékhoz ajánlott megközelítés
- 3 játéksáv = 3 Spectrum harmad illeszkedés

---

## 8. üzenetváltás — 2026-06-10 23:28

**Kérés:** A színekkel ne foglalkozzunk — egyelőre fekete/fehér; később esetleg háttér vagy tinta szín.

**Válasz:** Rögzítve mindhárom dokumentumban:
- v1: monochrome, fix INK/PAPER induláskor, nincs színkezelés sprite-rajzoláskor
- Nincs attribute clash gond v1-ben
- Később opcionális PAPER/INK módosítás

---

## 9. üzenetváltás — 2026-06-10 23:32

**Kérés:** A gördeszkás legyen 3 karakter széles × 6 magas; feje a felső 3×3 terület; vékony, félig guggoló test. Frissítsd a dokumentációt, készíts grafikai terveket. Nagy méretben vagy végleges méretben érdemes tervezni?

**Válasz:**
- Méret rögzítve: 24×48 px, fej 3×3 cella, test vékony középen, alsó sáv 8 sor (sprite 48 px + 16 px margó)
- [`docs/karakter-grafika.md`](karakter-grafika.md) — pixelterv (gördülés, fej felénk vázlat)
- `skater-sprite-design` canvas — vizuális előnézet
- **Ajánlás:** egyenesen végleges 3×6 cella rács; papírvázlat OK arányokhoz; nagyított digitális rajz lekicsinyítése kerülendő

---

## 10. üzenetváltás — 2026-06-10 23:37

**Kérés:** Old meg, hogy a `/tools` könyvtár ne menjen ki GitHubra — a `.gitignore` valószínűleg hibás.

**Válasz:** Két probléma volt:
1. `tools/*` helyett `/tools/` kell
2. A már commitolt 116 fájl nem ignorálódik automatikusan

Javítás: `.gitignore` → `/tools/`, majd `git rm -r --cached tools/` (lokálisan megmaradt). Commit + push szükséges a GitHubról való eltávolításhoz.

---

## 11. üzenetváltás — 2026-06-10 23:41

**Kérés:** Az eddigi és ezentúl minden kommunikációt ments el egy `.md` fájlba; agent módban minden alkalommal frissítsd. Csak kérés és válasz, gondolkodás nélkül.

**Válasz:** Ez a fájl (`docs/kommunikacio.md`). Agent módban minden válasz végén új bejegyzéssel bővül. Cursor szabály: `.cursor/rules/kommunikacio-naplo.mdc`.

---

## 12. üzenetváltás — 2026-06-10 23:47

**Kérés:** Az „## N. üzenetváltás” után írd oda a pontos időpontot is (dátum, időpont). Frissítsd visszamenőleg is, ha teheted. Ez alapján módosítsd a `.mdc` fájlt is.

**Válasz:** Frissítve minden bejegyzés formátuma: `## N. üzenetváltás — YYYY-MM-DD HH:MM`. Visszamenőleg: 4–11. git/fájl alapján, 1–3. becsült (transcriptben nincs időbélyeg). A `.cursor/rules/kommunikacio-naplo.mdc` szabály is módosítva — ezentúl kötelező a dátum+idő a címsorban.

---
