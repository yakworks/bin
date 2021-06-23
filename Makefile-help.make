# HELP and helpers
log-vars: ## logs the BUILD_VARS in the build/make env
	$(foreach v, $(sort $(BUILD_VARS)), $(info $(v) = $($(v))))

build-log-vars: start-if-builder ## calls the build.sh logVars to sanity check
	${DockerExec} ${build.sh} logVars

print-%: ## echos the variable value
	@echo '$*=$($*)'

# This will output the help for each task thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# iterate in case there are imports and MAKEFILE_LIST has more than 1 element
.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; \
	  {printf "\033[36m%-20s\033[0m| %s\n", $$1, $$2}';
