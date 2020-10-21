{
  "name": "default",
  "type": "mysql",
  "host": "${DB_HOST}",
  "port": ${DB_PORT},
  "username": "${DB_USERNAME}",
  "password": "${DB_PASSWORD}",
  "database": "${DB_NAME}",
  "synchronize": true,
  "logging": false,
  "entities": [
    "dist/entity/*.js"
  ],
  "subscribers": [
    "dist/subscriber/*.js"
  ],
  "migrations": [
    "dist/migration/*.js"
  ],
  "cli": {
    "entitiesDir": "src/entity",
    "migrationsDir": "src/migration",
    "subscribersDir": "src/subscriber"
  }
}
