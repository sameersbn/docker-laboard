all: build

build:
	@docker build --tag=${USER}/laboard .
