#!/usr/bin/env bash
set -e

REPO="iamrichmack111/clownword-desert"
TAG="v1.0.0"

git init
git branch -M main

git add .
git commit -m "Initial release of ClownWord Desert"

if gh repo view "$REPO" >/dev/null 2>&1; then
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$REPO.git"
else
    gh repo create "$REPO" \
        --public \
        --source=. \
        --remote=origin
fi

git tag -a "$TAG" -m "ClownWord Desert $TAG"

git push -u origin main
git push origin "$TAG"

echo
echo "Published:"
echo "https://github.com/$REPO"
