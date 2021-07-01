# -------------
# Helper tasks to start and connect dockers for dev and building
# -------------

# --- docker builder ---
.PHONY: builder-start builder-shell builder-remove

# putting @ in front of command hides it from being echoed by make
# bash ifs have to be one line, as a reminder \ continues the line and need to end each command with a ;
## start the docker jdk-builder if its not started yet
builder-start: builder-network
	@$(build.sh) builderStart $(DOCK_BUILDER_NAME) $(DOCK_BUILDER_URL)

## run `docker network create builder` to make sure network there to connect dockers
builder-network:
	@$(build.sh) dockerNetworkCreate "builder-net"

## opens up a shell into the jdk-builder docker
builder-shell: builder-start
	$(DockerShellExec) bash -l

## stops and removes the jdk-builder docker
builder-remove:
	@$(build.sh) dockerRemove $(DOCK_BUILDER_NAME)
	@docker network rm builder-net || true

# double $$ means esacpe it and send to bash as a single $
## login to docker hub using whats in the env vars $DOCKERHUB_USER $DOCKERHUB_PASSWORD
dockerhub-login: FORCE
	echo "$$DOCKERHUB_PASSWORD" | docker login -u "$$DOCKERHUB_USER" --password-stdin
