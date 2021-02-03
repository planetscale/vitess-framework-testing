#!/bin/sh -ex

rails generate migration CreatePerson name:string
rails db:migrate

# 1 Validations Overview
rake guide_validation:step_1
rake guide_validation:step_1_1 # Why Use Validations?
rake guide_validation:step_1_2 # When Does Validation Happen?
rake guide_validation:step_1_3 # Skipping Validations
rake guide_validation:step_1_4 # valid? and invalid?
rake guide_validation:step_1_5 # errors[]

# 2 Validation Helpers
rails generate migration CreatePerson2 terms_of_service:string eula:string
rails generate migration CreatePerson3 email:string
rails generate migration CreatePerson4 opt_in:string
rails generate migration CreateNumbers integer:integer float:float string:string
rails db:migrate
rake guide_validation:step_2_1 # acceptance
rake guide_validation:step_2_2 # validates_associated
rake guide_validation:step_2_3 # confirmation
rake guide_validation:step_2_4 # exclusion
rake guide_validation:step_2_5 # format
rake guide_validation:step_2_6 # inclusion
rake guide_validation:step_2_7 # length
rake guide_validation:step_2_8 # numericality
rake guide_validation:step_2_9 # presence
rake guide_validation:step_2_10 # absence
rake guide_validation:step_2_11 # uniqueness
rake guide_validation:step_2_12 # validates_with
rake guide_validation:step_2_13 # validates_each

# 3 Common Validation Options
rails generate migration CreateCoffee size:string
rails generate migration CreateTopic title:string
rails generate migration CreatePerson5 name:string age:integer username:string
rails generate migration CreatePerson6 email:string age:integer name:string
rails db:migrate
rake guide_validation:step_3_1 # :allow_nil
rake guide_validation:step_3_2 # :allow_blank
rake guide_validation:step_3_3 # :message
rake guide_validation:step_3_4 # :on

