# --------------------- 
# Utils
# ---------------------

die() {
    log_error "$*"
    exit 1
}

confirm() {
    local msg="$1"
    local default="${2:-N}"
    local prompt="[${default}/$( [ "${default}" = "Y" ] && echo "n" || echo "y" )]"

    read -r -p "$(log_info "${msg} ${prompt}: "; echo -n)" ans
    ans="${ans:-$default}"

    case "${ans}" in
        [Yy]*) return 0 ;;
        *) log_msg "Aborted by user."; exit 0 ;;
    esac
}

detect_default_branch() {
  DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || true)"

  if [ -n "$DEFAULT_BRANCH" ]; then
      DEFAULT_BRANCH="${DEFAULT_BRANCH#refs/remotes/origin/}"
  else
      DEFAULT_BRANCH="$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}' || true)"
  fi

  [ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH="$MAIN_BRANCH"
}
