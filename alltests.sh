#!/bin/bash

source lib.sh

pushd "frameworks" >/dev/null

for language in $(get_languages); do
  for framework in $(get_frameworks "${language}"); do
    run_test "${language}" "${framework}"
  done
done

popd >/dev/null
