
.PHONY: clean compile check unit-test int-test boot-run

clean: ## cleans build dir
	${DockerExec} ./gradlew clean

compile: start-builder ## runs compile in build.sh that compiles all tests as well
	${DockerExec} ./gradlew classes

check: start-builder ## runs ./gradlew check
	${DockerExec} ./gradlew check

testArg := $(if $(tests),--tests $(tests), )

unit-test: start-builder ## runs ./gradlew test
	${DockerExec} ./gradlew test $(testArg)

int-test: start-builder start-db ## runs ./gradlew integrationTest
	${DockerExec} ./gradlew integrationTest $(testArg)

boot-run: start-builder start-db ## runs the app with gradle bootRun, ensures the DB is up
	${DockerExec} ./gradlew -DBMS=${DBMS} -Dgrails.env=${BUILD_ENV} bootRun
