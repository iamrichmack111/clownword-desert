#!/usr/bin/env bash
set -Eeuo pipefail

OWNER="${GITHUB_OWNER:-iamrichmack111}"
REPO="${REPO_NAME:-clownword-desert}"
VERSION="${VERSION:-v1.0.0}"
DESCRIPTION="${DESCRIPTION:-A 2D open-world desert spelling game where sight words defeat clown hordes.}"
HOMEPAGE="https://${OWNER}.github.io/${REPO}/"
FULL_REPO="${OWNER}/${REPO}"

TOPICS=(
  javascript html5 canvas canvas-game browser-game web-game
  educational-game spelling-game sight-words kids-game 2d-game
  open-world offline-first web-audio desert
)

say() {
  printf '\n\033[1;36m==>\033[0m %s\n' "$*"
}

die() {
  printf '\n\033[1;31mERROR:\033[0m %s\n' "$*" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || die "git is not installed."
command -v gh >/dev/null 2>&1 || die "GitHub CLI (gh) is not installed."
gh auth status >/dev/null 2>&1 || die "GitHub CLI is not authenticated. Run: gh auth login"

cd "$(dirname "${BASH_SOURCE[0]}")"

say "Preparing repository ${FULL_REPO}"

if [[ ! -d .git ]]; then
  git init
fi

git branch -M main

# Use the user's existing Git identity. Prompt only when Git has none.
if ! git config user.name >/dev/null; then
  read -r -p "Git author name: " git_name
  git config user.name "$git_name"
fi

if ! git config user.email >/dev/null; then
  read -r -p "Git author email: " git_email
  git config user.email "$git_email"
fi

mkdir -p dist

say "Creating the initial commit"
git add .
if git diff --cached --quiet; then
  echo "No uncommitted changes were found."
else
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    git commit -m "Release ClownWord Desert ${VERSION}"
  else
    git commit -m "Initial release of ClownWord Desert"
  fi
fi

say "Creating annotated tag ${VERSION}"
if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "Tag ${VERSION} already exists locally."
else
  git tag -a "$VERSION" -m "ClownWord Desert ${VERSION}"
fi

say "Creating release archive"
ARCHIVE="dist/clownword-desert-${VERSION#v}.zip"
rm -f "$ARCHIVE"

if command -v zip >/dev/null 2>&1; then
  zip -rq "$ARCHIVE" \
    index.html README.md LICENSE CHANGELOG.md CONTRIBUTING.md \
    CODE_OF_CONDUCT.md VERSION icon.svg manifest.webmanifest .nojekyll
else
  ARCHIVE="dist/clownword-desert-${VERSION#v}.tar.gz"
  tar -czf "$ARCHIVE" \
    index.html README.md LICENSE CHANGELOG.md CONTRIBUTING.md \
    CODE_OF_CONDUCT.md VERSION icon.svg manifest.webmanifest .nojekyll
fi

say "Creating or connecting the GitHub repository"
if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  echo "Repository already exists: ${FULL_REPO}"
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "https://github.com/${FULL_REPO}.git"
  else
    git remote add origin "https://github.com/${FULL_REPO}.git"
  fi
else
  gh repo create "$FULL_REPO" \
    --public \
    --source=. \
    --remote=origin \
    --description="$DESCRIPTION"
fi

say "Pushing main and ${VERSION}"
git push -u origin main
git push origin "$VERSION"

say "Configuring repository metadata"
edit_args=(
  "$FULL_REPO"
  --description "$DESCRIPTION"
  --homepage "$HOMEPAGE"
  --enable-issues
  --enable-wiki=false
  --delete-branch-on-merge
  --enable-squash-merge
  --enable-rebase-merge
)
for topic in "${TOPICS[@]}"; do
  edit_args+=(--add-topic "$topic")
done
gh repo edit "${edit_args[@]}"

# Enable Discussions through the API for older GitHub CLI versions.
gh api --method PATCH "repos/${FULL_REPO}"   -F has_discussions=true >/dev/null

say "Creating useful repository labels"

upsert_label() {
  local name="$1"
  local description="$2"
  local color="$3"
  local encoded_name

  encoded_name="$(
    python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$name"
  )"

  if gh api "repos/${FULL_REPO}/labels/${encoded_name}" >/dev/null 2>&1; then
    gh api --method PATCH \
      "repos/${FULL_REPO}/labels/${encoded_name}" \
      -f new_name="$name" \
      -f description="$description" \
      -f color="$color" >/dev/null
  else
    gh api --method POST \
      "repos/${FULL_REPO}/labels" \
      -f name="$name" \
      -f description="$description" \
      -f color="$color" >/dev/null
  fi
}

upsert_label "education" \
  "Educational content or learning mechanics" \
  "1D76DB"

upsert_label "gameplay" \
  "Gameplay and balance changes" \
  "F9D0C4"

upsert_label "accessibility" \
  "Accessibility improvements" \
  "0E8A16"

upsert_label "good first issue" \
  "Good for a first contribution" \
  "7057FF"

upsert_label "browser-compatibility" \
  "Browser-specific behavior" \
  "BFD4F2"

say "Creating or updating GitHub Release ${VERSION}"
if gh release view "$VERSION" --repo "$FULL_REPO" >/dev/null 2>&1; then
  gh release upload "$VERSION" "$ARCHIVE" --repo "$FULL_REPO" --clobber
  gh release edit "$VERSION" \
    --repo "$FULL_REPO" \
    --title "ClownWord Desert ${VERSION}" \
    --notes-file CHANGELOG.md \
    --latest
else
  gh release create "$VERSION" "$ARCHIVE" \
    --repo "$FULL_REPO" \
    --verify-tag \
    --title "ClownWord Desert ${VERSION}" \
    --notes-file CHANGELOG.md \
    --latest
fi

say "Enabling GitHub Pages from main:/"
if gh api "repos/${FULL_REPO}/pages" >/dev/null 2>&1; then
  gh api --method PUT "repos/${FULL_REPO}/pages" \
    -f 'source[branch]=main' \
    -f 'source[path]=/' >/dev/null
else
  gh api --method POST "repos/${FULL_REPO}/pages" \
    -f 'source[branch]=main' \
    -f 'source[path]=/' >/dev/null
fi

say "Verifying the published repository"
gh repo view "$FULL_REPO" \
  --json nameWithOwner,description,url,homepageUrl,visibility,repositoryTopics \
  --jq '{
    repository: .nameWithOwner,
    visibility: .visibility,
    url: .url,
    homepage: .homepageUrl,
    description: .description,
    topics: [.repositoryTopics[].name]
  }'

printf '\n\033[1;32mPublished successfully.\033[0m\n'
printf 'Repository: https://github.com/%s\n' "$FULL_REPO"
printf 'Game:       %s\n' "$HOMEPAGE"
printf 'Release:    https://github.com/%s/releases/tag/%s\n' "$FULL_REPO" "$VERSION"
