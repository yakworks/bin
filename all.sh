# ---
# collects all functions for build.sh, meant to be imported like so ...
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/all.sh
# ---

binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# echo "sourcing from binDir $binDir"
source ${binDir}/init_env
source ${binDir}/docker
source ${binDir}/kubernetes
source ${binDir}/docmark
source ${binDir}/sed_tpl

# lists all the function/methods
function list-functions {
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
