import os
import sys
import subprocess
import re
import mysql.connector
from mysql.connector import Error

# Rails Guide on Active Records
# https://guides.rubyonrails.org/active_record_migrations.html

# commamd is used to run bash commands and check that they succeeded
def command(cmd):
    sp = subprocess.run(cmd.split(" "))
    if sp.returncode != 0 :
        sys.exit(sp.returncode)

# commamd_with_ouput is used to run bash commands and return their outputs
def command_with_ouput(cmd):
    sp = subprocess.run(cmd.split(" "), capture_output=True, text = True)
    
    if sp.returncode != 0:
        print(sp.stderr)
        sys.exit(sp.returncode)
    return sp.stdout

# rake_migrate runs the db:migrate command from rake
def rake_migrate():
    command("rake db:migrate")

# rails_generate_model  is used to generate a model file with the given name
def rails_generate_model(model_name):
    command("rails generate model "+model_name)

# rails_generate_migration  is used to generate a migration file with the given name and return its name
def rails_generate_migration(migration_name):
    railsOutput = command_with_ouput("rails generate migration "+migration_name)
    
    isPresent = re.search('(db/migrate/.*)',railsOutput)
    if isPresent:
        return isPresent.group(1)
    else:
        sys.exit("Did not find filename in rails output:"+railsOutput)

# rails_command_with_timestamp  is used to run a rails command and return its timestamp
def rails_command_with_timestamp(command):
    railsOutput = command_with_ouput(command)
    
    isPresent = re.search('db/migrate/([0-9]*)',railsOutput)
    if isPresent:
        return isPresent.group(1)
    else:
        sys.exit("Did not find filename in rails output:"+railsOutput)

# revert_to_timestamp reverts the state of database to the given timestamp and it also deletes all the migration files after that timestamp
def revert_to_timestamp(revert_timestamp):
    command("rake db:migrate VERSION="+revert_timestamp)
    ls_output = command_with_ouput("ls db/migrate")
    files = ls_output.split('\n')
    for filename in files:
        timestamp = get_timestamp_from_filename(filename)
        if timestamp == "" or timestamp <= revert_timestamp:
            continue
        command("rm db/migrate/"+filename)

# revert_before_timestamp reverts the state of database to before the given timestamp and it also deletes all the migration files equal to or after that timestamp
def revert_before_timestamp(revert_timestamp):
    command("rake db:migrate VERSION="+revert_timestamp)
    command("rake db:rollback")
    ls_output = command_with_ouput("ls db/migrate")
    files = ls_output.split('\n')
    for filename in files:
        timestamp = get_timestamp_from_filename(filename)
        if timestamp == "" or timestamp < revert_timestamp:
            continue
        command("rm db/migrate/"+filename)

# get_timestamp_from_filename gives the timestamp from the filename
def get_timestamp_from_filename(filename):
    if len(filename) < 14:
        return ""
    return filename[0:14]

# write_to_file writes to a file
def write_to_file(fileName, textToWrite):
    with open(fileName,"w") as f:
        f.write(textToWrite)

# connect_to_mysql is used to connect to mysql
def connect_to_mysql():
    try:
        conn = mysql.connector.connect( host=os.environ['VT_HOST'],
                                        database=os.environ['VT_DATABASE'],
                                        user=os.environ['VT_USERNAME'],
                                        password=os.environ['VT_PASSWORD'],
                                        port=os.environ['VT_PORT'])
        if conn.is_connected():
            return conn
    except Error as e:
        sys.exit(e)

# select_mysql is used to run a select statement in mysql and return its result
def select_mysql(query):
    try:
        conn = connect_to_mysql()
        cursor = conn.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()
        return rows
    except Error as e:
        sys.exit(e)
    finally:
        cursor.close()
        conn.close()

# dml_mysql is used to run a insert, delete or update statement in mysql
def dml_mysql(query):
    try:
        conn = connect_to_mysql()
        cursor = conn.cursor()
        cursor.execute(query)
        conn.commit()
    except Error as e:
        sys.exit(e)
    finally:
        cursor.close()
        conn.close()

# assert_select_output asserts that the output of the given query is exactly the same as the expected output, if not then it exits
def assert_select_ouput(query,expected_output):
    rows = select_mysql(query)
    if rows != expected_output:
        sys.exit("For Query("+query+"), expected output:"+str(expected_output)+" but got:"+str(rows))

# check_create_products_migration checks that the create product migration works correctly
def check_create_products_migration():
    # create the migration file
    filename = rails_generate_migration("CreateProduct1s")
    # update the migration file as in the guide
    write_to_file(filename,"""class CreateProduct1s < ActiveRecord::Migration[6.0]
    def change
        create_table :product1s do |t|
            t.string :name
            t.text :description

            t.timestamps
        end
    end
end""")
    rake_migrate()
    # insert into the table a row
    dml_mysql("insert into product1s(name,description,created_at,updated_at) values ('RGT','Rails Guide Testing Migration Overview',NOW(),NOW())")
    # read from the table and assert that the output matches the expected output
    assert_select_ouput("select id,name,description from product1s",[(1, 'RGT', 'Rails Guide Testing Migration Overview')])

# check_create_products_migration checks that the changing price type migration works correctly
def check_change_product_price_type():
    # Implicit in the guide - creating a price column with integer type
    command("rails generate migration add_price_to_product1 price:integer")
    rake_migrate()
    # update one row and set prices to 100
    dml_mysql("update product1s set price = 100 where id = 1")
    # assert the output, more specifically the price is an integer
    assert_select_ouput("select id,name,description,price from product1s",[(1, 'RGT', 'Rails Guide Testing Migration Overview',100)])
    # Change Product Size
    filename = rails_generate_migration("ChangeProduct1sPrice")
    write_to_file(filename,"""class ChangeProduct1sPrice < ActiveRecord::Migration[6.0]
      def change
        reversible do |dir|
          change_table :product1s do |t|
            dir.up   { t.change :price, :string }
            dir.down { t.change :price, :integer }
          end
        end
      end
    end""")
    rake_migrate()
    # assert that the price is now a string
    assert_select_ouput("select id,name,description,price from product1s",[(1, 'RGT', 'Rails Guide Testing Migration Overview','100')])

# create_new_product_table is used to create a new product table with the given id
def create_new_product_table(id):
    # create the migration file
    filename = rails_generate_migration("CreateProduct"+id+"s")
    write_to_file(filename,"class CreateProduct"+id+"""s < ActiveRecord::Migration[6.0]
    def change
        create_table :product"""+id+"""s do |t|
            t.string :name

            t.timestamps
        end
    end
end""")
    rake_migrate()

# check_add_and_remove_partnumber_to_products checks the addition and deletion of a column part_number
def check_add_and_remove_partnumber_to_products():
    # create a table first
    create_new_product_table('2')
    # add a new column part_number
    command("rails generate migration AddPartNumberToProduct2s part_number:string")
    rake_migrate()
    # insert into the table a row
    dml_mysql("insert into product2s(name,part_number,created_at,updated_at) values ('Rails Guide','2.1',NOW(),NOW())")
    # read from the table and assert that the output matches the expected output
    assert_select_ouput("select id,name,part_number from product2s",[(1, 'Rails Guide', '2.1')])
    # remove the column now
    command("rails generate migration RemovePartNumberFromProduct2s part_number:string")
    rake_migrate()
    # verify that the column is indeed dropped
    assert_select_ouput("describe product2s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, '')])
    # verify that the row is still available
    assert_select_ouput("select id,name from product2s",[(1, 'Rails Guide')])

# check_add_partnumber_and_index_to_products checks the addition of a column part_number along with the index
def check_add_partnumber_and_index_to_products():
    # create a table first
    create_new_product_table('3')
    # add a new column part_number
    command("rails generate migration AddPartNumberToProduct3s part_number:string:index")
    rake_migrate()
    # verify that their is a index on the part_number column.
    assert_select_ouput("describe product3s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('part_number', 'varchar(255)', 'YES', 'MUL', None, '')])

# check_add_multiple_columns_to_products checks the addition of multiple columns
def check_add_multiple_columns_to_products():
    # create a table first
    create_new_product_table('4')
    # add two new columns part_number and price
    command("rails generate migration AddDetailsToProduct4s part_number:string price:decimal")
    rake_migrate()
    # insert into the table a row
    dml_mysql("insert into product4s(name,part_number,price,created_at,updated_at) values ('Add Multiple Columns','2.1','100.0',NOW(),NOW())")
    # read from the table and assert that the output matches the expected output
    assert_select_ouput("select id,name,part_number,price from product4s",[(1, 'Add Multiple Columns', '2.1',100.0)])

# check_add_products_table checks that the product table can be added via a single migration
def check_add_products_table():
    # Add the product table as a single migration
    command("rails generate migration CreateProduct5s name:string part_number:string")
    rake_migrate()
    # NOTE - The generated file from the above command is different from what the docs specify in rails 6.0. 
    # The line 't.timestamps' is not generated leading to the columns created_at and updated_at not being created.
    # Please refer to https://github.com/rails/rails/issues/28706 for more information
    # The issue is fixed in rails 6.1 by https://github.com/rails/rails/pull/28707
    dml_mysql("insert into product5s(name,part_number) values ('Single Migration for adding table','2.1')")
    # read from the table and assert that the output matches the expected output
    assert_select_ouput("select * from product5s",[(1,'Single Migration for adding table','2.1')])

# check_add_reference_column checks that a column that is a reference can be added
def check_add_reference_column():
    # create a table first
    create_new_product_table('6')
    # add a new column with reference to user table which we already have because of the base app.
    command("rails generate migration AddUserRefToProduct6s user:references")
    rake_migrate()
    # assert the creation of the foreign key
    assert_select_ouput("SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM  information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_NAME IS NOT NULL AND TABLE_NAME='product6s';",[('product6s', 'user_id', 'users', 'id')])

# check_join_table checks that a join table can be created
def check_join_table():
    # create a join table.
    command("rails generate migration CreateJoinTableCustomerProduct customer product")
    rake_migrate()
    # assert the creation of the join table
    assert_select_ouput("describe customers_products",[('customer_id', 'bigint(20)', 'NO', '', None, ''), ('product_id', 'bigint(20)', 'NO', '', None, '')])

# 1. Migration Overview
# https://guides.rubyonrails.org/active_record_migrations.html#migration-overview
check_create_products_migration()
check_change_product_price_type()

# 2. Creating a Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-migration
# 2.1 Creating a Standalone Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration
check_add_and_remove_partnumber_to_products()
check_add_partnumber_and_index_to_products()
check_add_multiple_columns_to_products()
check_add_products_table()
check_add_reference_column()
check_join_table()
# 2.2 Model Generators
# https://guides.rubyonrails.org/active_record_migrations.html#model-generators
command("rails generate model Product name:string description:text")