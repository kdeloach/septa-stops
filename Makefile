.PHONY: all clean console docker-image

DOCKER_IMAGE_TAG:=septa-stops
DOCKER_WORKDIR:=/usr/src
DB_FILE:=stops.db
DB_SOURCES:=routes.txt trips.txt stops.txt stop_times.txt
DIST_DIR=dist

all: $(DIST_DIR)

clean:
	git clean -fdx

console:
	docker run --rm -ti \
		--entrypoint /bin/bash \
		-v $(PWD):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE_TAG)

docker-image: Dockerfile
	docker build -t $(DOCKER_IMAGE_TAG) .

output.csv: $(DB_FILE) query.sql
	docker run --rm -i \
		--entrypoint /usr/bin/spatialite \
		-v $(PWD):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE_TAG) \
		-header -csv \
		$(DB_FILE) < query.sql > output.csv

all.csv: $(DB_FILE) all.sql
	docker run --rm -i \
		--entrypoint /usr/bin/spatialite \
		-v $(PWD):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE_TAG) \
		-header -csv \
		$(DB_FILE) < all.sql > all.csv

$(DIST_DIR): all.csv output.csv
	mkdir -p $(DIST_DIR)

	docker run --rm -ti \
		--entrypoint ./create_geojson.py \
		-v $(PWD):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE_TAG)

	docker run --rm -ti \
		--entrypoint ./create_all.py \
		-v $(PWD):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE_TAG)

$(DB_FILE): docker-image $(DB_SOURCES) columns.txt
	# Create SQLite database and insert GTFS data
	docker run --rm -ti \
		--entrypoint /usr/local/bin/csvsql \
		-v $(PWD):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE_TAG) \
		--db sqlite:///$(DB_FILE) \
		--insert $(DB_SOURCES) || true

columns.txt:
	head -n 1 $(DB_SOURCES) > columns.txt

$(DB_SOURCES): google_bus.zip
	unzip -n google_bus.zip

google_bus.zip: gtfs_public.zip
	unzip -n gtfs_public.zip

gtfs_public.zip:
	wget https://github.com/septadev/GTFS/releases/download/v20170314.1/gtfs_public.zip
