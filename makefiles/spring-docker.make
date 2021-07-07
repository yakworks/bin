# -------------
# spring and grails targets for building docker
# Makefile-core.make should be included before this
# -------------
# depends on spring-gradle so include it now
include $(BUILD_BIN)/makefiles/spring-gradle.make

gw := ./gradlew
build_docker_dir := build/docker
# source dir for deploy with Dockerfile etc..
deploy_src_dir := $(APP_DIR)/src/deploy

# rm -rf build/docker
clean-docker-build:
	@rm -rf $(build_docker_dir)/*

$(build_docker_dir):
	mkdir -p $@

DEPLOY_SOURCES := $(wildcard $(deploy_src_dir)/*)

# sets up the build/docker by copying in the src/deploy files, copy the executable jar
# then 'explodes' or unjars the executable jar so dockerfile can iterate on build changes
# layering docker see https://blog.jdriven.com/2019/08/layered-spring-boot-docker-images/
build/docker/Dockerfile: $(build_docker_dir) $(DEPLOY_SOURCES) | _verify_APP_JAR _verify_APP_DIR
	@ echo "copy Dockerfile"
	@ rm -rf $(build_docker_dir)/*
	cp -r $(deploy_src_dir)/. $(build_docker_dir);

# copies the jar in and explodes it
build/docker/app.jar: $(APP_JAR) build/docker/Dockerfile | _verify_APP_JAR _verify_APP_DIR
	@ echo "copy app.jar"
	@ cp $(APP_JAR) $(build_docker_dir)/app.jar; \
	  	cd $(build_docker_dir); \
	  	jar -xf app.jar; \

# $(build.sh) docker_build_prep $(deploy_src_dir) $(APP_JAR) $(build_docker_dir)

# does the docker build
build/docker_built: build/docker/app.jar | _verify_APP_DOCKER_URL
	docker build -t $(APP_DOCKER_URL) $(build_docker_dir)/.
	@touch build/docker_built

.PHONY: docker-app-build
# for easier testing of the docker build
docker-app-build: build/docker_built

# stamp to track if it was deployed
build/docker_push: build/docker_built | _verify_APP_DOCKER_URL
	docker push ${APP_DOCKER_URL}
	@touch build/docker_push

.PHONY: docker-app-push
## builds and deploys whats in the src/deploy for the APP_DOCKER_URL to docker hub
docker-app-push: build/docker_push

APP_COMPOSE_FILE ?= $(build_docker_dir)/docker-compose.yml
APP_COMPOSE_CMD := APP_DOCKER_URL=$(APP_DOCKER_URL) APP_NAME=$(APP_NAME) docker compose -p $(APP_NAME)_servers -f $(APP_COMPOSE_FILE)
APP_COMPOSE_CLEAN_FLAGS ?= --volumes --remove-orphans

## docker compose for the runnable jar, follow with a docker cmd such as up, down, shell or pull
docker-app: | _verify-DOCKER_CMD
	$(MAKE) docker-app-$(DOCKER_CMD)

# docker compose up for APP_JAR
docker-app-up: build/docker_built
	$(APP_COMPOSE_CMD) up -d

# stops the docker APP_JAR for docker-compose.yml
docker-app-down:
	$(APP_COMPOSE_CMD) down $(APP_COMPOSE_CLEAN_FLAGS)

docker-app-shell: docker-app-up
	docker exec -it $(APP_NAME) bash -l
