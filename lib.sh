#!/bin/bash

function show_and_drop_tables() {
  tables="$(mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne 'SHOW TABLES' 2>/dev/null | sed 's/^\|$/`/g' | xargs echo | sed 's/ /,/g')";

  if [[ "${tables}" != '' ]]; then
    mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne "DROP TABLE ${tables}" &>/dev/null;
  fi
}

function run_test() {
  validate_environment

  local language framework
  language="$(echo "$1" | cut -d'/' -f1)"
  framework="$(echo "$1" | cut -d'/' -f2)"

  pushd "frameworks/${language}/${framework}" >/dev/null || return

  if [ -e test ]; then
    # shellcheck disable=SC2065
    # The redirection here is intentional.
    ./test &>/dev/null
  elif [ -e Dockerfile ]; then
    tag="$(echo "${language}-${framework}-framework-testing:latest" | tr '[:upper:]' '[:lower:]')"
    if ! [ -z "${QUIET}" ]; then
      docker build -t "${tag}" . &>/dev/null
      docker run --rm -i --network host -e VT_HOST -e VT_USERNAME -e VT_PASSWORD -e VT_PORT -e VT_DATABASE "${tag}" &>/dev/null
    else
      docker build -t "${tag}" .
      docker run --rm -i --network host -e VT_HOST -e VT_USERNAME -e VT_PASSWORD -e VT_PORT -e VT_DATABASE "${tag}"
    fi;
  fi

  echo "${language}/${framework}: $?"
  popd >/dev/null || return

  show_and_drop_tables
}

function validate_environment() {
  if [[ -z "$VT_HOST" || -z "$VT_PORT" || -z "$VT_USERNAME" || -z "$VT_PASSWORD" || -z "$VT_DATABASE" ]]; then
    echo "Ensure VT_{HOST,PORT,USERNAME,PASSWORD,DATABASE} are set"
    exit 1
  fi
}

function get_frameworks() {
  find frameworks -mindepth 2 -maxdepth 2 -prune -type d | cut -d'/' -f2-
}
