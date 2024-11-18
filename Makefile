run-backend:
	docker compose up ognisko

run-backend-bg:
	docker compose up -d ognisko

stop:
	docker compose down

logs:
	docker compose logs -f

shell:
	docker run -it --net=host --entrypoint /bin/bash ognisko:latest

pma:
	docker compose up phpmyadmin
