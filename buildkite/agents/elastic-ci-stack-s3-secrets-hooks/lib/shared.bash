#!/bin/bash

s3_exists() {
  local bucket="$1"
  local key="$2"
  local aws_s3_args=("--region=$AWS_DEFAULT_REGION")

  # capture just stderr
  output=$(aws s3api head-object "${aws_s3_args[@]}" --bucket "$bucket" --key "$key" 2>&1 >/dev/null)
  exitcode=$?

  # If we didn't get a Not Found or Forbidden then show the error and return exit code 2
  if [[ $exitcode -ne 0 && ! $output =~ (Not Found|Forbidden)$ ]] ; then
    echo "$output" >&2
    return 2
  elif [[ $exitcode -ne 0 ]] ; then
    return 1
  fi
}

s3_bucket_exists() {
  local bucket="$1"
  if ! aws s3api head-bucket --bucket "$bucket" &>/dev/null ; then
    return 1
  fi
}

s3_download() {
  local bucket="$1"
  local key="$2"
  local aws_s3_args=("--only-show-errors" "--region=$AWS_DEFAULT_REGION")

  if [[ "${BUILDKITE_USE_KMS:-true}" =~ ^(true|1)$ ]] ; then
    aws_s3_args+=("--sse" "aws:kms")
  fi

  if ! aws s3 cp "${aws_s3_args[@]}" "s3://${bucket}/${key}" - ; then
    return 1
  fi
}

add_ssh_private_key_to_agent() {
  local ssh_key="$1"

  if [[ -z "${SSH_AGENT_PID:-}" ]] ; then
    echo "Starting an ephemeral ssh-agent" >&2;
    eval "$(ssh-agent -s)"
  fi

  echo "Loading ssh-key into ssh-agent (pid ${SSH_AGENT_PID:-})" >&2;
  echo "$ssh_key" | env SSH_ASKPASS="/bin/false" ssh-add -
}

grep_secrets() {
  grep -E 'private_ssh_key|id_rsa_github|env|environment|git-credentials$' "$@"
}
