#!/bin/sh

#############################################################################
#
# Gibbs JSON deserializing preprocessor shell script
#
#   Goes through the src directory and outputs for all files, the following:
#
#       <classname> <classpath>
#
#   which is then loaded by our JSON deserializer to resolve classpaths from
#   class names
#
#############################################################################

SRC_PATH=./src

# get into source path
cd $SRC_PATH

# get all .hx source files
hxfiles=$(find . -regex ".*\.hx")
for file in $hxfiles
do
    ####################
    # get classname
    ####################

    # get base filename
    classname=${file##*/}

    # trim ending '.hx'
    classname=${classname%\.*}

    ####################
    # get classpath
    ####################

    # trim beginning './'
    cp=${file##\./}

    # trim ending '.hx'
    cp=${cp%\.*}

    # replace all instances of '/' with '.'
    cp=$(echo $cp | sed -e "s/\//\./g")

    # finally, output classname classpath
    echo $classname $cp
done

# go back ( pipe to /dev/null because otherwise it outputs working directory path )
cd - >/dev/null
