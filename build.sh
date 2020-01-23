#!/bin/bash
ghc --make -O2 -threaded -o thex ./src/Main.hs
# Get rid of some MBs in the executable.
strip ./thex
