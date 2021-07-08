# The "main" utility functions and helpers useful for the common case. Most
# our makefiles require this file, so it's sensible to `include` it first.
# inspired by https://github.com/basejump/ludicrous-makefiles

# the dir this is in
BUILD_BIN := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
# include .env, sinclude ignores if its not there
sinclude ./.env
# include boilerplate to set BUILD_ENV and DB from targets
include $(BUILD_BIN)/make_core/env-db.make
# calls the build.sh make_env_file to build the vairables file for make, recreates on each make run
shResults := $(shell ./build.sh make_env_file $(BUILD_ENV) $(DB_VENDOR))
makefile_env := ./build/make/makefile.env
# import/sinclude the variables file to make it availiable to make as well
sinclude $(makefile_env)
# includes for common
include $(BUILD_BIN)/make_core/logging.make
include $(BUILD_BIN)/make_core/ship-it.make

HELP_AWK := $(BUILD_BIN)/make_core/help.awk

# -- standard names, all double :: so you can have many
# NOTE: any targets implemneted in main Makefile or others must also have :: for these
# See https://www.gnu.org/software/make/manual/make.html#Double_002dColon for more information.

## removes build artifacts
clean::
	@:

## runs lint and code style checks
lint::
	@:

## compiles the app
compile::
	@:

## Run the lint and tests
check::
	@:

## runs all tests
test::
	@:

## runs unit tests
test-unit::
	@:

## runs integration/e2e tests
test-e2e::
	@:

## builds the libs
build::
	@:

## publish the libs
publish::
	@:

# Full release, version bump, changelog update... usually only CI
release::
	@:

# Deploy the app. dockerize, kubernetes, etc... usually only CI will run this
deploy::
	@:

# Useful for forcing targets to build when .PHONY doesn't help, plus it looks a bit cleaner in many cases than .phony
FORCE:

.PHONY: clean lint compile check test test-unit test-e2e build publish release deploy FORCE

# see Target-specific Variable Values for above https://www.gnu.org/software/make/manual/html_node/Target_002dspecific.html
# done so main Makefile is seperate and comes last in awk so any help comments win for main file
help: _HELP_F := $(firstword $(MAKEFILE_LIST))

## list help docs
help: | _program_awk
	@awk -f $(HELP_AWK) $(wordlist 2,$(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) $(_HELP_F)

.PHONY: help
.DEFAULT_GOAL := help

## list the BUILD_VARS in the build/make env
log-vars: FORCE
	$(foreach v, $(sort $(BUILD_VARS)), $(info $(v) = $($(v))))

log-make_vars: FORCE
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

# for debugging, calls the build.sh log-vars to sanity check
log-buildsh-vars: FORCE
	$(build.sh) log-vars

## list all the functions sourced into the build.sh
list-functions: FORCE
	$(build.sh) list-functions

.PHONY: list-targets
## list all the availible Make targets, including the targets hidden from core help
list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort -u | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Helper target for declaring an external executable as a recipe dependency.
# For example,
#   `my_target: | _program_awk`
# will fail before running the target named `my_target` if the command `awk` is
# not found on the system path.
_program_%: FORCE
	@_=$(or $(shell which $* 2> /dev/null),$(error `$*` command not found. Please install `$*` and try again))

# Helper target for checking required environment variables.
#
# For example,
#   `my_target`: | _verify_FOO`
#
# will fail before running `my_target` if the variable `FOO` is not declared.
_verify_%: FORCE
	@_=$(if $($*),,$(error `$*` is not defined or is empty))

# text manipulation helpers
_awk_case = $(shell echo | awk '{ print $(1)("$(2)") }')
lc = $(call _awk_case,tolower,$(1))
uc = $(call _awk_case,toupper,$(1))


# The defult build dir, if we have only one it'll be easier to cleanup
BUILD_DIR =: build
# $(info BUILD_DIR=$(BUILD_DIR))
$(BUILD_DIR):
	mkdir -p $@


