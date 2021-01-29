'''
Functions:
  - command_with_ouput(<cmd>): run bash commands and return their outputs
  - command(<cmd>): Check if bash commands ran succesfully
  - rake_migrate(<version>): rake_migrate runs the db:migrate command from rake. It also adds the VERSION argument if it is passed
  - rails_generate_model(<model_name>): rails_generate_model  is used to generate a model file with the given name
  - rails_generate_migration(<migration_name>): rails_generate_migration  is used to generate a migration file with the given name and return its name
  - rails_command_with_timestamp(<command>): rails_command_with_timestamp  is used to run a rails command and return its timestamp
  - revert_to_timestamp(<revert_timestamp>): revert_to_timestamp reverts the state of database to the given timestamp and it also deletes all the migration files after that timestamp
  - revert_before_timestamp(<revert_timestamp>): revert_before_timestamp reverts the state of database to before the given timestamp and it also deletes all the migration files equal to or after that timestamp
  - get_timestamp_from_filename(<filename>): get_timestamp_from_filename gives the timestamp from the filename
  - write_to_file(<fileName>, <textToWrite>): write_to_file writes to a file
  - assert_select_ouput(<query>,<expected_output>): assert_select_output asserts that the output of the given query is exactly the same as the expected output, if not then it exits

  Functions implemented by @GuptaManan10 (Manan Gupta)
'''

import os
import sys
import shlex
import subprocess
import re

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

# assert_select_output asserts that the output of the given query is exactly the same as the expected output, if not then it exits
# (Could be redundant in future implementation)
def assert_select_ouput(query,expected_output):
    rows = select_mysql(query)
    if rows != expected_output:
        sys.exit("For Query("+query+"), expected output:"+str(expected_output)+" but got:"+str(rows))
