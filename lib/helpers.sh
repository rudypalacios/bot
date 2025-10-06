# --------------------- 
# Action helpers
# ---------------------

get_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || die "Unable to detect branch."
}

get_ticket_from_branch() {
    local br="$(get_current_branch)"

    # Get ocurrence in the branch name
    local ticket=$(echo "$br" | grep -Eo "$TICKET_PATTERN" | head -n 1 || true)

    # Revalidate the pattern
    if [[ "$ticket" =~ ^$TICKET_PATTERN$ ]]; then
        echo "$ticket"
    else
        echo ""
    fi
}

normalize_branch_name() {
    local raw="$*"

    # Remove leading/trailing spaces
    raw="$(echo "$raw" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"

    # Split into first token (ticket) and rest (desc)
    local ticket="$(echo "$raw" | awk '{print $1}')"
    local desc="$(echo "$raw" | cut -d' ' -f2-)"

    # Make sure the desc is not a duplicate from the ticket #
    [ "$desc" = "$raw" ] && desc=""

    # Validate ticket format: e.g. ABC-123 or TEAM_456 (configurable pattern)
    validate_ticket_pattern "$ticket"

    # Clean description:
    # - lowercase
    # - spaces → underscores
    # - strip illegal chars (allow a-z0-9._/-)
    if [ -n "$desc" ]; then
        desc="$(echo "$desc" | tr '[:upper:]' '[:lower:]')"
        desc="$(echo "$desc" | tr ' ' '_')"
        desc="$(echo "$desc" | sed -E 's/[^a-z0-9._/-]+/_/g; s/_+/_/g; s/^_//; s/_$//')"
    fi

    if [ -z "$desc" ]; then
      NEW_BRANCH="$ticket"
    else
      NEW_BRANCH="${ticket}_${desc}"
    fi
}

validate_ticket_pattern(){
    local ticket="$1"
    if [[ "$ENFORCE_TICKET_PATTERN" == true && ! "$ticket" =~ ^$TICKET_PATTERN ]]; then
        log_error "Invalid ticket format '$ticket' in the branch name. Expected pattern like ABC-123 or APP_45."
        exit 1
    fi
}
