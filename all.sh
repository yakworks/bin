# ---
# collects all functions for build.sh, meant to be imported like so ...
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/all.sh
# ---

binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# echo "sourcing from binDir $binDir"
source ${binDir}/setVar
source ${binDir}/versions
source ${binDir}/buildEnv
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

# lists all the function/methods
function list-methods {
  shopt -s extdebug
  funcList=`compgen -A function`
  # echo $funcList
  for f in $funcList; do
    funcParts=`declare -F $f`
    arr=($funcParts)
    local file=${arr[2]##*/}
    printf "%-25s %s:%s\n" ${arr[0]} ${file} ${arr[1]}
  done
}
