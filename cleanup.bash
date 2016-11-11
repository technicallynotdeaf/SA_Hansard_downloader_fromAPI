#!/bin/bash

cat $1 | sed 's/:/=/g' | tr "=" "\n" > $1.filtered
