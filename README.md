# Docker-AzCopy

[![ghcr-size](https://ghcr-badge.egpl.dev/licenseware/docker-azcopy/size)](https://github.com/orgs/licenseware/packages/container/package/docker-azcopy)
[![ghcr-tags](https://ghcr-badge.egpl.dev/licenseware/docker-azcopy/latest_tag?label=latest-tag)](https://github.com/orgs/licenseware/packages/container/package/docker-azcopy)

## Usage

```bash
STORAGE_ACCOUNT_NAME=examplesa
CONTAINER_NAME=examplecontainer
# optional
SAS_TOKEN="XXXXXXX"

docker run --rm \
  --name azcopy \
  -v /path/to/data/dir:/data-dir:ro \
  ghcr.io/licenseware/docker-azcopy:v10.26.0 \
  azcopy copy "/data-dir" "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME/data-dir$SAS_TOKEN" --recursive
```
