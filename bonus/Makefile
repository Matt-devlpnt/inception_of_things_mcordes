all:
	@sudo k3d cluster delete bonus-cluster
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi
	@bash ./scripts/init.sh

forward-argocd:
	kubectl port-forward svc/argocd-server -n argocd 8081:443 --address 0.0.0.0
# ajouter --address 0.0.0.0 pour autoriser windows à se connecter à wsl

forward-gitlab:
	kubectl port-forward -n gitlab svc/gitlab-nginx-ingress-controller 8888:80 8443:443 --address 0.0.0.0
# ajouter --address 0.0.0.0 pour autoriser windows à se connecter à wsl

fclean:
	@helm uninstall gitlab -n gitlab 2>/dev/null || true
	@kubectl delete namespace gitlab 2>/dev/null || true
	@if [ -n "$$(docker ps -q)" ]; then \
		docker stop $$(docker ps -q); \
	fi
	@if [ -n "$$(docker ps -aq)" ]; then \
		docker rm $$(docker ps -aq); \
	fi
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $$(docker images -qa) >/dev/null || true; \
	fi
	@k3d cluster delete bonus-cluster 2>/dev/null || true
