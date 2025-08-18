#!/usr/bin/env bash
set -euo pipefail

echo "Starting release_publish job"

# Clear local state
git add .
git reset --hard
git tag -l | xargs git tag -d
git checkout -B temp-branch
git branch | grep -v "temp-branch" | xargs git branch -D

git config user.name "${GITLAB_USER_NAME:-ci}"
git config user.email "${GITLAB_USER_EMAIL:-ci@example.com}"

# Optional GitHub auth & remote (for pushing the tag)
RELEASE_BRANCH="${RELEASE_BRANCH:-github-release}"
GH_TARGET_BRANCH="${GH_TARGET_BRANCH:-master}"
# Source of truth for publishing is the GitLab release branch; GitHub target branch receives that snapshot

# Prefer explicit commit from previous stage; else use latest on branch
if [ -n "${RELEASE_COMMIT:-}" ]; then
  git fetch origin "${RELEASE_COMMIT}" || true
  TAG_TARGET_SHA="${RELEASE_COMMIT}"
else
  git fetch origin "${RELEASE_BRANCH}" --depth=1 || true
  TAG_TARGET_SHA=$(git rev-parse "origin/${RELEASE_BRANCH}")
fi

if [ -z "${NEW_TAG:-}" ] && [ -n "${VERSION:-}" ]; then
  NEW_TAG="${VERSION}"
fi

if [ -z "${NEW_TAG:-}" ]; then
  if [ -f "Sources/MyGuavaPaymentSDK/Version.swift" ]; then
    NEW_TAG=$(grep -E 'static[[:space:]]+let[[:space:]]+version' Sources/MyGuavaPaymentSDK/Version.swift | sed -E 's/.*"([^"]+)".*/\1/')
  fi
fi

if [ -z "${NEW_TAG:-}" ]; then
  echo "ERROR: NEW_TAG not provided and could not infer from VERSION or Version.swift." >&2
  exit 1
fi

GH_ENABLED=0
if [ -n "${GH_TOKEN:-}" ] && [ -n "${GH_REPO:-}" ]; then
  GH_USER="${GH_USERNAME:-x-access-token}"
  # Normalize GH_REPO: allow either full URL or host/path
  if echo "$GH_REPO" | grep -E -q '^https?://'; then
    GH_BASE="${GH_REPO#https://}"
    GH_BASE="${GH_BASE#http://}"
  else
    GH_BASE="$GH_REPO"
  fi
  git remote remove github 2>/dev/null || true
  git remote add github "https://${GH_USER}:${GH_TOKEN}@${GH_BASE}"
  GH_ENABLED=1
fi

# Push branch and tag to GitHub if configured
if [ "$GH_ENABLED" = "1" ]; then

  # Create a temporary local branch at the desired commit
  PUBLISH_TMP="publish_tmp_${GH_TARGET_BRANCH}"
  if git show -s --quiet "${TAG_TARGET_SHA}" >/dev/null 2>&1; then
    git branch -f "$PUBLISH_TMP" "$TAG_TARGET_SHA" >/dev/null 2>&1 || git branch "$PUBLISH_TMP" "$TAG_TARGET_SHA"
  else
    echo "ERROR: Commit ${TAG_TARGET_SHA} not present locally." >&2
    exit 1
  fi

  echo "Pushing ${RELEASE_BRANCH} -> GitHub ${GH_TARGET_BRANCH}"
  git push github "$PUBLISH_TMP:refs/heads/${GH_TARGET_BRANCH}"
  git branch -D "$PUBLISH_TMP" >/dev/null 2>&1 || true

  # Ensure the release tag points to TAG_TARGET_SHA; create if missing
  if [ -n "${NEW_TAG:-}" ] && ! git rev-parse -q --verify "refs/tags/${NEW_TAG}" >/dev/null; then
    git tag -a "${NEW_TAG}" -m "Release ${NEW_TAG}" "${TAG_TARGET_SHA}"
  fi

  if [ -n "${NEW_TAG:-}" ] && git rev-parse -q --verify "refs/tags/${NEW_TAG}" >/dev/null; then
    echo "Pushing tag ${NEW_TAG} to GitHub"
    git push github "refs/tags/${NEW_TAG}" || echo "Warning: GitHub tag push failed." >&2
  fi

  echo "Release ${NEW_TAG} pushed to GitHub."
fi
