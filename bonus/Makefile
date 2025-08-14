all:
	@sudo k3d cluster delete cluster-1
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi
	@bash ./scripts/init.sh


fclean:
	@sudo k3d cluster delete cluster-1
	@kubectl delete namespace gitlab argocd dev
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi
