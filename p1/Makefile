all:
	@bash ./scripts/init.sh

fclean:
	@vagrant halt -f
	@vagrant destroy -f
	@rm -rf .vagrant

re: fclean all
