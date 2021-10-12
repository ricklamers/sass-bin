SHELL := /bin/bash

define derive_release_version
$$(echo $1 | cut -d "." -f1).$$(echo $1 | cut -d "." -f2).$2
endef

SASS_VERSION = 1.42.1
SASS_BIN_MINOR = 3
RELEASE_VERSION := $(call derive_release_version,${SASS_VERSION},${SASS_BIN_MINOR})

prep-release: clean release-announce set-child-package-json generate-release-package-json download-binaries

release-announce:
	@echo Sass version: ${SASS_VERSION}
	@echo Release version: ${RELEASE_VERSION}

download-binaries: \
	download-binaries-notice \
	download-binaries-linux-32 \
	download-binaries-linux-64 \
	download-binaries-darwin-64 \
	download-binaries-windows-32 \
	download-binaries-windows-64

download-binaries-notice:
	@echo "Downloading binaries..."

release: prep-release release-main release-bin-packages
	@echo "Releasing..."

release-main:
	npm publish

release-bin-packages:
	@echo "Releasing binaries..."
	cd npm/sass-bin-darwin-64 && npm publish
	cd npm/sass-bin-linux-32 && npm publish
	cd npm/sass-bin-linux-64 && npm publish
	cd npm/sass-bin-windows-64 && npm publish
	cd npm/sass-bin-windows-32 && npm publish

define download_zip_binary
	FILE=$1
	BIN_PATH=$2
	rm -rf ${BIN_PATH}
	mkdir -p ${BIN_PATH}
	wget -q https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/${FILE}
	unzip -q -o ${FILE} -d ${BIN_PATH}
	mv ${BIN_PATH}/dart-sass/* ${BIN_PATH}
	rm -r ${BIN_PATH}/dart-sass/
	rm ${FILE}
endef

define download_tar_binary
	FILE=$1
	BIN_PATH=$2
	rm -rf ${BIN_PATH}
	mkdir -p ${BIN_PATH}
	wget -q https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/${FILE}
	tar -xzf ${FILE} --directory ${BIN_PATH}
	mv ${BIN_PATH}/dart-sass/* ${BIN_PATH}
	rm -r ${BIN_PATH}/dart-sass/
	rm ${FILE}
endef

define install_package
	@cd $1 ;\
	npm pack ;\
	pack_file="$$(pwd)/$$(ls -1 *.tgz)" ;\
	echo $$pack_file ;\
	cd ../../ && npm install $$pack_file --no-save && rm $$pack_file
endef

define write_version_package_json
	cat $1/package-template.json | \
	sed "s|VERSION|${RELEASE_VERSION}|g" | \
	cat > $1/package.json
endef

download-binaries-linux-32:
	$(eval FILE=dart-sass-${SASS_VERSION}-linux-ia32.tar.gz)
	$(eval BIN_PATH=npm/sass-bin-linux-32/bin)
	@$(call download_tar_binary,${FILE},${BIN_PATH})
	@# Replace sass script contained in the tarball with modified version
	@cp ${BIN_PATH}/../sass ${BIN_PATH}/sass
	@chmod +x ${BIN_PATH}/src/dart

download-binaries-linux-64:
	$(eval FILE=dart-sass-${SASS_VERSION}-linux-x64.tar.gz)
	$(eval BIN_PATH=npm/sass-bin-linux-64/bin)
	@$(call download_tar_binary,${FILE},${BIN_PATH})
	@chmod +x ${BIN_PATH}/sass

download-binaries-darwin-64:
	$(eval FILE=dart-sass-${SASS_VERSION}-macos-x64.tar.gz)
	$(eval BIN_PATH=npm/sass-bin-darwin-64/bin)
	@$(call download_tar_binary,${FILE},${BIN_PATH})
	@# Replace sass script contained in the tarball with modified version
	@cp ${BIN_PATH}/../sass ${BIN_PATH}/sass
	@chmod +x ${BIN_PATH}/src/dart

download-binaries-windows-32:
	$(eval FILE=dart-sass-${SASS_VERSION}-windows-ia32.zip)
	$(eval BIN_PATH=npm/sass-bin-windows-32/bin)
	@$(call download_zip_binary,${FILE},${BIN_PATH})

download-binaries-windows-64:
	$(eval FILE=dart-sass-${SASS_VERSION}-windows-x64.zip)
	$(eval BIN_PATH=npm/sass-bin-windows-64/bin)
	@$(call download_zip_binary,${FILE},${BIN_PATH})

install-local-deps-darwin-64:
	$(call install_package,npm/sass-bin-darwin-64)

install-local-deps-windows-64:
	$(call install_package,npm/sass-bin-windows-64)

install-local-deps-windows-32:
	$(call install_package,npm/sass-bin-windows-32)

install-local-deps-linux-32:
	$(call install_package,npm/sass-bin-linux-32)

install-local-deps-linux-64:
	$(call install_package,npm/sass-bin-linux-64)

clean:
	@echo "Cleaning..."
	@find . -name 'package.json' -type f -prune -exec rm '{}' +
	@find . -name '*.tgz' -type f -prune -exec rm '{}' +
	@find . -name 'bin' -type d -prune -exec rm -r '{}' +

set-child-package-json:
	@echo "Write templates to package.json..."
	@$(call write_version_package_json,npm/sass-bin-darwin-64)
	@$(call write_version_package_json,npm/sass-bin-windows-64)
	@$(call write_version_package_json,npm/sass-bin-windows-32)
	@$(call write_version_package_json,npm/sass-bin-linux-64)
	@$(call write_version_package_json,npm/sass-bin-linux-32)

generate-local-package-json:
	@echo "Generate local root package.json..."
	@VERSION="${RELEASE_VERSION}" ;\
	PATH_DARWIN_64="file:$$(pwd)/npm/sass-bin-darwin-64" ;\
	PATH_LINUX_32="file:$$(pwd)/npm/sass-bin-linux-32" ;\
	PATH_LINUX_64="file:$$(pwd)/npm/sass-bin-linux-64" ;\
	PATH_WINDOWS_32="file:$$(pwd)/npm/sass-bin-windows-32" ;\
	PATH_WINDOWS_64="file:$$(pwd)/npm/sass-bin-windows-64" ;\
	cat package-template.json | \
	sed "s|PATH_DARWIN_64|$$PATH_DARWIN_64|g" | \
	sed "s|PATH_LINUX_32|$$PATH_LINUX_32|g" | \
	sed "s|PATH_LINUX_64|$$PATH_LINUX_64|g" | \
	sed "s|PATH_WINDOWS_32|$$PATH_WINDOWS_32|g" | \
	sed "s|PATH_WINDOWS_64|$$PATH_WINDOWS_64|g" | \
	sed "s|VERSION|$$VERSION|g" | \
	cat > package.json


generate-release-package-json:
	@echo "Generate release root package.json..."
	@VERSION="${RELEASE_VERSION}" ; \
	cat package-template.json | \
	sed "s|PATH_DARWIN_64|$$VERSION|g" | \
	sed "s|PATH_LINUX_32|$$VERSION|g" | \
	sed "s|PATH_LINUX_64|$$VERSION|g" | \
	sed "s|PATH_WINDOWS_32|$$VERSION|g" | \
	sed "s|PATH_WINDOWS_64|$$VERSION|g" | \
	sed "s|VERSION|$$VERSION|g" | \
	cat > package.json