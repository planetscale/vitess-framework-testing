# Rails Guide on Active Records
# https://guides.rubyonrails.org/active_record_migrations.html

source helper.sh

# check_create_products_migration checks that the create product migration works correctly
function check_create_products_migration(){
  # create the migration file and write the content
  rails_generate_migration_with_content "CreateProduct1s" "class CreateProduct1s < ActiveRecord::Migration[6.1]
  def change
      create_table :product1s do |t|
          t.string :name
          t.text :description

          t.timestamps
      end
  end
end"
  rake_migrate
  # insert into the table a row
  mysql_run "insert into product1s(name,description,created_at,updated_at) values ('RGT','Rails Guide Testing Migration Overview',NOW(),NOW())"
  # read from the table and assert that the output matches the expected output
  assert_mysql_output "select id,name,description from product1s" "1 RGT Rails Guide Testing Migration Overview"
}

# check_create_products_migration checks that the changing price type migration works correctly
function check_change_product_price_type(){
  # Implicit in the guide - creating a price column with integer type
  rails generate migration add_price_to_product1 price:integer
  rake_migrate
  # update one row and set prices to 100
  mysql_run "update product1s set price = 100 where id = 1"
  # assert the output, more specifically the price is an integer
  assert_mysql_output "select id,name,description,price from product1s" "1 RGT Rails Guide Testing Migration Overview 100"
  # Change Product Size
  rails_generate_migration_with_content "ChangeProduct1sPrice" "class ChangeProduct1sPrice < ActiveRecord::Migration[6.1]
    def change
      reversible do |dir|
        change_table :product1s do |t|
          dir.up   { t.change :price, :string }
          dir.down { t.change :price, :integer }
        end
      end
    end
  end"
  rake_migrate
  # assert that the price is now a string
  assert_mysql_output "describe product1s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL description text YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL price varchar(255) YES NULL"
}

# create_new_product_table is used to create a new product table with the given id
function create_new_product_table() {
  # $1 is the id to use for the table name
  # create the migration file
  migration_file_name="CreateProduct$1s"
  rails generate migration $migration_file_name name:string
  rake_migrate
}

# check_add_and_remove_partnumber_to_products checks the addition and deletion of a column part_number
function check_add_and_remove_partnumber_to_products(){
  # create a table first
  create_new_product_table "2"
  # add a new column part_number
  rails generate migration AddPartNumberToProduct2s part_number:string
  rake_migrate
  # insert into the table a row
  mysql_run "insert into product2s(name,part_number,created_at,updated_at) values ('Rails Guide','2.1',NOW(),NOW())"
  # read from the table and assert that the output matches the expected output
  assert_mysql_output "select id,name,part_number from product2s" "1 Rails Guide 2.1"
  # remove the column now
  rails generate migration RemovePartNumberFromProduct2s part_number:string
  rake_migrate
  # verify that the column is indeed dropped
  assert_mysql_output "describe product2s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
  # verify that the row is still available
  assert_mysql_output "select id,name from product2s" "1 Rails Guide"
}

# check_add_partnumber_and_index_to_products checks the addition of a column part_number along with the index
function check_add_partnumber_and_index_to_products(){
  # create a table first
  create_new_product_table "3"
  # add a new column part_number
  rails generate migration AddPartNumberToProduct3s part_number:string:index
  rake_migrate
  # verify that their is a index on the part_number column.
  assert_mysql_output "describe product3s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL part_number varchar(255) YES MUL NULL"
}

# check_add_multiple_columns_to_products checks the addition of multiple columns
function check_add_multiple_columns_to_products(){
  # create a table first
  create_new_product_table "4"
  # add two new columns part_number and price
  rails generate migration AddDetailsToProduct4s part_number:string price:decimal
  rake_migrate
  # insert into the table a row
  mysql_run "insert into product4s(name,part_number,price,created_at,updated_at) values ('Add Multiple Columns','2.1','100.0',NOW(),NOW())"
  # read from the table and assert that the output matches the expected output
  assert_mysql_output "select id,name,part_number,price from product4s" "1 Add Multiple Columns 2.1 100"
}

# check_add_products_table checks that the product table can be added via a single migration
function check_add_products_table(){
  # Add the product table as a single migration
  rails generate migration CreateProduct5s name:string part_number:string
  rake_migrate
  # insert into the table a row
  mysql_run "insert into product5s(name,part_number,created_at,updated_at) values ('Single Migration for adding table','2.1',NOW(),NOW())"
  # read from the table and assert that the output matches the expected output
  assert_mysql_output "select id,name,part_number from product5s" "1 Single Migration for adding table 2.1"
}

# check_add_reference_column checks that a column that is a reference can be added
function check_add_reference_column(){
  # create a table first"
  create_new_product_table "6"
  # add a new column with reference to user table which we already have because of the base app.
  rails generate migration AddUserRefToProduct6s user:references
  rake_migrate
  # assert the creation of the foreign key
  assert_mysql_output "SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM  information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_NAME IS NOT NULL AND TABLE_NAME='product6s';" "product6s user_id users id"
}

# check_join_table checks that a join table can be created
function check_join_table(){
  # create a join table.
  rails generate migration CreateJoinTableCustomerProduct customer product
  rake_migrate
  # assert the creation of the join table
  assert_mysql_output "describe customers_products" "customer_id bigint(20) NO NULL product_id bigint(20) NO NULL"
}

# check_migration_from_model checks the migration constructed from the model
function check_migration_from_model(){
  # create the model
  rails generate model Product7 name:string description:text
  rake_migrate
  # insert into the table a row
  mysql_run "insert into product7s(name,description,created_at,updated_at) values ('RGT','Rails Guide Testing Model Generators',NOW(),NOW())"
  # read from the table and assert that the output matches the expected output
  assert_mysql_output "select id,name,description from product7s" "1 RGT Rails Guide Testing Model Generators"
}

# check_passing_modifiers checks that passing modifiers to rails generate migration commands work
function check_passing_modifiers(){
  # create a table first
  create_new_product_table "8"
  # create a migration while passing modifiers
  rails generate migration AddDetailsToProduct8s 'price:decimal{5,2}' supplier:references{polymorphic}
  rake_migrate
  # assert the tables description
  assert_mysql_output "describe product8s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL price decimal(5,2) YES NULL supplier_type varchar(255) NO MUL NULL supplier_id bigint(20) NO NULL"
}

# check_migrate_to_version checks that rake db:migrate command works with VARIABLE as a given argument
function check_migrate_to_version(){
  rails generate migration CreateProduct9s name:string
  timestamp2=$(rails_command_with_timestamp "rails generate migration AddPartNumberToProduct9s part_number:int")
  rails generate migration AddDescriptionToProduct9s description:string
  rails generate migration RemovePartNumberFromProduct9s part_number:int
  rake_migrate
  # assert the table structure after the 4 commands
  assert_mysql_output "describe product9s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
  # migrate to a previous version
  rake_migrate $timestamp2
  # assert that the structure of table is the way we want -> part_number is added back and description is removed
  assert_mysql_output "describe product9s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL part_number int(11) YES NULL"
}

# check_rollback_and_redo checks that the rollback and redo commands work
function check_rollback_and_redo(){
  rails generate migration CreateProduct10s name:string
  rails generate migration AddPartNumberToProduct10s part_number:int
  rails generate migration AddDescriptionToProduct10s description:string
  rails generate migration RemovePartNumberFromProduct10s part_number:int
  rake_migrate
  # assert the table structure after the 4 commands
  assert_mysql_output "describe product10s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
  # migrate to a step back
  rails db:rollback
  # assert that the structure of table is the way we want -> part_number is added back
  assert_mysql_output "describe product10s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL part_number int(11) YES NULL"
  rake_migrate
  # migrate to 3 steps back
  rails db:rollback STEP=3
  # assert that the structure of table is the way we want -> part_number and description are removed
  assert_mysql_output "describe product10s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
  rake_migrate
  # redo 3 steps
  rails db:migrate:redo STEP=3
  # assert that the structure of table is the way we want that is after all migrations
  assert_mysql_output "describe product10s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
}

# check_setup_database checks the rails db:setup command
function check_setup_database(){
  # dump the schema so that the schema.rb file used in db:setup is upto date.
  rake db:schema:dump
  # check that the command succeeds though it would not do anything
  rails db:setup
}

# check_reset_database checks the rails db:reset command
function check_reset_database(){
  # dump the schema so that the schema.rb file used in db:setup is upto date.
  rake db:schema:dump
  # reset the database
  rails db:reset
  # assert that all the tables were reconstructed
  assert_mysql_output "show tables" "active_storage_attachments active_storage_blobs ar_internal_metadata customers_products microposts product10s product1s product2s product3s product4s product5s product6s product7s product8s product9s relationships schema_migrations users"
}

# check_run_specific_migrations checks the running of a specific migration given its timestamp
function check_run_specific_migrations(){
  rails generate migration CreateProduct11s name:string
  timestamp=$(rails_command_with_timestamp "rails generate migration AddPartNumberToProduct11s part_number:int")
  rails generate migration AddDescriptionToProduct11s description:string
  rails generate migration RemovePartNumberFromProduct11s part_number:int
  rake_migrate
  # assert the table structure after the 4 commands
  assert_mysql_output "describe product11s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
  # migrate to a previous version
  rails db:rollback STEP=3
  # run the up migration from the given timestamp
  rails db:migrate:up VERSION=$timestamp 
  # assert that the structure of table is the way we want -> part_number is added back and description is removed
  assert_mysql_output "describe product11s" "id bigint(20) NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL part_number int(11) YES NULL"
}

# check_run_migrations_different_environment checks running migrations for different environments
function check_run_migrations_different_environment(){
  # check that passing the environment variable works correctly
  rails db:migrate RAILS_ENV=production
}

# check_changing_output_migrations checks that changing the output of running migrations works
function check_changing_output_migrations(){
  # Create a migration along with commands to change the output
  rails_generate_migration_with_content "CreateProduct12s" "class CreateProduct12s < ActiveRecord::Migration[6.1]
    def change
    suppress_messages do
      create_table :product12s do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say \"Created a table\"

    suppress_messages {add_index :product12s, :name}
    say \"and an index!\", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end"
  # run the migration
  rake_migrate
  # Also check that there is no output when we call migration with false VERBOSE
  rails generate migration AddPriceToProduct12s price:int
  rails_output=$(rails db:migrate VERBOSE=false)
  if [ ! -z "$rails_output" ]
  then 
    echo "There should be no output when VERBOSE = false"
    exit 1
  fi
}

# 1. Migration Overview
# https://guides.rubyonrails.org/active_record_migrations.html#migration-overview
check_create_products_migration
check_change_product_price_type

# 2. Creating a Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-migration
# 2.1 Creating a Standalone Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration
check_add_and_remove_partnumber_to_products
check_add_partnumber_and_index_to_products
check_add_multiple_columns_to_products
check_add_products_table
check_add_reference_column
check_join_table
# 2.2 Model Generators
# https://guides.rubyonrails.org/active_record_migrations.html#model-generators
check_migration_from_model
# 2.3 Passing Modifiers
# https://guides.rubyonrails.org/active_record_migrations.html#passing-modifiers
check_passing_modifiers

# 4. Running Migrations
# https://guides.rubyonrails.org/active_record_migrations.html#running-migrations
check_migrate_to_version
# 4.1 Rolling Back
# https://guides.rubyonrails.org/active_record_migrations.html#rolling-back
check_rollback_and_redo
# 4.2 Setup the Database
# https://guides.rubyonrails.org/active_record_migrations.html#setup-the-database
check_setup_database
# 4.3 Resetting the Database
# https://guides.rubyonrails.org/active_record_migrations.html#resetting-the-database
# NOTE - Vitess does not support drop/create database commands as it requires changing the vschema
# rails db:reset will try to drop the database but that wont work with vitess and requires manual intervention
# therefore the next test is commented out.
# check_reset_database
# 4.4 Running Specific Migrations
# https://guides.rubyonrails.org/active_record_migrations.html#running-specific-migrations
check_run_specific_migrations
# 4.5 Running Migrations in Different Environments
# https://guides.rubyonrails.org/active_record_migrations.html#running-migrations-in-different-environments
check_run_migrations_different_environment
# 4.6 Changing the Output of Running Migrations
# https://guides.rubyonrails.org/active_record_migrations.html#changing-the-output-of-running-migrations
check_changing_output_migrations
