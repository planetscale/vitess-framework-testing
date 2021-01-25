#!/bin/bash

# Script to clean tables 
mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne 'SELECT DISTINCT TABLE_NAME, CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE REFERENCED_TABLE_NAME IS NOT NULL' 2>/dev/null | while read -r table key; do
  echo "ALTER TABLE \`${table}\` DROP FOREIGN KEY \`${key}\`;";
done | mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" 2>/dev/null;

tables="$(mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne 'SHOW TABLES' 2>/dev/null | sed 's/^\|$/`/g' | xargs echo | sed 's/ /,/g')";
if [[ "${tables}" != '' ]]; then
  mysql --host "${VT_HOST}" --port "${VT_PORT}" --user "${VT_USERNAME}" "-p${VT_PASSWORD}" "${VT_DATABASE}" -Ne "DROP TABLE ${tables}" 2>/dev/null;
fi
