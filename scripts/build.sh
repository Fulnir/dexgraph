#!/bin/bash
set -e
set -x

source scripts/functions.sh


start
startZero

#./gradlew check jacocoTestReport coveralls

quit 0