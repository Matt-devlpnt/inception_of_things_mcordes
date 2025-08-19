all:
	@bash ./scripts/init.sh

fclean:
	@rm -f script.log
	@sudo k3d cluster delete cluster-1 > /dev/null
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi

re: fclean all

argo-key:
	@kubectl --insecure-skip-tls-verify -n argocd get secrets argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d ; echo

gitlab-key:
	@kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
