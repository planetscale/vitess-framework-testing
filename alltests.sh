#!/bin/bash

dir="$(dirname "${0}")"

QUIET=1;
for framework in $("${dir}/run.sh" get_frameworks); do
  "${dir}/run.sh" run_test "${framework}"
done

