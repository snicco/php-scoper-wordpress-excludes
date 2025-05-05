#!/bin/bash
#
# Update repository from the latest release of php-stubs/wordpress-stubs
#

current_version="$(composer show --available --format=json snicco/php-scoper-wordpress-excludes | jq -r '."versions" | first(.[] | select(test("^v?\\d+\\.\\d+\\.\\d+$"))) | ltrimstr("v")')"
echo "Current version: ${current_version}"

php_stubs_latest_version="$(composer show --available --format=json php-stubs/wordpress-stubs | jq -r '."versions" | first(.[] | select(test("^v?\\d+\\.\\d+\\.\\d+$"))) | ltrimstr("v")')"
echo "Latest WordPress version: ${php_stubs_latest_version}"

if dpkg --compare-versions "${php_stubs_latest_version}" le "${current_version}"; then
	echo "Everything is up-to-date!"
	exit 1
fi

rm -rf generated/
mkdir generated
composer require --dev --no-update "php-stubs/wordpress-stubs:${php_stubs_latest_version}"
composer update php-stubs/wordpress-stubs

vendor/bin/generate-excludes --json --exclude-empty
mv generated/exclude-wordpress-globals-constants.json generated/exclude-wordpress-constants.json

if git diff --quiet; then
	echo "No content change!"
	exit 2
fi

git add -A
git commit -a -m "Automatic release for WordPress: ${php_stubs_latest_version}"
git tag "${php_stubs_latest_version}" HEAD
git push
git push --tags

echo "Tagged new version: ${php_stubs_latest_version}"
