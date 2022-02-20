EMVER := $(shell yq e ".version" manifest.yaml)
LNDG_SRC := $(shell find ./lndg)
S9PK_PATH=$(shell find . -name lndg.s9pk -print)

.DELETE_ON_ERROR:

all: verify

verify: lndg.s9pk $(S9PK_PATH)
	embassy-sdk verify $(S9PK_PATH)

install: lndg.s9pk 
	embassy-cli package install lndg.s9pk

lndg.s9pk: manifest.yaml assets/compat/* image.tar docs/instructions.md LICENSE icon.png
	embassy-sdk pack

image.tar: Dockerfile docker_entrypoint.sh ${LNDG_SRC}
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --driver docker-container --use
	docker buildx inspect --bootstrap
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/lndg/main:${EMVER} --platform=linux/arm64/v8 -f Dockerfile -o type=docker,dest=image.tar .

clean:
	rm -f lndg.s9pk
	rm -f image.tar