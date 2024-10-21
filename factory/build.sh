#!/bin/bash

base=`cat base.lua`

process_file() {
  content=`cat ../src/ARC1-$1.lua`
  content="${content//]]/] ]}"
  base="${base/"$2"/$content}"
}

process_file "Core" "%core%"
process_file "Burnable" "%burnable%"
process_file "Mintable" "%mintable%"
process_file "Pausable" "%pausable%"
process_file "Blacklist" "%blacklist%"
process_file "allApproval" "%all_approval%"
process_file "limitedApproval" "%limited_approval%"

echo "$base" > ARC1-Factory.lua
