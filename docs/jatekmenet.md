# Gördeszkás játék — játékmenet leírás

## Alapötlet

Egy gördeszkás karakter folyamatosan halad előre egy úton. Az úton és a feje fölött akadályok jelennek meg, amelyeket időben el kell kerülnie. A játék egyre gyorsul, az akadályok egyre sűrűbben érkeznek. A cél a minél hosszabb túlélés és a minél magasabb pontszám elérése.

---

## A karakter

- Gördeszkás fiú vagy lány — oldalnézetből látjuk.
- A képernyő bal oldalától számított **35%-nál** áll; **jobbra néz**, mintha előre gördülne.
- **Méret:** **3 karakter széles × 6 karakter magas** (24×48 pixel) az alsó játéksávban; a sáv 8 sor magas (64 px), a karakter alatta **16 px** margóval illeszkedik az úthoz.
- **Fej:** a felső **3×3** karakteres területet foglalja el (24×24 px) — a magasság fele.
- **Test:** vékony, középen; **félig guggoló** testtartás a gördeszkán.
- Karikatúra stílus: a **feje aránytalanul nagy** a testhez képest.
- **Sikeres akció után** (sikeres ugrás vagy lehajlás) a karakter **feje egy pillanatra felénk fordul** — rövid, jutalmazó reakció, mintha „na, megoldottam!” hangulatú lenne.
- Három alapállapot:
  - **Gördülés** — alaphelyzet, folyamatos előre haladás.
  - **Ugrás** — az úton lévő akadályok elkerülésére.
  - **Lehajlás** — a feje fölött repülő akadályok elkerülésére.

---

## Az út és a környezet

- Egy vízszintes útszakasz fut a képernyő alsó részén.
- Az út vizuálisan mozog (a karakter helyben marad, a világ „jön feléje”).
- Az úton és körülötte változatos tárgyak jelennek meg — nem minden pálya ugyanolyan, de az alapelv mindig ugyanaz: időben reagálni.

---

## Akadályok — át kell ugrani

Ezek az úton, a gördeszka szintjén vagy közvetlenül előtte jelennek meg. Ha a karakter nem ugrik időben, ütközés történik.

| Típus | Leírás |
|-------|--------|
| **Kövek** | Sziklák vagy kisebb kődarabok az úton. |
| **Kátyúk** | Behorpadások, bukkanók az aszfalton. |
| **Macskák** | Az útra tévedt macskák — állnak vagy átsétálnak. |
| **Kígyók** | Kígyók az úton — kígyóznak vagy gubbasztanak. |
| **Egyéb tárgyak** | Pl. konzervdoboz, göngyöleg, bicikli, stb. — a pálya változatosságát növelik. |

**Ugrás:** a **Fel** billentyűvel aktiválható. A karakter a levegőbe emelkedik, átrepül az akadályon, majd visszaér a gördeszkára.

---

## Akadályok — le kell hajolni

Ezek a karakter feje magassága körül, előlről vagy felülről érkeznek. Ha nem hajol le időben, ütközés történik.

| Típus | Leírás |
|-------|--------|
| **Faágak** | Lebegő vagy lengő ágak, mintha egy fa alá gördülne be. |
| **Madarak** | Madarak repülnek át a magasságában. |
| **Egyéb repülő tárgyak** | Pl. papírrepülő, frisbee, leeső tárgy — a pálya változatosságát növelik. |

**Lehajlás:** a **Le** billentyűvel aktiválható. A karakter lekuporodik / előrehajol a gördeszkán, a feje lejjebb kerül, és átengedi a repülő akadályt.

---

## Vezérlés

A játék **két billentyűvel** irányítható — más gomb nem szükséges:

| Billentyű | Akció |
|-----------|-------|
| **Fel** | Ugrás — úti akadályok elkerülésére |
| **Le** | Lehajlás — fej fölötti akadályok elkerülésére |

Nincs külön gomb a gördüléshez: ha nem nyomunk semmit, a karakter automatikusan halad előre alaphelyzetben.

---

## Akadályok szabálya

**Egyszerre soha nem jelenik meg úti és fej fölötti akadály.** Minden pillanatban legfeljebb egy akadály aktív a képernyőn — vagy lent kell ugrani, vagy felül le kell hajolni, de soha nem mindkettő egyszerre.

Ez tisztán tartható a reflexjátékot: mindig egyértelmű, melyik billentyű kell.

---

## Életek

- Alapértelmezés szerint **3 élet** áll rendelkezésre egy pályán — háromszor hibázhat a játékos ütközés nélkül el nem került akadály miatt.
- **Egy hiba = egy élet elvesztése.** A karakter összeesik vagy megáll, rövid bukás után a játék folytatódik a megmaradt életekkel.
- **A játék akkor ér véget, ha az összes élet elfogy** — nincs több esély.
- A felső sávon látható, hány élet maradt (pl. ikonok vagy számláló).

---

## Kombó rendszer

- Ha a játékos **egymás után**, hiba nélkül kerül el akadályokat, **kombó** épül.
- Minden sikeres elkerülés növeli a kombó számlálót; **hiba esetén a kombó nullázódik**.
- A kombó **extra pontot** ad (minél magasabb a lánc, annál értékesebb a sikeres mozdulat).
- **5-ös kombó jutalma:** ha a játékos **összehoz egy 5-ös kombót**, **visszakap egy életet** — pl. 1 életnél visszamegy 2-re, 2 életnél vissza 3-ra. Így a kockázatosabb futások során is van esély kigúzni a teljes kifogyás elől, ha ügyesen soroz.
- A kombó állapota a képernyőn is látható legyen (pl. „x3”, „x5!”), hogy a játékos érezze, közel van-e az élet-jutalomhoz.

---

## Nehezítés

A játék idővel egyre nehezebb lesz, két fő tengelyen:

1. **Sebesség növekedése** — a világ egyre gyorsabban „jön”, kevesebb idő marad reagálni.
2. **Akadályok sűrűsödése** — rövidebb szünetek az akadályok között, gyakrabban jön mindkét típus.

A nehezítés folyamatos, nem csak pályaváltáskor ugrik — a játékos fokozatosan érzi, hogy egyre szorosabb a helyzet.

---

## Képernyő elrendezés

A képernyő három vízszintes sávra oszlik:

### Felső harmad — információk

- **Pontszám** — az aktuális futás pontjai; sikeres akadályok elkerülése növeli, a kombó szorzóval.
- **Rekord** — a valaha elért legjobb eredmény.
- **Pálya száma** — hányadik „szakaszon” / hullámon tart a játékos (a nehezítés vizuális mérföldköve).
- **Életek** — három (vagy kevesebb) megmaradt esély; vizuálisan jól látható.
- **Kombó** — aktuális láncolt sikeres akciók száma.

### Középső harmad — sebesség jelzés

- A **sebességet vizuálisan animálja** a program.
- Nem számként kell érteni elsősorban, hanem **látható tempóként**: pl. gyorsuló vonalak, táj elemek, „szél” effekt, pulzáló jelzés — minél gyorsabb a játék, annál intenzívebb a középső sáv.
- A játékos innen érzi, hogy „most már nagyon megy”.

### Alsó harmad — játéktér

- Itt zajlik a tényleges játék.
- Az út, a karakter, az akadályok.
- A karakter fix vízszintes pozícióban marad (kb. 35% balról), a világ mozog jobbról balra.

---

## Játékmenet ciklusa

1. A játék indul — a gördeszkás elindul, lassú tempóval, **3 élettel**.
2. Egyesével érkeznek az akadályok — vagy úti (Fel), vagy fej fölötti (Le), soha egyszerre mindkettő.
3. A játékos a megfelelő billentyűvel reagál.
4. **Sikeres elkerülés** → rövid „fej felénk” reakció + pont + kombó nő.
5. **5-ös kombó** → extra jutalom: **+1 élet** (ha még nem a maximumnál van).
6. A sebesség és a sűrűség fokozatosan nő.
7. **Ütközés** → egy élet elvesztése, kombó nullázódik, rövid bukás, majd folytatás a megmaradt életekkel.
8. **Minden élet elfogyott** → a játék véget ér, megjelenik az eredmény; lehet újra próbálni a rekord megdöntésére.

---

## Hangulat és stílus

- **Vizuális megjelenés:** fekete–fehér (monochrome) — az első verzióban nincs színkezelés; később esetleg háttér- vagy tintaszín módosítható.
- Könnyed, humoros, karikatúra jellegű.
- Nem brutális — macskák, kígyók, kövek inkább vicces vagy kalandos hangulatúak, nem ijesztők.
- Gyors, reflexalapú, „még egy próba” érzésű játék.
- A sikeres mozdulatok kielégítőek legyenek — a fej-felénk pillanat ezt erősíti.

---

## Nyitott játékmeneti kérdések (később pontosítható)

- Pályaváltáskor újratöltődnek-e a 3 élet, vagy egy futásra szólnak az életek?
- Van-e felső határ az életek számának (pl. max. 3, vagy 5-ös kombóval lehet 4 is)?
- A 5-ös kombó pontszám-bónuszt is ad, vagy csak életet?
- Hogyan néz ki a bukás — azonnali megállás vagy rövid animáció után folytatódik?
- Van-e előjelezés az akadályok előtt (pl. felkiáltásjel), vagy csak tiszta reflex?
- A pálya száma automatikusan nő idővel, vagy fix távolságok után?
