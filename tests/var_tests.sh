#!/usr/bin/env bash

source ../setVar

vName=FOO
echo "FOO val is ${!vName+x}."
[[ $FOO = true ]] && echo "should not show, FOO not set"
[ -z "${!vName+x}" ] && echo "FOO not set 1"
[[ ! ${!vName+x} ]] && echo "FOO not set 1"

setVar FOO true
echo "FOO val is $FOO"
echo "vName $vName val is ${!vName}"
[[ ${!vName+x} ]] && echo "FOO is set"
[ "$FOO" = true ] && echo "FOO evaluates to true"
FOO=
[[ ! ${!vName:+1} ]] && echo "FOO not set 3"
[ "$FOO" != true ] && echo "FOO != true"
[[ "$FOO" != true ]] && echo "FOO != true"

FOO=""
[[ ! ${!vName+x} ]] && echo "FOO not set 4, should not get here"
[[ ${!vName} = "" ]] && echo "FOO is an empty string"
[[ ${FOO+x} ]] && echo "FOO evaluates to true"
[[ $FOO != true ]] && echo "FOO evaluates to false"
