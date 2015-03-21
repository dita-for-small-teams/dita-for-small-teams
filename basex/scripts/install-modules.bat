@echo off
REM Shell script to set up a new BaseX 
REM database using the basexclient command-line
REM client. The basexclient command must be on the
REM path (see BaseX documentation)

set BAT_HOME=%~dp0
@echo Installing DFST XQuery packages:
basexclient -U %1 -P %2 -c "repo install %BAT_HOME\..\..\modules\util\dita-utils.xqm"
basexclient -U %1 -P %2 -c "repo install %BAT_HOME\..\..\modules\util\relpath-utils.xqm"
basexclient -U %1 -P %2 -c "repo list"