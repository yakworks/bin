#!/usr/bin/env bash

source ../setVar

vName=FOO
echo "FOO val is ${!vName+x}."
[[ $FOO = true ]] && echo "should not show, FOO not set"
[ -z "${FOO+x}" ] && echo "FOO not set 1"
[[ ! ${FOO+x} ]] && echo "FOO not set 2"
[ -z "${!vName+x}" ] && echo "FOO not set 3"
[[ ! ${!vName+x} ]] && echo "FOO not set 4"
echo

setVar FOO true
echo "FOO val is $FOO"
echo "vName $vName val is ${!vName}"
[[ ${!vName+x} ]] && echo "FOO is set"
[[ $FOO = true ]] && echo "FOO evaluates to true 1"
[ "$FOO" = true ] && echo "FOO evaluates to true 2"
echo

FOO=
echo 'FOO='
echo "-${FOO+x}-"
case ${FOO+x} in
  (x) echo Foo is empty;;
  ("") echo Foo is unset;;
  (x*[![:blank:]]*) echo Foo is non-blank;;
  (*) echo Foo is blank
esac

if [ -z "${FOO+set}" ]; then
    echo "FOO is unset"
fi
if [ -z "${FOO-unset}" ]; then
    echo "FOO is set to the empty string"
fi

[[ ! $FOO ]] && echo 'FOO= : [[ ! $FOO ]] is true'
[[ -z "${FOO+x}" ]] && echo 'FOO= : [[ -z ${FOO+x} ]] is true'
[[ -z ${FOO:+x} ]] && echo 'FOO= : [[ -z ${FOO:+x} ]] is true'
[ "$FOO" != true ] && echo "FOO= : FOO != true 1"
[[ "$FOO" != true ]] && echo "FOO= : FOO != true 2"
echo

FOO=""
echo 'FOO=""'
echo "-${FOO+x$FOO}-"
case ${FOO+x$FOO} in
  (x) echo Foo is empty;;
  ("") echo Foo is unset;;
  (x*[![:blank:]]*) echo Foo is non-blank;;
  (*) echo Foo is blank
esac

if [ -z "${FOO+set}" ]; then
    echo "FOO is unset"
fi
if [ -z "${FOO-unset}" ]; then
    echo "FOO is set to the empty string"
fi
[ ! "$FOO" ] && echo 'FOO="" : [ ! $FOO ] is true'
[ ! ${FOO+x} ] && echo 'FOO="" : [ ! ${FOO+x} ] is true'
[ ! ${FOO:+x} ] && echo 'FOO="" : [ ! ${FOO:+x} ] is true'
[[ ! ${!vName} ]] && echo 'FOO="" : `[[ ! ${!vName} ]]` is true'
[[ ! ${!vName+x} ]] && echo 'FOO="" : `[[ ! ${!vName+x} ]]` is true'
[[ ! ${!vName:+x} ]] && echo 'FOO="" : `[[ ! ${!vName:+x} ]]` is true'
[[ ${!vName} = "" ]] && echo "FOO is an empty string"
[[ ${FOO+x} ]] && echo "FOO evaluates to true"
[[ $FOO != true ]] && echo "FOO evaluates to false"

FOO="  "
echo 'FOO="  "'
echo "-${FOO+x$FOO}-"
case ${FOO+x$FOO} in
  (x) echo Foo is empty;;
  ("") echo Foo is unset;;
  (x*[![:blank:]]*) echo Foo is non-blank;;
  (*) echo Foo is blank
esac

