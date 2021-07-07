# Framework testing

From a high level, the intention of this repo is to provide a suite of "black box" tests that can be run on-demand by the Vitess project to validate compatibility with MySQL.  CI is provided via Github Actions; the tests themselves are validated by running against vanilla MySQL, and validated tests are run against vttestserver to test Vitess's own compatibility.

#### Running tests locally

To run the tests, there are seven environment variables you need to set:  `VT_HOST`, `VT_PORT`, `VT_USERNAME`, `VT_PASSWORD`, `VT_DATABASE`, `VT_NUM_SHARDS`, and `VT_DIALECT`.
* `VT_HOST` is an IP address or port to access the Vitess/MySQL database you want to run the tests against
* `VT_PORT` is the port number on which the database server is listening; `3306` is probably what you'll want to set this to
* `VT_USERNAME` is any username with access to the database you want to run tests against
* `VT_PASSWORD` is the password for that user
* `VT_DATABASE` is the name of the database/keyspace you want to access
* `VT_NUM_SHARDS` is the number of shards that are being used for the test.
* `VT_DIALECT` is the MySQL version we're targeting - currently supported options are `mysql57` and `mysql80`

##### Example

Using a simple MySQL container as an example:
```bash
docker run --name=mysql -d -e MYSQL_DATABASE=test -e MYSQL_ROOT_PASSWORD=testpassword mysql:5.7
# ... wait for container to start ...
# Note that simply doing a port forward with -p on the `docker run` line doesn't
#    allow us to use `localhost` here, because the framework runs the tests in
#    their own containers.  For that reason, we get the IP address for the MySQL
#    container and use that.
export VT_HOST="$(docker inspect mysql | jq -r '.[].NetworkSettings.IPAddress')"
export VT_PORT=3306
export VT_USERNAME=root
export VT_PASSWORD=testpassword
export VT_DATABASE=test
export VT_NUM_SHARDS=1
export VT_DIALECT=mysql57
./run.sh run_test rust/mysql_async # Runs a single test, the Rust mysql_async client
./alltests.sh # Runs the entire test suite
```

#### Testing local changes

To test local changes to a test, there are two steps - build the test's container image, and run it.
* To build, simply run `./run.sh build_image "$language/$framework", e.g. `./run.sh build_image rust/mysql_async`
* To run, follow the instructions under "Running the tests", above.

##### Example

Using vttestserver as an example:
```bash
docker run --name=vttestserver -d -e PORT=33574 -e KEYSPACES=test -e NUM_SHARDS=1 -e MYSQL_BIND_HOST=0.0.0.0 vitess/vttestserver:mysql57
export VT_HOST="$(docker inspect vttestserver | jq -r '.[].NetworkSettings.IPAddress')"
export VT_PORT=3306
export VT_USERNAME=root
export VT_PASSWORD=testpassword
export VT_DATABASE=test
export VT_NUM_SHARDS=1
export VT_DIALECT=mysql57
./run.sh run_test ruby/rails6
./alltests.sh
```

#### Introducing a new framework

New frameworks, languages, or tools can get added for testing by introducing the following directory structure:

- __vitess\-framework\-testing__/
   - frameworks/__language__/
     - __framework__/
       - src/ (source code)
       - Dockerfile (dockerfile)

Provided there is a `Dockerfile`, tests will be run automatically.  The guidelines for an individual test are as follows:
* The test is run in a container.
* As much as possible should be done at container build time
  * Examples
    * Any run-time dependencies should all be installed at build time
    * For compiled languages, the code should be compiled and the binary placed in the image.
      * One exception would be when database interaction at compile time is a feature of the framework; Rust `sqlx` is an example
* The container's `ENTRYPOINT` is responsible for everything related to test setup, run, and teardown _EXCEPT_ running the database itself; the database will be provided by CI, and, for local test runs, is expected to be provided.
  * Examples
    * If the framework can be used for a "simple" program that just runs to completion and exits, that is preferable.  In this case, the program would create any tables it needs, run through code that exercises its database features (e.g. runs queries), drops the tables, then exits.
    * If the framework is strictly used to setup a server, such as a web service, the container entrypoint should start the service as a background process, then interact with it in ways that exercise the database features.
* The container's entrypoint should exit with a status code of 0 when the test succeeds, or nonzero if it fails in any way.
* In cases when the test container fails prematurely, the framework will take care of cleaning up tables after each test.

