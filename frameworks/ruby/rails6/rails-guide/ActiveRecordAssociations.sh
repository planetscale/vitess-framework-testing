#!/bin/sh -ex

# 1 Why Associations?
rails db:migrate
rake guide_association:step_1

