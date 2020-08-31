# ---
# collects all functions for build.sh, meant to be imported like so ...
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/all.sh
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

