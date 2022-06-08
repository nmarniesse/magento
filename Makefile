.PHONY: build-php
build-php:
	docker build --target dev -t jellyfish/magento-php-dev:master .

.PHONY: up
up:
	docker-compose up -d --remove-orphans ${C}

.PHONY: down
down:
	docker-compose down -v

.PHONY: install
install:
	[ -f app/etc/env.php ] && rm app/etc/env.php || true
	[ -f app/etc/config.php ] && rm app/etc/config.php || true
	[ -f app/config_sandbox ] && rm app/config_sandbox || true
	docker-compose run --rm -u www-data php bin/magento setup:install \
		--cleanup-database \
		--base-url=http://localhost:8080 \
		--db-host=mysql \
		--db-name=akeneo \
		--db-user=akeneo \
		--db-password=akeneo \
		--admin-firstname=admin \
		--admin-lastname=admin \
		--admin-email=admin@admin.com \
		--admin-user=admin \
		--admin-password=admin123 \
		--language=en_US \
		--currency=USD \
		--timezone=America/Chicago \
		--use-rewrites=1 \
		--search-engine=elasticsearch7 \
		--elasticsearch-host=elasticsearch \
		--elasticsearch-port=9200 \
		--elasticsearch-index-prefix=magento2 \
		--elasticsearch-timeout=15
	docker-compose run --rm -u www-data php bin/magento module:disable Magento_TwoFactorAuth
	docker-compose run --rm -u www-data php bin/magento config:set oauth/consumer/enable_integration_as_bearer 1
