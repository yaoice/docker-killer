# build image

## build arm image

use buildx to build multiarch images
```
$(eval PLATFORM=linux_arm64)
$(eval OS=linux)
$(eval ARCH=arm64)
DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --no-cache \
           --network=host \
           --platform linux/arm64 \
           --load -t docker-killer:v1 \
           --build-arg http_proxy=${http_proxy} -f Dockerfile .
```

