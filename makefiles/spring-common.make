# -------------
# Spring/grails collection of includes for common needs to cut down on the include noise in main makefile
# For a spring project that has a docker builder, docs,
# -------------
# --- helper makefiles ---
include $(BUILD_BIN)/makefiles/secrets.make
include $(BUILD_BIN)/makefiles/docker.make
include $(BUILD_BIN)/makefiles/kubectl-config.make
include $(BUILD_BIN)/makefiles/kube.make
include $(BUILD_BIN)/makefiles/jbuilder-docker.make
include $(BUILD_BIN)/makefiles/spring-gradle.make
include $(BUILD_BIN)/makefiles/spring-docker.make
include $(BUILD_BIN)/makefiles/circle.make
include $(BUILD_BIN)/makefiles/docmark.make
