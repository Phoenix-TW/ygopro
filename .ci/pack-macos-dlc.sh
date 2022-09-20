#!/bin/bash
set -x
set -o errexit

ARCHIVE_FILES=(ygopro.app cards.cdb locales fonts textures strings.conf system.conf pack)

TARGET_PLATFORM=darwin

apt update && apt -y install tar zstd
mkdir dist replay

cp -rf locales/$TARGET_LOCALE/* .

tar -acf "dist/KoishiPro-dlc-$CI_COMMIT_REF_NAME-$TARGET_PLATFORM-$TARGET_LOCALE.tar.$ARCHIVE_SUFFIX" --exclude='.git*' "${ARCHIVE_FILES[@]}"
