# --------------------- 
# Environment Checks
# ---------------------

# Git is available
command -v git >/dev/null 2>&1 || log_warn "git not installed."

# Is a valid git repository
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || log_warn "Not a git repository."
