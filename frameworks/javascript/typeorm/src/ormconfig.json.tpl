{
  "name": "default",
  "type": "mysql",
  "host": "${VT_HOST}",
  "port": ${VT_PORT},
  "username": "${VT_USERNAME}",
  "password": "${VT_PASSWORD}",
  "database": "${VT_DATABASE}",
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
