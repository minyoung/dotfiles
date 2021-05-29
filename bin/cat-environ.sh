#!/bin/bash

cat /proc/$1/environ | xargs -0 -L1 -I{} echo export {}
