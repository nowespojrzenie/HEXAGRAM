# zamek_pid.sh — JEDNA funkcja czytania plików-zamków `PID:czas[:…]` (źródłują ją mutacje.sh i zapis_git.sh; zlecenie 22 · Z1, 29.10.2026).
# Pierwotnie dwie kopie tego samego kodu (#112: zamek biegu mutacyjnego w mutacje.sh i w zapis_git.sh); zamek drzewa zapisu (rc=11) byłby trzecią (#49).
# Użycie:  zp_rc=0; zamek_pid_czytaj <plik> || zp_rc=$?      (pod `set -e` zawsze z `|| …`)
#   0 = brak pliku (zamek wolny) · 1 = ŻYWY (PID realnie działa) · 2 = OSIEROCONY (PID martwy albo nieczytelny)
# Ustawia: ZP_PID (cyfry albo pusty) · ZP_CZAS (wszystko po pierwszym ':') · ZP_CZAS_START (pole 2) · ZP_SESJA (pole 3, jeśli jest).
zamek_pid_czytaj() {
  ZP_PID=""; ZP_CZAS=""; ZP_CZAS_START=""; ZP_SESJA=""
  [ -f "$1" ] || return 0
  ZP_PID="$(cut -d: -f1 "$1" 2>/dev/null)"
  ZP_CZAS="$(cut -d: -f2- "$1" 2>/dev/null)"
  ZP_CZAS_START="$(cut -d: -f2 "$1" 2>/dev/null)"
  ZP_SESJA="$(cut -d: -f3 "$1" 2>/dev/null)"
  case "$ZP_PID" in ''|*[!0-9]*) ZP_PID="" ;; esac
  if [ -n "$ZP_PID" ] && kill -0 "$ZP_PID" 2>/dev/null; then return 1; fi
  return 2
}
