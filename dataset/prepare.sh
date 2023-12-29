#!/bin/bash

# Define the base directory
base_dir="./src/vendor"

# Only java is needed
repos=(
"https://github.com/tree-sitter/tree-sitter-java.git"
)

# Clone each repository
mkdir -p $base_dir
for repo in "${repos[@]}"
do
  cd $base_dir
  git clone $repo
  cd ../../
done

# Run the setup
python script/setup.py