# ---
# commons helper functions for build.sh, expects a BUILD_VARS to be populated when functions called
# meant to be imported like so
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/build_functions.sh
# ---

# sets the variable and tracks its name in BUILD_VARS
# also tracks BUILD_VARS_SED_ARGS for doing a sed replace on template files
function setVar {
  # declare -g "$1"="$2" # not working in older bash 3 on mac
  eval $1=\$2
  [[ ! $BUILD_VARS == *" $1 "* ]] && BUILD_VARS+="$1 "
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
