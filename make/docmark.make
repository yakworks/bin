# -------------
# Common targets for docs engine
# -------------
docmark.sh := $(BUILD_BIN)/docmark

.PHONY: docmark-publish docmark-git-push

# clones pages branch, builds and copies into branch, doesn't push,
# git-push-pages should be called after this
docmark-publish-prep: docmark-build git-clone-pages
	@cp -r build/site/. build/gh-pages
	@if [ -d "build/docs/groovydoc" ]; then cp -r build/docs/groovydoc build/site/api; fi

# --- helpers -----
## start the docs server locally to serve pages
docmark-start: docmark-copy-readme
	$(docmark.sh) docmark_run

## use this to open shell and test targets for CI such as docmark-build
docmark-shell:
	$(docmark.sh) docmark_shell

## build the docs, run this inside the docmark docker, call docmark-shell target first
docmark-build: docmark-copy-readme
	docmark build --site-dir build/site

# copy readme to main index
docmark-copy-readme:
	$(docmark.sh) cp_readme_index $(VERSION)
