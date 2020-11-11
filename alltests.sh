#!/bin/bash

source lib.sh

for framework in $(get_frameworks); do
  run_test "${framework}"
done
