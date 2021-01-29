#!/bin/sh -ex

rails generate migration CreatePerson name:string
rake db:migrate

# 1 Validations Overview
rails console <<EOF
raise "validation failed" unless Person.create(name: "John Doe").valid?
raise "validation should have failed" if Person.create(name: nil).valid?
EOF

# 1.1 Why Use Validations?
true

# 1.2 When Does Validation Happen?
rails console <<EOF
p = Person.new(name: "John Doe")
raise "not new" unless p.new_record?
raise "save failed" unless p.save
raise "new" if p.new_record?
EOF

# 1.3 Skipping Validations
true # There are no code snippets; should we write some ourselves that use the functions mentioned?

# 1.4 valid? and invalid?
rails console <<EOF
p = Person.new
raise "errors" unless p.errors.size == 0
raise "should be invalid" if p.valid?
raise "wrong error" if p.errors.objects.first.full_message != "Name can't be blank"
EOF
rails console <<EOF
p = Person.create
raise "wrong error" if p.errors.objects.first.full_message != "Name can't be blank"
raise "save succeeded" if p.save
begin
	p.save!
rescue ActiveRecord::RecordInvalid
end
begin
	Person.create!
rescue ActiveRecord::RecordInvalid
end
EOF

# 1.5 errors[]
rails console <<EOF
raise "errors before validation" if Person.new.errors[:name].any?
raise "no errors after validation" unless Person.create.errors[:name].any?
EOF

