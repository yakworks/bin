# ---
# collects all functions for build.sh, meant to be imported like so ...
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/all.sh
# ---

binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# echo "sourcing from binDir $binDir"
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
source ${binDir}/utils

# source the version.properties
source version.properties
setVersion $version

# initialize from build.yml
# arg $1 - the file
function init_from_build_yml {
  create_yml_variables $1
  setVar RELEASABLE_BRANCHES "$git_releasableBranchRegex"
  setVar GITHUB_FULLNAME "$github_fullName"
  setVar CHANGELOG_NAME "$releaseNotes_file"
  # keeps whats after last /
  setVar PROJECT_NAME ${GITHUB_FULLNAME##*/}
}

# just spins through the BUILD_VARS and creates a sed replace in the form
# s|\${$SOME_VAR}|the value|g;
function buildSedArgs {
  for varName in $BUILD_VARS; do
    ESCAPED_VarName=$(printf '%s\n' "${!varName}" | sed -e 's/[\|&]/\\&/g')
    BUILD_VARS_SED_ARGS+="s|\\\${$varName}|$ESCAPED_VarName|g; "
  done
  # echo "$BUILD_VARS_SED_ARGS"
}

# runs sed on the kubernetes tpl.yml template files to update and replace variables with values
# $1 - the tpl.yml file
# $2 - the dir for sed to put the processed file
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

