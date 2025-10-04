# --------------------- 
# Action helpers
# ---------------------

get_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || die "Unable to detect branch."
}

get_ticket_from_branch() {
    local br
    br="$(get_current_branch)"
    echo "$br" | awk -F'_' '{print $1}'
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
    if [ "$ENFORCE_TICKET_PATTERN" = true ]; then
        if ! [[ "$ticket" =~ ^[A-Za-z]{2,10}[-_][0-9]{1,5}$ ]]; then
            log_error "Invalid ticket format '$ticket'. Expected pattern like ABC-123 or APP_45."
            exit 1
        fi
        ticket="$(echo "$ticket" | tr '[:lower:]' '[:upper:]')"
    else
        ticket="$(echo "$ticket" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | sed -E 's/[^a-z0-9._/-]+/_/g')"
    fi

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
