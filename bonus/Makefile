all:
	@sudo k3d cluster delete bonus-cluster
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi
	@bash ./scripts/init.sh

forward: # permet de forward argocd sur le port 8081
	kubectl port-forward svc/argocd-server -n argocd 8081:443

fclean:
	@sudo k3d cluster delete bonus-cluster
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi
