#!/bin/bash

find Modules -name "swiftgen.yml" | while read -r file; do
    echo "Running SwiftGen for $file"
    swiftgen config run --config "$file"
done
