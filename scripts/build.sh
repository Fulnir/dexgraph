#!/bin/bash
set -e
set -x

. scripts/functions.sh

startZero
start

#./gradlew check jacocoTestReport coveralls

quit 0