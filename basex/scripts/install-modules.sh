#!/bin/sh
# Shell script to set up a new BaseX 
# database using the basexclient command-line
# client. The basexclient command must be on the
# path (see BaseX documentation)

pwd=`pwd`
echo Installing DFST XQuery packages:
basexclient -U $1 -P $2 -c "repo install $pwd/../../modules/util/dita-utils.xqm"
basexclient -U $1 -P $2 -c "repo install $pwd/../../modules/util/relpath-utils.xqm"
basexclient -U $1 -P $2 -c "repo list"