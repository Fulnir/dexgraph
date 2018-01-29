#!/bin/bash


sleepTime=30

function quit {
  echo "Shutting down dgraph server and zero"
  curl -s localhost:8080/admin/shutdown
  # Kill Dgraphzero
  kill -9 $(pgrep -f "dgraph zero") > /dev/null

  if pgrep -x dgraph > /dev/null
  then
    while pgrep dgraph;
    do
      echo "Sleeping for 5 secs so that Dgraph can shutdown."
      sleep 5
    done
  fi

  echo "Clean shutdown done."
  return $1
}

function start {
  echo -e "Starting first server."
  dgraph server -p --memory_mb 4096 --zero localhost:5080
  # Wait for membership sync to happen.
  sleep $sleepTime
  return 0
}

function startZero {
	echo -e "Starting dgraph zero.\n"
  dgraph zero -w  --port_offset -2000
  # To ensure dgraph doesn't start before dgraphzero.
	# It takes time for zero to start on travis(mac).
	sleep $sleepTime
}