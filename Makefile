IMAGE = my-blog
CONTAINER = my-blog-dev

up:
	docker build -t $(IMAGE) .
	docker run --rm --name $(CONTAINER) -p 8080:8080 -v $(PWD):/app -v /app/node_modules $(IMAGE)

down:
	docker stop $(CONTAINER)

build:
	docker build -t $(IMAGE) .

.PHONY: up down build
