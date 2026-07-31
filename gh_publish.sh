#!/usr/bin/env bash
set -euo pipefail

OWNER="iamrichmack111"
REPO="clownword-desert"
TAG="v1.0.0"
FULL_REPO="$OWNER/$REPO"
PAGES_URL="https://${OWNER}.github.io/${REPO}/"

gh auth status

if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
    echo "Repository already exists: $FULL_REPO"
else
    gh repo create "$FULL_REPO" \
        --public \
        --source=. \
        --remote=origin \
        --push \
        --description="A 2D open-world desert spelling game where sight words defeat clown hordes."
fi

gh repo edit "$FULL_REPO" \
    --description="A 2D open-world desert spelling game where sight words defeat clown hordes." \
    --homepage="$PAGES_URL" \
    --enable-issues \
    --enable-discussions \
    --enable-wiki=false \
    --delete-branch-on-merge \
    --enable-squash-merge \
    --enable-rebase-merge \
    --add-topic=javascript \
    --add-topic=html5 \
    --add-topic=canvas \
    --add-topic=canvas-game \
    --add-topic=browser-game \
    --add-topic=web-game \
    --add-topic=educational-game \
    --add-topic=spelling-game \
    --add-topic=sight-words \
    --add-topic=kids-game \
    --add-topic=2d-game \
    --add-topic=open-world \
    --add-topic=offline-game \
    --add-topic=desert

gh label create education \
    --repo "$FULL_REPO" \
    --description="Educational content and learning mechanics" \
    --color="1D76DB" \
    --force

gh label create gameplay \
    --repo "$FULL_REPO" \
    --description="Gameplay and balancing changes" \
    --color="F9D0C4" \
    --force

gh label create accessibility \
    --repo "$FULL_REPO" \
    --description="Accessibility improvements" \
    --color="0E8A16" \
    --force

gh label create browser-compatibility \
    --repo "$FULL_REPO" \
    --description="Browser-specific problems" \
    --color="BFD4F2" \
    --force

if gh release view "$TAG" --repo "$FULL_REPO" >/dev/null 2>&1; then
    echo "Release already exists: $TAG"
else
    gh release create "$TAG" \
        --repo "$FULL_REPO" \
        --target=main \
        --title="ClownWord Desert $TAG" \
        --generate-notes \
        --latest
fi

if gh api "repos/$FULL_REPO/pages" >/dev/null 2>&1; then
    gh api \
        --method PUT \
        "repos/$FULL_REPO/pages" \
        -f 'source[branch]=main' \
        -f 'source[path]=/'
else
    gh api \
        --method POST \
        "repos/$FULL_REPO/pages" \
        -f 'source[branch]=main' \
        -f 'source[path]=/'
fi

gh repo view "$FULL_REPO" \
    --json nameWithOwner,url,description,homepageUrl,visibility,repositoryTopics \
    --jq '{
      repository: .nameWithOwner,
      visibility: .visibility,
      url: .url,
      homepage: .homepageUrl,
      topics: [.repositoryTopics[].name]
    }'

echo
echo "Repository: https://github.com/$FULL_REPO"
echo "Release:    https://github.com/$FULL_REPO/releases/tag/$TAG"
echo "Live game:  $PAGES_URL"
