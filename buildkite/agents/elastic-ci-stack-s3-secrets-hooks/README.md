# AWS S3 Secrets Buildkite Plugin

A set of agent hooks that expose secrets to build steps via Amazon S3 (encrypted-at-rest). Used in the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws).

Different types of secrets are supported and exposed to your builds in appropriate ways:

- `ssh-agent` for SSH Private Keys
- Environment Variables for strings
- `git-credential` via git's credential.helper

## Installation

The hooks needs to be installed directly in the agent so that secrets can be downloaded before jobs attempt checking out your repository. We are going to assume that buildkite has been installed at `/buildkite`, but this will vary depending on your operating system. Change the instructions accordingly.

```bash
# clone to a path your buildkite-agent can access
git clone https://github.com/buildkite-plugins/s3-secrets-buildkite-plugin.git /buildkite/s3_secrets
```

Modify your agent's global hooks (see [https://buildkite.com/docs/agent/v3/hooks#global-hooks](https://buildkite.com/docs/agent/v3/hooks#global-hooks)):

### `${BUILDKITE_ROOT}/hooks/environment`

```bash
if [[ "${SECRETS_PLUGIN_ENABLED:-1}" == "1" ]] ; then
  export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET="my-s3-secrets-bucket"

  source /buildkite/s3_secrets/hooks/environment
fi
```

### `${BUILDKITE_ROOT}/hooks/pre-exit`

```bash
if [[ "${SECRETS_PLUGIN_ENABLED:-1}" == "1" ]] ; then
  export BUILDKITE_PLUGIN_S3_SECRETS_BUCKET="my-s3-secrets-bucket"

  source /buildkite/s3_secrets/hooks/pre-exit
fi
```

## Usage

When run via the agent environment and pre-exit hook, your builds will check in the s3 secrets bucket you created for secrets files in the following formats:

- `s3://{bucket_name}/{pipeline}/private_ssh_key`
- `s3://{bucket_name}/{pipeline}/environment` or `s3://{bucket_name}/{pipeline}/env`
- `s3://{bucket_name}/{pipeline}/git-credentials`
- `s3://{bucket_name}/private_ssh_key`
- `s3://{bucket_name}/environment` or `s3://{bucket_name}/env`
- `s3://{bucket_name}/git-credentials`

The private key is exposed to both the checkout and the command as an ssh-agent instance. The secrets in the env file are exposed as environment variables.

## Uploading Secrets

### SSH Keys

This example uploads an ssh key and an environment file to the root of the bucket, which means it matches all pipelines that use it. You use per-pipeline overrides by adding a path prefix of `/my-pipeline/`.

```bash
# generate a deploy key for your project
ssh-keygen -t rsa -b 4096 -f id_rsa_buildkite
pbcopy < id_rsa_buildkite.pub # paste this into your github deploy key

export secrets_bucket=my-buildkite-secrets
aws s3 cp --acl private --sse aws:kms id_rsa_buildkite "s3://${secrets_bucket}/private_ssh_key"
```

Note the `-sse aws:kms`, as without this your secrets will fail to download.

### Git credentials

For git over https, you can use a `git-credentials` file with credential urls in the format of:

```bash
https://user:password@host/path/to/repo
```

```bash
aws s3 cp --acl private --sse aws:kms <(echo "https://user:password@host/path/to/repo") "s3://${secrets_bucket}/git-credentials"
```

These are then exposed via a [gitcredential helper](https://git-scm.com/docs/gitcredentials) which will download the
credentials as needed.

### Environment variables

Key values pairs can also be uploaded.

```bash
aws s3 cp --acl private --sse aws:kms <(echo "MY_SECRET=blah") "s3://${secrets_bucket}/environment"
```

## Options

### `bucket`

An s3 bucket to look for secrets in.

## License

MIT (see [LICENSE](LICENSE))
