#!/bin/sh -ex

# 1 What is the Active Record Query Interface?
rails db:migrate

rake guide_query_interface:seed

# 2 Retrieving Objects from the Database
rake guide_query_interface:step_2_1 # Retrieving a Single Object
rake guide_query_interface:step_2_2 # Retrieving Multiple Objects in Batches

