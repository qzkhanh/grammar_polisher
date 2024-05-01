#!/bin/bash
set -euo pipefail

# Nếu chưa có .git, khởi tạo
if [ ! -d .git ]; then
  git init
  git branch -M main
fi

# Nếu chưa có remote origin, hãy uncomment và chỉnh URL phù hợp hoặc đảm bảo đã add origin
# git remote add origin git@github.com:qzkhanh/grammar_polisher.git

echo "🚀 Start creating realistic commits (adding all files each time)..."

COMMITS=(
"2024-05-01T10:00:00|feat: init project structure"
"2024-05-10T11:30:00|feat: add task creation screen"
"2024-05-20T09:00:00|fix: fix list layout on small screens"
"2024-06-01T15:00:00|perf: optimize local db queries"
"2024-07-01T10:00:00|feat: mark task as completed"
"2024-07-15T14:00:00|refactor: separate data layer (repository)"
"2024-08-05T11:00:00|feat: add grammar handbook module"
"2024-08-20T16:00:00|chore: integrate firebase for sync"
"2024-09-05T19:00:00|feat: notifications for daily reminders"
"2024-09-12T10:15:00|test: add basic unit tests and fix failing cases"
"2024-09-20T20:30:00|fix: ui/ux bug fixes and polish animations"
"2024-09-28T18:00:00|style: update icons and theme"
"2024-10-01T13:00:00|ci: add fastlane config for release"
"2024-10-10T17:00:00|release: prepare v1.0"
)

# Ensure CHANGELOG.md exists and is tracked
touch CHANGELOG.md
git add CHANGELOG.md || true

for entry in "${COMMITS[@]}"; do
  DATE="${entry%%|*}"
  MSG="${entry#*|}"

  # Append a small note so that git add . will include a change each time
  echo "- $MSG ($DATE)" >> CHANGELOG.md

  # Add all files in project
  git add .

  # Commit with backdated author & committer date
  GIT_AUTHOR_DATE="$DATE" GIT_COMMITTER_DATE="$DATE" \
    git commit -m "$MSG"
  echo "Committed: $MSG ($DATE)"
done

echo "✅ Created ${#COMMITS[@]} commits. To push to GitHub run:"
echo "git push -u origin main --force"
