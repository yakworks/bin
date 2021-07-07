# -------------
# Common circle CI helpers.
# -------------

circle.sh := $(BUILD_BIN)/circle

# generates the cache-key.tmp for CI to checksum. depends on PROJECT_SUBPROJECTS var
cache-key-file: | _verify_PROJECT_SUBPROJECTS
	@$(circle.sh) create_cache_key "$(PROJECT_SUBPROJECTS)"
