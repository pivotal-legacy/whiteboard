#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# export AWS_STUB_DEBUG=/dev/tty
# export SSH_ADD_STUB_DEBUG=/dev/tty
# export SSH_AGENT_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty

@test "Show unexpected s3 errors" {
  export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET=my_secrets_bucket
  export BUILDKITE_PLUGIN_S3_SECRETS_DUMP_ENV=true
  export BUILDKITE_PIPELINE_SLUG=test

  stub aws \
    "s3api head-bucket --bucket my_secrets_bucket : echo Forbidden; exit 0" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/private_ssh_key : echo Unexpected llamas >&2; exit 1"

  run bash -c "$PWD/hooks/environment && $PWD/hooks/pre-exit"

  assert_failure
  assert_output --partial "Unexpected llamas"

  unstub aws
}

@test "Load env file from s3 bucket" {
  export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET=my_secrets_bucket
  export BUILDKITE_PLUGIN_S3_SECRETS_DUMP_ENV=true
  export BUILDKITE_PIPELINE_SLUG=test

  stub ssh-agent "-s : echo export SSH_AGENT_PID=93799"

  stub aws \
    "s3api head-bucket --bucket my_secrets_bucket : echo Forbidden; exit 0" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/private_ssh_key : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/id_rsa_github : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key private_ssh_key : exit 0" \
    "s3 cp --only-show-errors --region=us-east-1 --sse aws:kms s3://my_secrets_bucket/private_ssh_key - : echo secret material" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key id_rsa_github : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key env : exit 0" \
    "s3 cp --only-show-errors --region=us-east-1 --sse aws:kms s3://my_secrets_bucket/env - : echo SECRET=24" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key environment : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/env : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/environment : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key git-credentials : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/git-credentials : echo Forbidden >&2; exit 1"

  stub ssh-add \
    "- : echo added ssh key"

  run bash -c "$PWD/hooks/environment && $PWD/hooks/pre-exit"

  assert_success
  assert_output --partial "ssh-agent (pid 93799)"
  assert_output --partial "added ssh key"
  assert_output --partial "SECRET=24"

  unstub ssh-agent
  unstub ssh-add
  unstub aws
}

@test "Load git-credentials from bucket into GIT_CONFIG_PARAMETERS" {
  export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET=my_secrets_bucket
  export BUILDKITE_PLUGIN_S3_SECRETS_DUMP_ENV=true
  export BUILDKITE_PIPELINE_SLUG=test
  unset SSH_AGENT_PID

  stub aws \
    "s3api head-bucket --bucket my_secrets_bucket : echo Forbidden; exit 0" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/private_ssh_key : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/id_rsa_github : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key private_ssh_key : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key id_rsa_github : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key env : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key environment : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/env : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/environment : echo Forbidden >&2; exit 1" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key git-credentials : exit 0" \
    "s3api head-object --region=us-east-1 --bucket my_secrets_bucket --key test/git-credentials : exit 0"

  run bash -c "$PWD/hooks/environment && $PWD/hooks/pre-exit"

  assert_success
  assert_output --partial "Adding git-credentials in git-credentials as a credential helper"
  assert_output --partial "Adding git-credentials in test/git-credentials as a credential helper"
  assert_output --partial "GIT_CONFIG_PARAMETERS='credential.helper="

  unstub aws
}
