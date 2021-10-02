SASS_VERSION=1.42.1

download-binaries: \
	download-binaries-linux-32 \
	download-binaries-linux-64 \
	download-binaries-darwin-64 \
	download-binaries-windows-32 \
	download-binaries-windows-64

release: release-main release-bin-packages
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
