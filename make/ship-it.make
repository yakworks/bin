# -------------
# targets for release process
# included in core
# -------------

shipit := $(BUILD_BIN)/ship_it
git_tools := $(BUILD_BIN)/git_tools

## clones the docs pages, normally to build/gh-pages for github
git-clone-pages: | _verify_GH_PAGES_BRANCH _verify_GITHUB_FULLNAME
	$(git_tools) git_clone_pages $(GH_PAGES_BRANCH) $(GH_PAGES_DIR) $(GITHUB_FULLNAME)

## pushes the docs pages that was cloned into build, normally build/gh-pages for github
git-push-pages: | _verify_GH_PAGES_BRANCH _verify_GITHUB_FULLNAME
	$(git_tools) git_push_pages $(GH_PAGES_BRANCH) $(GH_PAGES_DIR) $(GITHUB_FULLNAME)

# updates change log, bumps version, updates the publishingVersion in README
release-prep: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_CHANGELOG_NAME _verify_GITHUB_FULLNAME
	$(shipit) release_prep $(VERSION) $(PUBLISHED_VERSION) $(CHANGELOG_NAME) $(GITHUB_FULLNAME)

# pushes tag release to github
release-tag:
	$(shipit) release_tag

## updates files and pushes tag release
release-it: release-tag release-prep
