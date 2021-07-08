# -------------
# targets for release process on git, not
# -------------

shipit := $(BUILD_BIN)/ship_it
git_tools := $(BUILD_BIN)/git_tools

# clones the docs pages, normally to build/gh-pages for github
git-clone-pages: | _verify_PAGES_BRANCH _verify_PROJECT_FULLNAME
	$(git_tools) git_clone_pages $(PAGES_BRANCH) $(PAGES_BUILD_DIR) $(PROJECT_FULLNAME)

# pushes the docs pages that was cloned into build, normally build/gh-pages for github
git-push-pages: | _verify_PAGES_BRANCH _verify_PROJECT_FULLNAME
	$(git_tools) git_push_pages $(PAGES_BRANCH) $(PAGES_BUILD_DIR) $(PROJECT_FULLNAME)

update-changelog: | _verify_VERSION _verify_PUBLISHED_VERSION _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(git_tools) update_changelog $(VERSION) $(PUBLISHED_VERSION) $(RELEASE_CHANGELOG) $(PROJECT_FULLNAME)

update-readme-version: | _verify_VERSION
	$(shipit) replace_version "$(VERSION)" README.md

bump-version: | _verify_VERSION
	$(shipit) bump_version_props "$(VERSION)"

# updates change log, bumps version, updates the publishingVersion in README
release-prep: update-changelog update-readme-version bump-version
	@echo "snapshot:false ... did release process for version bump"

# pushes tag release to github
release-tag: release-prep | _verify_VERSION _verify_RELEASABLE_BRANCH _verify_RELEASE_CHANGELOG _verify_PROJECT_FULLNAME
	$(shipit) release_tag $(VERSION) $(RELEASE_CHANGELOG) $(RELEASABLE_BRANCH) $(PROJECT_FULLNAME)

