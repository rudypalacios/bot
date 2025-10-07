# 🛠 Overview

This repository provides a lightweight helper tool (`bot`) to streamline Git workflows with branch conventions and standardized commit messages.

It includes:

- `init.sh` → Adds `bin/` to your `PATH` so you can run `bot` from anywhere.
- `lib/` → Modular shell helpers for colors, logging, git, config, and more.
- `bin/bot` → The main CLI tool (`bot`) for branch management and commits.

# 📑 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Branch Naming Convention](#branch-naming-convention)
- [Commit Message Convention](#commit-message-convention)
- [Environment Configuration](#environment-configuration)
- [Notes](#notes)
- [Examples](#examples)

# 📂 Project Structure

```
.
├── init.sh           # Setup script to add bin/ to PATH
├── lib/
│   ├── checks.sh     # Validation helpers
│   ├── colors.sh     # Color + logging helpers
│   ├── config.sh     # Config loading
│   ├── git.sh        # Git command helpers
│   ├── helpers.sh    # Misc helpers
│   ├── includes.sh   # Library loader
│   └── utils.sh      # Utility functions
└── bin/
    └── bot           # Main CLI tool
```

# 🚀 Installation

1. Clone or copy this repo into a folder of your choice.
2. Run the initializer once:

   ```
   ./init.sh
   ```

   > This will add the `bin/` directory to your shell `PATH` by updating your profile (`.zshrc`, `.bashrc`, or `.bash_profile`).
   > After this, the `bot` command will be available globally.

3. Reload your shell or run:

   ```
   source ~/.zshrc   # or ~/.bashrc or ~/.bash_profile
   ```

# 📝 Usage

The `bot` script provides a set of commands to simplify common git workflows.  
Below are the available commands and their descriptions:

| Command                       | Description                                                                 |
| ----------------------------- | --------------------------------------------------------------------------- |
| `bot co <branch-description>` | Create and checkout a new branch from `${BASE_BRANCH}`                      |
| `bot ci -m "message"`         | Commit changes, updating from `${BASE_BRANCH}`                              |
| `bot wip -m "message"`        | Commit as work-in-progress (appends `-WIP` to the message)                  |
| `bot pull [branch]`           | Merge latest from `origin/<branch>` into current branch. Default: `develop` |
| `bot rebase [branch]`         | Rebase current branch onto `origin/<branch>` Default: `develop`             |
| `bot squash <n>`              | Interactively squash the last `n` commits                                   |
| `bot amend`                   | Amend the last commit                                                       |
| `bot rename <new-branch>`     | Rename the current branch                                                   |
| `bot undo`                    | Undo the last commit (keeps changes staged)                                 |
| `bot status`                  | Show a git status summary                                                   |
| `bot help`                    | Show usage information                                                      |

Run `bot help` or just `bot` to display this list of commands in your terminal.

## Create a Branch

```
bot co "abc-123 Add login feature"
```

👉 This will:

- Normalize the branch name to: `ABC-123_add_login_feature`
- Create it from the latest `develop` branch (configurable)

## Commit Changes

```
bot ci -m "implement login form validation"
```

👉 This will:

1. Fetch and update your local develop branch
2. Stash your local changes, if any
3. Merge or rebase the updated develop into your current branch
4. Pop your changes
5. Stage and commit all changes with a ticket-prefixed message if a ticket is found in the name

## WIP Commit

```
bot wip -m "refactor login service"
```

👉 Same as `ci`, but marks the commit as work-in-progress:

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

# ⚙️ Environment Configuration

You can configure project-specific settings using a `.env` file in the project root.  
**Any variable set in `.env` will override the default values from `lib/config.sh`.**

Supported variables include:

- `MAIN_BRANCH` — The main branch name (default: `main`)
- `DEVELOP_BRANCH` — The develop branch name (default: `develop`)
- `BASE_BRANCH` — The base branch for new branches (default: value of `DEVELOP_BRANCH`)
- `PREFERED_STRATEGY` — Default commit/branch strategy (`pull` or `rebase`)
- `ENFORCE_TICKET_PATTERN` — Enforce ticket ID in branch names (`true` or `false`)
- `TICKET_PATTERN` — Regex pattern to extract ticket numbers from branch names

Example `.env`:

```
MAIN_BRANCH=main
DEVELOP_BRANCH=develop
BASE_BRANCH=main
PREFERED_STRATEGY=pull
ENFORCE_TICKET_PATTERN=true
TICKET_PATTERN='[A-Za-z]{2,10}[-_][0-9]{1,5}'
```

> The `.env` file is loaded automatically if present and will override any corresponding variable in `lib/config.sh`.  
> You can customize branch and commit conventions by editing these variables.

# ⚠️ Notes

- Conflicts during `git merge` or `git rebase` will stop the script. You must resolve conflicts manually, then rerun `bot ci` or `bot wip`.
- If no changes are staged, the script will attempt a commit but Git will block it — safe behavior.
- All helper scripts are modularized under `lib/` for maintainability.

# ✅ Examples

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
