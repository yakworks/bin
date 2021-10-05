# ----- setup the BUILD_ENV based on targets  -------
# BUILD_ENV is used to to pass to gradle/liquibase and to build the database name etc....
BUILD_ENV = dev
# MAKECMDGOALS has the list of all target goals that are passed into make cmd
ifeq (test-env,$(filter test-env,${MAKECMDGOALS}))
  BUILD_ENV = test
else ifeq (seed,$(filter seed,${MAKECMDGOALS}))
  BUILD_ENV = seed
endif

# ----- setup the specified database based on phony target we pass in
# phony is any target that might does not really exist and does not relate to a dir or file (most of them)
.PHONY: sqlserver mysql h2 postgres
# we can do `make build dev sqlserver` or `make build dev sqlserver`
DB_VENDOR ?= mysql
ifeq (sqlserver,$(filter sqlserver,${MAKECMDGOALS}))
  DB_VENDOR = sqlserver
else ifeq (oracle,$(filter oracle,${MAKECMDGOALS}))
  DB_VENDOR = oracle
else ifeq (h2,$(filter h2,${MAKECMDGOALS}))
  DB_VENDOR = h2
else ifeq (postgres,$(filter postgres,${MAKECMDGOALS}))
  DB_VENDOR = postgres
endif

# ----- if use-docker then force docker builder
ifeq (use-builder,$(filter use-builder,${MAKECMDGOALS}))
  USE_BUILDER = true
endif

# dummy targets so we dont get the make[1]: Nothing to be done for `xxx'.
dummy_targets = dev seed test-env mysql sqlserver oracle h2 postgres use-builder
.PHONY: $(dummy_targets)
$(dummy_targets):
	@:
