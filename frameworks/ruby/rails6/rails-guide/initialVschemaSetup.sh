#!/bin/sh -e

source helper.sh

mysql_run "alter vschema on test.schema_migrations add vindex \`binary\`(version) using \`binary\`;"
mysql_run "alter vschema on test.users add vindex \`binary_md5\`(version) using \`binary_md5\`;"
mysql_run "alter vschema on test.ar_internal_metadata add vindex \`xxhash\`(\`key\`) using \`xxhash\`;"