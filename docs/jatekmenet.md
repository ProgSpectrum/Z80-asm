# Gördeszkás játék — játékmenet leírás

## Alapötlet

Egy gördeszkás karakter folyamatosan halad előre egy úton. Az úton és a feje fölött akadályok jelennek meg, amelyeket időben el kell kerülnie. A játék egyre gyorsul, az akadályok egyre sűrűbben érkeznek. A cél a minél hosszabb túlélés és a minél magasabb pontszám elérése.

---

## A karakter

- Gördeszkás fiú vagy lány — oldalnézetből látjuk.
- A képernyő bal oldalától számított **35%-nál** áll; **jobbra néz**, mintha előre gördülne.
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

**Ugrás:** egyetlen gombbal aktiválható. A karakter a levegőbe emelkedik, átrepül az akadályon, majd visszaér a gördeszkára.

---

## Akadályok — le kell hajolni

Ezek a karakter feje magassága körül, előlről vagy felülről érkeznek. Ha nem hajol le időben, ütközés történik.

| Típus | Leírás |
|-------|--------|
| **Faágak** | Lebegő vagy lengő ágak, mintha egy fa alá gördülne be. |
| **Madarak** | Madarak repülnek át a magasságában. |
| **Egyéb repülő tárgyak** | Pl. papírrepülő, frisbee, leeső tárgy — a pálya változatosságát növelik. |

**Lehajlás:** a karakter lekuporodik / előrehajol a gördeszkán, a feje lejjebb kerül, és átengedi a repülő akadályt.

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

- **Pontszám** — az aktuális futás pontjai; sikeres akadályok elkerülése növeli.
- **Rekord** — a valaha elért legjobb eredmény.
- **Pálya száma** — hányadik „szakaszon” / hullámon tart a játékos (a nehezítés vizuális mérföldköve).

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

1. A játék indul — a gördeszkás elindul, lassú tempóval.
2. Akadályok érkeznek az úton és a feje fölött.
3. A játékos ugrál vagy lehajol, ahogy kell.
4. Sikeres elkerülés → rövid „fej felénk” reakció + pont.
5. A sebesség és a sűrűség fokozatosan nő.
6. Ütközés → a futás véget ér.
7. Megjelenik az eredmény; lehet újra próbálni a rekord megdöntésére.

---

## Hangulat és stílus

- Könnyed, humoros, karikatúra jellegű.
- Nem brutális — macskák, kígyók, kövek inkább vicces vagy kalandos hangulatúak, nem ijesztők.
- Gyors, reflexalapú, „még egy próba” érzésű játék.
- A sikeres mozdulatok kielégítőek legyenek — a fej-felénk pillanat ezt erősíti.

---

## Nyitott játékmeneti kérdések (később pontosítható)

- Van-e combo / láncolt sikeres akció bónusz?
- Lehet-e kétféle akadály egyszerre (pl. kő alatt ág)?
- Hogyan néz ki a „game over” — azonnali megállás vagy bukás animáció?
- Van-e készülődési idő az akadályok előtt (pl. felkiáltásjel), vagy csak tiszta reflex?
- A pálya száma automatikusan nő idővel, vagy fix távolságok után?
