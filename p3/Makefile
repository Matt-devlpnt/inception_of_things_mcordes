all:
	@rm -f script.log
	@sudo k3d cluster delete cluster-1 >> ./script.log 2>&1
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) >> ./script.log 2>&1; \
	fi
	@bash ./scripts/init.sh

fclean:
	@rm -f script.log
	@sudo k3d cluster delete cluster-1 > /dev/null
	@if [ $$(docker images -qa | wc -l) -ne 0 ]; then \
		docker rmi -f $(shell docker images -qa) > /dev/null; \
	fi
