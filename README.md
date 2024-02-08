# Docker-AzCopy

## Usage

```bash
STORAGE_ACCOUNT_NAME=examplesa
CONTAINER_NAME=examplecontainer
# optional
SAS_TOKEN="XXXXXXX"

docker run --rm \
  --name azcopy \
  -v /path/to/data/dir:/data-dir:ro \
  ghcr.io/licenseware/docker-azcopy:v10.23.0 \
  copy "/data-dir" "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME/data-dir$SAS_TOKEN" --recursive
```
