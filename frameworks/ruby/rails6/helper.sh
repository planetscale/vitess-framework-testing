#!/bin/sh

# rake_migrate runs the db:migrate command from rake. It also adds the VERSION argument if it is supplied
function rake_migrate(){
  # $1 version to rake
  if [ -z "$1" ]
  then
    rails db:migrate
  else
    rails db:migrate VERSION="$1"
  fi
}

# rails_generate_migration  is used to generate a migration file with the given name and return its name
function rails_generate_migration(){
  # $1 name of the migration to create
  rails_output=$(rails generate migration "$1")
  file_name=$(echo "$rails_output" | grep -o "db/migrate.*")
  if [ -z "$file_name" ]
  then
    echo "Couldn't find the filename when generating the migration"
    exit 1
  fi
  echo $file_name
}

# write_to_file writes to a file
function write_to_file(){
  # $1 file name
  # $2 content to write
  echo "$2" > $1
}

# rails_generate_migration_with_content  is used to generate a migration file with the given name and write into it the content provided
function rails_generate_migration_with_content(){
  # $1 file name
  # $2 content to write
  filename=$(rails_generate_migration $1)
  write_to_file $filename "$2"
}

# mysql_run is used to run a query in mysql and return its result
function mysql_run(){
  # $1 Query to execute
  query_output=$(mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -rsNe "$1")
  echo $query_output
}

# assert_mysql_output is used to assert that the output of the given query is exactly the same as the expected output, if not then it exits
function assert_mysql_output(){
  #$1 Query to execute
  #$2 outputs
  query_output=$(mysql_run "$1")
  if [[ "$query_output" != "$2" ]]
  then
    echo "Query: $1 got wrong output \nExpected: $2 \nGot: $query_output"
    exit 1
  fi
}
