#!/bin/bash

our_current_version=$(curl https://api.github.com/repos/sniccowp/php-scoper-wordpress-excludes/tags -s | jq -r .[].name | grep '^[0-9]\.[0-9]*\.[0-9]*$' | sort -nr | head -n1)
echo "Current version: $our_current_version"

tmp_their_current_version=$(curl https://api.github.com/repos/php-stubs/wordpress-stubs/tags -s | jq -r .[].name | grep '^v[0-9]\.[0-9]*\.[0-9]*$' | sort -nr | head -n1)
their_current_version=$(echo "$tmp_their_current_version" | cut -c 2-)
echo "Latest WordPress version: $their_current_version"

if dpkg --compare-versions "$their_current_version" gt "$our_current_version";
then
        do_update=true
else
        do_update=false
fi

if $do_update;
then
        composer require php-stubs/wordpress-stubs:"$their_current_version" --dev
        composer update php-stubs/wordpress-stubs
        composer install
        vendor/bin/generate-excludes --json
        git add -A
        git commit -a -m "Automatic release for WordPress: $their_current_version"
        git push
        git tag "$their_current_version" HEAD
        git push --tags
        exit 0
else
	echo "Everything is up-to-date!"
        exit 1
fi
