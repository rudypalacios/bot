# --------------------- 
# Environment Checks
# ---------------------

# Git is available
command -v git >/dev/null 2>&1 || die "git not installed."

# Is a valid git repository
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not a git repository."
