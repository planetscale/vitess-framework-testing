# Framework testing

#### Introducing a new framework

New frameworks, languages, or tools can get added for testing by introducing the following directory structure:

- __vitess\-framework\-testing__
   - __language__
     - __framework__
       - src/main.go (source code)
       - Dockerfile (dockerfile)
       - build (entrypoint)

Provided there is a `Dockerfile` _or_ `test` tests will start to automatically get run.