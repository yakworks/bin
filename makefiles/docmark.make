# -------------
# Common targets for docs engine
# -------------
docmark.sh := $(BUILD_BIN)/docmark

# --- Dockers ---
## docker for docmark docs, follow with a docker cmd  up, down, shell or pull
docker-dockmark: | _verify-DOCKER_CMD
	$(MAKE) docker-dockmark-$(DOCKER_CMD)

# start the docs server locally to serve pages
docker-dockmark-up: docmark-copy-readme
	$(docmark.sh) docmark_run

# start the docs server locally to serve pages
docker-dockmark-down: docmark-copy-readme
	$(docmark.sh) dockerRemove docmark-serve

# use this to open shell and test targets for CI such as docmark-build
docker-dockmark-shell:
	$(docmark.sh) docmark_shell

# pulls the latest version
docker-dockmark-pull:
	$(docmark.sh) docmark_pull

# --- BUILDS ----

# copy readme to main index
docmark-copy-readme:
	$(docmark.sh) cp_readme_index $(VERSION)

## build the docs, run this inside docmark container such as in CI, make docker-dockmark-shell locally
docmark-build: docmark-copy-readme
	docmark build --site-dir build/site

# clones pages branch, builds and copies into branch, doesn't push,
# git_push_pages should be called after this or task that calls the push should depend on this one
# this should be run inside of the docmark docker
docmark-publish-prep: docmark-build git-clone-pages
	@cp -r build/site/. build/gh-pages
	@if [ -d "build/docs/groovydoc" ]; then cp -r build/docs/groovydoc build/site/api; fi

docmark-publish: docmark-publish-prep
	$(MAKE) git-push-pages

.PHONY: publish-docs
# main publisher for docs, empty unless RELEASABLE_BRANCH below
publish-docs:

# TODO at some point we want to look at publishing snapshot version of docs like we once did?
# NOT_SNAPSHOT := $(if $(IS_SNAPSHOT),,true)
# ifneq (,$(and $(RELEASABLE_BRANCH),$(NOT_SNAPSHOT)))

ifdef RELEASABLE_BRANCH

 publish-docs:
	@if [ ! "$(IS_SNAPSHOT)" ]; then \
		echo "not a snapshot, publishing docs"; \
		$(MAKE) docmark-publish; \
	else \
		echo "IS_SNAPSHOT ... NOT publishing docs "; \
	fi;

endif
