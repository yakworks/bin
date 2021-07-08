# ---
# collects all functions for build.sh, meant to be imported like so ...
# [ ! -e build/bin ] && git clone https://github.com/yakworks/bin.git build/bin --single-branch --depth 1
# source build/bin/all.sh
# ---
# set -u  # Attempt to use undefined variable outputs error message, and forces an exit
# set -x  # Similar to verbose mode (-v), but expands commands
# set -o pipefail  # Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value.
# ! DEPRECATED, tryign to remove the monolith

binDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# echo "sourcing from binDir $binDir"
source ${binDir}/init_env
source ${binDir}/docker_tools
source ${binDir}/jbuilder_docker
source ${binDir}/spring_gradle
source ${binDir}/docmark
