# ---
# commons base helpers and functions for build.sh, expects a BUILD_VARS to be populated when functions called
# meant to be imported like so
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/build_functions.sh
# ---
binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "sourcing from binDir $binDir"
source ${binDir}/setVar
source ${binDir}/versions
source ${binDir}/makeEnv.sh
source ${binDir}/docker
source ${binDir}/kubernetes
source ${binDir}/yaml
source ${binDir}/git_tools
source ${binDir}/publish
source ${binDir}/circle
source ${binDir}/docmark

# source the version.properties
source version.properties
setVersion $version

# dummy function so that this can through first and clone the git yakworks/bin
function init {
  echo "init"
}

# create env file from BUILD_VARS for importing into makefile.
# arg $1 - the file to use
function createEnvFile {
  echo "# ----- Generated from build.sh --------" > $1
  for varName in $BUILD_VARS; do
      val=${!varName}
      echo "$varName=$val" >> $1
  done
  echo "BUILD_VARS=$BUILD_VARS" >> $1
  echo "created $1"
}

# set build environment
# arg $1 - BUILD_ENV (test, dev, seed)
# arg $2 - DBMS Vendor (sqlserver,mysql, etc)
function initEnv {
  setVar BUILD_ENV ${1:-test}
  setDbEnv $2
  # build and env vars
  setVar DB_NAME rcm_9ci_${BUILD_ENV}
  : ${DOCK_BUILDER_NAME:="${PROJECT_NAME}-builder"}
  setVar DOCK_BUILDER_NAME "$DOCK_BUILDER_NAME"
}

# create build/make_env_db.env for importing into makefile.
# arg $1 - the env
# arg $2 - the db
function makeEnvFile {
  initEnv $1 $2
  mkdir -p build/make
  createEnvFile "build/make/${BUILD_ENV}_${DBMS}.env"
}

# sets up defaults vars for docker ninedb and dock builders
function setupDockerBuilder {
  # *** the primary Dockerhub repo we will be publishing to ***
  setVar DOCK_BUILDER_URL "yakworks/alpine-java:jdk8-builder"

  # Do default builders to true if not already set
  : ${USE_DOCK_BUILDER:=true}
  : ${USE_DOCK_DB_BUILDER:=true}
  # if /.dockerenv this is inside a docker (such as circleCI) already
  # then we don't want to run docker in dockers, so force to false
  if [ -f /.dockerenv ] || [ "$CI" == "true" ]; then
    USE_DOCK_BUILDER=false
    USE_DOCK_DB_BUILDER=false
  fi
  BUILD_VARS+="USE_DOCK_BUILDER USE_DOCK_DB_BUILDER "

  if [ "$USE_DOCK_BUILDER" = "true" ]; then
    setVar DockerExec "docker exec ${DOCK_BUILDER_NAME}"
  fi
  setVar DockerShellExec "docker exec -it ${DOCK_BUILDER_NAME}"
}

# setups the env specific variables
# arg $1 - the database dbms (mysql,sqlserver,etc)
function setDbEnv {
  # arg $1 must always be the database, defaults to mysql if nothing specified
  setVar DBMS ${1:-mysql}
  setVar DOCK_DB_BUILD_NAME "$DBMS-build"
  setVar DOCKER_NINEDB_REPO "dock9/nine-db"
  setVar DB_IMAGE_TAG "${DBMS}-${NINEDB_VERSION}"
  setVar DOCKER_NINEDB_URL "$DOCKER_NINEDB_REPO:$DB_IMAGE_TAG"
  setVar DOCKER_DB_URL "$DOCKER_NINEDB_URL"

  # **** DB Vars (MYSQL by default) ****
  setVar DB_HOST 127.0.0.1
  setVar DB_PORT 3306
  # PASS_VAR_NAME is the environment variable name that the docker dbs require. will be different based on vendor
  setVar PASS_VAR_NAME "MYSQL_ROOT_PASSWORD"

  # DBMS overrides for sqlserver (Oracle in future)
  if [ "$DBMS" == "sqlserver" ]; then
    PASS_VAR_NAME="SA_PASSWORD"
    DB_PORT=1433
  fi
  if [ "$USE_DOCK_DB_BUILDER" = "true" ]; then
    setVar DockerDbExec "docker exec ${DOCK_DB_BUILD_NAME}"
  fi
  # if we are inside the docker builder but not in circleCI force the DB_HOST
  if [ "$USE_DOCK_BUILDER" = "true" ] || [ -f /.dockerenv ] && [ "$CI" != "true" ]; then
    setVar DB_HOST "${DOCK_DB_BUILD_NAME}"
  fi
}

# just spins through the BUILD_VARS and creates a sed replace in the form
# s|\${$SOME_VAR}|the value|g;
function buildSedArgs {
  for varName in $BUILD_VARS; do
    BUILD_VARS_SED_ARGS+="s|\\\${$varName}|${!varName}|g; "
  done
}

# runs sed on the kubernetes tpl.yml template files to update and replace variables with values
# arg $1 the tpl.yml file
# arg $2 the dir for sed to put the processed file
# echos out the processed tpl build file location
function sedTplYml {
  buildSedArgs
  mkdir -p "$2"
  # parse just the file name
  local tplFile=${1##*/}
  # replace .tpl.yml with .yml
  local processedTpl="$2/${tplFile/.tpl.yml/.yml}"
  sed "$BUILD_VARS_SED_ARGS" "$1" > "$processedTpl"
	echo "$processedTpl"
}

# set build environment
# arg $1 - BUILD_ENV (test, dev, seed)
# arg $2 - BUILD_ENV (test, dev, seed)
function setBuildEnv {
  setVar BUILD_ENV ${1:-test}
  setVar DB_NAME rcm_9ci_${BUILD_ENV}
  # [ ! -z "$2" ] && dbEnv "$2"
}

#Increments the given version and returns it
function incrementVersion {
   FILE=./semver
  if [ -f "$FILE" ]; then
    echo $(./semver bump $@)
  else
    echo $(build/bin/semver bump $@)
  fi
}

