#!/usr/bin/env bash

set -eu

cf login -a ${PCF_API_ENDPOINT} -o ${PCF_ORG} -s ${PCF_SPACE}

echo "Deploying Buildkite agent to PCF"

erb ops/manifests/buildkite-deploy-agent.yml.erb > ops/manifests/buildkite-deploy-agent.yml

cf push buildkite-deploy-agent -f ops/manifests/buildkite-deploy-agent.yml

rm ops/manifests/buildkite-deploy-agent.yml
