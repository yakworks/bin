# -------------
# Common gradle tasks and helpers for CI.
# Makefile-core.make should be imported before this
# -------------
circle.sh := $(BUILD_BIN)/circle

.PHONY: cache-key-file resolve-dependencies lint check clean compile unit-test int-test boot-run

## generates the cache-key.tmp for CI to checksum. depends on GRADLE_PROJECTS var
cache-key-file: | _var_GRADLE_PROJECTS
	@$(circle.sh) cache-key-file "$(GRADLE_PROJECTS)"

## used on CI, calls ./gradlew resolveConfigurations to download gradle deps without a compile
resolve-dependencies:
	./gradlew resolveConfigurations --no-daemon

## runs codenarc and spotless
lint:
	./gradlew spotlessCheck codenarcMain

## call ./gradlew check to do a full lint and test
check:
	./gradlew check

## gradle clean
clean::
	$(DockerExec) ./gradlew clean

## runs gradle classes to compile
compile:
	$(DockerExec) ./gradlew classes

## on multi-project gradles this will merges test results into one spot to store in CI build
merge-test-results: | _var_GRADLE_PROJECTS
	$(circle.sh) merge-test-results "$(GRADLE_PROJECTS)"

testArg := $(if $(tests),--tests $(tests), )

## runs gradle test, add tests=... to pass to gradles --tests
unit-test:
	$(DockerExec) ./gradlew test $(testArg)

## runs gradle integrationTest
int-test:
	$(DockerExec) ./gradlew integrationTest $(testArg)

boot-run:
	$(DockerExec) ./gradlew -DBMS=$(DBMS) -Dgrails.env=$(BUILD_ENV) bootRun
