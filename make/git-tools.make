# -------------
# targets for git helpers
# -------------

git_tools := $(BUILD_BIN)/git_tools

## clones the docs pages, normally to build/gh-pages for github
git-clone-pages:
	$(git_tools) git-clone-pages

## pushes the docs pages that was cloned into build, normally build/gh-pages for github
git-push-pages:
	$(git_tools) git-push-pages
