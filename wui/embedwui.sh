#!/bin/bash
#
# generate wui.ego out of index.html
#

if which eg.sh > /dev/null; then
	# EG=$HOME/opt/bin/eg.sh
	EG=$(which eg.sh)
fi

$EG elm make tag.elm                                             || exit 20
# echo "<%! func WriteWuiHtml( w io.Writer ) error %>"  >  wui.ego || exit 30
cat index.html                                        >  wui.ego || exit 40
echo "<%! func WriteWuiHtml( w io.Writer ) error %>" >>  wui.ego || exit 30
$EG ego                                                          || exit 50
