#!/bin/sh -ex

# 1 What is the Active Record Query Interface?
rails db:migrate

rake guide_query_interface:seed

# 2 Retrieving Objects from the Database
rake guide_query_interface:step_2_1 # Retrieving a Single Object
rake guide_query_interface:step_2_2 # Retrieving Multiple Objects in Batches

# 3 Conditions
rake guide_query_interface:step_3_1 # Pure String Conditions
rake guide_query_interface:step_3_2 # Array Conditions
rake guide_query_interface:step_3_3 # Hash Conditions
rake guide_query_interface:step_3_4 # NOT Conditions
rake guide_query_interface:step_3_5 # OR Conditions

# 4 Ordering
rake guide_query_interface:step_4

# 5 Selecting Specific Fields
rake guide_query_interface:step_5

