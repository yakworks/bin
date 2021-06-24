# -------------
# Helper tasks to
# -------------

# --- docker builder ---
.PHONY: kube-config kube-create-ns kube-port-forward

# ----- kubernetes ------
kube-clean: ## removes everything with the app=${APP_NAME} under ${KUB_NAMESPACE}
	${build.sh} kubeClean "app=${APP_NAME}" ${KUB_NAMESPACE}

kube-config: ## creates kubectl config assumes $K8_USER $K8_TOKEN env vars are setup
	$(build.sh) kubeConfig ${KUB_SERVER} $$K8_USER $$K8_TOKEN ranch-dev

kube-create-ns: # creates the KUB_NAMESPACE namespace if its doesn't exist
	@$(build.sh) kubeCreateNamespace ${KUB_NAMESPACE}

kube-port-forward: ## runs kubectl port-forward to the ${KUB_DB_SERVICE_NAME}
	kubectl port-forward --namespace=${KUB_NAMESPACE} --address 0.0.0.0 service/${KUB_DB_SERVICE_NAME} 1${DB_PORT}:${DB_PORT}

version: ## Prints the BUILD_VERSION which will be released
	@echo $(BUILD_VERSION)

update-version: #updates version in version.properties
	@${build.sh} updateVersionProps ${VERSION}

git-tag: ##creates new git tag and pushes to github
	@${build.sh} git_tag $(VERSION) "[skip ci] bumped version to $(VERSION)"
	@${build.sh} git_push_tags

release: update-version build/docker-build build/docker-deploy git-tag #Create and push git tag, build new docker image, push to dockerhub
