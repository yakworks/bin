# -------------
# Helper tasks to start and connect dockers for dev and building
# -------------

# --- docker builder ---
.PHONY: clean compile check unit-test int-test boot-run

clean: ## cleans build dir
	${DockerExec} ./gradlew clean

compile: start-builder ## runs compile in build.sh that compiles all tests as well
	${DockerExec} ./gradlew classes

check: start-builder start-db ## runs gradlew check
	${DockerExec} ./gradlew check

unit-test: start-builder ## runs ./gradlew test
	${DockerExec} ./gradlew test

int-test: start-builder start-db ## runs ./gradlew integrationTest
	${DockerExec} ./gradlew integrationTest

boot-run: start-builder start-db ## runs the app with gradle bootRun, ensures the DB is up
	${DockerExec} ./gradlew -DBMS=${DBMS} -Dgrails.env=${BUILD_ENV} bootRun
