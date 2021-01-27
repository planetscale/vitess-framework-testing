#!/bin/sh -ex
set -o pipefail

# TODO:  Validate that each step produces data that we expect, instead of just
#    displaying it to the user and failing if the server rejects a query



python testingGuides.py
