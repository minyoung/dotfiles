#!/bin/sh

while inotifywait -qqre modify $1; do
  $2
done
