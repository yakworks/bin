# -------------
# Pages collection of includes for common needs to cut down on the include noise in main makefile
# for a project that is only for docs this should be all that is needed to include
# -------------
include $(BUILD_BIN)/makefiles/secrets.make
include $(BUILD_BIN)/makefiles/git-tools.make
include $(BUILD_BIN)/makefiles/kubectl-config.make
include $(BUILD_BIN)/makefiles/circle.make
include $(BUILD_BIN)/makefiles/docker.make
include $(BUILD_BIN)/makefiles/docmark.make

PAGES_DEPLOY_TPL := $(BUILD_BIN)/kube/docmark-pages-deploy.tpl.yml

pages-delete-deployment:
	kubectl delete deployment,ingress --selector="pages=$(PAGES_APP_KEY)" --namespace="$(PAGES_KUBE_NAMESPACE)"

## apply docmark-pages-deploy.tpl kubectl to deploy site to kubernetes cluster
pages-deploy: pages-delete-deployment
	@${kube_tools} kubeApplyTpl $(PAGES_DEPLOY_TPL)
