#!/bin/bash

VT_USERNAME=${VT_USERNAME:-"root"}
VT_PASSWORD=${VT_PASSWORD:-"root"}
VT_HOST=${VT_HOST:-"127.0.0.1"}
VT_PORT=${VT_PORT:-"3306"}
VT_DATABASE=${VT_DATABASE:-"vitess"}

function show_and_drop_tables() {
  tables="$(mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne 'SHOW TABLES' 2>/dev/null | sed 's/^\|$/`/g' | xargs echo | sed 's/ /,/g')";

  if [[ "${tables}" != '' ]]; then
    mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne "DROP TABLE ${tables}" &>/dev/null;
  fi
}

function run_test() {
  if [ "$#" -eq 1 ]; then
    local language="$(echo "$1" | cut -d'/' -f1)"
    local framework="$(echo "$1" | cut -d'/' -f2)"
  else
    local language="$1"
    local framework="$2"
  fi
  pushd "${language}/${framework}" >/dev/null

  if [ -e test ]; then
    ./test &>/dev/null
  elif [ -e Dockerfile ]; then
    local tag="$(echo "${language}-${framework}-framework-testing:latest" | tr '[:upper:]' '[:lower:]')"
    docker build -t ${tag} .
    docker run --rm -i -e VT_HOST -e VT_USERNAME -e VT_PASSWORD -e VT_PORT -e VT_DATABASE ${tag} &>/dev/null
  fi

  echo "${language}/${framework}: $?"
  popd >/dev/null

  show_and_drop_tables
}

function validate_environment() {
  if ! ensure_environment_variables 'VT_HOST' 'VT_PORT' 'VT_USERNAME' 'VT_PASSWORD' 'VT_DATABASE'; then
    echo "Ensure VT_{HOST,PORT,USERNAME,PASSWORD,DATABASE} are set"
    exit 1
  fi
}

function ensure_environment_variables() {
  for variable; do
    : ${!variable:?}
  done
}

function get_languages() {
  for directory in $(ls -d */); do
    echo "${directory%%/}"
  done
}

function get_frameworks() {
  local language="$1"

  for framework in $(ls "${language}"); do
    echo $framework
  done
}
