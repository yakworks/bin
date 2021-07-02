# bin
common scripts, templates and helpers for building and develpment

## Lost art of the makefile

- https://www.olioapps.com/blog/the-lost-art-of-the-makefile/
- https://3musketeers.io/

## 12 factor app is the philosophy
- https://12factor.net

## style guides we endeveur to follow

https://style-guides.readthedocs.io/en/latest/makefile.html
https://google.github.io/styleguide/shellguide.html

## Semantic versioning support
`semver` which is based on [this](https://github.com/fsaintjacques/semver-tool) tool provides utility
to manipulate semantic version strings from bash scripts.

syntax : `semver bump (major|minor|patch|pre-release) <version>`

Note: Version must be properly formatted as a semantic version string


**Examples**: 

| command  | output |
| ------------- | ------------- |
|./semver bump pre-release 10.0.0-RC.1 | 10.0.0-RC.2 |
|./semver bump patch 10.0.0| 10.0.1 |
|./semver bump minor 10.0.0| 10.1.0 |
|./semver bump major 10.0.0 | 11.0.0 |


Note: `./semver bump pre-release` will work only if the version has pre release part, eg `10.0.0-RC.2`

**`all.sh`** helpers

| command  | output | Note |
| ------------- | ------------- |----- |
|`incrementVersion patch 10.0.0` | 10.0.1| Helper method to increment version. It calls `semver bump` with given arguments
|`updateVersionProps 10.0.0-RC.1` | updates the version.properties with given version string | it expects version.properties in current directory|


**Example**

```bash
source ./all.sh
incrementVersion patch 10.0.0 #Will output 10.0.1
updateVersionProps 10.0.11 #Will update version.properties with version=10.0.11
```

**Make file helpers**

| Make target  |  Note |
| ------------- | ----- |
| `make version` | prints the version which will be released. |
| `make update-version` | updates version.properties with new version |
| `make git-tag` | Tags the current version and pushes to github |
| `make release` | it depends on following targets `update-version` `build/docker-build` `build/docker-deploy` `git-tag` <br/><br/> so it will update the version, build docker image, push image to dockerhub and then create a git tag 


`Makefile.deploy-common-targets` must have been included in the main make file of the target project
eg. `include /PATH-TO/Makefile.deploy-common-targets`


# TODO
Want to start using this to bring some standardization to the shell docs

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
