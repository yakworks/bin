# -------------
# kubernetes targets
# -------------
kube_tools := $(BUILD_BIN)/kube_tools

.PHONY: kube-clean kube-config kube-create-ns kube-port-forward

## removes everything with the app=$(APP_KEY) under $(APP_KUBE_NAMESPACE)
kube-clean: | _verify_APP_KUBE_NAMESPACE
	kubectl delete deployment,svc,configmap,ingress --selector="app=$(APP_KEY)" --namespace="$(APP_KUBE_NAMESPACE)"

# double $$ on K8_USER and K8_TOKEN as they should be env variables
## creates kubectl config assumes $K8_SERVER $K8_USER $K8_TOKEN env vars are setup
kube-config: | _verify_K8_SERVER
	@kubectl config set-cluster ranch-dev --server="$(K8_SERVER)"; \
	  kubectl config set-credentials "$(K8_USER)" --token="$(K8_TOKEN)"; \
	  kubectl config set-context "ranch-dev" --user="$(K8_USER)" --cluster="ranch-dev"; \
	  kubectl config use-context "ranch-dev";

## creates the APP_KUBE_NAMESPACE namespace if its doesn't exist
kube-create-ns: | _verify_APP_KUBE_NAMESPACE
	@$(kube_tools) kubeCreateNamespace $(APP_KUBE_NAMESPACE)

## runs kubectl port-forward to the $(KUBE_DB_SERVICE_NAME)
kube-port-forward:
	kubectl port-forward --namespace=$(APP_KUBE_NAMESPACE) --address 0.0.0.0 service/$(KUBE_DB_SERVICE_NAME) 1$(DB_PORT):$(DB_PORT)
