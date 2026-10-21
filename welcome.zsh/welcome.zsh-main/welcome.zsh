#!/usr/bin/env zsh

# ══════════════════════════════════════════════════════════════════════
#   Ubuntu WSL  ·  Professional Welcome Screen
# ══════════════════════════════════════════════════════════════════════

[[ $- != *i* ]] && return
# Show only once per WSL/user session, even when new terminals are opened.
# To show it again manually: rm -f "${WELCOME_ONCE_FILE}"
# WELCOME_ONCE_FILE="${XDG_RUNTIME_DIR:-/tmp}/zsh-welcome-shown-${USER}"

# [[ -e "$WELCOME_ONCE_FILE" ]] && return
# : >| "$WELCOME_ONCE_FILE"

export WELCOME_SHOWN=1

clear

# —— Color Palette —————————————————————————————————————————————————————
_e=$'\033'
R="${_e}[0m"; B="${_e}[1m"; D="${_e}[2m"
AMBER="${_e}[38;5;214m"
SKY="${_e}[38;5;75m"
SAGE="${_e}[38;5;114m"
GOLD="${_e}[38;5;221m"
STEEL="${_e}[38;5;111m"
WHT="${_e}[97m"
GRY="${_e}[38;5;250m"
FRM="${_e}[38;5;260m"
MINT="${_e}[38;5;121m"

# —— Configuration —————————————————————————————————————————————————————
PROJECTS_DIR="$HOME/projects"
WORKSPACES_DIR="$HOME/projects/.workspaces"
IW=88   # inner box width (terminal should be ≥ 90 columns)

# —— System Information ————————————————————————————————————————————————
_user="${USER:-$(whoami)}"
_host="$(hostname 2>/dev/null)"
_os="$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"')"
_kern="$(uname -r)"
_shell="$(basename "$SHELL")"
_date_str="$(date '+%A, %d %B %Y')"
_time_str="$(date '+%H:%M:%S')"
_uptime_raw="$(uptime -p 2>/dev/null | sed 's/up //')"
_uptime="$(printf '%s' "$_uptime_raw" | sed 's/ hours\?/h/g; s/ minutes\?/m/g; s/ seconds\?/s/g')"
_cwd="$(pwd | sed "s|^$HOME|~|")"
_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
_memu="$(free -h 2>/dev/null | awk '/Mem:/{print $3}')"
_memt="$(free -h 2>/dev/null | awk '/Mem:/{print $2}')"
_disk="$(df -h / 2>/dev/null | awk 'NR==2{print $3"/"$2" "$5}')"
_load="$(awk '{printf "%s  %s  %s",$1,$2,$3}' /proc/loadavg 2>/dev/null)"
_mode="$(grep -qi microsoft /proc/version 2>/dev/null && echo 'WSL2' || echo 'Linux')"
_git=""
command -v git >/dev/null 2>&1 && _git="$(git branch --show-current 2>/dev/null)"

[[ -z "$_os" ]]     && _os="Ubuntu"
[[ -z "$_uptime" ]] && _uptime="N/A"
[[ -z "$_ip" ]]     && _ip="N/A"
[[ -z "$_memu" ]]   && _memu="N/A"
[[ -z "$_memt" ]]   && _memt="N/A"
[[ -z "$_disk" ]]   && _disk="N/A"
[[ -z "$_load" ]]   && _load="N/A"

_hour="$(date '+%H')"
if   (( _hour >= 5  && _hour < 12 )); then _greet="Good morning"
elif (( _hour >= 12 && _hour < 18 )); then _greet="Good afternoon"
else                                        _greet="Good evening"
fi

_weather="—"
if command -v curl >/dev/null 2>&1; then
  _w="$(curl -fsS --max-time 2 'https://wttr.in/?format=%c+%t,+%C' 2>/dev/null)"
  [[ -n "$_w" ]] && _weather="$_w"
fi

# —— Helper Functions ——————————————————————————————————————————————————
_ROW=1
_CLOCK_ROW=0
_CLOCK_COL=0


# Repeat a Unicode character safely. Do not use `tr` with Unicode: it is byte-oriented
# and can produce replacement characters like ���� in some terminals/locales.
_fill() {
  local n="$1" ch="${2:-─}" out
  printf -v out "%${n}s" ""
  out="${out// /$ch}"
  printf "%s" "$out"
}

# Strip ANSI escape sequences
_sa() { printf "%s" "$1" | sed $'s/\033\[[0-9;]*[a-zA-Z]//g'; }

# Visual length (without ANSI codes)
_vl() { local s; s="$(_sa "$1")"; printf "%d" "${#s}"; }

# Print line and track row
_p() { printf "%s\n" "$1"; (( _ROW++ )); }

# Truncate to max length with ellipsis
_trn() { local s="$1" n="${2:-20}"; (( ${#s} > n )) && s="${s:0:$((n-1))}…"; printf "%s" "$s"; }

# —— Box Drawing Functions —————————————————————————————————————————————
# Column widths for 3-column info grid (C1 + C2 + C3 + 2 separators = IW)
_C1=30 _C2=30 _C3=$(( IW - _C1 - _C2 - 2 ))  # = 26

# Full-width box borders
_btop() {
  printf "${FRM}╭%s╮${R}\n" "$(_fill "$IW")"
  (( _ROW++ ))
}

_bmid() {
  printf "${FRM}├%s┤${R}\n" "$(_fill "$IW")"
  (( _ROW++ ))
}

_bbot() {
  printf "${FRM}╰%s╯${R}\n" "$(_fill "$IW")"
  (( _ROW++ ))
}

# Transition from full-width to 3-column layout
_b3mid() {
  printf "${FRM}├%s┬%s┬%s┤${R}\n" \
    "$(_fill "$_C1")" \
    "$(_fill "$_C2")" \
    "$(_fill "$_C3")"
  (( _ROW++ ))
}

# 3-column box bottom
_b3bot() {
  printf "${FRM}╰%s┴%s┴%s╯${R}\n" \
    "$(_fill "$_C1")" \
    "$(_fill "$_C2")" \
    "$(_fill "$_C3")"
  (( _ROW++ ))
}

# Full-width row inside box (auto-padded)
_br() {
  local c="$1" vw pad
  vw=$(_vl "$c"); pad=$(( IW - vw ))
  (( pad < 0 )) && pad=0
  printf "${FRM}│${R}%s%${pad}s${FRM}│${R}\n" "$c" ""
  (( _ROW++ ))
}

# 3-column info row with separators
_ir() {
  local c1="$1" c2="$2" c3="$3" p1 p2 p3
  p1=$(( _C1 - $(_vl "$c1") ))
  p2=$(( _C2 - $(_vl "$c2") ))
  p3=$(( _C3 - $(_vl "$c3") ))
  (( p1 < 0 )) && p1=0; (( p2 < 0 )) && p2=0; (( p3 < 0 )) && p3=0
  printf "${FRM}│${R}%s%${p1}s${FRM}│${R}%s%${p2}s${FRM}│${R}%s%${p3}s${FRM}│${R}\n" \
    "$c1" "" "$c2" "" "$c3" ""
  (( _ROW++ ))
}

# 2-column split box (for Projects/Workspaces)
_LW=$(( (IW - 1) / 2 ))  # = 43
_RW=$(( IW - _LW - 1 ))  # = 44

_s2top() {
  printf "${FRM}╭%s┬%s╮${R}\n" \
    "$(_fill "$_LW")" \
    "$(_fill "$_RW")"
  (( _ROW++ ))
}

_s2mid() {
  printf "${FRM}├%s┼%s┤${R}\n" \
    "$(_fill "$_LW")" \
    "$(_fill "$_RW")"
  (( _ROW++ ))
}

_s2bot() {
  printf "${FRM}╰%s┴%s╯${R}\n" \
    "$(_fill "$_LW")" \
    "$(_fill "$_RW")"
  (( _ROW++ ))
}

_s2r() {
  local l="$1" r="$2" pl pr
  pl=$(( _LW - $(_vl "$l") ))
  pr=$(( _RW - $(_vl "$r") ))
  (( pl < 0 )) && pl=0; (( pr < 0 )) && pr=0
  printf "${FRM}│${R}%s%${pl}s${FRM}│${R}%s%${pr}s${FRM}│${R}\n" "$l" "" "$r" ""
  (( _ROW++ ))
}

# Key-value formatter
_kv() {
  printf " ${D}${GRY}%-9s${R}  ${3:-$WHT}%s${R}" "$1" "$(_trn "$2" "${4:-20}")"
}

# Pill tag
_pill() { printf " ${FRM}[${SKY}%s${FRM}]${R}" "$1"; }

# Section header (no box)
_sec() {
  local lbl="$1" rem
  rem=$(( IW + 2 - ${#lbl} - 5 ))
  (( rem < 0 )) && rem=0
  printf "${FRM}—— ${R}${B}${WHT}%s${R} ${FRM}%s${R}\n" \
    "$lbl" "$(_fill "$rem")"
  (( _ROW++ ))
}

# ══════════════════════════════════════════════════════════════════════
#  RENDER WELCOME SCREEN
# ══════════════════════════════════════════════════════════════════════

# —— HEADER (Greeting + Date/Time) —————————————————————————————————————
_btop

_hl="${B}  ${AMBER}◆${R}  ${B}${WHT}${_greet}, ${AMBER}${_user}${R}"
# _hrr="  ${D}${GRY}${_date_str}${R}  ${B}${SKY}${_time_str}${R}  "

_hll=$(_vl "$_hl")
# _hlr=$(_vl "$_hrr")
# _hpad=$(( IW - _hll - _hlr ))
# (( _hpad < 1 )) && _hpad=1

# Calculate clock position for live updates
# _CLOCK_ROW=$_ROW
# _CLOCK_COL=$(( 1 + _hll + _hpad + 2 + ${#_date_str} + 2 + 1 ))

# printf "${FRM}│${R}%s%${_hpad}s%s${FRM}│${R}\n" "$_hl" "" "$_hrr"
# (( _ROW++ ))

# —— INFO GRID (3 Columns with T-Junctions) ————————————————————————————
_b3mid

# Column headers
_ir \
  "  ${D}${FRM}— SYSTEM${R}" \
  "  ${D}${FRM}— RESOURCES${R}" \
  "  ${D}${FRM}— ENVIRONMENT${R}"

_ir "" "" ""

# System information rows
# col1: max 18 chars, col2: max 17 chars, col3: max 14 chars
_ir \
  "$(_kv " OS"     "$_os"            "$SAGE"  18)" \
  "$(_kv " Memory" "$_memu / $_memt" "$STEEL" 17)" \
  "$(_kv " IP"     "$_ip"            "$SKY"   14)"

_ir \
  "$(_kv " Mode"   "$_mode"          "$SAGE"  18)" \
  "$(_kv " Disk"   "$_disk"          "$STEEL" 17)" \
  "$(_kv " Shell"  "$_shell"         "$SKY"   14)"

_ir \
  "$(_kv " Host"   "$(_trn "$_host" 18)"   "$SAGE"  18)" \
  "$(_kv " Load"   "$_load"                 "$STEEL" 17)" \
  "$(_kv " Uptime" "$(_trn "$_uptime" 14)" "$SKY"   14)"

_env_last=""
if [[ -n "$_git" ]]; then
  _env_last="$(_kv " Branch" "⎇  $(_trn "$_git" 11)" "$MINT" 14)"
else
  _env_last="$(_kv " Dir"    "$(_trn "$_cwd" 14)"    "$MINT" 14)"
fi

_ir \
  "$(_kv " Kernel"  "$(_trn "$_kern" 18)"    "$SAGE" 18)" \
  "$(_kv " Weather" "$(_trn "$_weather" 17)" "$GOLD" 17)" \
  "$_env_last"

_ir "" "" ""
_b3bot

printf "\n"
(( _ROW++ ))

# —— PROJECTS  │  WORKSPACES ————————————————————————————————————————————
typeset -ga WELCOME_PROJECT_COMMANDS=()
typeset -ga WELCOME_WORKSPACE_COMMANDS=()

# Gather workspace entries
typeset -a _wlines=()
_wc=0
if [[ -d "$WORKSPACES_DIR" ]]; then
  for _wp in "$WORKSPACES_DIR"/*(N); do
    (( _wc++ ))
    _wname="$(basename "$_wp")"
    _wdisp="${_wname%.code-workspace}"
    _wpath="${_wp/#$HOME/~}"
    _wcmd="cursor ${_wpath}"
    WELCOME_WORKSPACE_COMMANDS+=("$_wcmd")
    if [[ -d "$_wp" ]]; then
      _wlines+=("  ${AMBER}›${R} ${MINT}$(_trn "$_wdisp/" 28)${R}  $(_pill "w${_wc}")")
    else
      _wlines+=("  ${AMBER}›${R} ${MINT}$(_trn "$_wdisp" 28)${R}  $(_pill "w${_wc}")")
    fi
  done
  (( _wc == 0 )) && _wlines+=("  ${D}${GRY}No workspaces found yet.${R}")
else
  _wlines+=("  ${D}${GRY}Directory not found.${R}")
  _wlines+=("  ${D}${GRY}mkdir -p ~/projects/.workspaces/${R}")
fi

# Gather project entries
typeset -a _plines=()
_pcmd="cursor ~/projects"
WELCOME_PROJECT_COMMANDS+=("$_pcmd")
_plines+=("  ${D}${GRY}${PROJECTS_DIR/#$HOME/~}/${R}")

if [[ -d "$PROJECTS_DIR" ]]; then
  _plines+=("  ${AMBER}›${R} ${WHT}cursor ~/projects${R}  $(_pill "p1")")
else
  _plines+=("  ${D}${GRY}Directory not found.${R}")
  _plines+=("  ${AMBER}›${R} ${WHT}cursor ~/projects${R}  $(_pill "p1")")
fi

_s2top

_s2r \
  "  ${B}${WHT}Projects${R}   ${D}${GRY}~/projects/${R}" \
  "  ${B}${WHT}Workspaces${R}   ${D}${GRY}~/projects/.workspaces/${R}"

_s2mid

_maxr=${#_plines[@]}
(( ${#_wlines[@]} > _maxr )) && _maxr=${#_wlines[@]}

for _i in {1..$_maxr}; do
  _s2r "${_plines[$_i]:-}" "${_wlines[$_i]:-}"
done

_s2bot

printf "\n"
(( _ROW++ ))

# —— RECENT COMMANDS ————————————————————————————————————————————————————
typeset -ga WELCOME_RECENT_COMMANDS=()

_get_recent() {
  local hf="${HISTFILE:-$HOME/.zsh_history}"
  {
    [[ -r "$hf" ]] && tail -n 5000 "$hf" 2>/dev/null \
      | sed -E 's/^: [0-9]+:[0-9]+;//'
    fc -ln -1000 2>/dev/null
  } | sed 's/^[[:space:]]*//' \
    | awk '/^(cursor|code)([[:space:]]|$|\.)/&&!seen[$0]++{c[++n]=$0}
           END{s=n-2;if(s<1)s=1;for(i=s;i<=n;i++)if(c[i]!="")print c[i]}'
}

_recent="$(_get_recent)"

_sec "Continue where you left off"
_btop

if [[ -n "$_recent" ]]; then
  WELCOME_RECENT_COMMANDS=("${(@f)_recent}")
  _ri=1
  for _rcmd in "${WELCOME_RECENT_COMMANDS[@]}"; do
    _br "  ${AMBER}◆${R}  ${WHT}${_rcmd}${R}  $(_pill "c${_ri}")"
    (( _ri++ ))
  done
else
  _br "  ${D}${GRY}No recent Cursor or VS Code commands found.${R}"
  _br "  ${D}${GRY}Try:${R}  ${WHT}cursor ~/projects/${R}"
fi

_bbot

printf "\n"
(( _ROW++ ))

# —— FOOTER —————————————————————————————————————————————————————————————
printf "  ${D}${GRY}Start with${R}  ${AMBER}cursor ~/projects/${R}  ${D}${GRY}·${R}  ${AMBER}cursor .${R}  ${D}${GRY}·${R}  ${AMBER}cursor ~/projects/.workspaces/<name>${R}\n"
printf "  ${D}${GRY}WSL tip:${R}   ${WHT}Restart WSL from Windows with ${AMBER}wsl.exe --shutdown${R}\n"
printf "\n"
(( _ROW += 3 ))

# —— QUICK-RUN FUNCTIONS ————————————————————————————————————————————————
_run_wc() {
  local arr_name="$1" idx="$2"
  local cmd="${${(P)arr_name}[$idx]}"
  if [[ -z "$cmd" ]]; then
    printf "${GOLD}Nothing configured for index %s.${R}\n" "$idx"
    return 1
  fi
  printf "${SAGE}Running:${R} ${WHT}%s${R}\n" "$cmd"
  eval "$cmd"
}

c1() { _run_wc WELCOME_RECENT_COMMANDS    1 }
c2() { _run_wc WELCOME_RECENT_COMMANDS    2 }
c3() { _run_wc WELCOME_RECENT_COMMANDS    3 }
p1() { _run_wc WELCOME_PROJECT_COMMANDS   1 }
p2() { _run_wc WELCOME_PROJECT_COMMANDS   2 }
p3() { _run_wc WELCOME_PROJECT_COMMANDS   3 }
w1() { _run_wc WELCOME_WORKSPACE_COMMANDS 1  }
w2() { _run_wc WELCOME_WORKSPACE_COMMANDS 2  }
w3() { _run_wc WELCOME_WORKSPACE_COMMANDS 3  }
w4() { _run_wc WELCOME_WORKSPACE_COMMANDS 4  }
w5() { _run_wc WELCOME_WORKSPACE_COMMANDS 5  }
w6() { _run_wc WELCOME_WORKSPACE_COMMANDS 6  }
w7() { _run_wc WELCOME_WORKSPACE_COMMANDS 7  }
w8() { _run_wc WELCOME_WORKSPACE_COMMANDS 8  }
w9() { _run_wc WELCOME_WORKSPACE_COMMANDS 9  }

# —— LIVE CLOCK —————————————————————————————————————————————————————————
# _wclock() {
#   while true; do
#     sleep 1
#     [[ ! -t 1 ]] && break
#     printf "\0337\033[%d;%dH${B}${SKY}%s${R}\0338" \
#       "$_CLOCK_ROW" "$_CLOCK_COL" "$(date '+%H:%M:%S')"
#   done
# }

# _wclock &!
_WCLOCK_PID=$!

# autoload -Uz add-zsh-hook 2>/dev/null
# if typeset -f add-zsh-hook >/dev/null 2>&1; then
#   _wclock_stop() {
#     [[ -n "$_WCLOCK_PID" ]] && kill "$_WCLOCK_PID" 2>/dev/null
#     unset _WCLOCK_PID
#     add-zsh-hook -d preexec _wclock_stop 2>/dev/null
#   }
#   add-zsh-hook preexec _wclock_stop
# fi

# trap '[[ -n "$_WCLOCK_PID" ]] && kill "$_WCLOCK_PID" 2>/dev/null' EXIT
