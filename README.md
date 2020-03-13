# bin
common scripts, templates and helpers for building and develpment

## Lost art of the makefile

- https://www.olioapps.com/blog/the-lost-art-of-the-makefile/
- https://3musketeers.io/

## 12 factor app is the philosophy
- https://12factor.net

## Semantic versioning support
```semver.sh ``` which is based on [this](https://github.com/fsaintjacques/semver-tool) tool provides utility
to manipulate semantic version strings from bash scripts.

syntax : ```semver bump (major|minor|patch|pre-release) <version>```

Note: Version must be properly formatted as a semantic version string

**Examples**: 

```bash
semver bump pre-release 10.0.0-RC.1 > 10.0.0-RC.2
semver bump patch 10.0.0 > 10.0.1
semver bump minor 10.0.0 > 10.1.0
semver bump major 10.0.0 > 11.0.0
```

**```build_functions.sh```** helpers
- provides a helper method to bump version using eg. ```incrementVersion(patch 10.0.0)```
- update version.properties with given version. ```updateVersion(10.0.0-RC.1)```

**Make file helpers**

Makefile.deploy-common-targets must have been included in the main make file

- ``make version`` will print the version which will be released.
- ``make update-version`` will update version.properties with new version
- ``make git-tag`` Tags the current version and pushes to github
- ``make release`` will update version, build docker image, push the image to docker hub and tag to github

**How to use semantic version and release support in another projects**
- The project must have a version.properties file with proper semantic version
- within build.sh of the project, source build_functions.sh and use updateVersion/incrementVersion as explained above to manipulate versions as required
- Within main make file of the project, include ``Makefile.deploy-common-targets``. The above mentioned common targets will be available to the project.


# Refs

links for using make and docker
- https://amaysim.engineering/the-3-musketeers-how-make-docker-and-compose-enable-us-to-release-many-times-a-day-e92ca816ef17
- https://3musketeers.io/about/#what
- https://www.freecodecamp.org/news/want-to-know-the-easiest-way-to-save-time-use-make-eec453adf7fe/
- https://swcarpentry.github.io/make-novice/02-makefiles/
- https://krzysztofzuraw.com/blog/2016/makefiles-in-python-projects.html
- https://datakurre.pandala.org/2016/04/evolution-of-our-makefile-for-docker.html/
- https://engineering.docker.com/2019/06/containerizing-test-tooling-creating-your-dockerfile-and-makefile/
- https://github.com/marmelab/make-docker-command/blob/master/Makefile
- https://github.com/mvanholsteijn/docker-makefile
- https://itnext.io/docker-makefile-x-ops-sharing-infra-as-code-parts-ea6fa0d22946

## versioning example

- https://github.com/mvanholsteijn/docker-makefile

## docker makefiles
- https://philpep.org/blog/a-makefile-for-your-dockerfiles
- https://stackoverflow.com/questions/44969605/incrementally-build-docker-image-hierarchy-with-makefile
