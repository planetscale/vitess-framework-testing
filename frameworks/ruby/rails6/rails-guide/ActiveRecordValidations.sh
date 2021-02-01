#!/bin/sh -ex

rails generate migration CreatePerson name:string
rake db:migrate

# 1 Validations Overview
rake guide_validation:step_1
rake guide_validation:step_1_1 # Why Use Validations?
rake guide_validation:step_1_2 # When Does Validation Happen?
rake guide_validation:step_1_3 # Skipping Validations
rake guide_validation:step_1_4 # valid? and invalid?
rake guide_validation:step_1_5 # errors[]

