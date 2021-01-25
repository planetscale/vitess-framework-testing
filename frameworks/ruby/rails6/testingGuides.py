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

# writeToFile writes to a file
def writeToFile(fileName, textToWrite):
    with open(fileName,"w") as f:
        f.write(textToWrite)

# Migration Overview
# https://guides.rubyonrails.org/active_record_migrations.html#migration-overview
command("rails generate model product name:string description:text")
rake_migrate()
# Implicit in the guide
command("rails generate migration add_price_to_product price:integer")
rake_migrate()
# Change Product Size
filename = rails_generate_migration("ChangeProductsPrice")
writeToFile(filename,"""class ChangeProductsPrice < ActiveRecord::Migration[6.0]
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

