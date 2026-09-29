#!/usr/bin/env bash
set -euo pipefail

: "${APP_URL:?APP_URL must point to the deployed API}"
: "${ANALYSIS_INTERNAL_KEY:?ANALYSIS_INTERNAL_KEY must be configured as a secret}"

response="$(curl --fail-with-body --silent --show-error \
  --request POST "${APP_URL%/}/v1/jobs/daily-analysis" \
  --header "X-Analysis-Key: ${ANALYSIS_INTERNAL_KEY}")"

printf '%s\n' "$response"
