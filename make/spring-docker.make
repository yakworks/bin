# -------------
# spring-boot tasks for building docker
# Makefile-core.make should be imported before this
# -------------
gw := ./gradlew
build_docker_dir := build/docker
# source dir for deploy with Dockerfile etc..
deploy_src_dir := $(APP_DIR)/src/deploy

# rm -rf build/docker
clean-docker-build:
	@rm -rf $(build_docker_dir)

$(build_docker_dir):
	mkdir -p $@

# sets up the build/docker by copying in the src/deploy files, copy the executable jar
# then 'explodes' or unjars the executable jar so dockerfile can iterate on build changes
# layering docker see https://blog.jdriven.com/2019/08/layered-spring-boot-docker-images/
build/docker/Dockerfile: $(build_docker_dir)
	@ cp "$(deploy_src_dir)/Dockerfile" "$(build_docker_dir)/"; \
	  cp $(deploy_src_dir)/*.sh "$(build_docker_dir)/"
	@ cp $(APP_JAR) $(build_docker_dir)/app.jar; \
	  cd $(build_docker_dir); \
	  jar -xf app.jar; \

# $(build.sh) docker_build_prep $(deploy_src_dir) $(APP_JAR) $(build_docker_dir)

build/docker/built: build/docker/Dockerfile # stamp to track if it was built
	docker build -t $(APP_DOCKER_URL) $(build_docker_dir)/.
	@touch build/docker/built
