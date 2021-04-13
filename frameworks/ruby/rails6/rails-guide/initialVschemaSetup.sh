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
add_sequence_table "users"

# TODO: Add vschema for vindex and authoritative column list for test.microposts column.
# mysql_run "alter vschema on test.microposts add vindex \`binary_md5\`(user_id) using \`binary_md5\`"
add_sequence_table "microposts"

add_binary_md5_vindex "relationships" "follower_id"

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
