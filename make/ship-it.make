# -------------
# targets for release process
# included in core
# -------------

shipit := $(BUILD_BIN)/ship_it
git_tools := $(BUILD_BIN)/git_tools

# clones the docs pages, normally to build/gh-pages for github
git-clone-pages: | _verify_PAGES_BRANCH _verify_PROJECT_FULLNAME
	$(git_tools) git_clone_pages $(PAGES_BRANCH) $(PAGES_BUILD_DIR) $(PROJECT_FULLNAME)

# pushes the docs pages that was cloned into build, normally build/gh-pages for github
git-push-pages: | _verify_PAGES_BRANCH _verify_PROJECT_FULLNAME
	$(git_tools) git_push_pages $(PAGES_BRANCH) $(PAGES_BUILD_DIR) $(PROJECT_FULLNAME)

# updates change log, bumps version, updates the publishingVersion in README
release-prep: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(shipit) release_prep $(VERSION) $(PUBLISHED_VERSION) $(RELEASE_CHANGELOG) $(PROJECT_FULLNAME)

# pushes tag release to github
release-tag: release-prep | _verify_VERSION _verify_RELEASABLE_BRANCH _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(shipit) release_tag $(VERSION) $(RELEASE_CHANGELOG) $(RELEASABLE_BRANCH) $(PROJECT_FULLNAME)

# _verify_RELEASABLE_BRANCH ensures its set to a value or this will fail
# updates files and pushes tag release, use in CI
release-it: release-tag | _verify_RELEASABLE_BRANCH
