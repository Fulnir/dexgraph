#!/bin/bash
set -e
set -x

source scripts/functions.sh

startZero &
start &
testing 

#./gradlew check jacocoTestReport coveralls

# quit 0