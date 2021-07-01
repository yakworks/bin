# The "main" utility functions and helpers useful for the common case. Most
# ludicrous makefiles require this file, so it's sensible to `include` it first.
# see https://github.com/basejump/ludicrous-makefiles

# the dir this is in
BUILD_BIN := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

HELP_AWK := $(BUILD_BIN)/make/help.awk

## displays this message
help: _HELP_F := $(firstword $(MAKEFILE_LIST))
help: | _program_awk
	@awk -f $(HELP_AWK) $(wordlist 2,$(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) $(_HELP_F)  # always prefer help from the top-level makefile

.PHONY: help
.DEFAULT_GOAL := help

## list the BUILD_VARS in the build/make env
log-vars: FORCE
	$(foreach v, $(sort $(BUILD_VARS)), $(info $(v) = $($(v))))

## calls the build.sh logVars to sanity check
build-log-vars: FORCE
	$(build.sh) log-vars

## lists the functions sourced into the build.sh
build-list-functions: FORCE
	$(DockerExec) $(build.sh) list-functions

# Helper target for declaring an external executable as a recipe dependency.
# For example,
#   `my_target: | _program_awk`
# will fail before running the target named `my_target` if the command `awk` is
# not found on the system path.
_program_%: FORCE
	@_=$(or $(shell which $* 2> /dev/null),$(error `$*` command not found. Please install `$*` and try again))

# Helper target for declaring required environment variables.
#
# For example,
#   `my_target`: | _var_PARAMETER`
#
# will fail before running `my_target` if the variable `PARAMETER` is not declared.
_var_%: FORCE
	@_=$(if $($*),,$(error `$*` is not defined or is empty))

# The defult build dir, if we have only one it'll be easier to cleanup
BUILD_DIR =: build

$(BUILD_DIR):
	mkdir -p $@

# text manipulation helpers
_awk_case = $(shell echo | awk '{ print $(1)("$(2)") }')
lc = $(call _awk_case,tolower,$(1))
uc = $(call _awk_case,toupper,$(1))

# Useful for forcing targets to build when .PHONY doesn't help, plus it looks a bit cleaner in many cases than .phony
FORCE:

# Removes build artifacts, implement with your own `clean::` target to remove additional artifacts.
# See https://www.gnu.org/software/make/manual/make.html#Double_002dColon for more information.
## removes build artifacts
clean::
	@:

.PHONY: clean FORCE

# include the logging make
include $(BUILD_BIN)/make/logging.make
