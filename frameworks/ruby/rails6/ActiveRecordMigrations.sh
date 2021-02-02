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
  assert_mysql_output "describe product1s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL description text YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL price varchar(255) YES NULL"
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
  assert_mysql_output "describe product2s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
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
  assert_mysql_output "describe product3s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL part_number varchar(255) YES MUL NULL"
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
  assert_mysql_output "describe customers_products" "customer_id $BIGINT NO NULL product_id $BIGINT NO NULL"
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
  assert_mysql_output "describe product8s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL price decimal(5,2) YES NULL supplier_type varchar(255) NO MUL NULL supplier_id $BIGINT NO NULL"
}

# ------------------------ Task 3 -------------------------------

# 3.1 create tables
# check_create_table checks that the create table construct works
function check_create_table(){
  rails_generate_migration_with_content "CreateTable" "class CreateTable < ActiveRecord::Migration[6.1]
    def change
       create_table :products101 do |t|
         t.string :name
       end
    end
  end"
  rake_migrate

  assert_mysql_output "describe products101" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL"
}

# check_create_table_option_blackhole checks that blackhole engine works with create table statement
function check_create_table_option_blackhole(){
  rails_generate_migration_with_content "CreateTableBlackhole" "class CreateTableBlackhole < ActiveRecord::Migration[6.1]
    def change
       create_table :products102, options: 'ENGINE=BLACKHOLE' do |t|
         t.string :name, null: false
       end
    end
  end"
  rake_migrate

  assert_mysql_output "describe products102" "id $BIGINT NO PRI NULL auto_increment name varchar(255) NO NULL"
}

# 3.2 creating a join table
# check_create_join_table checks that the create join table construct works
function check_create_join_table(){
  rails_generate_migration_with_content "CreateJoinTable" "class CreateJoinTable < ActiveRecord::Migration[6.1]
    def change
       create_join_table :products103, :categories103
    end
  end"
  rake_migrate

  assert_mysql_output "describe categories103_products103" "products103_id $BIGINT NO NULL categories103_id $BIGINT NO NULL"
}

# check_create_join_table_null_true checks that a column can have null values in join table construct
function check_create_join_table_null_true(){
  rails_generate_migration_with_content "CreateJoinTable1" "class CreateJoinTable1 < ActiveRecord::Migration[6.1]
    def change
        create_join_table :products104, :categories104, column_options: { null: true }
    end
  end"
  rake_migrate

  assert_mysql_output "describe categories104_products104" "products104_id $BIGINT YES NULL categories104_id $BIGINT YES NULL"
}

# check_create_join_table_and_name_categorization checks that the characterization works with join tables
function check_create_join_table_and_name_categorization(){
  rails_generate_migration_with_content "CreateJoinTable2" "class CreateJoinTable2 < ActiveRecord::Migration[6.1]
    def change
       create_join_table :products105, :categories105, table_name: :categorization
    end
  end"
  rake_migrate

  assert_mysql_output "describe categorization" "products105_id $BIGINT NO NULL categories105_id $BIGINT NO NULL"
}

# check_create_join_table_index checks that the indexes works with join tables
function check_create_join_table_index(){
  rails_generate_migration_with_content "CreateJoinTable3" "class CreateJoinTable3 < ActiveRecord::Migration[6.1]
    def change
       create_join_table :products106, :categories106 do |t|
          t.index :products106_id
          t.index :categories106_id
       end
    end
  end"
  rake_migrate

  assert_mysql_output "describe categories106_products106" "products106_id $BIGINT NO MUL NULL categories106_id $BIGINT NO MUL NULL"
}

# 3.3 Changing Tables
# check_change_table_products checks that the change table construct works
function check_change_table_products(){
  # Create table
  rails_generate_migration_with_content "CreateJoinTable4" "class CreateJoinTable4 < ActiveRecord::Migration[6.1]
    def change
      create_table :products_change do |t|
        t.string :name
        t.string :description
        t.string :upccode
      end
    end
  end"

  rake_migrate

  # Edit table products_change
  rails_generate_migration_with_content "CreateJoinTable5" "class CreateJoinTable5 < ActiveRecord::Migration[6.1]
    def change
      change_table :products_change do |t|
        t.remove :description, :name
        t.string :part_number
        t.index :part_number
        t.rename :upccode, :upc_code
      end
    end
  end"

  rake_migrate

  assert_mysql_output "describe products_change" "id $BIGINT NO PRI NULL auto_increment upc_code varchar(255) YES NULL part_number varchar(255) YES MUL NULL"
}

# 3.4 Changing Columns
# check_change_column checks that change_column works
function check_change_column(){
  # create a new table with name and part_number columns
  rails generate migration CreateProduct107s name:string part_number:integer
  # run the migration
  rake_migrate
  # assert that the table is created
  assert_mysql_output "describe product107s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL part_number $INT YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
  # generate a migration for changing the part_number to text
  rails_generate_migration_with_content "ChangeColumnPartNumberProduct107s" "class ChangeColumnPartNumberProduct107s < ActiveRecord::Migration[6.1]
    def change
      change_column :product107s, :part_number, :text
    end
  end"
  # run the migration
  rake_migrate
  # assert that the tables structure has changed
  assert_mysql_output "describe product107s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL part_number text YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
}

# check_change_column_null_default checks that change_column_null and change_column_default works
function check_change_column_null_default(){
  # create a new table with name and approved columns
  rails generate migration CreateProduct108s name:string approved:boolean
  # run the migration
  rake_migrate
  # assert that the table is created
  assert_mysql_output "describe product108s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL approved $TINYINT YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
  # generate a migration for changing the columns
  rails_generate_migration_with_content "ChangeColumnsProduct108s" "class ChangeColumnsProduct108s < ActiveRecord::Migration[6.1]
    def change
      change_column_null :product108s, :name, false
      change_column_default :product108s, :approved, from: true, to: false
    end
  end"
  # run the migration
  rake_migrate
  # assert that the tables structure has changed
  assert_mysql_output "describe product108s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) NO NULL approved $TINYINT YES 0 created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
}
# ---------------------------------------------------------------

# check_migrate_to_version checks that rake db:migrate command works with VARIABLE as a given argument
function check_migrate_to_version(){
  rails generate migration CreateProduct9s name:string
  timestamp2=$(rails_command_with_timestamp "rails generate migration AddPartNumberToProduct9s part_number:int")
  rails generate migration AddDescriptionToProduct9s description:string
  rails generate migration RemovePartNumberFromProduct9s part_number:int
  rake_migrate
  # assert the table structure after the 4 commands
  assert_mysql_output "describe product9s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
  # migrate to a previous version
  rake_migrate $timestamp2
  # assert that the structure of table is the way we want -> part_number is added back and description is removed
  assert_mysql_output "describe product9s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL part_number $INT YES NULL"
}

# check_rollback_and_redo checks that the rollback and redo commands work
function check_rollback_and_redo(){
  rails generate migration CreateProduct10s name:string
  rails generate migration AddPartNumberToProduct10s part_number:int
  rails generate migration AddDescriptionToProduct10s description:string
  rails generate migration RemovePartNumberFromProduct10s part_number:int
  rake_migrate
  # assert the table structure after the 4 commands
  assert_mysql_output "describe product10s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
  # migrate to a step back
  rails db:rollback
  # assert that the structure of table is the way we want -> part_number is added back
  assert_mysql_output "describe product10s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL part_number $INT YES NULL"
  rake_migrate
  # migrate to 3 steps back
  rails db:rollback STEP=3
  # assert that the structure of table is the way we want -> part_number and description are removed
  assert_mysql_output "describe product10s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL"
  rake_migrate
  # redo 3 steps
  rails db:migrate:redo STEP=3
  # assert that the structure of table is the way we want that is after all migrations
  assert_mysql_output "describe product10s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
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
  assert_mysql_output "describe product11s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL description varchar(255) YES NULL"
  # migrate to a previous version
  rails db:rollback STEP=3
  # run the up migration from the given timestamp
  rails db:migrate:up VERSION=$timestamp 
  # assert that the structure of table is the way we want -> part_number is added back and description is removed
  assert_mysql_output "describe product11s" "id $BIGINT NO PRI NULL auto_increment name varchar(255) YES NULL created_at datetime(6) NO NULL updated_at datetime(6) NO NULL part_number $INT YES NULL"
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

# check_schema_dump checks the mysql and rails schema dumps
function check_schema_dump(){
  create_new_product_table "13"
  # check if schema dump works. We do not need to check its output since it is not dependent on the database
  rake db:schema:dump
  # sqldump is a new task defined in the file /lib/tasks/my_task.rake.
  rake db:sqldump
  # find the structure of product13s table in the structure.sql file
  structure_output=$(grep -A 6 -oF "CREATE TABLE \`product13s\` (" ./db/structure.sql)
  create_definition="CREATE TABLE \`product13s\` (
  \`id\` $BIGINT NOT NULL AUTO_INCREMENT,
  \`name\` varchar(255) DEFAULT NULL,
  \`created_at\` datetime(6) NOT NULL,
  \`updated_at\` datetime(6) NOT NULL,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=$DEFAULT_CHARSET;"
  # check if the create table statement for product13s matches the expectation or not
  if [[ "$structure_output" != "$create_definition" ]]
  then
    echo -e "The structure of product13s table does not match the expectation.\nExpectation: $create_definition\nGot:$structure_output"
    exit 1
  fi
}

# check_add_data_via_migration checks that we can add data via a migration
function check_add_data_via_migration(){
  # create the model
  rails generate model Product14 name:string description:text
  # Create a migration that adds data to the table
  rails_generate_migration_with_content "AddInitialProduct14s" "class AddInitialProduct14s < ActiveRecord::Migration[6.1]
  def up
    5.times do |i|
      Product14.create(name: \"Product ##{i}\", description: \"A product.\")
    end
  end

  def down
    Product14.delete_all
  end
end"
  # run the migration
  rake_migrate
  # assert that the data is inserted into the table
  assert_mysql_output "select id, name, description from product14s" "1 Product #0 A product. 2 Product #1 A product. 3 Product #2 A product. 4 Product #3 A product. 5 Product #4 A product."
}

# check_migration_status checks that the migration status command works
function check_migration_status(){
  rails db:migrate:status
}

# setup_mysql_attributes will setup the mysql attributes
setup_mysql_attributes

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

# 3 Writing a Migration
# https://guides.rubyonrails.org/active_record_migrations.html#writing-a-migration
# 3.1 Create a Table
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-table
check_create_table
# create table with option blackhole and null set to false
check_create_table_option_blackhole
# 3.2 Creating a Join Table
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-join-table
check_create_join_table
check_create_join_table_null_true
check_create_join_table_and_name_categorization
check_create_join_table_index
# 3.3 Changing Tables
# https://guides.rubyonrails.org/active_record_migrations.html#changing-tables
check_change_table_products
# 3.4 Changing Columns
# https://guides.rubyonrails.org/active_record_migrations.html#changing-columns
check_change_column
check_change_column_null_default

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

# 5. Changing Existing Migrations
# https://guides.rubyonrails.org/active_record_migrations.html#changing-existing-migrations
# NOTE - There are no new commands to test in this part.

# 6. Schema Dumping and You
# https://guides.rubyonrails.org/active_record_migrations.html#schema-dumping-and-you
# 6.1 What are Schema Files for?
# https://guides.rubyonrails.org/active_record_migrations.html#what-are-schema-files-for-questionmark
# NOTE - There are no new commands to test in this part.
# 6.2 Types of Schema Dumps
# https://guides.rubyonrails.org/active_record_migrations.html#types-of-schema-dumps
check_schema_dump
# 6.3 Schema Dumps and Source Control
# https://guides.rubyonrails.org/active_record_migrations.html#schema-dumps-and-source-control
# NOTE - There are no new commands to test in this part.

# 7. Active Record and Referential Integrity
# https://guides.rubyonrails.org/active_record_migrations.html#active-record-and-referential-integrity
# NOTE - There are no new commands to test in this part.

# 8. Migrations and Seed Data
# https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data
check_add_data_via_migration
# check of db:seed has already be done as part of the tests of the base application

# 9. Old Migrations
# https://guides.rubyonrails.org/active_record_migrations.html#old-migrations
check_migration_status
