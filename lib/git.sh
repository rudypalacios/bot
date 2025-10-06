# --------------------- 
# GIT code execution
# ---------------------

create_commit() {
    local command="${1:-}"
    local flag="${2:-}"
    local description="${3:-}"

    if [ "$#" -lt 3 ] || [ "${flag}" != "-m" ]; then
        die "Usage: bot $command -m \"commit message\""
    fi

    [ -z "$description" ] && die "Empty commit message."

    TICKET="$(get_ticket_from_branch)"

    [ -z "$TICKET" ] && die "Cannot detect ticket prefix from branch."

    update_before_actions

    FINAL_MSG="${TICKET} - ${COMMIT_MSG}"
    [ "$COMMAND" = "wip" ] && FINAL_MSG="${FINAL_MSG} -WIP"

    git add .
    git commit -a -m "$FINAL_MSG"

    log_success "Committed with message: \"$FINAL_MSG\""
}

create_branch() {
    if [ "$#" -lt 1 ]; then
        die "Usage: bot co \"<branch-name>\""
    fi

    normalize_branch_name "$*" # Generates NEW_BRANCH variable

    log_info "Checking if branch name is unique..."
    git show-ref --verify --quiet "refs/heads/${NEW_BRANCH}" && die "Branch '${NEW_BRANCH}' exists."

    log_info "Creating '${NEW_BRANCH}' from ${BASE_BRANCH}..."
    git fetch origin "$BASE_BRANCH"
    git checkout -b "$NEW_BRANCH" "$BASE_BRANCH"

    log_success "Branch '${NEW_BRANCH}' created and checked out."
}

stash_changes() {
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_info "Uncommitted changes detected. Stashing before operation..."
        git stash push --include-untracked -k -m "bot-stash-$(date +%s)" >/dev/null
        return 1
    fi

    return 0
}

stash_pop() {
    local stashes
    stashes=$(git stash list | wc -l)

    if [ "$stashes" -gt 0 ]; then
        log_info "Restoring stashed changes..."
        if ! git stash pop; then
            log_error "Conflicts occurred while popping stash. Resolve manually."
            exit 1
        fi
    fi
}

pull_from_remote() {
    local remote_branch="${1:-$BASE_BRANCH}"
    local current_branch="$(get_current_branch)"

    if ! git diff --quiet || ! git diff --cached --quiet; then
        confirm "Uncommitted changes detected. Continue? (they will be stashed)" Y
    fi

    log_info "Fetching origin/${remote_branch}..."
    git fetch origin "$remote_branch"

    log_info "Merging origin/${remote_branch} into ${current_branch}..."

    git pull --no-rebase origin "$remote_branch" || die "Pull failed. Resolve conflicts manually."

    log_success "Branch '${current_branch}' merged from '${remote_branch}'."
}

rebase_from_remote() {
    local remote_branch="${1:-$BASE_BRANCH}"
    local current_branch="$(get_current_branch)"

    if ! git diff --quiet || ! git diff --cached --quiet; then
        confirm "Uncommitted changes detected. Continue? (they will be stashed)" Y
    fi

    log_info "Fetching origin/${remote_branch}..."
    git fetch origin "$remote_branch"

    log_info "Rebasing '${current_branch}' onto origin/${remote_branch}..."
    git rebase origin/"$remote_branch" || die "Rebase failed. Resolve with 'git rebase --continue' or abort."

    log_success "Branch '${current_branch}' rebased onto origin/${remote_branch}'."
}

update_before_actions() {
    local stashed=0
    if stash_changes; then
        stashed=0
    else
        stashed=1
    fi

    if [ "$PREFERED_STRATEGY" = "rebase" ]; then
        rebase_from_remote "$BASE_BRANCH"
    else
        pull_from_remote "$BASE_BRANCH"
    fi

    if [ "$stashed" -eq 1 ]; then
        stash_pop
    fi
}

squash_commits() {
    if [ -z "${1:-}" ]; then
        die "Usage: bot squash <amount-of-commits-to-squash>"
    fi

    [[ "$1" =~ ^[0-9]+$ ]] || die "Invalid number: must be integer."

    confirm "Squash the last ${1} commits?" Y
    git rebase -i HEAD~"$1"
}

amend_commit() {
    confirm "Amend last commit with current changes?" Y

    git add .
    git commit --amend --no-edit

    log_success "Last commit amended."
}

rename_branch() {
    if [ -z "${1:-}" ]; then
        die "Usage: bot rename <new-branch-name>"
    fi

    NEW_NAME="$1"

    # Check if ticket pattern is enforced
    validate_ticket_pattern "$NEW_NAME"

    log_info "Checking if branch name is unique..."
    git show-ref --verify --quiet "refs/heads/${NEW_NAME}" && die "Branch '${NEW_NAME}' exists."

    confirm "Rename current branch to '${NEW_NAME}'?" Y
    git branch -m "$NEW_NAME"

    log_success "Branch renamed to '${NEW_NAME}'."
}

undo_last_commit() {
    git rev-parse --verify HEAD >/dev/null 2>&1 || die "No commits to undo."

    confirm "Undo last commit and keep your staged changes?" Y

    git reset --soft HEAD~1
    log_success "Last commit undone; staged files restored."
}

print_branch_status() {
    log_info "Git status summary:"

    CURRENT_BRANCH="$(get_current_branch)"
    UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo '(no upstream)')"
    AHEAD=$(git rev-list --count "${UPSTREAM}..HEAD" 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count "HEAD..${UPSTREAM}" 2>/dev/null || echo "0")

    log_msg "Current branch:  ${CURRENT_BRANCH}"
    log_msg "Tracking:        ${UPSTREAM}"
    log_msg "Ahead/Behind:    +${AHEAD}/-${BEHIND}"
    log_msg "Untracked files: $(git ls-files --others --exclude-standard | wc -l)"
    log_msg "Modified files:  $(git status --porcelain | grep -E '^( M|M )' | wc -l)"
    log_msg "Staged changes:  $(git diff --cached --name-only | wc -l)"
    log_msg "Detailed branch-aware status:"
    git status -sb
}

