#!/bin/bash

# usage: contains "$list" "$value"
#   returns success if $value is in $list; failure if not
function contains() {
  for item in $1; do
    if [ "$item" == "$2" ]; then
      return 0
    fi
  done
  return 1
}

function cleanup_tables() {
  mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne 'SELECT DISTINCT TABLE_NAME, CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_NAME IS NOT NULL' 2>/dev/null | while read -r table key; do
    echo "ALTER TABLE \`${table}\` DROP FOREIGN KEY \`${key}\`;";
  done | mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" 2>/dev/null;

  tables="$(mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne 'SHOW TABLES' 2>/dev/null | sed 's/^\|$/`/g' | xargs echo | sed 's/ /,/g')";
  if [[ "${tables}" != '' ]]; then
    mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne "DROP TABLE ${tables}" 2>/dev/null;
  fi
}

# usage: generate_image_name "$language/$framework"
function generate_image_name() {
  echo "gcr.io/planetscale-vitess-testing/frameworks/${1}:latest" | tr '[:upper:]' '[:lower:]'
}

# usage: pull_image "$language/$framework"
function pull_image() {
  docker pull "$(generate_image_name "${1}")"
}

# usage: build_image "$language/$framework"
function build_image() {
  docker build -t "$(generate_image_name "${1}")" "frameworks/${1}"
}

# usage: run_test language/framework
#    To rebuild a framework's container image for testing during local development, use build_image "$language/$framework"
function run_test() {
  validate_environment

  local language framework
  language="$(echo "$1" | cut -d'/' -f1)"
  framework="$(echo "$1" | cut -d'/' -f2)"

  pushd "frameworks/${language}/${framework}" >/dev/null || return

  tag="$(generate_image_name "${language}/${framework}")"
  if ! [ -z "${QUIET}" ]; then
    docker run --rm -i --network host -e VT_HOST -e VT_USERNAME -e VT_PASSWORD -e VT_PORT -e VT_DATABASE -e VT_NUM_SHARDS "${tag}" &>/dev/null
  else
    docker run --rm -i --network host -e VT_HOST -e VT_USERNAME -e VT_PASSWORD -e VT_PORT -e VT_DATABASE -e VT_NUM_SHARDS "${tag}"
  fi;

  result="$?"
  echo "${language}/${framework}: $result"
  popd >/dev/null || return

  cleanup_tables
  return $result
}

function validate_environment() {
  if [[ -z "$VT_HOST" || -z "$VT_PORT" || -z "$VT_USERNAME" || -z "$VT_PASSWORD" || -z "$VT_DATABASE" || -z "$VT_NUM_SHARDS" ]]; then
    echo "Ensure VT_{HOST,PORT,USERNAME,PASSWORD,DATABASE} are set"
    exit 1
  fi
}

function get_frameworks() {
  find frameworks -mindepth 2 -maxdepth 2 -prune -type d | cut -d'/' -f2-
}

cmd="${1}"
shift

"${cmd}" "$@"
