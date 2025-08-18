#!/usr/bin/env bash
set -euo pipefail

### --- Helpers ---

bump_patch() {
  local v="$1"
  IFS='.' read -r MA MI PA <<< "$v"
  : "${MA:=0}"; : "${MI:=0}"; : "${PA:=0}"
  PA=$((PA+1))
  echo "${MA}.${MI}.${PA}"
}

update_version_file() {
  local NEW_TAG="$1"
  local VERSION_FILE_DEFAULT="Version.swift"
  local VERSION_FILE="${VERSION_FILE:-$VERSION_FILE_DEFAULT}"

  if [ ! -f "$VERSION_FILE" ]; then
    # Try to locate Version.swift in the repo if path not provided
    local CANDIDATE
    CANDIDATE=$(git ls-files | grep -E '(^|/)Version\.swift$' | head -n1 || true)
    if [ -n "$CANDIDATE" ]; then
      VERSION_FILE="$CANDIDATE"
    fi
  fi

  if [ -f "$VERSION_FILE" ]; then
    echo "Bumping SDK.version in $VERSION_FILE to $NEW_TAG"
    # Portable sed replacement for GNU/BSD
    if sed --version >/dev/null 2>&1; then
      sed -E -i "s/(static[[:space:]]+let[[:space:]]+version[[:space:]]*=[[:space:]]*\")([^\"]+)(\")/\1${NEW_TAG}\3/" "$VERSION_FILE"
    else
      sed -E -i '' "s/(static[[:space:]]+let[[:space:]]+version[[:space:]]*=[[:space:]]*\")([^\"]+)(\")/\1${NEW_TAG}\3/" "$VERSION_FILE"
    fi

    # Verify
    if ! grep -E -q "static[[:space:]]+let[[:space:]]+version[[:space:]]*=\s*\\\\?\?\"" "$VERSION_FILE" >/dev/null 2>&1; then
      : # avoid shellcheck; we verify precisely below
    fi
    if ! grep -E -q "static[[:space:]]+let[[:space:]]+version[[:space:]]*=\s*\"${NEW_TAG}\"" "$VERSION_FILE"; then
      echo "Warning: could not update version string in $VERSION_FILE automatically." >&2
    fi

    git add "$VERSION_FILE" || true
    if ! git diff --cached --quiet; then
      git commit -m "Bump SDK.version to ${NEW_TAG}"
    else
      echo "No changes detected in $VERSION_FILE; skipping commit."
    fi
  else
    echo "Warning: Version.swift not found; skipping SDK.version bump." >&2
  fi
}

### --- Main ---

echo "Starting update_version job on ${CI_COMMIT_REF_NAME:-detached}"

git config user.name "${GITLAB_USER_NAME:-ci}"
git config user.email "${GITLAB_USER_EMAIL:-ci@example.com}"

git fetch origin --tags --prune

# Determine NEW_TAG
LATEST_TAG=$(git tag --list --sort=-v:refname | head -n1)
[ -z "$LATEST_TAG" ] && LATEST_TAG="0.0.0"

if [ -n "${VERSION:-}" ]; then
  if git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
    NEW_TAG="$(bump_patch "$VERSION")"
  else
    NEW_TAG="$VERSION"
  fi
else
  NEW_TAG="$(bump_patch "$LATEST_TAG")"
fi

# Ensure uniqueness
while git rev-parse -q --verify "refs/tags/${NEW_TAG}" >/dev/null; do
  echo "Tag ${NEW_TAG} already exists, bumping patch..."
  NEW_TAG="$(bump_patch "$NEW_TAG")"
done

echo "Chosen NEW_TAG: ${NEW_TAG}"

# Update Version.swift and commit
update_version_file "$NEW_TAG"

# Prepare authenticated push URL
TARGET_BRANCH="${CI_COMMIT_REF_NAME:-master}"
if [ -n "${GL_TOKEN:-}" ]; then
  git remote set-url origin "https://oauth2:${GL_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
elif [ -n "${CI_JOB_TOKEN:-}" ]; then
  git remote set-url origin "https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
else
  echo "Warning: no GL_TOKEN or CI_JOB_TOKEN; skipping push of version commit." >&2
fi

# Push the version bump commit (if any) to the branch
if ! git diff --quiet HEAD^ HEAD 2>/dev/null || ! git diff --quiet; then
  echo "Pushing version bump commit to ${TARGET_BRANCH}"
  git push origin "HEAD:refs/heads/${TARGET_BRANCH}" || echo "Warning: push failed. Ensure token has write_repository." >&2
else
  echo "Nothing to push."
fi

# Export variables for downstream job (if CI collects dotenv from this path)
DOTENV_PATH="${CI_PROJECT_DIR:-.}/release.env"
echo "NEW_TAG=${NEW_TAG}" > "$DOTENV_PATH"
echo "RELEASE_COMMIT=$(git rev-parse HEAD)" >> "$DOTENV_PATH"
echo "Wrote dotenv to $DOTENV_PATH"

# Try to persist GitLab variable VERSION
if [ -n "${CI_API_V4_URL:-}" ] && [ -n "${CI_PROJECT_ID:-}" ] && [ -n "${GL_TOKEN:-}" ]; then
  echo "Updating GitLab CI variable VERSION -> ${NEW_TAG}"
  set +e
  HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" --request PUT \
    --header "PRIVATE-TOKEN: ${GL_TOKEN}" \
    --data "value=${NEW_TAG}" \
    --data "masked=false" \
    "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/variables/VERSION")
  if [ "$HTTP_CODE" = "404" ]; then
    HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" --request POST \
      --header "PRIVATE-TOKEN: ${GL_TOKEN}" \
      --data "key=VERSION" \
      --data "value=${NEW_TAG}" \
      --data "masked=false" \
      "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/variables")
  fi
  if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "201" ]; then
    echo "Warning: failed to update GitLab variable VERSION (HTTP $HTTP_CODE)." >&2
  else
    echo "GitLab variable VERSION updated (HTTP $HTTP_CODE)."
  fi
  set -e
else
  echo "Skipping GitLab variable update: CI_API_V4_URL/CI_PROJECT_ID/GL_TOKEN not set." >&2
fi

echo "Done. NEW_TAG=${NEW_TAG}, COMMIT=$(git rev-parse --short HEAD)"
