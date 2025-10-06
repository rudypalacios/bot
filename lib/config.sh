# ------------------------- 
# Behaviour Configuration
# -------------------------

MAIN_BRANCH="main"
DEVELOP_BRANCH="develop"
PREFERED_STRATEGY="rebase" # pull|rebase
ENFORCE_TICKET_PATTERN=true  # true | false — enforce ticket ID in branch names
TICKET_PATTERN='[A-Za-z]{2,10}[-_][0-9]{1,5}'

BASE_BRANCH="$DEVELOP_BRANCH"  # develop is working base

# Load .env if it exists (override previous)
if [[ -f "./.env" ]]; then
  # Export vars defined as KEY=VALUE (skip comments or blanks)
  set -a  # auto-export all variables
  source "./.env"
  set +a
fi