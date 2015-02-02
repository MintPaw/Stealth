color 0A
cd %~dp0..\..\
subst b: /d
subst b: .
cd /d b:\
set path=%path%;b:\extra\commandline

cmd /k "cls"