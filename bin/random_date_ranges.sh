#! /bin/bash 

set -e -o pipefail

NOW=$(date +%s)

while true; do
  START=$(($NOW + $RANDOM))
  END=$(($START + $RANDOM))
  printf "('$(date -r $START '+%m/%d/%Y:%H:%M:%S')', '$(date -r $END '+%m/%d/%Y:%H:%M:%S')'),\n"
done
