#!/bin/sh

# rake_migrate runs the db:migrate command from rake. It also adds the VERSION argument if it is supplied
function rake_migrate(){
   # $1 version ot rake
   if [ -z "$1" ]
   then
     rails db:migrate
   else
     rails db:migrate VERSION="$1"
   fi
}

# rails_generate_migration  is used to generate a migration file with the given name and return its name
function rails_generate_migration(){
   #$1 migration_name

  rails_output=$(rails generate migration "$1")

  file_name=$(echo "$rails_output" | grep -o "db/migrate.*")

  if [ -z "$file_name" ]
  then
    echo "Migration failed"
    exit
  fi

  echo $file_name

}

# write_to_file writes to a file
function write_to_file(){
  #$1 fileName
  #$2 content to write
  echo "$2" > $1
}

function mysql_run(){
  #$1 Query to execute
  query_output=$(mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -rsNe "$1")

  echo $query_output

}

function assert_mysql_output(){
  #$1 Query to execute
  #$2 outputs

  query_output=$(mysql_run "$1")

   if [[ "$query_output" != "$2" ]]
   then
    echo "Query: $1 got wrong output \nExpected: $2 \nGot: $query_output"
    exit
   fi
}

assert_mysql_output "show databases" "information_schema mysql sys performance_schema commerce"
