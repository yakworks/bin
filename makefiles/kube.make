# -------------
# kubernetes targets
# -------------

.PHONY: kube-clean kube-config kube-create-ns kube-port-forward

## removes everything with the app=$(APP_KEY) under $(APP_KUB_NAMESPACE)
kube-clean: | _verify_APP_KUB_NAMESPACE
	kubectl delete deployment,svc,configmap,ingress --selector="app=$(APP_KEY)" --namespace="$(APP_KUB_NAMESPACE)"

# double $$ on K8_USER and K8_TOKEN as they should be env variables
## creates kubectl config assumes $K8_SERVER $K8_USER $K8_TOKEN env vars are setup
kube-config: | _verify_K8_SERVER
	@kubectl config set-cluster ranch-dev --server="$(K8_SERVER)"; \
	  kubectl config set-credentials "$(K8_USER)" --token="$(K8_TOKEN)"; \
	  kubectl config set-context "ranch-dev" --user="$(K8_USER)" --cluster="ranch-dev"; \
	  kubectl config use-context "ranch-dev";

## creates the KUB_NAMESPACE namespace if its doesn't exist
kube-create-ns: | _verify_APP_KUB_NAMESPACE
	@[ ! "$(kubectl get ns | grep $(APP_KUB_NAMESPACE))" ] && kubectl create namespace "$(APP_KUB_NAMESPACE)"

## runs kubectl port-forward to the $(KUB_DB_SERVICE_NAME)
kube-port-forward:
	kubectl port-forward --namespace=$(APP_KUB_NAMESPACE) --address 0.0.0.0 service/$(KUB_DB_SERVICE_NAME) 1$(DB_PORT):$(DB_PORT)
