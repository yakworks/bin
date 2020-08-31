# -------------
# Helper tasks to start and connect the database dockers for dev and building
# -------------

include ./build/bin/Makefile-docker.make

#----- DB targets -------
.PHONY: db-start db-startup db-wait db-down

db-start: builder-network ## starts the DOCK_DB_BUILD_NAME db if its not started yet, unless USE_DOCKER_DB_BUILDER=false
	@${build.sh} db_start ${DOCK_DB_BUILD_NAME} ${DOCKER_DB_URL} ${DB_PORT}:${DB_PORT} ${PASS_VAR_NAME}=${DB_PASSWORD}

db-startup: ## calls db-start if USE_DOCKER_DB_BUILDER=true
	@if [ "${USE_DOCKER_DB_BUILDER}" == "true" ]; then \
	  $(MAKE) ${DBMS} db-start; \
	fi;

db-wait: # runs a wait-for script that blocks until db mysql or sqlcmd succeeds
	@${DockerDbExec} ${build.sh} wait_for_$(DBMS) $(DB_HOST) $(DB_PASSWORD)

db-down: ## stop and remove the docker DOCK_DB_BUILD_NAME
	@${build.sh} dockerRemove ${DOCK_DB_BUILD_NAME}
