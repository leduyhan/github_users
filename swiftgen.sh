#!/bin/bash

# Find all swiftgen.yml files in the repository and run swiftgen config run for each
git ls-files -z '**/swiftgen.yml' | grep -zv 'xctemplate' | while IFS= read -r -d '' file; do
  echo Processing $file
  Pods/SwiftGen/bin/swiftgen config run --config "$file"
done
