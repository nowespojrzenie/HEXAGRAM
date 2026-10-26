#!/usr/bin/env node
/**
 * profil_stylu.js — mierzy WŁASNY styl pisania z N tekstów i pilnuje, czy nowy tekst go trzyma.
 *
 * METODA ODDZIELONA OD ZASOBU: ten plik nie niesie ani jednej liczby, ani frazy konkretnego autora.
 * Profil to osobny plik JSON jednej osoby (`--zmierz` go robi); kod tylko mierzy i porównuje.
 * Pomiar, nie ocena: narzędzie mówi, w czym tekst odbiega od profilu i o ile. Nie mówi, czy tekst jest dobry.
 *
 * Wcześniejsza wersja narzędzia miała profil jednej osoby zaszyty w kodzie; tu metoda i profil są rozdzielone, więc metoda może być publiczna.
 *
 * UŻYCIE:
 *   node profil_stylu.js --zmierz tekst1.md tekst2.md … > profil.json   (N ≥ 10 własnych tekstów)
 *   node profil_stylu.js --lint profil.json nowy.md [kolejny.md]        (`-` zamiast pliku = stdin)
 *   node profil_stylu.js --test                                         (tor +/−: narzędzie musi umieć NIE przejść)
 *
 * KOD WYJŚCIA: 0 = w profilu · 1 = odchylenia · 2 = błąd wejścia (brak pliku, profil zły lub niepełny, brak tekstów).
 * Werdykt czytaj z kodu wyjścia, nie z frazy w raporcie.
 *
 * ZNANE OGRANICZENIA (nazwane, nie zaklejone):
 *  - tryb rozkazujący to lista + heurystyka końcówek, nie morfologia; rozkaz spoza listy i bez końcówki z wzorca umknie;
 *  - progi (`progi()`) to ułamki profilu ustawione tak, by ODTWORZYĆ progi, z którymi narzędzie żyło przed wydzieleniem
 *    profilu z kodu (ciągłość), a nie wynik niezależnej kalibracji; dla innych korpusów są niezmierzone;
 *  - poniżej 20 zdań pomiar rytmu jest niepewny, poniżej 10 tekstów profil jest niepewny (narzędzie to zgłasza).
 */

const fs = require('fs');
const path = require('path');
const { isDeepStrictEqual } = require('util');

// ── GRANICA SŁOWA ODPORNA NA DIAKRYTYKI ──────────────────────────────────
// `\b` w JS opiera się na \w = [A-Za-z0-9_]; polskie ą ć ę ł ń ó ś ź ż do \w nie należą, więc `\bzaś\b` nie dopasuje
// nigdy (granica po `ś` nie istnieje). Dlatego własna granica: litera polska lub łacińska po obu stronach.
const PL = 'a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ';
const gr = (wzor, flagi = 'gi') => new RegExp(`(?<![${PL}])(?:${wzor})(?![${PL}])`, flagi);

// ── METODA: listy ogólnopolskie, nie cudze nawyki ────────────────────────
const CZERWONE = [ // frazy-znaczniki tekstu maszynowego i patos — obecność = odchylenie
  'w dzisiejszych czasach','warto zauważyć','warto pamiętać','kluczowym elementem',
  'podsumowując','reasumując','należy podkreślić','nie da się ukryć','co więcej',
  'w dobie','w erze cyfrowej','game changer','mindset','insight','flow state',
];
const ROZKAZ_LISTA = [ // częste imperatywy prozy osobistej
  'pozwól','poczuj','wyobraź','zamknij','otwórz','spójrz','zatrzymaj','obserwuj','weź',
  'zaczerpnij','odetchnij','odszukaj','zapisz','spróbuj','bądź','wypełnij','zanurz',
  'zaparz','policz','napisz','sięgnij','sprawdź','zrób','daj','idź','przeczytaj','posłuchaj',
  'pamiętaj','zauważ','wybierz','odpuść','puść','zacznij','przestań','usiądź','stań','zobacz',
  'powiedz','zapytaj','poszukaj','wróć','zostaw','przyjrzyj','rozejrzyj','pozostań','przytrzymaj',
  'wdychaj','wydychaj','oddychaj','odłóż','weźcie','pomyśl','przemyśl','wyjdź','uważaj','patrz',
];
// Warstwa druga: forma imperatywna na POCZĄTKU ZDANIA. Końcówki rozkaźnika (-aj/-ij/-yj/-uj/-ń/-rz) kolidują z pospolitymi
// rzeczownikami — stąd lista wykluczeń. To przybliżenie i tor to sprawdza.
const ROZKAZ_WYKLUCZENIA = new Set([
  'kraj','maj','gaj','zwyczaj','kij','klej','olej','ul','rój','wuj','strój','nastrój','pokój',
  'napój','podwój','zdrój','ruj','przypadkiem','raj','skraj','urodzaj','rodzaj','obyczaj',
  'mij','żmij','szyj','tuj','czerwiec','kwiecień','dzień',
]);
const KOSZE = ['1-5', '6-12', '13-20', '21-30', '31+'];
const KLUCZE = ['zdanie_srednia', 'zdanie_mediana', 'zdanie_odch', 'akapit_mediana', 'polpauza_1k', 'myslnik_1k',
  'pogrubienie_1k', 'bowiem_10k', 'poprzez_10k', 'zatem_10k', 'zas_10k', 'siebie_10k', 'hedge_10k'];

function liczRozkaz(flat) {
  const zListy = (flat.match(gr(ROZKAZ_LISTA.join('|'))) || []).length;
  const kandydaci = [...flat.matchAll(/(?:^|[.!?…]\s+)([a-ząćęłńóśźż]+)(?=[\s,!?.])/gi)]
    .map(m => m[1].toLowerCase())
    .filter(w => w.length >= 4 && !ROZKAZ_WYKLUCZENIA.has(w) && !ROZKAZ_LISTA.includes(w) && /(aj|ij|yj|uj|ń|rz|dź|sz)$/.test(w));
  return zListy + kandydaci.length;
}

// ── LICZENIE SUROWE (jeden tekst) — z niego idą i lint, i profil ──────────
function zlicz(raw) {
  const naglowki = [...raw.matchAll(/^#{1,4}\s+(.+)$/gm)].map(m => m[1].trim());
  const pogrub = (raw.match(/\*\*[^*\n]+\*\*/g) || []).length;
  const punkty = (raw.match(/^\s*[-*+]\s+/gm) || []).length;
  // proza: bez nagłówków, bez markup, bez bloków kodu
  const body = raw.replace(/```[\s\S]*?```/g, ' ').replace(/^#{1,4}\s+.*$/gm, ' ')
                  .replace(/^\s*[-*+]\s+/gm, ' ').replace(/\*\*|\*|`|_/g, '');
  const flat = body.replace(/\s+/g, ' ').trim();
  const dl = flat.split(/(?<=[.!?…])\s+/).map(s => s.trim()).filter(s => s.length > 0).map(s => s.split(/\s+/).length);
  const akap = body.split(/\n\s*\n/).map(a => a.replace(/\s+/g, ' ').trim()).filter(a => a.length > 0).map(a => a.split(/\s+/).length);
  const licz = (re) => (flat.match(re) || []).length;
  return {
    znaki: flat.length, slowa: (flat.match(/[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ]+/g) || []).length, dl, akap,
    pol: licz(/–/g), myslnik: licz(/—/g), pogrub, punkty, naglowki,
    bowiem: licz(gr('bowiem')), poprzez: licz(gr('poprzez')), zatem: licz(gr('zatem')), zas: licz(gr('zaś')),
    siebie: licz(gr('siebie|sobą')),
    hedge: licz(gr('być może|chyba|wydaje mi się|moim zdaniem|sądzę|prawdopodobnie')),
    rozkaz: liczRozkaz(flat),
    ty: licz(gr('Ty|Tobie|Ciebie|Cię|Twój|Twoja|Twoje|Twoim|Twojej|Wam|Was', 'g')),
    my: licz(gr('możemy|jesteśmy|nasze|naszych|naszą|naszego|naszej|nasz|nam|nas')),
    ja: licz(gr(`[${PL}]+łem|mi|mnie|mogę|mój|moja|moje|moim|mojej`)),
    emoji: (raw.match(/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/gu) || []).length,
    czerwone: CZERWONE.filter(f => flat.toLowerCase().includes(f)),
  };
}

const sr = a => a.length ? a.reduce((x, y) => x + y, 0) / a.length : 0;
const med = a => { if (!a.length) return 0; const s = [...a].sort((x, y) => x - y); const m = s.length >> 1; return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2; };
const odch = a => { if (!a.length) return 0; const m = sr(a); return Math.sqrt(sr(a.map(x => (x - m) ** 2))); };
const zaokr = (x, n) => Math.round(x * 10 ** n) / 10 ** n;
const koszyk = w => (w <= 5 ? '1-5' : w <= 12 ? '6-12' : w <= 20 ? '13-20' : w <= 30 ? '21-30' : '31+');
function rozklad(dl) {
  const k = Object.fromEntries(KOSZE.map(b => [b, 0]));
  dl.forEach(w => k[koszyk(w)]++);
  return Object.fromEntries(KOSZE.map(b => [b, dl.length ? 100 * k[b] / dl.length : 0]));
}

// Tekst → miary do porównania z profilem (M = profil; potrzebny tylko do progu długości nagłówka).
function mierz(z, M) {
  return { ...z, zdan: z.dl.length, zd_sr: sr(z.dl), zd_med: med(z.dl), zd_odch: odch(z.dl), rozklad: rozklad(z.dl),
    ak_med: med(z.akap), ak_n: z.akap.length, polpauza: z.pol, pogrubienia: z.pogrub,
    nag_dlugie: M && M.naglowek_slow_max !== null ? z.naglowki.filter(h => h.split(/\s+/).length > M.naglowek_slow_max) : [] };
}

// ── ZASÓB: korpus → profil ────────────────────────────────────────────────
function scal(zs) {
  const s = { znaki: 0, slowa: 0, dl: [], akap: [], pol: 0, myslnik: 0, pogrub: 0, bowiem: 0, poprzez: 0, zatem: 0, zas: 0, siebie: 0, hedge: 0, naglowki: [] };
  for (const z of zs) {
    for (const k of ['znaki', 'slowa', 'pol', 'myslnik', 'pogrub', 'bowiem', 'poprzez', 'zatem', 'zas', 'siebie', 'hedge']) s[k] += z[k];
    s.dl.push(...z.dl); s.akap.push(...z.akap); s.naglowki.push(...z.naglowki);
  }
  return s;
}
function profilZ(zs) {
  const s = scal(zs), k = s.znaki / 1000, w = s.slowa / 10000;
  const nag = s.naglowki.map(h => h.split(/\s+/).length).sort((a, b) => a - b);   // 90. percentyl (nearest-rank): jeden długi nagłówek nie rozciąga normy
  return {
    wersja: 1,
    korpus: { tekstow: zs.length, znakow: s.znaki, slow: s.slowa, zdan: s.dl.length, akapitow: s.akap.length },
    miary: {
      zdanie_srednia: zaokr(sr(s.dl), 1), zdanie_mediana: med(s.dl), zdanie_odch: zaokr(odch(s.dl), 1),
      rozklad: Object.fromEntries(Object.entries(rozklad(s.dl)).map(([b, v]) => [b, zaokr(v, 1)])),
      akapit_mediana: med(s.akap),
      polpauza_1k: zaokr(s.pol / k, 2), myslnik_1k: zaokr(s.myslnik / k, 2), pogrubienie_1k: zaokr(s.pogrub / k, 2),
      bowiem_10k: zaokr(s.bowiem / w, 1), poprzez_10k: zaokr(s.poprzez / w, 1), zatem_10k: zaokr(s.zatem / w, 1), zas_10k: zaokr(s.zas / w, 1),
      siebie_10k: zaokr(s.siebie / w, 1),
      naglowek_slow_max: nag.length ? nag[Math.ceil(0.9 * nag.length) - 1] : null,   // null = korpus bez nagłówków → reguła nagłówków wyłączona
      hedge_10k: zaokr(s.hedge / w, 1),
    },
  };
}

// Brak = zwrócona lista nazw (pusta = profil pełny). Profil niepełny to rc=2, nie ciche „0 odchyleń”.
function brakiProfilu(p) {
  const M = p && p.miary;
  if (!M || typeof M !== 'object') return ['miary'];
  const b = KLUCZE.filter(k => !Number.isFinite(M[k]));
  if (!M.rozklad || typeof M.rozklad !== 'object') b.push('rozklad');
  else KOSZE.forEach(k => { if (!Number.isFinite(M.rozklad[k])) b.push(`rozklad.${k}`); });
  if (!('naglowek_slow_max' in M) || !(M.naglowek_slow_max === null || Number.isFinite(M.naglowek_slow_max))) b.push('naglowek_slow_max');
  return b;
}

// Progi = ułamki profilu (zaokrąglone). Mnożniki dobrane tak, by profil, z którym narzędzie powstało, dawał te same progi
// co przed wydzieleniem profilu z kodu (ciągłość) — to ustawienie metody, nie pomiar.
function progi(M) {
  const spoj = M.bowiem_10k + M.poprzez_10k + M.zatem_10k + M.zas_10k;
  return { zd_tol: 4, med_tol: 4, ak_tol: 18,
    odch_min: zaokr(M.zdanie_odch * 0.72, 0), krotkie_min: zaokr(M.rozklad['1-5'] * 0.57, 0), pogrub_max: zaokr(M.pogrubienie_1k * 3.5, 1),
    spoj_min: zaokr(spoj * 0.44, 0), siebie_min: zaokr(M.siebie_10k * 0.33, 0), hedge_max: zaokr(M.hedge_10k * 3, 0), spoj_profil: spoj };
}
// Kreski: reguła tylko tam, gdzie profil ma kreskę dominującą (3:1); profil mieszany nie ma czego pilnować.
function kreskiOk(m, M) {
  if (M.polpauza_1k > M.myslnik_1k * 3) return m.myslnik === 0 || m.polpauza > m.myslnik * 3;
  if (M.myslnik_1k > M.polpauza_1k * 3) return m.polpauza === 0 || m.myslnik > m.polpauza * 3;
  return true;
}

// ── RAPORT --lint ─────────────────────────────────────────────────────────
function raport(m, nazwa, M) {
  const pr = progi(M), k = m.znaki / 1000, w = m.slowa / 10000;
  let uwag = 0;
  const L = [];
  const zn = (ok) => { if (!ok) uwag++; return ok ? '\x1b[32m✓\x1b[0m' : '\x1b[33m▲\x1b[0m'; };
  const p = (x) => String(x).padStart(5);

  L.push(`\n\x1b[1m═══ ${nazwa} ═══\x1b[0m`);
  L.push(`  ${m.znaki} znaków · ${m.slowa} słów · ${m.zdan} zdań · ${m.ak_n} akapitów`);
  if (m.zdan < 20) L.push('  \x1b[2m(próbka mała — poniżej 20 zdań pomiar rytmu jest niepewny)\x1b[0m');

  L.push('\n  \x1b[1mRYTM\x1b[0m                        tekst   ·  profil');
  L.push(`  ${zn(Math.abs(m.zd_sr - M.zdanie_srednia) <= pr.zd_tol)} średnia długość zdania    ${p(m.zd_sr.toFixed(1))}   ·  ${M.zdanie_srednia}`);
  L.push(`  ${zn(Math.abs(m.zd_med - M.zdanie_mediana) <= pr.med_tol)} mediana                   ${p(m.zd_med)}   ·  ${M.zdanie_mediana}`);
  L.push(`  ${zn(m.zd_odch >= pr.odch_min)} rozrzut (odch. std)       ${p(m.zd_odch.toFixed(1))}   ·  ${M.zdanie_odch}  \x1b[2m← niski = tekst monotonny\x1b[0m`);
  L.push(`  ${zn(m.rozklad['1-5'] >= pr.krotkie_min)} zdań krótkich (≤5 sł)     ${String(m.rozklad['1-5'].toFixed(0)).padStart(4)}%   ·  ${M.rozklad['1-5']}%  \x1b[2m← uderzenia po fali\x1b[0m`);
  L.push(`  ${zn(Math.abs(m.ak_med - M.akapit_mediana) <= pr.ak_tol)} mediana słów w akapicie   ${p(m.ak_med)}   ·  ${M.akapit_mediana}`);

  L.push('\n  \x1b[1mTYPOGRAFIA\x1b[0m');
  L.push(`  ${zn(kreskiOk(m, M))} półpauza – : myślnik —     ${m.polpauza} : ${m.myslnik}   ·  profil ${M.polpauza_1k} : ${M.myslnik_1k} na 1000 zn`);
  L.push(`  ${zn(m.pogrubienia / k <= pr.pogrub_max)} pogrubień na 1000 zn      ${p((m.pogrubienia / k).toFixed(2))}   ·  ${M.pogrubienie_1k}`);
  L.push(`  ${zn(m.punkty === 0)} punktów listy             ${p(m.punkty)}   ·  ~0  \x1b[2m← w prozie osobistej proza, nie punkty\x1b[0m`);
  if (M.naglowek_slow_max !== null) {
    L.push(`  ${zn(m.nag_dlugie.length === 0)} nagłówków dłuższych niż ${M.naglowek_slow_max} sł.: ${m.nag_dlugie.length}`);
    m.nag_dlugie.slice(0, 6).forEach(h => L.push(`       \x1b[2m→ „${h}"\x1b[0m`));
  }
  L.push(`  ${zn(m.emoji === 0)} emoji                     ${p(m.emoji)}   ·  0`);

  L.push('\n  \x1b[1mLEKSYKA\x1b[0m  (na 10 tys. słów)');
  const sumaSpoj = m.bowiem + m.poprzez + m.zatem + m.zas;
  L.push(`  ${zn(w > 0 && sumaSpoj / w >= pr.spoj_min)} spójniki książkowe łącznie ${p((w ? sumaSpoj / w : 0).toFixed(1))}   ·  ${zaokr(pr.spoj_profil, 1)}`);
  [['bowiem', m.bowiem, M.bowiem_10k], ['poprzez', m.poprzez, M.poprzez_10k], ['zatem', m.zatem, M.zatem_10k], ['zaś', m.zas, M.zas_10k]]
    .forEach(([n, c, pv]) => L.push(`      ${n.padEnd(9)} ${String(c).padStart(3)} → ${(w ? c / w : 0).toFixed(1).padStart(5)}/10k · ${pv}`));
  L.push(`  ${zn(w > 0 && m.siebie / w >= pr.siebie_min)} siebie / sobą             ${p((w ? m.siebie / w : 0).toFixed(1))}   ·  ${M.siebie_10k}`);
  L.push(`  ${zn(w === 0 || m.hedge / w <= pr.hedge_max)} asekuracja (być może…)    ${p((w ? m.hedge / w : 0).toFixed(1))}   ·  ${M.hedge_10k}  \x1b[2m← wysokie = miękczysz\x1b[0m`);

  L.push('\n  \x1b[1mOSOBA\x1b[0m  (trzy takty: MY → JA → TY)');
  L.push(`  ${zn(m.my > 0)} MY włączające             ${p(m.my)}`);
  L.push(`  ${zn(m.ja > 0)} JA (świadectwo własne)    ${p(m.ja)}`);
  L.push(`  ${zn(m.ty + m.rozkaz > 0)} TY (zwrot + tryb rozkaz.) ${p(m.ty + m.rozkaz)}`);

  if (m.czerwone.length) {
    uwag += m.czerwone.length;
    L.push(`\n  \x1b[31m✗ FRAZY ZAKAZANE (${m.czerwone.length}):\x1b[0m ${m.czerwone.map(f => `„${f}"`).join(' · ')}`);
  } else L.push('\n  \x1b[32m✓\x1b[0m brak fraz zakazanych');

  L.push(`\n  \x1b[1mODCHYLEŃ OD PROFILU: ${uwag}\x1b[0m`);
  L.push('  \x1b[2m▲ = odchylenie, nie błąd. Rejestr rzeczowy (liczby, normy, źródła) odchyla się zasadnie.\x1b[0m');
  L.push('  \x1b[2m  Rozstrzyga autor — narzędzie tylko pokazuje, gdzie i o ile.\x1b[0m');
  console.log(L.join('\n'));
  return uwag;
}

// ── WEJŚCIE / WYJŚCIE ─────────────────────────────────────────────────────
function blad(msg) { console.error(`[!] ${msg}`); process.exit(2); }
function czytaj(p) {
  if (p === '-') return fs.readFileSync(0, 'utf8');
  if (!fs.existsSync(p)) blad(`nie ma pliku: ${p}`);
  return fs.readFileSync(p, 'utf8');
}
function czytajProfil(p) {
  let prof;
  try { prof = JSON.parse(czytaj(p)); } catch (e) { blad(`profil nieczytelny (${p}): ${e.message}`); }
  const b = brakiProfilu(prof);
  if (b.length) blad(`profil niepełny (${p}), brak lub nie-liczba: ${b.join(', ')}`);
  return prof;
}

function zmierzTryb(pliki) {
  if (!pliki.length) blad('--zmierz: podaj pliki z własnymi tekstami (zalecane N ≥ 10)');
  const zs = pliki.map(f => zlicz(czytaj(f)));
  const prof = profilZ(zs);
  if (!prof.korpus.slow) blad('--zmierz: korpus bez słów — nie ma czego mierzyć');
  if (pliki.length < 10) console.error(`[!] N=${pliki.length} < 10 tekstów — profil niepewny (zalecane N ≥ 10, najlepiej kilkadziesiąt)`);
  console.log(JSON.stringify(prof, null, 2));
  return 0;
}
function lintTryb(profPlik, teksty) {
  if (!profPlik || !teksty.length) blad('--lint: podaj profil.json i co najmniej jeden tekst');
  const prof = czytajProfil(profPlik);
  let suma = 0;
  teksty.forEach(t => { suma += raport(mierz(zlicz(czytaj(t)), prof.miary), t, prof.miary); });
  console.log('');
  return suma > 0 ? 1 : 0;
}

// ── TOR (--test): narzędzie musi umieć NIE PRZEJŚĆ ────────────────────────
// Profil toru jest SYNTETYCZNY (ustawiony ręką w torze) — ani kod, ani tor nie niosą liczb żadnego autora.
const PT = { zdanie_srednia: 10, zdanie_mediana: 9, zdanie_odch: 6, rozklad: { '1-5': 20, '6-12': 50, '13-20': 20, '21-30': 8, '31+': 2 },
  akapit_mediana: 20, polpauza_1k: 2, myslnik_1k: 0.1, pogrubienie_1k: 0.4, bowiem_10k: 10, poprzez_10k: 10, zatem_10k: 10, zas_10k: 10,
  siebie_10k: 40, naglowek_slow_max: 2, hedge_10k: 4 };
const PM = { polpauza_1k: 0.1, myslnik_1k: 2 };   // profil z dominującym myślnikiem (tylko pola kresek)
const TOR = [ // [nazwa, tekst, ocena(m)]
  ['+ imperatyw Z LISTY liczy się', 'Weź głęboki oddech. Pozwól sobie na chwilę ciszy.', m => m.rozkaz >= 2],
  ['+ imperatyw SPOZA listy też', 'Zaparz herbatę i odstaw ją. Policz do trzystu. Napisz mi potem.', m => m.rozkaz >= 3],
  ['− rzeczownik na -aj NIE jest rozkazem', 'Kraj się zmienia. Zwyczaj pozostał. Maj był ciepły.', m => m.rozkaz === 0],
  ['− tekst bez zwrotu do czytelnika daje TY=0', 'Rzecz opisano rzeczowo. Wynik zapisano w tabeli. Dane pochodzą z pomiaru.', m => (m.ty + m.rozkaz) === 0],
  ['+ półpauza dominująca przechodzi', 'Rzecz jest prosta – i tak zostaje. Druga rzecz – również.', m => m.myslnik === 0 && m.polpauza === 2 && kreskiOk(m, PT)],
  ['− myślnik zamiast półpauzy jest łapany', 'Rzecz jest prosta — i tak zostaje. Druga — również. Trzecia — też.', m => m.myslnik === 3 && !kreskiOk(m, PT)],
  ['+ profil z myślnikiem dominującym: myślniki przechodzą', 'Rzecz jest prosta — i tak zostaje. Druga — również. Trzecia — też.', m => kreskiOk(m, PM)],
  ['− profil z myślnikiem dominującym: półpauzy są łapane', 'Rzecz jest prosta – i tak zostaje. Druga – również. Trzecia – też.', m => !kreskiOk(m, PM)],
  ['− fraza zakazana jest łapana', 'W dzisiejszych czasach warto zauważyć jedno.', m => m.czerwone.length === 2],
  ['+ czysty tekst nie daje fałszywej frazy zakazanej', 'Rzecz jest prosta i tak zostaje.', m => m.czerwone.length === 0],
  ['− emoji jest łapane', 'Tekst z emoji 🙂 w środku.', m => m.emoji === 1],
  ['− punkt listy jest łapany', 'Wstęp.\n\n- pierwszy\n- drugi', m => m.punkty === 2],
  ['− nagłówek dłuższy niż próg profilu jest łapany', '## Trzy słowa w nagłówku\n\nTreść.', m => m.nag_dlugie.length === 1],
  ['+ nagłówek w progu profilu przechodzi', '## Granice\n\nTreść.\n\n## W terapii\n\nTreść.', m => m.nag_dlugie.length === 0],
  ['+ spójniki książkowe są liczone', 'Rzecz jest prosta, bowiem tak wyszło. Zatem poprzez to, zaś dalej inaczej.', m => m.bowiem === 1 && m.zatem === 1 && m.poprzez === 1 && m.zas === 1],
  ['+ oś siebie/sobą jest liczona', 'Poznać siebie. Być sobą. Wrócić do siebie.', m => m.siebie === 3],
  ['− nagłówek NIE wchodzi do prozy (rytm)', '## Bardzo długi nagłówek liczący wiele słów\n\nKrótko.', m => m.zdan === 1],
  ['− pusty tekst nie liczy zdań', '', m => m.zdan === 0],
];

// Fikstura --zmierz: trzy teksty, liczby policzone RĘCZNIE (nie wyprowadzone z kodu). Zdania: 2,6,4 | 6,5 | 1,10 (suma 34, n=7);
// akapity 8,4 | 6,5 | 1,10; słowa 11+10+11=32; znaki po spłaszczeniu 73+58+69=200; półpauza 1, myślnik 1, pogrubienie 1 (zaś);
// bowiem 1, poprzez 1, zatem 1, zaś 1, siebie 2, asekuracja 2 („chyba”, „moim zdaniem”); jeden nagłówek jednowyrazowy.
const FIKSTURA = ['Weź oddech. Poznaj siebie – bowiem tak trzeba.\n\nZatem możemy zacząć razem.\n',
  '## Granice\n\nTo chyba prawda, **zaś** nie tylko.\n\nPoprzez ciszę — do siebie.\n',
  'Krótko.\n\nMoim zdaniem wszystko jest jasne i pewne dziś rano wieczorem.\n'];
const FIKSTURA_MIARY = { zdanie_srednia: 4.9, zdanie_mediana: 5, zdanie_odch: 2.7, rozklad: { '1-5': 57.1, '6-12': 42.9, '13-20': 0, '21-30': 0, '31+': 0 },
  akapit_mediana: 5.5, polpauza_1k: 5, myslnik_1k: 5, pogrubienie_1k: 5, bowiem_10k: 312.5, poprzez_10k: 312.5, zatem_10k: 312.5, zas_10k: 312.5,
  siebie_10k: 625, naglowek_slow_max: 1, hedge_10k: 625 };
// Tekst z MY, JA i TY, bez nagłówków i list: własny profil musi go przepuścić (+), cudzy, rozciągnięty, nie (−).
const WLASNY = 'Weź oddech. Możemy zacząć razem, bo mnie to cieszy. Poznaj siebie – bowiem tak trzeba. Zatem poprzez ciszę wracamy do siebie, zaś hałas odpuszczamy.\n\nMówię to spokojnie. Spróbuj.\n';
const DLUGI = 'To jest bardzo długie zdanie które toczy się dalej i dalej bez żadnego oddechu i bez żadnego skrótu, ponieważ jego autor lubi dopisywać kolejne człony, kolejne wtrącenia i kolejne dopowiedzenia, aż czytelnik zapomni, od czego zaczął, a mimo to zdanie wciąż trwa i trwa w tym samym równym tempie.\n';

function tor() {
  console.log('\n╔═══ PROFIL STYLU — TOR WALIDACYJNY ═══╗');
  const { spawnSync } = require('child_process');
  const tmp = fs.mkdtempSync(path.join(require('os').tmpdir(), 'profil_stylu_'));
  const zapisz = (nazwa, tresc) => { const f = path.join(tmp, nazwa); fs.writeFileSync(f, tresc); return f; };
  const uruchom = (...a) => spawnSync(process.execPath, [__filename, ...a], { encoding: 'utf8' });
  let zdanych = 0; const zle = [];
  const spr = (nazwa, ok, szczegol = '') => {
    if (ok) { zdanych++; console.log(`  \x1b[32m✓\x1b[0m ${nazwa}`); } else { zle.push(nazwa); console.log(`  \x1b[31m✗\x1b[0m ${nazwa}${szczegol ? ` [${szczegol}]` : ''}`); }
  };
  for (const [nazwa, tekst, ocena] of TOR) {
    let ok = false, err = '';
    try { ok = !!ocena(mierz(zlicz(tekst), PT)); } catch (e) { err = e.message; }
    spr(nazwa, ok, err);
  }
  // progi: ułamki profilu liczą się tak, jak opisano (przypadek bez remisów przy zaokrągleniu)
  const pr = progi(PT);
  spr('progi: ułamki profilu (4 · 11 · 1,4 · 18 · 13 · 12)',
    pr.odch_min === 4 && pr.krotkie_min === 11 && pr.pogrub_max === 1.4 && pr.spoj_min === 18 && pr.siebie_min === 13 && pr.hedge_max === 12, JSON.stringify(pr));
  // --zmierz na fiksturze: liczby policzone ręcznie (komentarz nad FIKSTURA)
  const pliki = FIKSTURA.map((t, i) => zapisz(`f${i}.md`, t));
  const zm = uruchom('--zmierz', ...pliki);
  let prof = null; try { prof = JSON.parse(zm.stdout); } catch (e) { /* ocena niżej */ }
  spr('--zmierz: rc=0 i JSON', zm.status === 0 && prof !== null, `rc=${zm.status}`);
  spr('--zmierz: miary z fikstury zgodne z liczonymi ręcznie', prof !== null && isDeepStrictEqual(prof.miary, FIKSTURA_MIARY), prof ? JSON.stringify(prof.miary) : '');
  spr('--zmierz: korpus 3 teksty · 200 znaków · 32 słowa · 7 zdań · 6 akapitów',
    prof !== null && isDeepStrictEqual(prof.korpus, { tekstow: 3, znakow: 200, slow: 32, zdan: 7, akapitow: 6 }));
  spr('--zmierz: N < 10 ostrzega na stderr (profil niepewny)', /niepewny/.test(zm.stderr));
  spr('− --zmierz bez plików → rc=2', uruchom('--zmierz').status === 2);
  spr('− --zmierz z nieistniejącym plikiem → rc=2', uruchom('--zmierz', path.join(tmp, 'nie_ma.md')).status === 2);
  spr('− --zmierz na korpusie bez słów → rc=2', uruchom('--zmierz', zapisz('pusty.md', '\n')).status === 2);
  // --lint: rc 0/1/2
  const wlasny = zapisz('wlasny.md', WLASNY);
  const profWl = zapisz('wlasny.json', uruchom('--zmierz', wlasny).stdout);
  spr('+ --lint: tekst z własnym profilem → rc=0', uruchom('--lint', profWl, wlasny).status === 0);
  const profDl = zapisz('dlugi.json', uruchom('--zmierz', zapisz('dlugi.md', DLUGI)).stdout);
  spr('− --lint: ten sam tekst wobec cudzego (rozciągniętego) profilu → rc=1', uruchom('--lint', profDl, wlasny).status === 1);
  spr('− --lint: fraza zakazana → rc=1', uruchom('--lint', profWl, zapisz('czerw.md', WLASNY + '\nW dzisiejszych czasach to ważne.\n')).status === 1);
  spr('− --lint: brak pliku profilu → rc=2', uruchom('--lint', path.join(tmp, 'brak.json'), wlasny).status === 2);
  spr('− --lint: profil nie jest JSON → rc=2', uruchom('--lint', zapisz('smiec.json', 'to nie json'), wlasny).status === 2);
  const niepelny = JSON.parse(fs.readFileSync(profWl, 'utf8')); delete niepelny.miary.siebie_10k;
  const rNiep = uruchom('--lint', zapisz('niepelny.json', JSON.stringify(niepelny)), wlasny);
  spr('− --lint: profil bez jednej miary → rc=2 i nazwa braku w komunikacie', rNiep.status === 2 && /siebie_10k/.test(rNiep.stderr));
  spr('− --lint: brak pliku tekstu → rc=2', uruchom('--lint', profWl, path.join(tmp, 'nie_ma.md')).status === 2);
  spr('− --lint: bez tekstów → rc=2', uruchom('--lint', profWl).status === 2);
  spr('− nieznany tryb → rc=2', uruchom('--nieznany').status === 2);
  fs.rmSync(tmp, { recursive: true, force: true });

  console.log(`\n  zmierzone: zdanych ${zdanych} · oblanych ${zle.length} · przypadków ${zdanych + zle.length}`);
  if (!zle.length) { console.log('  \x1b[32m✓ NARZĘDZIE ŻYWE\x1b[0m — łapie odchylenia, nie łapie tekstu własnego i odmawia na wadliwym wejściu.'); return 0; }
  console.log(`  \x1b[31m✗ NARZĘDZIE MARTWE\x1b[0m — oblane: ${zle.join(' · ')}`);
  return 1;
}

const [tryb, ...reszta] = process.argv.slice(2);
if (tryb === '--test') process.exit(tor());
if (tryb === '--zmierz') process.exit(zmierzTryb(reszta));
if (tryb === '--lint') process.exit(lintTryb(reszta[0], reszta.slice(1)));
console.error('użycie: profil_stylu.js --zmierz <teksty…> > profil.json  |  --lint <profil.json> <tekst…>  |  --test');
process.exit(2);
