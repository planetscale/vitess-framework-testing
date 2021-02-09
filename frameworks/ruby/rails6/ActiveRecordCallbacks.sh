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