#!/bin/bash

# Get current date in YYYYMMDD format
DATE=$(date +"%Y%m%d")

# Get existing tags for today with prefix
EXISTING_TAGS=$(git tag | grep "^release-databricks-infra-${DATE}\.[0-9]\{3\}$")

# Determine next release number
# Exit if current commit already has a release tag
if git tag --points-at HEAD | grep "^release-databricks-infra-${DATE}\.[0-9]\{3\}$" >/dev/null; then
    echo "Current commit already has a release tag for today."
    exit 0
fi

if [ -z "$EXISTING_TAGS" ]; then
    RELEASE_NUM="001"
else
    LAST_NUM=$(echo "$EXISTING_TAGS" | awk -F. '{print $2}' | sort -n | tail -1)
    NEXT_NUM=$(printf "%03d" $((10#$LAST_NUM + 1)))
    RELEASE_NUM="$NEXT_NUM"
fi

TAG="release-databricks-infra-${DATE}.${RELEASE_NUM}"

# Tag current branch
# Get summary of changes since last release tag
LAST_TAG=$(git tag | grep "^release-databricks-infra-[0-9]\{8\}\.[0-9]\{3\}$" | sort | tail -1)
if [ -n "$LAST_TAG" ]; then
    CHANGE_SUMMARY=$(git log "$LAST_TAG"..HEAD --oneline)
else
    CHANGE_SUMMARY=$(git log --oneline)
fi

git tag -a "$TAG" -m "Release summary:\n$CHANGE_SUMMARY"
echo "Tagged current branch with: $TAG"