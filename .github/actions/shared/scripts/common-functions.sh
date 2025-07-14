#!/bin/bash

# Common functions used across multiple actions

# Rate limit checking function with exponential backoff
check_rate_limit() {
  echo "Checking GitHub API rate limit..."
  
  # Get current rate limit status
  RATE_LIMIT_RESPONSE=$(gh api /rate_limit)
  REMAINING=$(echo "$RATE_LIMIT_RESPONSE" | jq -r '.rate.remaining')
  LIMIT=$(echo "$RATE_LIMIT_RESPONSE" | jq -r '.rate.limit')
  RESET_TIME=$(echo "$RATE_LIMIT_RESPONSE" | jq -r '.rate.reset')
  
  echo "API Rate Limit Status: $REMAINING remaining out of $LIMIT (resets at $(date -d @$RESET_TIME))"
  
  # Check if we're approaching the limit (less than 50 remaining)
  if [ "$REMAINING" -lt 50 ]; then
    echo "WARNING: API rate limit is low ($REMAINING remaining). Initiating backoff strategy..."
    
    local iteration=1
    local wait_time=30
    local max_iterations=10
    
    while [ $iteration -le $max_iterations ]; do
      echo "Backoff iteration $iteration/$max_iterations: waiting ${wait_time} seconds..."
      sleep $wait_time
      
      # Check rate limit again
      RATE_LIMIT_RESPONSE=$(gh api /rate_limit)
      NEW_REMAINING=$(echo "$RATE_LIMIT_RESPONSE" | jq -r '.rate.remaining')
      
      echo "Rate limit after wait: $NEW_REMAINING remaining"
      
      # Check if the limit increased by more than 100
      local increase=$((NEW_REMAINING - REMAINING))
      if [ $increase -gt 100 ]; then
        echo "Rate limit increased by $increase. Continuing with API calls..."
        return 0
      fi
      
      # If this is the last iteration and limit hasn't increased sufficiently
      if [ $iteration -eq $max_iterations ]; then
        echo "ERROR: Available API limit ceiling has been reached"
        exit 1
      fi
      
      # Double the wait time for next iteration
      wait_time=$((wait_time * 2))
      iteration=$((iteration + 1))
      REMAINING=$NEW_REMAINING
    done
  fi
  
  echo "Rate limit check passed. Proceeding with API call..."
}

# Function to transform URLs from source to target repository
transform_url() {
  local original_url="$1"
  local source_owner="$2"
  local source_repo="$3"
  local target_owner="$4"
  local target_repo="$5"
  
  local source_pattern="https://github.com/$source_owner/$source_repo"
  local target_replacement="https://github.com/$target_owner/$target_repo"
  
  if [[ "$original_url" == *"$source_pattern"* ]]; then
    echo "${original_url/$source_pattern/$target_replacement}"
  else
    echo "$original_url"
  fi
}

# Function to log broken URLs
log_broken_url() {
  local broken_url="$1"
  local context="$2"
  local broken_urls_file="${3:-broken_urls.json}"
  
  echo "Logging broken URL: $broken_url (context: $context)"
  
  # Add to broken URLs log
  jq --arg url "$broken_url" --arg context "$context" \
    '. += [{"url": $url, "context": $context, "timestamp": now | todate}]' \
    "$broken_urls_file" > "${broken_urls_file}_temp.json" && \
    mv "${broken_urls_file}_temp.json" "$broken_urls_file"
}

# Function to initialize JSON files
initialize_json_files() {
  echo "{}" > parent_child_links.json
  echo "{}" > source_target_mapping.json
  echo "[]" > broken_urls.json
}

# Function to display broken URLs summary
display_broken_urls_summary() {
  local broken_urls_file="${1:-broken_urls.json}"
  
  if [ -f "$broken_urls_file" ] && [ "$(jq '. | length' "$broken_urls_file")" -gt 0 ]; then
    echo "BROKEN URLS DETECTED:"
    echo "====================="
    jq -r '.[] | "URL: \(.url) | Context: \(.context) | Time: \(.timestamp)"' "$broken_urls_file"
    echo "====================="
    echo "Total broken URLs: $(jq '. | length' "$broken_urls_file")"
  else
    echo "No broken URLs detected."
  fi
}