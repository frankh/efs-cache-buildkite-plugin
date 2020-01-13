#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
# export GIT_STUB_DEBUG=/dev/tty

@test "Pre-command restores cache with basic key" {
  stub ln 'ln -s /tmp/efs/v1-cache-key/bundle bundle'

  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_EFS_CACHE_EFS_PATH="/tmp/efs"
  export BUILDKITE_PLUGIN_EFS_CACHE_PATHS_0="bundle"
  export BUILDKITE_PLUGIN_EFS_CACHE_PATHS_1="node_modules"
  export BUILDKITE_PLUGIN_EFS_CACHE_CACHE_KEY="v1-cache-key"

  mkdir -p /tmp/efs/v1-cache-key/bundle
  touch /tmp/efs/v1-cache-key/bundle/cached_file

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "ln -s /tmp/efs/v1-cache-key/bundle bundle"
}

@test "Post-command syncs artifacts with a single path" {
  export BUILDKITE_ORGANIZATION_SLUG="my-org"
  export BUILDKITE_PIPELINE_SLUG="my-pipeline"
  export BUILDKITE_PLUGIN_EFS_CACHE_EFS_PATH="/tmp/efs"
  export BUILDKITE_PLUGIN_EFS_CACHE_PATHS_0="bundle"
  export BUILDKITE_PLUGIN_EFS_CACHE_PATHS_1="hooks"
  export BUILDKITE_PLUGIN_EFS_CACHE_CACHE_KEY="v1-cache-key"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "populating hooks cache"
}
