#!/bin/bash
nim doc --project -o:docs/ --index:off src/numberstring.nim
mv docs/numberstring.html docs/index.html