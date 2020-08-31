# -------------
# Helper tasks to start and connect the database dockers for dev and building
# -------------

# --- docker builder ---
.PHONY: builder-start builder-shell builder-remove start-if-builder

# putting @ in front of command hides it from being echoed by make
# bash ifs have to be one line, as a reminder \ continues the line and need to end each command with a ;
builder-start: builder-network ## start the docker jdk-builder if its not started yet, unless USE_BUILDER=false
	@${build.sh} builderStart ${DOCK_BUILDER_NAME} ${DOCK_BUILDER_URL}

builder-network: # run `docker network create builder` to make sure network there to connect dockers
	@${build.sh} dockerNetworkCreate "builder-net"

builder-shell: builder-start ## opens up a shell into the jdk-builder docker
	$(DockerShellExec) ${DOCK_BUILDER_NAME} bash -l

builder-remove: ## stops and removes the jdk-builder docker
	@${build.sh} dockerRemove ${DOCK_BUILDER_NAME}
  @docker network rm builder-net || true

start-if-builder: ## calls db-start if USE_DOCKER_DB_BUILDER=true and builder-start if USE_BUILDER=true
	@if [ "${USE_BUILDER}" == "true" ]; then \
	  $(MAKE) ${DBMS} builder-start; \
	fi;
  @if [ "${USE_DOCKER_DB_BUILDER}" == "true" ]; then \
	  $(MAKE) ${DBMS} db-start; \
	fi;

#----- DB targets -------
.PHONY: db-start db-wait db-down

db-start: builder-network ## starts the DOCK_DB_BUILD_NAME db if its not started yet, unless USE_DOCKER_DB_BUILDER=false
	@${build.sh} db_start ${DOCK_DB_BUILD_NAME} ${DOCKER_DB_URL} ${DB_PORT}:${DB_PORT} ${PASS_VAR_NAME}=${DB_PASSWORD}

db-wait: # runs a wait-for script that blocks until db mysql or sqlcmd succeeds
	@${DockerDbExec} ${build.sh} wait_for_$(DBMS) $(DB_HOST) $(DB_PASSWORD)

db-down: ## stop and remove the docker DOCK_DB_BUILD_NAME
	@${build.sh} dockerRemove ${DOCK_DB_BUILD_NAME}

#----- clean up-------
docker-remove-all: builder-remove ## runs `make db-down` for sqlserver and mysql and
	$(MAKE) mysql db-down
	$(MAKE) sqlserver db-down
