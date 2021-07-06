# ---
# collects all functions for build.sh, meant to be imported like so ...
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/all.sh
# ---

binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# echo "sourcing from binDir $binDir"
source ${binDir}/init_env
source ${binDir}/docker
source ${binDir}/jbuilder_docker
source ${binDir}/spring_gradle
source ${binDir}/kubernetes
source ${binDir}/docmark
source ${binDir}/sed_tpl
