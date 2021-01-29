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
  migration_file_name="CreateProduct($id)s"
  rails generate migration $migration_file_name name:string
  rake_migrate
}


# 1. Migration Overview
# https://guides.rubyonrails.org/active_record_migrations.html#migration-overview
check_create_products_migration
check_change_product_price_type

# 2. Creating a Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-migration
# 2.1 Creating a Standalone Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration
