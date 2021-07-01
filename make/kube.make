# -------------
# kubernetes targets
# -------------

.PHONY: kube-config kube-create-ns kube-port-forward

## removes everything with the app=$(APP_NAME) under $(KUB_NAMESPACE)
kube-clean:
	$(build.sh) kubeClean "app=$(APP_NAME)" $(KUB_NAMESPACE)

## creates kubectl config assumes $K8_USER $K8_TOKEN env vars are setup
kube-config:
	$(build.sh) kubeConfig $(KUB_SERVER) $$K8_USER $$K8_TOKEN ranch-dev

## creates the KUB_NAMESPACE namespace if its doesn't exist
kube-create-ns:
	@$(build.sh) kubeCreateNamespace $(KUB_NAMESPACE)

## runs kubectl port-forward to the $(KUB_DB_SERVICE_NAME)
kube-port-forward:
	kubectl port-forward --namespace=$(KUB_NAMESPACE) --address 0.0.0.0 service/$(KUB_DB_SERVICE_NAME) 1$(DB_PORT):$(DB_PORT)

##creates new git tag and pushes to github
git-tag:
	@$(build.sh) git_tag $(VERSION) "[skip ci] bumped version to $(VERSION)"
	@$(build.sh) git_push_tags

release: update-version build/docker-build build/docker-deploy git-tag #Create and push git tag, build new docker image, push to dockerhub
