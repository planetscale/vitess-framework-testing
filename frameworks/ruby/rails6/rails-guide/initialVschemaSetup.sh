#!/bin/sh -e

source helper.sh

# Tables that rails uses internally
mysql_run "alter vschema on test.schema_migrations add vindex \`binary\`(version) using \`binary\`"
mysql_run "alter vschema on test.ar_internal_metadata add vindex \`xxhash\`(\`key\`) using \`xxhash\`"
mysql_run "alter vschema on test.active_storage_attachments add vindex \`null\`(id) using \`null\`"
mysql_run "alter vschema on test.active_storage_blobs add vindex \`null\`(id) using \`null\`"

# User created tables
# TODO: Add vschema for vindex and authoritative column list for test.users column.
# mysql_run "alter vschema on test.users add vindex \`binary_md5\`(id) using \`binary_md5\`;"
mysql_run "create table unsharded.users_seq(id bigint, next_id bigint, cache bigint, primary key(id)) comment 'vitess_sequence'"
mysql_run "insert into unsharded.users_seq(id, next_id, cache) values(0, 1, 3)"
mysql_run "alter vschema add sequence unsharded.users_seq"
mysql_run "alter vschema on test.users add auto_increment id using unsharded.users_seq"

# TODO: Add vschema for vindex and authoritative column list for test.microposts column.
# mysql_run "alter vschema on test.microposts add vindex \`binary_md5\`(user_id) using \`binary_md5\`"
mysql_run "create table unsharded.microposts_seq(id bigint, next_id bigint, cache bigint, primary key(id)) comment 'vitess_sequence'"
mysql_run "insert into unsharded.microposts_seq(id, next_id, cache) values(0, 1, 3)"
mysql_run "alter vschema add sequence unsharded.microposts_seq"
mysql_run "alter vschema on test.microposts add auto_increment id using unsharded.microposts_seq"

mysql_run "alter vschema on test.relationships add vindex \`binary_md5\`(follower_id) using \`binary_md5\`"

add_sequence_and_vindex "library"
add_binary_md5_vindex "books" "library_id"
add_sequence_table "books"

add_sequence_and_vindex "computers"
add_binary_md5_vindex "markets" "computer_id"
add_sequence_table "markets"
add_binary_md5_vindex "trackpads" "computer_id"
add_sequence_table "trackpads"

add_sequence_and_vindex "invoices"
add_binary_md5_vindex "customers" "invoice_id"
add_sequence_table "customers"
