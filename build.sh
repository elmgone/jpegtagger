#!/bin/bash
#
# build the whole selfcontained binary
#

if which eg.sh > /dev/null; then
	EG=$(which eg.sh)
fi

(cd wui && $EG go generate) && $EG go install -race && jpegtagger wui
