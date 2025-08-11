#!/bin/bash

set -e

# Debug mode
if [ "$DEBUG" = "true" ]; then
  set -x
fi

# Set variables
SOURCE_PATH="${SOURCE_PATH:-./}"
TARGET_PATH="$TARGET_PATH"
SYNC_MODE="${SYNC_MODE:-overwrite}"
SSH_USER="$SSH_USER"
SSH_PORT="${SSH_PORT:-22}"
PEER_IP="$PEER_IP"
DRY_RUN="${DRY_RUN:-false}"

# Build rsync command
RSYNC_CMD="rsync -avzr --progress --filter='merge .rsync-filter'"

# Add delete flag for clean_copy mode
if [ "$SYNC_MODE" = "clean_copy" ]; then
  RSYNC_CMD="$RSYNC_CMD --delete"
fi

# Add dry-run flag if enabled
if [ "$DRY_RUN" = "true" ]; then
  RSYNC_CMD="$RSYNC_CMD --dry-run"
  echo "DRY RUN MODE: No files will actually be transferred"
fi

# Add source and destination
RSYNC_CMD="$RSYNC_CMD $SOURCE_PATH $SSH_USER@$PEER_IP:$TARGET_PATH"

# Print the command that will be executed
echo "Executing: $RSYNC_CMD"

# Create a temporary file to capture rsync output
TEMP_OUTPUT=$(mktemp)

# Execute rsync and capture output
if $RSYNC_CMD > "$TEMP_OUTPUT" 2>&1; then
  SYNC_STATUS="success"
  
  # Parse output for statistics
  FILES_COUNT=$(grep "Number of files:" "$TEMP_OUTPUT" | awk '{print $4}' || echo "0")
  BYTES_TRANSFERRED=$(grep "Total transferred file size:" "$TEMP_OUTPUT" | awk '{print $5}' || echo "0")
  
  echo "Sync completed successfully"
  echo "Files transferred: $FILES_COUNT"
  echo "Bytes transferred: $BYTES_TRANSFERRED"
else
  SYNC_STATUS="failure"
  FILES_COUNT="0"
  BYTES_TRANSFERRED="0"
  
  echo "Sync failed"
  cat "$TEMP_OUTPUT"
fi

# Set outputs
echo "status=$SYNC_STATUS" >> $GITHUB_OUTPUT
echo "files_count=$FILES_COUNT" >> $GITHUB_OUTPUT
echo "bytes_transferred=$BYTES_TRANSFERRED" >> $GITHUB_OUTPUT

# Clean up
rm -f "$TEMP_OUTPUT"

# Exit with appropriate code
if [ "$SYNC_STATUS" = "success" ]; then
  exit 0
else
  exit 1
fi