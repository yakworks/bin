# ---
# functions for th Makefile to setup environment and variables file that it imports
# ---

# create build/make_env_db.env for importing into makefile.
# arg $1 - the env
# arg $2 - the db
# arg $3 - IS_DOCKER_BUILDER
function makeEnvFile {
  initEnv $1 $2 $3
  mkdir -p build/make
  createEnvFile "build/make/${BUILD_ENV}_${DBMS}.env"
}

# set build environment
# arg $1 - BUILD_ENV (test, dev, seed)
# arg $2 - DBMS Vendor (sqlserver,mysql, etc)
# arg $3 - IS_DOCKER_BUILDER
function initEnv {
  setVar BUILD_ENV ${1:-test}
  setDbEnv $2
  [ "$3" = true ] && USE_DOCKER_BUILDER=true
  # build and env vars
  setVar DB_NAME rcm_9ci_${BUILD_ENV}
  setVar DOCK_BUILDER_NAME "${PROJECT_NAME}-builder"}
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

# sets up defaults vars for docker ninedb and dock builders
function setupDockerBuilder {
  # default docker builder
  setVar DOCK_BUILDER_URL "yakworks/alpine-jdk:builder8"

  # Default builders to true if not already set
  setVar USE_DOCKER_BUILDER true
  setVar USE_DOCK_DB_BUILDER true
  # if /.dockerenv this is inside a docker (such as circleCI) already
  # then we don't want to run docker in dockers, so force to false
  if [ -f /.dockerenv ] || [ "$CI" == "true" ]; then
    USE_DOCKER_BUILDER=false
    USE_DOCKER_DB_BUILDER=false
  fi

  # if USE_DOCK_BUILDER then set DockerExec which is what make will try and use
  if [ "$USE_DOCK_BUILDER" = true ]; then
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

