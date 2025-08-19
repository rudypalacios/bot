# 🛠 Overview

This repository provides a lightweight helper tool (`bot`) to streamline Git workflows with branch conventions and standardized commit messages.

It includes:

- `init.sh` → Adds `bin/` to your `PATH` so you can run `bot` from anywhere.
- `lib/colors.sh` → Provides color-coded logging helpers.
- `bin/bot.sh` → The main CLI tool (`bot`) for branch management and commits.

# 📂 Project Structure

```
.
├── init.sh          # Setup script to add bin/ to PATH
├── lib/
│   └── colors.sh    # Color + logging helpers
└── bin/
    └── bot.sh       # Main CLI tool
```

# 🚀 Installation

1. Clone or copy this repo into a folder of your choice.
1. Run the initializer once:

```
./init.sh
```

> This will add the `bin/` directory to your shell `PATH` by updating your profile (`.zshrc` or `.bashrc`).
> After this, the bot command will be available globally.

3. Reload your shell or run:

```
source ~/.zshrc   # or ~/.bashrc
```

# 🖥 Usage

## Create a Branch

```
bot co "abc-123 Add login feature"
```

👉 This will:

- Normalize the branch name to: `ABC-123_add_login_feature`
- Create it from the latest `main` branch

## Commit Changes

```
bot ci -m "implement login form validation"
```

👉 This will:

1. Fetch and update your local main branch:

```
git fetch origin main:main
```

2. Merge the updated main into your current branch:

```
git merge main
```

3. Stage and commit all changes with a ticket-prefixed message:

```
ABC-123 - implement login form validation
```

## WIP Commit

```
bot wip -m "refactor login service"
```

👉 Same as ci, but marks the commit as work-in-progress:

```
ABC-123 - refactor login service - WIP
```

# 🔖 Branch Naming Convention

When creating a branch with `bot co`:

- The first word is always treated as the ticket number and converted to uppercase.
- The rest of the description is converted to lowercase and spaces are replaced with underscores.

Example:

```
bot co "abc-456 Fix LOGIN bug"
```

Branch name becomes:

```
ABC-456_fix_login_bug
```

## 📜 Commit Message Convention

All commits created with `bot ci` or `bot wip`:

- Are prefixed with the ticket number from the branch name.
- Format:

```
<TICKET> - <Commit message> [- WIP]
```

Example:

```
bot ci -m "add error messages"
```

If current branch is `ABC-123_add_login_feature`:

```
ABC-123 - add error messages
```

## ⚠️ Notes

- Conflicts during `git merge main` will stop the script (`set -e`). You must resolve conflicts manually, then rerun `bot ci` or `bot wip`.
- If no changes are staged, the script will attempt a commit but Git will block it — safe behavior.
- No rebase is used (`git merge` strategy is enforced).

## ✅ Examples

```bash
# Create branch

bot co "abc-321 Improve dashboard UI"

# → Branch: ABC-321_improve_dashboard_ui

# Commit

bot ci -m "add new charts to dashboard"

# → Commit: "ABC-321 - add new charts to dashboard"

# WIP Commit

bot wip -m "testing new API integration"

# → Commit: "ABC-321 - testing new API integration - WIP"
```
