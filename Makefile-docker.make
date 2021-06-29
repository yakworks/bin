# -------------
# Helper tasks to start and connect dockers for dev and building
# -------------

# --- docker builder ---
.PHONY: builder-start builder-shell builder-remove start-builder

# putting @ in front of command hides it from being echoed by make
# bash ifs have to be one line, as a reminder \ continues the line and need to end each command with a ;
builder-start: builder-network ## start the docker jdk-builder if its not started yet, unless USE_BUILDER=false
	@${build.sh} builderStart ${DOCK_BUILDER_NAME} ${DOCK_BUILDER_URL}

builder-network: ## run `docker network create builder` to make sure network there to connect dockers
	@${build.sh} dockerNetworkCreate "builder-net"

builder-shell: builder-start ## opens up a shell into the jdk-builder docker
	$(DockerShellExec) bash -l

builder-remove: ## stops and removes the jdk-builder docker
	@${build.sh} dockerRemove ${DOCK_BUILDER_NAME}
	@docker network rm builder-net || true

start-builder: ## calls builder-start if USE_BUILDER=true
	@if [ "${USE_BUILDER}" == "true" ]; then \
	  $(MAKE) ${DBMS} builder-start; \
	fi;

.PHONY: dockerhub-login
dockerhub-login: ## login to docker hub using whats in the env vars $DOCKERHUB_USER $DOCKERHUB_PASSWORD
	echo "$$DOCKERHUB_PASSWORD" | docker login -u "$$DOCKERHUB_USER" --password-stdin
