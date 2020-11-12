#!/bin/bash

source lib.sh

QUIET=1;
for framework in $(get_frameworks); do
  run_test "${framework}"
done
