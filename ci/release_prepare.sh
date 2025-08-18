#!/usr/bin/env bash
set -euo pipefail

echo "Starting release_prepare job"

git config user.name "${GITLAB_USER_NAME:-ci}"
git config user.email "${GITLAB_USER_EMAIL:-ci@example.com}"

# Auth for pushes (optional; falls back to read-only if missing)
if [ -n "${GL_TOKEN:-}" ]; then
  git remote set-url origin "https://oauth2:${GL_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
elif [ -n "${CI_JOB_TOKEN:-}" ]; then
  git remote set-url origin "https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
fi

# Sync refs & tags
git fetch origin --tags --prune

TARGET_BRANCH="develop"
#TARGET_BRANCH="${CI_COMMIT_REF_NAME:-develop}"

# Prefer explicit commit from previous stage; else use latest on branch
if [ -n "${RELEASE_COMMIT:-}" ]; then
  git fetch origin "${RELEASE_COMMIT}" || true
  TAG_TARGET_SHA="${RELEASE_COMMIT}"
else
  git fetch origin "${TARGET_BRANCH}" --depth=1 || true
  TAG_TARGET_SHA=$(git rev-parse "origin/${TARGET_BRANCH}")
fi

echo "Tag target: ${TAG_TARGET_SHA} (branch ${TARGET_BRANCH})"

# --- Determine NEW_TAG without bumping ---
# 1) Prefer env NEW_TAG (from dotenv)
# 2) Else use VERSION env var
# 3) Else parse Version.swift
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

# Do not bump here; if tag exists — fail
if git rev-parse -q --verify "refs/tags/${NEW_TAG}" >/dev/null; then
  echo "ERROR: Tag ${NEW_TAG} already exists. Refusing to overwrite." >&2
  exit 1
fi

echo "Creating annotated tag ${NEW_TAG} for ${TAG_TARGET_SHA}"
git tag -a "${NEW_TAG}" -m "Release ${NEW_TAG}" "${TAG_TARGET_SHA}"
git push origin "${NEW_TAG}"

# Push release branch to GitLab (origin)
RELEASE_BRANCH="${RELEASE_BRANCH:-${TARGET_BRANCH}}"
echo "Pushing branch ${RELEASE_BRANCH} to GitLab (origin)"
git push origin "${TAG_TARGET_SHA}:refs/heads/${RELEASE_BRANCH}"

echo "Release ${NEW_TAG} pushed to GitLab."
