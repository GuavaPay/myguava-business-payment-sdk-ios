#!/usr/bin/env bash
set -euo pipefail

# ---------- config ----------
SOURCE_BRANCH="${SOURCE_BRANCH:-master}"
RELEASE_BRANCH="${RELEASE_BRANCH:-github-release}"
REMOTE="${REMOTE:-origin}"          # where to push the release branch
PUSH="${PUSH:-1}"                   # 1 = push, 0 = don't

# ----------------------------

# Clear local state
git add .
git reset --hard
git tag -l | xargs git tag -d
git checkout -B temp-branch
git branch | grep -v "temp-branch" | xargs git branch -D

# Auth for pushes (optional; falls back to read-only if missing)
if [ -n "${GL_TOKEN:-}" ]; then
  git remote set-url origin "https://oauth2:${GL_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
elif [ -n "${CI_JOB_TOKEN:-}" ]; then
  git remote set-url origin "https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
fi

echo "Squash-merge $SOURCE_BRANCH -> $RELEASE_BRANCH (remote=$REMOTE, push=$PUSH)"

# 1) Checks and update
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is dirty. Commit or stash changes."
  exit 1
fi

git config --local checkout.defaultRemote "${REMOTE}" || true
git fetch "${REMOTE}" --prune

#
# 2) Ensure master is up-to-date
if git show-ref --verify --quiet "refs/heads/${SOURCE_BRANCH}"; then
  git checkout "${SOURCE_BRANCH}"
  git branch --set-upstream-to="${REMOTE}/${SOURCE_BRANCH}" >/dev/null 2>&1 || true
  git pull --ff-only "${REMOTE}" "${SOURCE_BRANCH}" || true
else
  # Create/fast-forward local source branch strictly from the chosen remote
  git checkout -B "${SOURCE_BRANCH}" "${REMOTE}/${SOURCE_BRANCH}"
fi

SRC_SHA=$(git rev-parse --short HEAD)
echo "Source $SOURCE_BRANCH at $SRC_SHA"

# 3) Switch/create release branch
if git show-ref --verify --quiet "refs/heads/${RELEASE_BRANCH}"; then
  git checkout "${RELEASE_BRANCH}"
else
  if git ls-remote --exit-code "${REMOTE}" "refs/heads/${RELEASE_BRANCH}" >/dev/null 2>&1; then
    git checkout -t "${REMOTE}/${RELEASE_BRANCH}"
  else
    git checkout -b "${RELEASE_BRANCH}"
  fi
fi

BASE_SHA=$(git rev-parse --short HEAD)
echo "Release branch $RELEASE_BRANCH at $BASE_SHA"

# 4) Squash-merge prioritizing changes from master
#    -X theirs => take version from SOURCE_BRANCH in conflicts.
set +e
git merge --squash -X theirs --no-commit --allow-unrelated-histories "${SOURCE_BRANCH}"
merge_rc=$?
set -e

if [ $merge_rc -ne 0 ]; then
  echo "Merge produced conflicts. Auto-resolving in favor of ${SOURCE_BRANCH}..."
  # accept all conflicting files from 'theirs' (i.e. from SOURCE_BRANCH)
  CONFLICTS=$(git diff --name-only --diff-filter=U || true)
  if [ -n "$CONFLICTS" ]; then
    echo "$CONFLICTS" | while read -r f; do
      [ -n "$f" ] && git checkout --theirs -- "$f"
      git add -- "$f"
    done
  fi
fi

# 5) Are there changes to release?
if git diff --cached --quiet; then
  echo "Nothing to release: no changes from ${SOURCE_BRANCH}."
  git reset --hard
  git checkout "${SOURCE_BRANCH}"
  exit 0
fi

# 6) Form commit message (single combined release)
COMMITS=$(git log --oneline --no-decorate --no-merges "${BASE_SHA}..${SOURCE_BRANCH}" || true)
MSG="Release - ${SRC_SHA}

Included changes (since ${BASE_SHA} on ${RELEASE_BRANCH}):
${COMMITS}
"

git commit -m "$MSG"

NEW_SHA=$(git rev-parse --short HEAD)
echo "Created release commit ${NEW_SHA} on ${RELEASE_BRANCH}"

# 7) Push if needed
if [ "${PUSH}" = "1" ]; then
  echo "Pushing ${RELEASE_BRANCH} to ${REMOTE}..."
  git push "${REMOTE}" "HEAD:refs/heads/${RELEASE_BRANCH}"
fi

# 8) Return to master (optional)
git checkout "${SOURCE_BRANCH}"
echo "Done."
