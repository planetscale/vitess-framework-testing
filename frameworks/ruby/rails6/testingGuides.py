import os
import sys
import subprocess
import re

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

def revert_to_timestamp(revert_timestamp):
    command("rake db:migrate VERSION="+revert_timestamp)
    ls_output = command_with_ouput("ls db/migrate")
    files = ls_output.split('\n')
    for filename in files:
        timestamp = get_timestamp_from_filename(filename)
        if timestamp == "" or timestamp <= revert_timestamp:
            continue
        command("rm db/migrate/"+filename)

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

def get_timestamp_from_filename(filename):
    if len(filename) < 14:
        return ""
    return filename[0:14]

# write_to_file writes to a file
def write_to_file(fileName, textToWrite):
    with open(fileName,"w") as f:
        f.write(textToWrite)

# 1. Migration Overview
# https://guides.rubyonrails.org/active_record_migrations.html#migration-overview
initial_timestamp = rails_command_with_timestamp("rails generate migration CreateProducts name:string description:text")
rake_migrate()
# Implicit in the guide
command("rails generate migration add_price_to_product price:integer")
rake_migrate()
# Change Product Size
filename = rails_generate_migration("ChangeProductsPrice")
write_to_file(filename,"""class ChangeProductsPrice < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      change_table :products do |t|
        dir.up   { t.change :price, :string }
        dir.down { t.change :price, :integer }
      end
    end
  end
end""")
rake_migrate()

# 2. Creating a Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-migration
# 2.1 Creating a Standalone Migration
# https://guides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration
command("rails generate migration AddPartNumberToProducts part_number:string")
rake_migrate()
command("rails generate migration RemovePartNumberFromProducts part_number:string")
rake_migrate()
# Revert to initial timestamp to add a migration with the same filename as before
revert_to_timestamp(initial_timestamp)
command("rails generate migration AddPartNumberToProducts part_number:string:index")
rake_migrate()
# Revert to initial timestamp to add a column that we have already added
revert_to_timestamp(initial_timestamp)
rake_migrate()
command("rails generate migration AddDetailsToProducts part_number:string price:decimal")
rake_migrate()
# revert before the initial timestamp to remove the products table and create it again
revert_before_timestamp(initial_timestamp)
command("rails generate migration CreateProducts name:string part_number:string")
rake_migrate()
command("rails generate migration AddUserRefToProducts user:references")
rake_migrate()
command("rails generate migration CreateJoinTableCustomerProduct customer product")
rake_migrate()
