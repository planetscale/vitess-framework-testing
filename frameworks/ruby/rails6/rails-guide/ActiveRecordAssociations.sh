#!/bin/sh -ex

# 1 Why Associations?
rails db:migrate
rake guide_association:step_1

# 2 The Types of Associations
rake guide_association:step_2_1 # The belongs_to Association
rake guide_association:step_2_2 # The has_one Association
rake guide_association:step_2_3 # The has_many Association
rake guide_association:step_2_4 # The has_many :through Association
rake guide_association:step_2_5 # The has_one :through Association
rake guide_association:step_2_6 # The has_and_belongs_to_many Association
rake guide_association:step_2_7 # Choosing between belongs_to and has_one
rake guide_association:step_2_8 # Choosing between has_many :through and has_and_belongs_to_many
rake guide_association:step_2_9 # Polymorphic Associations
rake guide_association:step_2_10 # Self Joins

# 3 Tips, Tricks, and Warnings
rake guide_association:step_3_1 # Controlling Caching
# 3.2 Avoiding Name Collisions is just advice about naming fields
rake guide_association:step_3_3 # Updating the schema
# 3.4 Controlling Association Scope is only examples for more fine-grained Ruby module organization, nothing to do with the database
rake guide_association:step_3_5 # Bi-directional Associations

