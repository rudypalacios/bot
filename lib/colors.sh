#!/bin/bash

# Color codes
RESET="\033[0m"
BOLD="\033[1m"

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"

# Functions for colored printing
log_msg() {
  echo -e "${RESET}$*${RESET}"
}

log_error() {
  echo -e "${BOLD}${RED}>>> ❌ $*${RESET}"
}

log_warn() {
  echo -e "${YELLOW}>>> ⚠️  $*${RESET}"
}

log_info() {
  echo -e "${BLUE}>>> ℹ️  $*${RESET}"
}

log_success() {
  echo -e "${GREEN}>>> ✅ $*${RESET}"
}
