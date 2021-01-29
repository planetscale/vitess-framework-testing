#!/bin/sh -ex

rails generate migration CreatePerson name:string
rake db:migrate

# 1 Validations Overview
(
	echo 'raise "validation failed" unless Person.create(name: "John Doe").valid?'
	echo 'raise "validation should have failed" if Person.create(name: nil).valid?'
) | rails console

