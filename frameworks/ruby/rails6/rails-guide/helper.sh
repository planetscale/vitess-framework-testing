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

# rails_command_with_timestamp  is used to run a rails command and return its timestamp
function rails_command_with_timestamp(){
  # $1 is the rails command to run
  rails_output=$($1)
  timestamp=$(echo "$rails_output" | grep -o "db/migrate/.*" | grep -oE '[0-9]+' | head -1)
  if [ -z "$timestamp" ]
  then
    echo "Couldn't find the timestamp when running the rails command"
    exit 1
  fi
  echo $timestamp
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
    echo -e "Query: $1 got wrong output \nExpected: $2 \nGot: $query_output"
    exit 1
  fi
}

# assert_matches is used to assert that the two strings match
function assert_matches(){
  # $1 is the actual output
  # $2 is the expected output
  if [[ "$(echo -e "$1")" != "$(echo -e "$2")" ]]
  then
    echo -e "Got wrong output \nExpected: $2 \nGot: $1"
    exit 1
  fi
}

# get_mysql_version gets the mysql version
function get_mysql_version(){
  version=$(mysql_run "SELECT @@version")
  echo "$version"
}

# setup_mysql_attributes sets up the mysql attributes like the default charactersets
function setup_mysql_attributes(){
  # get the default character set
  DEFAULT_CHARSET=$(mysql_run "SELECT default_character_set_name FROM information_schema.SCHEMATA WHERE schema_name = '${VT_DATABASE}';")

  # get the mysql version
  mysql_version=$(get_mysql_version)
  # Set the BIGINT variable so that while asserting the outputs of `DESCRIBE <table>` and `SHOW CREATE TABLE <table>` it can be used since mysql 5.7 and mysql 8.0 differ in this respect
  if echo "$mysql_version" | grep -o "8.0"
  then
    BIGINT="bigint"
    INT="int"
    TINYINT="tinyint(1)"
    SMALLINT="smallint"
  else
    BIGINT="bigint(20)"
    INT="int(11)"
    TINYINT="tinyint(1)"
    SMALLINT="smallint(6)"
  fi
}

# Add sequence table
function add_sequence_table(){
  # $1 is the name of the table
  if [ "$VT_NUM_SHARDS" -gt "1" ]; then
    mysql_run "create table unsharded.\`${1}_seq\`(id bigint, next_id bigint, cache bigint, primary key(id)) comment 'vitess_sequence'"
    mysql_run "insert into unsharded.\`${1}_seq\`(id, next_id, cache) values(0, 1, 3)"
    mysql_run "alter vschema add sequence unsharded.\`${1}_seq\`"
    mysql_run "alter vschema on test.\`${1}\` add auto_increment id using unsharded.\`${1}_seq\`"
  else
    echo "Running unsharded mode"
  fi
}

# Running for basic vindex and sequence addition
function add_sequence_and_vindex(){
  # $1 is the name of the table
  if [ "$VT_NUM_SHARDS" -gt "1" ]; then
    add_binary_md5_vindex "$1" "id"
    add_sequence_table "$1"
  else
    echo "Running unsharded mode"
  fi
}

# Adds a binary_md5 vindex for a given table
function add_binary_md5_vindex(){
  # $1 is the name of the table
  # $2 is the name of the column to use
  if [ "$VT_NUM_SHARDS" -gt "1" ]; then
    mysql_run "alter vschema on test.\`${1}\` add vindex \`binary_md5\`(${2}) using \`binary_md5\`;"
  else
    echo "Running unsharded mode"
  fi
}

# Drops the given table from the vschema
function drop_table_vschema(){
  # $1 is the name of the table to drop
  if [ "$VT_NUM_SHARDS" -gt "1" ]; then
    mysql_run "alter vschema drop table test.\`${1}\`;"
  else
    echo "Running unsharded mode"
  fi
}
