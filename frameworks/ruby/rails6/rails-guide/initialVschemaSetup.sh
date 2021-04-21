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

# add vindex for books to be based on library_id column for sharded keyspace.
# This is required since the foreign key constraint exists between them so whatever row 
# books references must live in the same shard.
# This is ensured by using the column part of the foreign key for sharding and also the same sharding scheme.
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

add_sequence_and_vindex "authors"
add_binary_md5_vindex "book2s" "author_id"
add_sequence_table "book2s"

# The structure of the 3 tables is as following :-
: '
   ┌─────────┐
   │Suppliers│
   │         │
   │    id   │◄───┐
   │         │    │
   │   name  │    │
   └─────────┘    │
                  │         ┌──────────────┐
                  │         │ Accounts     │
                  │         │              │
                  │       ┌►│    id        │
                  │       │ │              │
                  └───────┼─┤supplier_id   │
                          │ │              │
                          │ │account_number│
                          │ └──────────────┘
                          │
  ┌─────────────────┐     │
  │Account_histories│     │
  │                 │     │
  │    id           │     │
  │                 │     │
  │   account_id    ├─────┘
  │                 │
  │  credit_history │
  └─────────────────┘
'
# In this example foreign key constraints are not added so having a sharding key
# based on only id column for all the three tables will give correct results
# But we can do better than that. We can shard accounts according to 
# supplier, then the supplier that each record in accounts is referencing will be available in that shard
# i.e. join between accounts and suppliers will not require a scatter join on vtgate.
# Futher we also want that the rows of account_histories live in the same place as the one that they are referencing
# But the accounts column is sharded by supplier_id. We need a way to find the keyspace of a row given the id.
# To do this we add a consistent_lookup_unique vindex on accounts which maps the ids to a keyspace.
# We then shard account_histories on account_id using this vindex.
add_sequence_and_vindex "suppliers"
add_binary_md5_vindex "account2s" "supplier_id"
add_sequence_table "account2s"
# Add consistent_lookup_unique vindex, more info at https://vitess.io/docs/user-guides/vschema-guide/unique-lookup/
mysql_run "create table unsharded.account2s_keyspace_id(id bigint not null auto_increment, keyspace_id varbinary(20), primary key(id))"
mysql_run "alter vschema add table unsharded.account2s_keyspace_id"
mysql_run "alter vschema on test.account2s add vindex account2s_keyspace_id(id) using consistent_lookup_unique with owner=\`account2s\`, table=\`unsharded.account2s_keyspace_id\`, from=\`id\`, to=\`keyspace_id\`"
# Use the vindex created above for sharding account_histories, more info at https://vitess.io/docs/user-guides/vschema-guide/lookup-as-primary/
mysql_run "alter vschema on test.account_histories add vindex account2s_keyspace_id(account2_id)"
add_sequence_table "account_histories"

# The structure of the 3 tables is as following :-
: '
    ┌───────────┐
    │ Physicians│
    │           │
    │   id      │◄───────┐
    │           │        │
    │   name    │        │
    └───────────┘        │             ┌────────────────┐
                         │             │ Appointment    │
                         │             │                │
                         │             │      id        │
                         │             │                │
                         └─────────────┤ physician_id   │
                                       │                │
                         ┌─────────────┤ patient_id     │
                         │             │                │
                         │             │ appintment_date│
    ┌─────────┐          │             └────────────────┘
    │ Patients│          │
    │         │          │
    │   id    │◄─────────┘
    │         │
    │  name   │
    └─────────┘

'
# In this example foreign key constraints are not added so having a sharding key
# based on only id column for all the three tables will give correct results
# But we can do better than that. We can shard appointment according to 
# patient_id, then the patient that each record in appointment is referencing will be available in that shard
# i.e. join between appointments and patients will not require a scatter join on vtgate.
# NOTE :- In this example, we can enforce one foreign key constraint based on our sharding schema
# patient_id can be made a foreign key it will be correct because the referenced rows will be in the same shard
# We cannot enforce both the foreign key constraints because that would require all the rows living in the same shard
# That would only be possible in an unsharded environment
add_sequence_and_vindex "physicians"
add_sequence_and_vindex "patients"
add_binary_md5_vindex "appointments" "patient_id"
add_sequence_table "appointments"

# These 3 tables have a similar structure as the one above
# TODO: Add assemblies table authoritative columns, as it is required while joining with assemblies_parts.
add_sequence_table "assemblies"
add_sequence_and_vindex "parts"
add_binary_md5_vindex "assemblies_parts" "part_id"

add_sequence_and_vindex "supplier2s"
add_sequence_and_vindex "account3s"

# These 3 tables have a similar structure as seen above
# TODO: Add assembly2s table authoritative columns, as it is required while joining with assembly2s_part2s.
add_sequence_table "assembly2s"
add_sequence_and_vindex "part2s"
add_binary_md5_vindex "assembly2s_part2s" "part2_id"

# These 3 tables have a similar structure as seen above
# TODO: Add assembly3s table authoritative columns, as it is required while joining with manifests.
add_sequence_table "assembly3s"
add_sequence_and_vindex "part3s"
add_binary_md5_vindex "manifests" "part3_id"
add_sequence_table "manifests"

# In these 3 tables, pictures can have reference to either table, employees or products.
# which table it is a reference to is determined by imageable_type
# If we shard both employees and products by the same vindex then
# we can shard pictures by the same vindex on imageable_id. 
# Then either record will live in the same shard and joins with either table will 
# not require scatter joins on vtgate.
add_sequence_and_vindex "employees"
add_sequence_and_vindex "products"
add_binary_md5_vindex "pictures" "imageable_id"
add_sequence_table "pictures"

# having a foreign_key to the table itself will not work in the sharded mode
# so using a null vindex will send all the rows to the first shard
# basically the entire table will reside in a single shard
mysql_run "alter vschema on test.employee2s add vindex \`null\`(id) using \`null\`"

# in employee3s, the foreign key constraint is not enforced
# otherwise it is structurally equivalent to emplyee2s
add_sequence_and_vindex "employee3s"

# These 3 tables have a similar structure as seen above
# TODO: Add assembly4s table authoritative columns, as it is required while joining with assembly4s_part4s.
add_sequence_table "assembly4s"
add_sequence_and_vindex "part4s"
add_binary_md5_vindex "assembly4s_part4s" "part4_id"

add_sequence_and_vindex "author2s"
add_binary_md5_vindex "book3s" "author2_id"
add_sequence_table "book3s"

# explicit commands here because the primary key is called guid instead of id
mysql_run "alter vschema on test.author3s add vindex \`binary_md5\`(guid) using \`binary_md5\`;"
mysql_run "create table unsharded.author3s_seq(id bigint, next_id bigint, cache bigint, primary key(id)) comment 'vitess_sequence'"
mysql_run "insert into unsharded.author3s_seq(id, next_id, cache) values(0, 1, 3)"
mysql_run "alter vschema add sequence unsharded.author3s_seq"
mysql_run "alter vschema on test.author3s add auto_increment guid using unsharded.author3s_seq"
add_binary_md5_vindex "book4s" "author3_id"
add_sequence_table "book4s"


# The structure of the 3 tables is similar to seen above where we created a consistent_lookup_unique vindex
add_sequence_and_vindex "author4s"
add_binary_md5_vindex "book5s" "author4_id"
add_sequence_table "book5s"
# Add consistent_lookup_unique vindex, more info at https://vitess.io/docs/user-guides/vschema-guide/unique-lookup/
mysql_run "create table unsharded.book5s_keyspace_id(id bigint not null auto_increment, keyspace_id varbinary(20), primary key(id))"
mysql_run "alter vschema add table unsharded.book5s_keyspace_id"
mysql_run "alter vschema on test.book5s add vindex book5s_keyspace_id(id) using consistent_lookup_unique with owner=\`book5s\`, table=\`unsharded.book5s_keyspace_id\`, from=\`id\`, to=\`keyspace_id\`"
# Use the vindex created above for sharding chapter5s, more info at https://vitess.io/docs/user-guides/vschema-guide/lookup-as-primary/
mysql_run "alter vschema on test.chapters add vindex book5s_keyspace_id(book5_id)"
add_sequence_table "chapters"

# explicit commands here because the primary key is called guid instead of id
mysql_run "alter vschema on test.supplier3s add vindex \`binary_md5\`(guid) using \`binary_md5\`;"
mysql_run "create table unsharded.supplier3s_seq(id bigint, next_id bigint, cache bigint, primary key(id)) comment 'vitess_sequence'"
mysql_run "insert into unsharded.supplier3s_seq(id, next_id, cache) values(0, 1, 3)"
mysql_run "alter vschema add sequence unsharded.supplier3s_seq"
mysql_run "alter vschema on test.supplier3s add auto_increment guid using unsharded.supplier3s_seq"
# id used here for vindex and not supplier_id, because the tests change this field and updating primary vindex is not supported
add_binary_md5_vindex "account4s" "id"
add_sequence_table "account4s"

# similar structure seen previously
add_sequence_and_vindex "supplier4s"
add_binary_md5_vindex "account5s" "supplier4_id"
add_sequence_table "account5s"
# Add consistent_lookup_unique vindex, more info at https://vitess.io/docs/user-guides/vschema-guide/unique-lookup/
mysql_run "create table unsharded.account5s_keyspace_id(id bigint not null auto_increment, keyspace_id varbinary(20), primary key(id))"
mysql_run "alter vschema add table unsharded.account5s_keyspace_id"
mysql_run "alter vschema on test.account5s add vindex account5s_keyspace_id(id) using consistent_lookup_unique with owner=\`account5s\`, table=\`unsharded.account5s_keyspace_id\`, from=\`id\`, to=\`keyspace_id\`"
# Use the vindex created above for sharding account_histories, more info at https://vitess.io/docs/user-guides/vschema-guide/lookup-as-primary/
mysql_run "alter vschema on test.transactions add vindex account5s_keyspace_id(account5_id)"
add_sequence_table "transactions"

# Since there are 2 foreign keys from puppers_friends to puppers, we cannot shard by just one of them
# The only way the foreign keys can be enforced if the entire tables live in a single shard
mysql_run "alter vschema on test.puppers add vindex \`null\`(id) using \`null\`"
mysql_run "alter vschema on test.puppers_friends add vindex \`null\`(this_pupper_id) using \`null\`"

add_sequence_and_vindex "assembly5s"
add_sequence_and_vindex "part5s"
add_sequence_and_vindex "manufacturers"
add_binary_md5_vindex "assembly5s_part5s" "part5_id"
add_binary_md5_vindex "manufacturers_part5s" "part5_id"

# Query Interface
add_sequence_and_vindex "author5s"
add_sequence_and_vindex "supplier5s"
add_binary_md5_vindex "book6s" "author5_id"
add_sequence_table "book6s"
add_sequence_and_vindex "customer2s"
add_binary_md5_vindex "order2s" "customer2_id"
add_sequence_table "order2s"
add_binary_md5_vindex "reviews" "customer2_id"
add_sequence_table "reviews"
add_binary_md5_vindex "book6s_order2s" "book6_id"

