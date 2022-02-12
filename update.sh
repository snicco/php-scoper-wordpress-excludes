#!/bin/bash

current_version=$(curl https://api.github.com/repos/sniccowp/php-scoper-wordpress-excludes/tags -s | jq -r .[].name | grep '^[0-9]\.[0-9]*\.[0-9]*$' | sort -nr | head -n1)
echo "Current version: $current_version"

tmp_version=$(curl https://api.github.com/repos/php-stubs/wordpress-stubs/tags -s | jq -r .[].name | grep '^v[0-9]\.[0-9]*\.[0-9]*$' | sort -nr | head -n1)
lastest_version=$(echo "$tmp_version" | cut -c 2-)
echo "Latest WordPress version: $lastest_version"

if dpkg --compare-versions "$lastest_version" gt "$current_version";
then
	rm -rf generated/
	mkdir generated
        composer require php-stubs/wordpress-stubs:"$lastest_version" --dev
        composer update php-stubs/wordpress-stubs
        composer install
        vendor/bin/generate-excludes --json --exclude-empty
	mv generated/exclude-wordpress-globals-constants.json generated/exclude-wordpress-constants.json
        git add -A
        git commit -a -m "Automatic release for WordPress: $lastest_version"
        git push
        git tag "$lastest_version" HEAD
        git push --tags
        echo "Tagged new version:" "$lastest_version"
        exit 0
else
	echo "Everything is up-to-date!"
        exit 1
fi
