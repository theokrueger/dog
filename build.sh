#!/bin/bash
# compile and sim icarusverilog targets n stuff
cd "$(dirname $0)"

###############################

OUT="$PWD/build"
FLIST="$PWD/flist.f"
ROOT_MOD="testbench"

###############################

try() {
  $@
  if [[ "$?" != 0 ]]; then
    echo "Failed at command '$@'"
    exit
  fi
}

try mkdir -p $OUT

echo "Building..."
try iverilog -gassertions -s "$ROOT_MOD" -o "$OUT/$ROOT_MOD" -c "$FLIST"
echo

echo "Running..."
try vvp "$OUT/$ROOT_MOD"
echo
