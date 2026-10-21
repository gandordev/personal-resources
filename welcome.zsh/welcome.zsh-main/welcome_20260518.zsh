#!/usr/bin/env zsh

# ============================================================
#  Professional Ubuntu WSL Welcome Screen for Zsh
#  Compact horizontal layout + live clock + workspaces files
# ============================================================

[[ $- != *i* ]] && return

if [[ -n "$WELCOME_SCREEN_SHOWN" ]]; then
  return
fi
export WELCOME_SCREEN_SHOWN=1

clear

# ----------------------------
# Colors
# ----------------------------
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

ORANGE="\033[38;5;208m"
WHITE="\033[97m"
GRAY="\033[90m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"

# ----------------------------
# Paths
# ----------------------------
PROJECTS_DIR="$HOME/projects"
WORKSPACES_DIR="$HOME/projects/.workspaces"

PROJECTS_LABEL="~/projects/"
WORKSPACES_LABEL="~/projects/.workspaces/"

# ----------------------------
# System data
# ----------------------------
USER_NAME="${USER:-unknown}"
HOST_NAME="$(hostname 2>/dev/null)"
DISTRO="$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2- | tr -d '"')"
KERNEL="$(uname -r)"
SHELL_NAME="$(basename "$SHELL")"
DATE_NOW="$(date '+%A, %d %B %Y')"
UPTIME_NOW="$(uptime -p 2>/dev/null | sed 's/up //')"
CURRENT_DIR="$(pwd | sed "s|^$HOME|~|")"

[[ -z "$DISTRO" ]] && DISTRO="Ubuntu"
[[ -z "$UPTIME_NOW" ]] && UPTIME_NOW="N/A"

if grep -qi microsoft /proc/version 2>/dev/null; then
  WSL_INFO="WSL"
else
  WSL_INFO="Linux"
fi

LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
[[ -z "$LOCAL_IP" ]] && LOCAL_IP="N/A"

MEM_TOTAL="$(free -h 2>/dev/null | awk '/Mem:/ {print $2}')"
MEM_USED="$(free -h 2>/dev/null | awk '/Mem:/ {print $3}')"
[[ -z "$MEM_TOTAL" ]] && MEM_TOTAL="N/A"
[[ -z "$MEM_USED" ]] && MEM_USED="N/A"

DISK_INFO="$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
[[ -z "$DISK_INFO" ]] && DISK_INFO="N/A"

LOAD_AVG="$(awk '{print $1 ", " $2 ", " $3}' /proc/loadavg 2>/dev/null)"
[[ -z "$LOAD_AVG" ]] && LOAD_AVG="N/A"

if command -v git >/dev/null 2>&1; then
  GIT_BRANCH="$(git branch --show-current 2>/dev/null)"
else
  GIT_BRANCH=""
fi

# ----------------------------
# Greeting
# ----------------------------
CURRENT_HOUR="$(date '+%H')"

if (( CURRENT_HOUR >= 5 && CURRENT_HOUR < 12 )); then
  GREETING="Good morning"
elif (( CURRENT_HOUR >= 12 && CURRENT_HOUR < 18 )); then
  GREETING="Good afternoon"
else
  GREETING="Good evening"
fi

# ----------------------------
# Weather
# ----------------------------
WEATHER_INFO="Unavailable"

if command -v curl >/dev/null 2>&1; then
  WEATHER_RESULT="$(curl -fsS --max-time 1.5 'https://wttr.in/?format=%c+%t+%C' 2>/dev/null)"
  [[ -n "$WEATHER_RESULT" ]] && WEATHER_INFO="$WEATHER_RESULT"
fi

# ----------------------------
# Layout tracking
# ----------------------------
CURRENT_ROW=1
WELCOME_CLOCK_ROW=""
WELCOME_CLOCK_COL=""

print_row() {
  printf "%b\n" "$1"
  CURRENT_ROW=$((CURRENT_ROW + 1))
}

line() {
  print_row "${GRAY}────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
}

strip_ansi() {
  sed -E 's/\x1B\[[0-9;]*[mK]//g'
}

label_value() {
  local label="$1"
  local value="$2"
  printf "${GRAY}%-10s${RESET}  %b" "$label" "$value"
}

# ----------------------------
# Recent Cursor / Code commands
# ----------------------------
get_recent_editor_commands() {
  fc -ln -1000 2>/dev/null \
    | sed 's/^[[:space:]]*//' \
    | awk '
        /^(cursor|code)([[:space:]]|$|\.)/ {
          if (!seen[$0]++) {
            commands[++count] = $0
          }
        }
        END {
          start = count - 2
          if (start < 1) start = 1
          for (i = start; i <= count; i++) {
            if (commands[i] != "") print commands[i]
          }
        }
      '
}

# ----------------------------
# Compact Ubuntu logo
# ----------------------------
typeset -a UBUNTU_LOGO
UBUNTU_LOGO=(
"             .-/+oossssoo+/-.             "
"         .:+ssssssssssssssssss+:-        "
"       -+ssssssssssssssssssyyssss+-       "
"     .ossssssssssssssssssdMMMNysssso.     "
"    /ssssssssssshdmmNNmmyNMMMMhssssss/    "
"   +ssssssssshmydMMMMMMMNddddyssssssss+   "
"  /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/  "
" .ssssssssdMMMNhsssssssssshNMMMdssssssss. "
" +sssshhhyNMMNyssssssssssssyNMMMysssssss+ "
" ossyNMMMNyMMhsssssssssssssshmmmhssssssso "
" ossyNMMMNyMMhsssssssssssssshmmmhssssssso "
" +sssshhhyNMMNyssssssssssssyNMMMysssssss+ "
" .ssssssssdMMMNhsssssssssshNMMMdssssssss. "
"  /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/  "
"   +sssssssssdmydMMMMMMMMddddyssssssss+   "
"    /ssssssssssshdmNNNNmyNMMMMhssssss/    "
"     .ossssssssssssssssssdMMMNysssso.     "
"       -+sssssssssssssssssyyyssss+-       "
"         \+ssssssssssssssssssss+:/        "
"             .-/+oossssoo+/-.             "
)

# ----------------------------
# Info panel
# ----------------------------
typeset -a INFO_LINES
INFO_LINES=(
"${BOLD}${WHITE}${GREETING}, ${ORANGE}${USER_NAME}${WHITE}.${RESET}"
"${DIM}${GRAY}Ubuntu WSL development environment ready.${RESET}"
""
"$(label_value "Time" "${CYAN}$(date '+%H:%M:%S')${RESET}")"
"$(label_value "Date" "${CYAN}${DATE_NOW}${RESET}")"
"$(label_value "Weather" "${CYAN}${WEATHER_INFO}${RESET}")"
"$(label_value "System" "${GREEN}${DISTRO}${RESET}")"
"$(label_value "Mode" "${GREEN}${WSL_INFO}${RESET}")"
"$(label_value "Host" "${GREEN}${HOST_NAME}${RESET}")"
"$(label_value "Kernel" "${YELLOW}${KERNEL}${RESET}")"
"$(label_value "Shell" "${YELLOW}${SHELL_NAME}${RESET}")"
"$(label_value "Uptime" "${BLUE}${UPTIME_NOW}${RESET}")"
"$(label_value "Memory" "${BLUE}${MEM_USED} / ${MEM_TOTAL}${RESET}")"
"$(label_value "Disk" "${BLUE}${DISK_INFO}${RESET}")"
"$(label_value "Load" "${BLUE}${LOAD_AVG}${RESET}")"
"$(label_value "IP" "${CYAN}${LOCAL_IP}${RESET}")"
"$(label_value "Location" "${WHITE}${CURRENT_DIR}${RESET}")"
)

if [[ -n "$GIT_BRANCH" ]]; then
  INFO_LINES+=("$(label_value "Git" "${ORANGE}${GIT_BRANCH}${RESET}")")
fi

LOGO_WIDTH=36
GAP_WIDTH=3
LABEL_WIDTH=10

MAX_TOP_ROWS=${#UBUNTU_LOGO[@]}
(( ${#INFO_LINES[@]} > MAX_TOP_ROWS )) && MAX_TOP_ROWS=${#INFO_LINES[@]}

# The live clock column is calculated from the real layout:
# logo width + gap + label width + two spaces + terminal columns are 1-based.
CLOCK_VALUE_OFFSET=$((LOGO_WIDTH + GAP_WIDTH + LABEL_WIDTH + 3))

for i in {1..$MAX_TOP_ROWS}; do
  logo_part="${UBUNTU_LOGO[$i]}"
  info_part="${INFO_LINES[$i]}"

  # Store the real row where Time is printed.
  if (( i == 4 )); then
    WELCOME_CLOCK_ROW="$CURRENT_ROW"
    WELCOME_CLOCK_COL="$CLOCK_VALUE_OFFSET"
  fi

  printf "${ORANGE}${BOLD}%-${LOGO_WIDTH}s${RESET}" "$logo_part"
  printf "%*s" "$GAP_WIDTH" ""
  printf "%b\n" "$info_part"

  CURRENT_ROW=$((CURRENT_ROW + 1))
done

line

# ----------------------------
# Projects + workspaces
# ----------------------------
LEFT_WIDTH=44

print_row "${BOLD}${WHITE}Projects${RESET}                                    ${GRAY}│${RESET} ${BOLD}${WHITE}Workspaces${RESET}"
print_row "${GRAY}──────────────────────────────────────────── │ ────────────────────────────────────────────${RESET}"

typeset -a PROJECT_LINES
PROJECT_LINES=(
"$(label_value "Start from" "${GREEN}${PROJECTS_LABEL}${RESET}")"
)

if [[ -d "$PROJECTS_DIR" ]]; then
  PROJECT_LINES+=("${ORANGE}›${RESET} ${WHITE}Project directory found.${RESET}")
else
  PROJECT_LINES+=("${ORANGE}›${RESET} ${YELLOW}Missing directory.${RESET}")
  PROJECT_LINES+=("${ORANGE}›${RESET} ${GRAY}Create it:${RESET} ${WHITE}mkdir -p ~/projects/${RESET}")
fi

PROJECT_LINES+=("${ORANGE}›${RESET} ${GRAY}Open with:${RESET} ${WHITE}cursor ~/projects/${RESET}")

typeset -a WORKSPACE_LINES
WORKSPACE_LINES=(
"$(label_value "Located at" "${GREEN}${WORKSPACES_LABEL}${RESET}")"
)

if [[ -d "$WORKSPACES_DIR" ]]; then
  WORKSPACE_COUNT=0

  # IMPORTANT:
  # This lists files and directories, not only directories.
  # Your .code-workspace files will appear here.
  for workspace in "$WORKSPACES_DIR"/*(N); do
    WORKSPACE_COUNT=$((WORKSPACE_COUNT + 1))

    WORKSPACE_BASENAME="$(basename "$workspace")"
    WORKSPACE_DISPLAY="$WORKSPACE_BASENAME"

    if [[ "$WORKSPACE_DISPLAY" == *.code-workspace ]]; then
      WORKSPACE_DISPLAY="${WORKSPACE_DISPLAY%.code-workspace}"
    fi

    WORKSPACE_PATH="${workspace/#$HOME/~}"

    if [[ -d "$workspace" ]]; then
      WORKSPACE_LINES+=("${ORANGE}›${RESET} ${GREEN}${WORKSPACE_DISPLAY}/${RESET} ${GRAY}→${RESET} ${WHITE}cursor ${WORKSPACE_PATH}${RESET}")
    else
      WORKSPACE_LINES+=("${ORANGE}›${RESET} ${GREEN}${WORKSPACE_DISPLAY}${RESET} ${GRAY}→${RESET} ${WHITE}cursor ${WORKSPACE_PATH}${RESET}")
    fi
  done

  if (( WORKSPACE_COUNT == 0 )); then
    WORKSPACE_LINES+=("${ORANGE}›${RESET} ${YELLOW}No workspaces found yet.${RESET}")
  fi
else
  WORKSPACE_LINES+=("${ORANGE}›${RESET} ${YELLOW}Missing directory.${RESET}")
  WORKSPACE_LINES+=("${ORANGE}›${RESET} ${GRAY}Create it:${RESET} ${WHITE}mkdir -p ~/projects/.workspaces/${RESET}")
fi

MAX_ROWS=${#PROJECT_LINES[@]}
(( ${#WORKSPACE_LINES[@]} > MAX_ROWS )) && MAX_ROWS=${#WORKSPACE_LINES[@]}

for i in {1..$MAX_ROWS}; do
  left="${PROJECT_LINES[$i]}"
  right="${WORKSPACE_LINES[$i]}"

  printf "%b" "$left"

  plain_left="$(printf "%b" "$left" | strip_ansi)"
  pad=$((LEFT_WIDTH - ${#plain_left}))
  (( pad < 1 )) && pad=1
  printf "%*s" "$pad" ""

  printf " ${GRAY}│${RESET} "
  printf "%b\n" "$right"

  CURRENT_ROW=$((CURRENT_ROW + 1))
done

line

# ----------------------------
# Continue where you left off
# ----------------------------
print_row "${BOLD}${WHITE}Shall we continue where you left off?${RESET}"
print_row "${GRAY}────────────────────────────────────────────────────────────────────────────────────────────${RESET}"

RECENT_COMMANDS="$(get_recent_editor_commands)"

if [[ -n "$RECENT_COMMANDS" ]]; then
  echo "$RECENT_COMMANDS" | while IFS= read -r command_item; do
    print_row "  ${ORANGE}›${RESET} ${WHITE}${command_item}${RESET}"
  done
else
  print_row "  ${ORANGE}›${RESET} ${GRAY}No recent Cursor or VS Code commands found yet.${RESET}"
  print_row "  ${ORANGE}›${RESET} ${GRAY}Try:${RESET} ${WHITE}cursor ~/projects/${RESET}"
fi

line

print_row "${DIM}${GRAY}Tip:${RESET} ${WHITE}Start coding with ${ORANGE}cursor ~/projects/${WHITE}, ${ORANGE}cursor ~/projects/.workspaces/<workspace>${WHITE}, or ${ORANGE}cursor .${WHITE}.${RESET}"
print_row "${DIM}${GRAY}WSL:${RESET} ${WHITE}If something feels stuck, restart it from Windows with ${ORANGE}wsl.exe --shutdown${WHITE}.${RESET}"
print_row ""

# ----------------------------
# Live clock
# ----------------------------
welcome_live_clock() {
  while true; do
    sleep 1
    [[ ! -t 1 ]] && break

    # Save current cursor position
    printf "\033[s"

    # Move to the exact row and column where the Time value was printed
    printf "\033[%s;%sH" "$WELCOME_CLOCK_ROW" "$WELCOME_CLOCK_COL"

    # Rewrite only HH:MM:SS
    printf "${CYAN}%s${RESET}" "$(date '+%H:%M:%S')"

    # Restore cursor position
    printf "\033[u"
  done
}

welcome_live_clock &!
WELCOME_CLOCK_PID=$!

autoload -Uz add-zsh-hook 2>/dev/null

if typeset -f add-zsh-hook >/dev/null 2>&1; then
  welcome_stop_clock_on_command() {
    if [[ -n "$WELCOME_CLOCK_PID" ]]; then
      kill "$WELCOME_CLOCK_PID" 2>/dev/null
      unset WELCOME_CLOCK_PID
    fi

    add-zsh-hook -d preexec welcome_stop_clock_on_command 2>/dev/null
  }

  add-zsh-hook preexec welcome_stop_clock_on_command
fi

trap '[[ -n "$WELCOME_CLOCK_PID" ]] && kill "$WELCOME_CLOCK_PID" 2>/dev/null' EXIT
