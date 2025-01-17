#!/usr/bin/env bash

cwd=$(echo ${1} || pwd)
pushd $cwd > /dev/null
  zellij --layout ide
popd > /dev/null
