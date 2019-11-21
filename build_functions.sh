# ---
# commons helpers and functions for build.sh, expects a BUILD_VARS to be populated when functions called
# meant to be imported like so
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/build_functions.sh
# ---

# dummy function so that this can through first and clone the git yakworks/bin
function init {
  echo "init"
}

# sets the variable and tracks its name in BUILD_VARS
# also tracks BUILD_VARS_SED_ARGS for doing a sed replace on template files
function setVar {
  # declare -g "$1"="$2" # not working in older bash 3 on mac
  eval $1=\$2
  [[ ! $BUILD_VARS == *" $1 "* ]] && BUILD_VARS+="$1 "
}

function setVersion {
  setVar VERSION "$1"
  # ${version%.*} returns the version from source version.properties without last dot so we can add the .x
  # will turn 10.0.2 into 10.0.x
  setVar VERSIONX "${VERSION%.*}.x"
  #replace dots with - so 10.0.x turns into v10-0-x. kubernetes can't have dots in names
  setVar VERX_NO_DOTS "v${VERSIONX//./-}"
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
    setVar DockerExec "docker exec -it ${DOCK_BUILDER_NAME}"
  fi
}

# setups the env specific variables
# arg $1 - the database dbms (mysql,sqlserver,etc)
function setDbEnv {
  # arg $1 must always be the database, defaults to mysql if nothing specified
  setVar DBMS ${1:-mysql}
  setVar DOCK_DB_BUILD_NAME "$DBMS-build"
  setVar DOCKER_NINEDB_REPO "dock9/nine-db"
  setVar DB_IMAGE_TAG "${DBMS}-${VERSIONX}"
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
  if [ -f /.dockerenv ] && [ "$CI" != "true" ]; then
    setVar DB_HOST "${DOCK_DB_BUILD_NAME}"
  fi
}

# create env file from BUILD_VARS for importing into makefile.
# arg $1 - the file to use
function createEnvFile {
  echo "# ----- Generated from build.sh --------" > $1
  for varName in $BUILD_VARS; do
      val=${!varName}
      echo "$varName=$val" >> $1
  done
  echo "created $1"
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
  local tplFile=${1##*/}
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
