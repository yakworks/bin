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

function setupDockBuilderVars {
  # **** Docker Builder Defaults *****
  setVar DOCK_BUILDER jdk8-builder
  setVar DOCK_BUILDER_REPO yakworks/alpine-java

  # if /.dockerenv this is inside a docker already and we don't need to run builders
  # if its in a docker then we are probably running inside circle CI
  if [ ! -f /.dockerenv ]; then
    : ${USE_DOCK_BUILDER:=true}
    : ${USE_DOCK_DB_BUILDER:=true}
    BUILD_VARS+="USE_DOCK_BUILDER USE_DOCK_DB_BUILDER "
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
  echo "created $1 file"
}

# just spins through the BUILD_VARS and creates a sed replace in the form
# s|\${$SOME_VAR}|the value|g;
function buildSedArgs {
  for varName in $BUILD_VARS; do
    BUILD_VARS_SED_ARGS+="s|\\\${$varName}|${!varName}|g; "
  done
}

# helper/debug function ex: `build.sh logVars test sqlserver`
function logVars {
  buildEnv "$@"
  for varName in $BUILD_VARS; do
      echo "$varName = ${!varName}"
  done
}
