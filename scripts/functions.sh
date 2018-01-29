#!/bin/bash


sleepTime=30

function quit {
  echo "Shutting down dgraph server and zero"
  curl -s localhost:8082/admin/shutdown
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
  dgraph server --memory_mb 2048 --zero localhost:5082 -o 2
  # Wait for membership sync to happen.
  
  sleep $sleepTime
  return 0
}

function startZero {
	echo -e "Starting dgraph zero.\n"
  dgraph zero --port_offset -1998
  # To ensure dgraph doesn't start before dgraphzero.
	# It takes time for zero to start on travis(mac).
  echo -e "dgraph zero ios started ------------------------------------- \n"
	sleep $sleepTime
  echo -e "dgraph zero ios started ------------3------------------------- \n"
}

function testing {
  echo -e "Testing."
  
  # Wait for membership sync to happen.
  sleep $sleepTime
  sleep $sleepTime
  mix local.rebar --force
  mix local.hex --force
  mix deps.get
  mix deps.compile
  mix test
  echo -e "Finnished Testing --------------------------------------------"
  return 0
}