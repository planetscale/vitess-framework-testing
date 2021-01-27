import os
import sys
import shlex
import subprocess
import re
import mysql.connector
from mysql.connector import Error

# Rails Guide on Active Records
# https://guides.rubyonrails.org/active_record_migrations.html

# commamd is used to run bash commands and check that they succeeded
def command(cmd):
    sp = subprocess.run(shlex.split(cmd))
    if sp.returncode != 0 :
        sys.exit(sp.returncode)

# commamd_with_ouput is used to run bash commands and return their outputs
def command_with_ouput(cmd):
    sp = subprocess.run(shlex.split(cmd), capture_output=True, text = True)
    if sp.returncode != 0:
        print(sp.stderr)
        sys.exit(sp.returncode)
    return sp.stdout

# rake_migrate runs the db:migrate command from rake. It also adds the VERSION argument if it is passed
def rake_migrate(version=""):
    if version == "":
        command("rails db:migrate")
    else:
        command("rails db:migrate VERSION="+version)

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
    write_to_file(filename,"""class CreateProduct1s < ActiveRecord::Migration[6.1]
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
    write_to_file(filename,"""class ChangeProduct1sPrice < ActiveRecord::Migration[6.1]
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
    command("rails generate migration CreateProduct"+id+"s name:string")
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
    # insert into the table a row
    dml_mysql("insert into product5s(name,part_number,created_at,updated_at) values ('Single Migration for adding table','2.1',NOW(),NOW())")
    # read from the table and assert that the output matches the expected output
    assert_select_ouput("select id,name,part_number from product5s",[(1,'Single Migration for adding table','2.1')])

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

# check_migration_from_model checks the migration constructed from the model
def check_migration_from_model():
    # create the model
    command("rails generate model Product7 name:string description:text")
    rake_migrate()
    # insert into the table a row
    dml_mysql("insert into product7s(name,description,created_at,updated_at) values ('RGT','Rails Guide Testing Model Generators',NOW(),NOW())")
    # read from the table and assert that the output matches the expected output
    assert_select_ouput("select id,name,description from product7s",[(1, 'RGT', 'Rails Guide Testing Model Generators')])

# check_passing_modifiers checks that passing modifiers to rails generate migration commands work
def check_passing_modifiers():
    # create a table first
    create_new_product_table('8')
    # create a migration while passing modifiers
    command("rails generate migration AddDetailsToProduct8s 'price:decimal{5,2}' supplier:references{polymorphic}")
    rake_migrate()
    # assert the tables description
    assert_select_ouput("describe product8s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('price', 'decimal(5,2)', 'YES', '', None, ''), ('supplier_type', 'varchar(255)', 'NO', 'MUL', None, ''), ('supplier_id', 'bigint(20)', 'NO', '', None, '')])

# check_migrate_to_version checks that rake db:migrate command works with VARIABLE as a given argument
def check_migrate_to_version():
    command("rails generate migration CreateProduct9s name:string")
    timestamp2 = rails_command_with_timestamp("rails generate migration AddPartNumberToProduct9s part_number:int")
    command("rails generate migration AddDescriptionToProduct9s description:string")
    command("rails generate migration RemovePartNumberFromProduct9s part_number:int")
    rake_migrate()
    # assert the table structure after the 4 commands
    assert_select_ouput("describe product9s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('description', 'varchar(255)', 'YES', '', None, '')])
    # migrate to a previous version
    rake_migrate(timestamp2)
    # assert that the structure of table is the way we want -> part_number is added back and description is removed
    assert_select_ouput("describe product9s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('part_number', 'int(11)', 'YES', '', None, '')])

# check_rollback_and_redo checks that the rollback and redo commands work
def check_rollback_and_redo():
    command("rails generate migration CreateProduct10s name:string")
    command("rails generate migration AddPartNumberToProduct10s part_number:int")
    command("rails generate migration AddDescriptionToProduct10s description:string")
    command("rails generate migration RemovePartNumberFromProduct10s part_number:int")
    rake_migrate()
    # assert the table structure after the 4 commands
    assert_select_ouput("describe product10s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('description', 'varchar(255)', 'YES', '', None, '')])
    # migrate to a step back
    command("rails db:rollback")
    # assert that the structure of table is the way we want -> part_number is added back
    assert_select_ouput("describe product10s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('description', 'varchar(255)', 'YES', '', None, ''), ('part_number', 'int(11)', 'YES', '', None, '')])
    rake_migrate()
    # migrate to 3 steps back
    command("rails db:rollback STEP=3")
    # assert that the structure of table is the way we want -> part_number and description are removed
    assert_select_ouput("describe product10s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, '')])
    rake_migrate()
    # redo 3 steps
    command("rails db:migrate:redo STEP=3")
    # assert that the structure of table is the way we want that is after all migrations
    assert_select_ouput("describe product10s",[('id', 'bigint(20)', 'NO', 'PRI', None, 'auto_increment'), ('name', 'varchar(255)', 'YES', '', None, ''), ('created_at', 'datetime(6)', 'NO', '', None, ''), ('updated_at', 'datetime(6)', 'NO', '', None, ''), ('description', 'varchar(255)', 'YES', '', None, '')])
    
# check_setup_database checks the rails db:setup command
def check_setup_database():
    # dump the schema so that the schema.rb file used in db:setup is upto date.
    command("rake db:schema:dump")
    # check that the command succeeds though it would not do anything
    command("rails db:setup")

# check_reset_database checks the rails db:reset command
def check_reset_database():
    # dump the schema so that the schema.rb file used in db:setup is upto date.
    command("rake db:schema:dump")
    # reset the database
    command("rails db:reset")
    # assert that all the tables were reconstructed
    assert_select_ouput("show tables",[('active_storage_attachments',), ('active_storage_blobs',), ('ar_internal_metadata',), ('customers_products',), ('microposts',), ('product10s',), ('product1s',), ('product2s',), ('product3s',), ('product4s',), ('product5s',), ('product6s',), ('product7s',), ('product8s',), ('product9s',), ('relationships',), ('schema_migrations',), ('users',)])

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
check_migration_from_model()
# 2.3 Passing Modifiers
# https://guides.rubyonrails.org/active_record_migrations.html#passing-modifiers
check_passing_modifiers()

# 4. Running Migrations
# https://guides.rubyonrails.org/active_record_migrations.html#running-migrations
check_migrate_to_version()
# 4.1 Rolling Back
# https://guides.rubyonrails.org/active_record_migrations.html#rolling-back
check_rollback_and_redo()
# 4.2 Setup the Database
# https://guides.rubyonrails.org/active_record_migrations.html#setup-the-database
check_setup_database()
# 4.3 Resetting the Database
# https://guides.rubyonrails.org/active_record_migrations.html#resetting-the-database
check_reset_database()
