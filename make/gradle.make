# -------------
# Common gradle tasks and helpers for CI.
# Makefile-core.make should be imported before this
# -------------
circle.sh := $(BUILD_BIN)/circle

.PHONY: cache-key-file resolve-dependencies

## generates the cache-key.tmp for CI to checksum. depends on GRADLE_PROJECTS var
cache-key-file: | _verify_GRADLE_PROJECTS
	@$(circle.sh) cache-key-file "$(GRADLE_PROJECTS)"

## calls `gradlew resolveConfigurations` to download deps without compiling, used mostly for CI cache
resolve-dependencies:
	./gradlew resolveConfigurations --no-daemon

## runs codenarc and spotless
lint::
	./gradlew spotlessCheck codenarcMain

## Run the lint and test suite with ./gradlew check
check::
	./gradlew check

## gradle clean
clean::
	./gradlew clean

## compiles with gradle classes
compile:
	./gradlew classes

# on multi-project gradles this will merges test results into one spot to store in CI build
merge-test-results: FORCE | _verify_GRADLE_PROJECTS
	$(circle.sh) merge-test-results "$(GRADLE_PROJECTS)"

testArg := $(if $(tests),--tests $(tests), )

## unit tests with gradle test, add tests=... to pass to gradles --tests
test-unit: FORCE
	./gradlew test $(testArg)

## integration tests with gradle integrationTest
test-int: FORCE
	./gradlew integrationTest $(testArg)

## publish snapshot jar to local maven
snapshot:
	./gradlew snapshot

