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

# 6 Limit and Offset
rake guide_query_interface:step_6

# 7 Group
rake guide_query_interface:step_7

# 8 Having
rake guide_query_interface:step_8

# 9 Overriding Conditions
rake guide_query_interface:step_9_1 # unscope
rake guide_query_interface:step_9_2 # only
rake guide_query_interface:step_9_3 # reselect
rake guide_query_interface:step_9_4 # reorder
rake guide_query_interface:step_9_5 # reverse_order
rake guide_query_interface:step_9_6 # rewhere

# 10 Null Relation
rake guide_query_interface:step_10

# 11 Readonly Objects
rake guide_query_interface:step_11

# 12 Locking Records for Update
rake guide_query_interface:step_12_1 # Optimistic Locking
rake guide_query_interface:step_12_2 # Pessimistic Locking
