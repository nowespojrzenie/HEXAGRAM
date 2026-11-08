#!/usr/bin/env node
// Wejście npm (hexagram-kronos): `npx -y hexagram-kronos kronos-lens now` albo bin kronos-lens|kronos-natal|kronos-pelnia|plan-okien.
// Silniki nie mają shebangu i nie są ruszane — ten plik tylko wybiera silnik i przekazuje argumenty i kod wyjścia.
const { spawnSync } = require('child_process');
const path = require('path');
const SILNIKI = { 'kronos-lens': 'kronos_lens.js', 'kronos-natal': 'kronos_natal.js', 'kronos-pelnia': 'kronos_pelnia.js', 'plan-okien': 'plan_okien.js' };
let args = process.argv.slice(2);
let nazwa = path.basename(process.argv[1] || '').replace(/\.js$/, '');
if (!SILNIKI[nazwa]) nazwa = args.shift();
if (!SILNIKI[nazwa]) {
  console.error('użycie: hexagram-kronos <' + Object.keys(SILNIKI).join('|') + '> [argumenty silnika]');
  process.exit(2);
}
const r = spawnSync(process.execPath, [path.join(__dirname, SILNIKI[nazwa]), ...args], { stdio: 'inherit' });
process.exit(r.status === null ? 1 : r.status);
