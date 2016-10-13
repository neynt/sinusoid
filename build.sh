#!/bin/bash

echo "Listening for changes in existing files in src/ and songs/."
echo "New files will not be detected."

mkdir -p script
while true; do
  lsc -wo script/ src/ songs/
done
