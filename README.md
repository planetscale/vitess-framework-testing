# Framework testing

#### Running the tests

To run the tests, there are five environment variables you need to set:  `VT_HOST`, `VT_PORT`, `VT_USERNAME`, `VT_PASSWORD`, and `VT_DATABASE`.
* `VT_HOST` is an IP address or port to access the Vitess/MySQL database you want to run the tests against
* `VT_PORT` is the port number on which the database server is listening; `3306` is probably what you'll want to set this to
* `VT_USERNAME` is any username with access to the database you want to run tests against
* `VT_PASSWORD` is the password for that user
* `VT_DATABASE` is the name of the database/keyspace you want to access

##### Example

Using a simple MySQL container as an example:
```bash
docker run --name=mysql -d -e MYSQL_DATABASE=test -e MYSQL_ROOT_PASSWORD=testpassword mysql:5.7
# Wait for container to start
export VT_HOST="$(docker inspect mysql | jq -r '.[].NetworkSettings.IPAddress')"
export VT_PORT=3306
export VT_USERNAME=root
export VT_PASSWORD=testpassword
export VT_DATABASE=test
./run.sh run_test rust/mysql_async # Runs a single test, the Rust mysql_async client
./alltests.sh # Runs the entire test suite
```

#### Introducing a new framework

New frameworks, languages, or tools can get added for testing by introducing the following directory structure:

- __vitess\-framework\-testing__
   - frameworks/__language__
     - __framework__
       - src/main.go (source code)
       - Dockerfile (dockerfile)
       - build (entrypoint)

Provided there is a `Dockerfile` _or_ `test` tests will start to automatically get run.

