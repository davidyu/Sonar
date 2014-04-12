#!/bin/sh -x

set -e
CWD=$(pwd)
cd "$CWD/Gibbs"
ctags -R . *
cd "$CWD/Sonar"
ctags -R . *
cd "$CWD/relay"
ctags -R . *
