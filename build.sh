#!/bin/bash

if [ -z ${1+x} ]; then echo "output directory unset"; else echo "output directory set to '${1}'"; fi

zip -r9 ${1}/spalg.love *.lua hc hump resources states tween
