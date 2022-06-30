# Install

```bash
# Build php container
make build-php
# Start containers
make up
# Wait for MySQL start (few seconds), then install Magento
make install
> ...
> [SUCCESS]: Magento Admin URI: /admin_1tif5v
```

Then go to http://localhost:8080/admin_1tif5v

Credentials are admin/admin123


# MySQL

```bash
mysql -h 127.0.0.1 --port 33009 -u akeneo -pakeneo
```

# Elasticsearch

To reindex all data:

```bash
docker-compose run --rm -u www-data php bin/magento indexer:reindex
```

# API

```bash
curl -X POST "http://localhost:8080/rest/V1/integration/admin/token" -H "Content-Type:application/json" -d '{"username":"admin", "password":"admin123"}'
> Response should be like "vbnf3hjklp5iuytre"

curl -X GET "http://localhost:8080/rest/V1/products/{sku}" -H "Authorization: Bearer vbnf3hjklp5iuytre"
```
