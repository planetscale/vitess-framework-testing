# Rails Guide on Active Records Callbacks
# https://guides.rubyonrails.org/active_record_callbacks.html

source helper.sh

# 2. Callbacks Overview
# 2.1 Callback Registration
# check_ensure_login_has_a_value checks that the callback function ensure_login_has_a_value works
function check_ensure_login_has_a_value(){
  # create a user model
  rails generate model User100s name:string login:string email:string
  # run the migration
  rake_migrate
  # implement the callback method ensure_login_has_a_value
  write_to_file "app/models/user100.rb" "class User100 < ApplicationRecord
    validates :login, :email, presence: true

    before_validation :ensure_login_has_a_value

    private
      def ensure_login_has_a_value
        if login.nil?
          self.login = email unless email.blank?
        end
      end
  end"
  # check that indeed an empty login and email value cannot be inserted
  if rails runner 'User100.create!(:name => "Incorrect Record")'; then
    echo "Command should have failed!"
    exit 1
  fi
  # check that an empty login value works because of the pre-validation function
  rails runner 'User100.create!(:name => "RailsUser", :email => "rails@vitess.in")'
  # check that the data is inserted into the table and login is the same as the email
  assert_mysql_output "select id, name, login, email from user100s" "1 RailsUser rails@vitess.in rails@vitess.in"
}

# check_name_login_capitalization checks that the callback function for setting name to login.capitalize works
function check_name_login_capitalization(){
  # create a user model
  rails generate model User101s name:string login:string email:string
  # run the migration
  rake_migrate
  # implement the callback method ensure_login_has_a_value
  write_to_file "app/models/user101.rb" "class User101 < ApplicationRecord
    validates :login, :email, presence: true

    before_create do
      self.name = login.capitalize if name.blank?
    end
  end
  "
  # check that an empty name value works because of the pre-validation function
  rails runner 'User101.create!(:email => "rails@vitess.in", :login => "railsuser")'
  # check that the data is inserted into the table and name is set to captial of login
  assert_mysql_output "select id, name, login, email from user101s" "1 Railsuser railsuser rails@vitess.in"
}

# check_normalize_name_and_set_location checks that normalize_name and set_location works
function check_normalize_name_and_set_location(){
  # create a user model
  rails generate model User102s name:string location:string
  # run the migration
  rake_migrate
  # implement the callback methods
  write_to_file "app/models/user102.rb" "class User102 < ApplicationRecord
    before_validation :normalize_name, on: :create

    # :on takes an array as well
    after_validation :set_location, on: [ :create, :update ]

    private
      def normalize_name
        self.name = name.downcase.titleize
      end

      def set_location
        self.location = 'customLoc'
      end
  end"
  # create a new user
  rails runner 'User102.create!(:name => "RAILSUSER", :location => "loc")'
  # check that the row is created with location customLoc and name is downcased
  assert_mysql_output "select id, name, location from user102s" "1 Railsuser customLoc"
  # update the user record
  rails runner 'User102.find(1).update!(:name => "RAILSUSER", :location => "loc")'
  # check that the row is created with location customLoc but the name is as is
  assert_mysql_output "select id, name, location from user102s" "1 RAILSUSER customLoc"
}

# 3. Available Callbacks
# check_before_validation checks the callback before_validation
function check_before_validation(){
  # create a user model
  rails generate model User103s name:string login:string email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user103.rb" "class User103 < ApplicationRecord
    validates :login, :email, presence: true

    before_validation :set_login

    private
      def set_login
        self.login = name
      end
  end"

  # check that an empty login value works because of the pre-validation function
  rails runner 'User103.create!(:name => "RailsUser", :email => "rails@vitess.in")'
  # check that the data is inserted into the table and login is the same as the email
  assert_mysql_output "select id, name, login, email from user103s" "1 RailsUser RailsUser rails@vitess.in"
  # changing the name should also change the login
  rails runner 'User103.find(1).update!(:name => "NewName")'
  assert_mysql_output "select id, name, login, email from user103s" "1 NewName NewName rails@vitess.in"
}

# check_after_validation checks the callback after_validation
function check_after_validation(){
  # create a user model
  rails generate model User104s name:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user104.rb" "class User104 < ApplicationRecord
    validates :name, length: { maximum: 10 }

    after_validation :delete_spaces

    private
      def delete_spaces
        self.name = name.delete(' ')
      end
  end"

  # check that a long name does not work. If the spaces had been removed before, then the validation would have passed
  if rails runner 'User104.create!(:name => "  TooLong       ")'; then
    echo "Command should have failed!"
    exit 1
  fi
  # check that the post-validation function is called on creation
  rails runner 'User104.create!(:name => " name  1")'
  # check that the data is inserted into the table
  assert_mysql_output "select id, name from user104s" "1 name1"
  # check that the post-validation function is called on updation
  rails runner 'User104.find(1).update!(:name => " name 2 ")'
  assert_mysql_output "select id, name from user104s" "1 name2"
}

# check_before_save checks the callback before_save
function check_before_save(){
  # create a user model
  rails generate model User105s name:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user105.rb" "class User105 < ApplicationRecord
    before_save :replace_spaces

    private
      def replace_spaces
        self.name = name.parameterize(separator: '_')
      end
  end"

  # check that the before-save function is called on creation
  rails runner 'User105.create!(:name => "name 1")'
  # check that the data is inserted into the table
  assert_mysql_output "select id, name from user105s" "1 name_1"
  # check that the before-save function is called on updation
  rails runner 'User105.find(1).update!(:name => "name 2")'
  assert_mysql_output "select id, name from user105s" "1 name_2"
}

# check_around_save checks the callback around_save
function check_around_save(){
  # create a user model
  rails generate model User106s name:string
  # also create a model for the emails
  rails generate model Email106s user106:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user106.rb" "class User106 < ApplicationRecord
    around_save :parameterize_name_and_insert_email

    private
      def parameterize_name_and_insert_email
        self.name = name.parameterize(separator: '_')
        yield
        if email_row = Email106.where(:user106_id => id).first
          email_row.email = (name+'@vitess.in')
          email_row.save
        else
          Email106.create!(:user106_id => id, :email => (name+'@vitess.in'))
        end
      end
  end"

  # check that the around-save function is called on creation
  rails runner 'User106.create!(:name => "name 1")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user106s" "1 name_1"
  assert_mysql_output "select id, user106_id, email from email106s" "1 1 name_1@vitess.in"
  # check that the around-save function is called on updation
  rails runner 'User106.find(1).update!(:name => "name 2")'
  assert_mysql_output "select id, name from user106s" "1 name_2"
  # also check that the email got changed
  assert_mysql_output "select id, user106_id, email from email106s" "1 1 name_2@vitess.in"
}

# check_after_save checks the callback after_save
function check_after_save(){
  # create a user model
  rails generate model User107s name:string
  # also create a model for the emails
  rails generate model Email107s user107:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user107.rb" "class User107 < ApplicationRecord
  after_save :insert_email

  private
    def insert_email
      if email_row = Email107.where(:user107_id => id).first
        email_row.email = (name+'@vitess.in')
        email_row.save
      else
        Email107.create!(:user107_id => id, :email => (name+'@vitess.in'))
      end
  end"

  # check that the after-save function is called on creation
  rails runner 'User107.create!(:name => "name")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user107s" "1 name"
  assert_mysql_output "select id, user107_id, email from email107s" "1 1 name@vitess.in"
  # check that the after-save function is called on updation
  rails runner 'User107.find(1).update!(:name => "name2")'
  assert_mysql_output "select id, name from user107s" "1 name2"
  # also check that the email got changed
  assert_mysql_output "select id, user107_id, email from email107s" "1 1 name2@vitess.in"
}

# check_before_create checks the callback before_create
function check_before_create(){
  # create a user model
  rails generate model User108s name:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user108.rb" "class User108 < ApplicationRecord
    before_create :parameterize_name

    private
      def parameterize_name
        self.name = name.parameterize(separator: '_')
      end
  end"

  # check that the before-create function is called on creation
  rails runner 'User108.create!(:name => "name 1")'
  # check that the data is inserted into the table
  assert_mysql_output "select id, name from user108s" "1 name_1"
  # check that the before-create function is not called on updation
  rails runner 'User108.find(1).update!(:name => " name 2")'
  assert_mysql_output "select id, name from user108s" "1 name 2"
}

# check_around_create checks the callback around_create
function check_around_create(){
  # create a user model
  rails generate model User109s name:string
  # also create a model for the emails
  rails generate model Email109s user109:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user109.rb" "class User109 < ApplicationRecord
    around_create :parameterize_name_and_insert_email

    private
      def parameterize_name_and_insert_email
        self.name = name.parameterize(separator: '_')
        yield
        Email109.create!(:user109_id => id, :email => (name+'@vitess.in'))
      end
  end"

  # check that the around-create function is called on creation
  rails runner 'User109.create!(:name => "name 1")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user109s" "1 name_1"
  assert_mysql_output "select id, user109_id, email from email109s" "1 1 name_1@vitess.in"
  # check that the around-create function is not called on updation
  rails runner 'User109.find(1).update!(:name => "name 2")'
  assert_mysql_output "select id, name from user109s" "1 name 2"
  # also check that the email didn't get changed
  assert_mysql_output "select id, user109_id, email from email109s" "1 1 name_1@vitess.in"
}

# check_after_create checks the callback after_create
function check_after_create(){
  # create a user model
  rails generate model User110s name:string
  # also create a model for the emails
  rails generate model Email110s user110:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user110.rb" "class User110 < ApplicationRecord
    after_create :insert_email

    private
      def insert_email
        Email110.create!(:user110_id => id, :email => (name+'@vitess.in'))
      end
  end"

  # check that the after_create function is called on creation
  rails runner 'User110.create!(:name => "name")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user110s" "1 name"
  assert_mysql_output "select id, user110_id, email from email110s" "1 1 name@vitess.in"
  # check that the around-create function is not called on updation
  rails runner 'User110.find(1).update!(:name => "name2")'
  assert_mysql_output "select id, name from user110s" "1 name2"
  # also check that the email didn't get changed
  assert_mysql_output "select id, user110_id, email from email110s" "1 1 name@vitess.in"
}

# 3.4 after_initialize and after_find
# check_after_initialize_and_after_find checks the callbacks after_initialize and after_find
function check_after_initialize_and_after_find(){
  # create a user model
  rails generate model User111s name:string
  # run the migration
  rake_migrate
  # implement the callback methods
  write_to_file "app/models/user111.rb" "class User111 < ApplicationRecord
    after_initialize do |user|
      puts \"You have initialized an object!\"
    end

    after_find do |user|
      puts \"You have found an object!\"
    end
  end
  "
  new_output=$(rails runner 'User111.new')
  expected_output="You have initialized an object!"
  # assert that the output matches the expectation
  assert_matches "$new_output" "$expected_output"

  # insert a new user
  create_output=$(rails runner 'User111.create(:name => "RailsUser")')
  expected_output="You have initialized an object!"
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  first_output=$(rails runner 'User111.first')
  expected_output="You have found an object!\nYou have initialized an object!"
  # assert that the output matches the expectation
  assert_matches "$first_output" "$expected_output"
}

# 3.5 after_touch
# check_after_touch checks the callback after_touch
function check_after_touch(){
  # create a user model
  rails generate model User112s name:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user112.rb" "class User112 < ApplicationRecord
    after_touch do |user|
      puts \"You have touched an object\"
    end
  end"

  # insert a new user and touch it
  touch_output=$(rails runner 'u = User112.create(name: "Kuldeep"); u.touch')
  expected_output="You have touched an object"
  # assert that the output matches the expectation
  assert_matches "$touch_output" "$expected_output"
}

# check_after_touch_with_belongs_to checks that the callback after_touch works with the association belongs_to
function check_after_touch_with_belongs_to(){
  # create an employee and a company migration
  rails generate model Company1 name:string
  rails generate model Employee1 company1:references
  # run the migration
  rake_migrate
  # implement the callback methods
  write_to_file "app/models/employee1.rb" "class Employee1 < ApplicationRecord
    belongs_to :company1, touch: true
    after_touch do
      puts 'An Employee was touched'
    end
  end"
  write_to_file "app/models/company1.rb" "class Company1 < ApplicationRecord
    has_many :employee1s
    after_touch :log_when_employees_or_company_touched

    private
      def log_when_employees_or_company_touched
        puts 'Employee/Company was touched'
      end
  end"

  # insert a new company and a new employee
  rails runner 'Company1.create(:name => "Vitess")'
  rails runner 'Employee1.create(:company1_id => 1)'

  # find the output of touch
  touch_output=$(rails runner '@employee = Employee1.last; @employee.touch')
  expected_output="An Employee was touched\nEmployee/Company was touched"
  # assert that the output matches the expectation
  assert_matches "$touch_output" "$expected_output"
}

# Registers a callback to be called before a record is updated
function check_before_update(){
  # create a user model
  rails generate model User113s name:string
  # also create a model for the emails
  rails generate model Email113s user113:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user113.rb" "class User113 < ApplicationRecord
  before_update :insert_email

  private
    def insert_email
      Email113.create!(:user113_id => id, :email => (name+'@vitess.in'))
    end
  end"

  # check that the after_create function is called on creation
  rails runner 'User113.create!(:name => "name")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user113s" "1 name"
  assert_mysql_output "select id, user113_id, email from email113s" ""
  # check that the around-create function is not called on updation
  rails runner 'User113.find(1).update!(:name => "name2")'
  assert_mysql_output "select id, name from user113s" "1 name2"
  # also check that the email didn't get changed
  assert_mysql_output "select id, user113_id, email from email113s" "1 1 name2@vitess.in"
}

# Registers a callback to be called around the update of a record.
function check_around_update(){

  # create a user model
  rails generate model User114s name:string
  # also create a model for the emails
  rails generate model Email114s user114:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user114.rb" "class User114 < ApplicationRecord
  around_update :insert_email

  private
    def insert_email
      Email114.create!(:user114_id => id, :email => (name+'@vitess.in'))
    end
  end"

  # check that the after_create function is called on creation
  rails runner 'User114.create!(:name => "name")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user114s" "1 name"
  assert_mysql_output "select id, user114_id, email from email114s" ""
  # check that the around-create function is not called on updation
  rails runner 'User114.find(1).update!(:name => "name2")'
  assert_mysql_output "select id, name from user114s" "1 name"
  # also check that the email didn't get changed
  assert_mysql_output "select id, user114_id, email from email114s" "1 1 name2@vitess.in"

}

# Registers a callback to be called after a record is updated
function check_after_update(){

  # create a user model
  rails generate model User115s name:string
  # also create a model for the emails
  rails generate model Email115s user115:references email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user115.rb" "class User115 < ApplicationRecord
  after_update :insert_email

  private
    def insert_email
      Email115.create!(:user115_id => id, :email => (name+'@vitess.in'))
    end
  end"

  # check that the after_create function is called on creation
  rails runner 'User115.create!(:name => "name")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user115s" "1 name"
  assert_mysql_output "select id, user115_id, email from email115s" ""
  # check that the around-create function is not called on updation
  rails runner 'User115.find(1).update!(:name => "name2")'
  assert_mysql_output "select id, name from user115s" "1 name2"
  # also check that the email didn't get changed
  assert_mysql_output "select id, user115_id, email from email115s" "1 1 name2@vitess.in"

}

# Registers a callback to be called before a record is destroyed
function check_before_destroy(){

  # create a user model
  rails generate model User116s name:string
  # also create a model for the emails
  rails generate model Email116s email:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user116.rb" "class User116 < ApplicationRecord
  before_destroy :insert_email

  private
    def insert_email
      Email116.create!(:email => (name+'@vitess.in'))
    end
  end"

  # check that the after_create function is called on creation
  rails runner 'User116.create!(:name => "name")'
  rails runner 'User116.create!(:name => "name2")'
  # check that the data is inserted into the table and email is also added
  assert_mysql_output "select id, name from user116s" "1 name 2 name2"

  rails runner 'User116.find(1).destroy()'
  assert_mysql_output "select id, name from user116s" "2 name2"
  assert_mysql_output "select id, email from email116s" "1 name@vitess.in"
}

# 6. Halting Execution
# check_halting_execution checks that throw :abort works
function check_halting_execution(){
  # create a user model
  rails generate model User113s name:string
  # run the migration
  rake_migrate
  # implement the callback method
  write_to_file "app/models/user113.rb" "class User113 < ApplicationRecord
    after_create :throw_abort
    private
      def throw_abort
        throw :abort
      end
  end"

  # try to create a new user and assert that it fails
  if rails runner 'User113.create!(:name => "name")'; then
    echo "Command should have failed!"
    exit 1
  fi
  # check that the data is not inserted into the table
  assert_mysql_output "select id, name from user113s" ""
}

# 7. Relational Callbacks
# check_relational_callbacks checks that relational callbacks
function check_relational_callbacks(){
  # create a user model
  rails generate model User114s name:string
  # create an articles model
  rails generate model Article114s user114:references
  # run the migration
  rake_migrate
  # add the callbacks and the association
  write_to_file "app/models/user114.rb" "class User114 < ApplicationRecord
    has_many :article114s, dependent: :destroy
  end"
  write_to_file "app/models/article114.rb" "class Article114 < ApplicationRecord
    after_destroy :log_destroy_action
    def log_destroy_action
      puts 'Article destroyed'
    end
  end"

  # create a new user
  rails runner 'User114.create(:name => "railsTester")'
  # create a new article for this user
  rails runner 'user = User114.first; user.article114s.create!'
  # assert the data in the tables
  assert_mysql_output "select id, name from user114s" "1 railsTester"
  assert_mysql_output "select id, user114_id from article114s" "1 1"
  # delete the user
  destroy_output=$(rails runner 'user = User114.first; user.destroy')
  expected_output="Article destroyed"
  # assert the output is the same as the expectation
  assert_matches "$destroy_output" "$expected_output"
  # assert the data in the tables is deleted
  assert_mysql_output "select id, name from user114s" ""
  assert_mysql_output "select id, user114_id from article114s" ""
}

# 8. Conditional Callbacks
# 8.1 Using :if and :unless with a Symbol
# check_if_with_symbol checks that if statement in a callback works with a symbol
function check_if_with_symbol(){
  # create an order model
  rails generate model Order100s phoneNumber:string cardNumber:string
  # run the migration
  rake_migrate
  # add the callback function conditioned using if with a symbol
  write_to_file "app/models/order100.rb" "class Order100 < ApplicationRecord
    before_save :normalize_card_number, if: :paid_with_card?
    private
      def paid_with_card?
        return !cardNumber.nil?
      end
      def normalize_card_number
        puts \"Normalize Card Number called\"
        self.cardNumber = cardNumber.parameterize(separator: '-')
      end
  end"

  # insert a new order with only phone number
  create_output=$(rails runner 'Order100.create!(:phoneNumber => "9999999999")')
  expected_output=""
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  # insert a new order with card number
  create_output=$(rails runner 'Order100.create!(:cardNumber => "9999 9999 9999 9999")')
  expected_output="Normalize Card Number called"
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  # check that the tables have the data
  assert_mysql_output "select id, cardNumber, phoneNumber from order100s" "1 NULL 9999999999 2 9999-9999-9999-9999 NULL"
}

# 8.2 Using :if and :unless with a Proc
# check_if_with_proc_v1 checks that if statement in a callback works with a proc - version 1
function check_if_with_proc_v1(){
  # create an order model
  rails generate model Order101s phoneNumber:string cardNumber:string
  # run the migration
  rake_migrate
  # add the callback function conditioned using if with a symbol
  write_to_file "app/models/order101.rb" "class Order101 < ApplicationRecord
    before_save :normalize_card_number,
      if: Proc.new { |order| order.paid_with_card? }

    def paid_with_card?
      return !cardNumber.nil?
    end

    private
      def normalize_card_number
        puts \"Normalize Card Number called\"
        self.cardNumber = cardNumber.parameterize(separator: '-')
      end
  end"

  # insert a new order with only phone number
  create_output=$(rails runner 'Order101.create!(:phoneNumber => "9999999999")')
  expected_output=""
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  # insert a new order with card number
  create_output=$(rails runner 'Order101.create!(:cardNumber => "9999 9999 9999 9999")')
  expected_output="Normalize Card Number called"
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  # check that the tables have the data
  assert_mysql_output "select id, cardNumber, phoneNumber from order101s" "1 NULL 9999999999 2 9999-9999-9999-9999 NULL"
}

# check_if_with_proc_v2 checks that if statement in a callback works with a proc - version 2
function check_if_with_proc_v2(){
  # create an order model
  rails generate model Order102s phoneNumber:string cardNumber:string
  # run the migration
  rake_migrate
  # add the callback function conditioned using if with a symbol
  write_to_file "app/models/order102.rb" "class Order102 < ApplicationRecord
    before_save :normalize_card_number, if: Proc.new { paid_with_card? }

    def paid_with_card?
      return !cardNumber.nil?
    end

    private
      def normalize_card_number
        puts \"Normalize Card Number called\"
        self.cardNumber = cardNumber.parameterize(separator: '-')
      end
  end"

  # insert a new order with only phone number
  create_output=$(rails runner 'Order102.create!(:phoneNumber => "9999999999")')
  expected_output=""
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  # insert a new order with card number
  create_output=$(rails runner 'Order102.create!(:cardNumber => "9999 9999 9999 9999")')
  expected_output="Normalize Card Number called"
  # assert that the output matches the expectation
  assert_matches "$create_output" "$expected_output"

  # check that the tables have the data
  assert_mysql_output "select id, cardNumber, phoneNumber from order102s" "1 NULL 9999999999 2 9999-9999-9999-9999 NULL"
}

# setup_mysql_attributes will setup the mysql attributes
setup_mysql_attributes

# 1. The Object Life Cycle
# https://guides.rubyonrails.org/active_record_callbacks.html#the-object-life-cycle
# NOTE - There are no new commands to test in this part.

# 2. Callbacks Overview
# https://guides.rubyonrails.org/active_record_callbacks.html#callbacks-overview
# 2.1 Callback Registration
# https://guides.rubyonrails.org/active_record_callbacks.html#callback-registration
check_ensure_login_has_a_value
check_name_login_capitalization
check_normalize_name_and_set_location

# 3. Available Callbacks
# https://guides.rubyonrails.org/active_record_callbacks.html#available-callbacks
check_before_validation
check_after_validation
check_before_save
check_around_save
check_after_save
check_before_create
check_around_create
check_after_create
check_before_update
check_around_update
check_after_update
check_before_destroy
# 3.4 after_initialize and after_find
# https://guides.rubyonrails.org/active_record_callbacks.html#after-initialize-and-after-find
check_after_initialize_and_after_find
# 3.5 after_touch
# https://guides.rubyonrails.org/active_record_callbacks.html#after-touch
check_after_touch
check_after_touch_with_belongs_to

# 4. Running Callbacks
# https://guides.rubyonrails.org/active_record_callbacks.html#running-callbacks
# NOTE - There are no new commands to test in this part.

# 5. Skipping Callbacks
# https://guides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks
# NOTE - There are no new commands to test in this part.

# 6. Halting Execution
# https://guides.rubyonrails.org/active_record_callbacks.html#halting-execution
check_halting_execution

# 7. Relational Callbacks
# https://guides.rubyonrails.org/active_record_callbacks.html#relational-callbacks
check_relational_callbacks

# 8. Conditional Callbacks
# https://guides.rubyonrails.org/active_record_callbacks.html#conditional-callbacks
# 8.1 Using :if and :unless with a Symbol
# https://guides.rubyonrails.org/active_record_callbacks.html#using-if-and-unless-with-a-symbol
check_if_with_symbol
# 8.2 Using :if and :unless with a Proc
check_if_with_proc_v1
check_if_with_proc_v2
