#!/usr/bin/env bash
set -euo pipefail

clear_local_git_state() {
  # Clear local state
  git add .
  git reset --hard
  tags="$(git tag -l || true)"
  if [ -n "$tags" ]; then
    echo "$tags" | xargs -n1 git tag -d
  fi
  git checkout -B temp-branch
  branches="$(git for-each-ref --format='%(refname:short)' refs/heads | grep -v '^temp-branch$' || true)"
  if [ -n "$branches" ]; then
    printf '%s\n' "$branches" | xargs -n1 git branch -D
  fi
}

echo "Starting release_publish job"

# Optional debug traces (set DEBUG=1 in job variables to enable)
if [ "${DEBUG:-0}" = "1" ]; then
  set -x
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1
fi

clear_local_git_state

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
  # Ensure full history and tags to avoid thin-pack base missing on remote (Git-version safe)
  if git rev-parse --is-shallow-repository 2>/dev/null | grep -q "true"; then
    # Unshallow the whole repo so push can build a non-thin pack without missing bases
    git fetch --unshallow --prune --tags || true
  else
    git fetch --prune --tags || true
  fi
  # Make sure we have the target branches locally for lease and ancestry checks
  git fetch origin "${RELEASE_BRANCH}" --prune || true
  git fetch github "${GH_TARGET_BRANCH}" --prune || true

  # Determine remote and local SHAs for safer logging and lease
  REMOTE_REF="refs/remotes/github/${GH_TARGET_BRANCH}"
  REMOTE_SHA=$(git rev-parse -q --verify "${REMOTE_REF}" 2>/dev/null || echo "")
  LOCAL_SHA=$(git rev-parse -q --verify "${PUBLISH_TMP}" 2>/dev/null || echo "")
  echo "Local ${PUBLISH_TMP}=${LOCAL_SHA}"
  echo "Remote ${GH_TARGET_BRANCH}@github=${REMOTE_SHA:-<none>}"

  # Normalize truthy values for GH_FORCE_PUSH (accept 1/true/yes/on)
  GH_FORCE_PUSH_NORM=0
  case "${GH_FORCE_PUSH:-0}" in
    1|true|TRUE|yes|YES|on|ON) GH_FORCE_PUSH_NORM=1 ;;
    *) GH_FORCE_PUSH_NORM=0 ;;
  esac

  set +e
  if [ "${GH_FORCE_PUSH_NORM}" = "1" ]; then
    if [ -n "${REMOTE_SHA}" ]; then
      echo "Safe overwrite using explicit lease (only if remote head matches what we fetched)"
      git -c pack.useThin=false push --no-thin --force-with-lease=${GH_TARGET_BRANCH}:${REMOTE_SHA} github "$PUBLISH_TMP:refs/heads/${GH_TARGET_BRANCH}"
    else
      echo "No remote head found (new branch on GitHub) — plain force is fine"
      git -c pack.useThin=false push --no-thin --force github "$PUBLISH_TMP:refs/heads/${GH_TARGET_BRANCH}"
    fi
    rc=$?
  else
    echo "Try a normal fast-forward push"
    git -c pack.useThin=false push --no-thin github "$PUBLISH_TMP:refs/heads/${GH_TARGET_BRANCH}"
    rc=$?
    if [ $rc -ne 0 ]; then
      echo "Non-fast-forward push rejected. Re-run with GH_FORCE_PUSH=1 (or 'true'/'yes') to overwrite GitHub ${GH_TARGET_BRANCH}." >&2
    fi
  fi
  set -e

  if [ $rc -ne 0 ]; then
    echo "Stop early to avoid tagging if branch push failed"
    exit $rc
  fi

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

  if [ -n "${NEW_TAG:-}" ] && git rev-parse -q --verify "refs/tags/${NEW_TAG}" >/dev/null; then
    echo "Pushing tag ${NEW_TAG} to GitLab"
    git push origin "refs/tags/${NEW_TAG}" || echo "Warning: GitLab tag push failed." >&2
  fi

  echo "Release version ${NEW_TAG} pushed to GitLab."
fi
