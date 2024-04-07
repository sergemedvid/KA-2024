@echo off
rem echo Running %1 test for %2

dir /B %2 > testenv\testname.txt
copy testenv\initname.txt+testenv\testname.txt testenv\varset.bat >NUL
call testenv\varset.bat
del /Q testenv\varset.bat
del /Q testenv\testname.txt

rem echo Test: %testname%
rem Skip the following code if .prm file is not present
if not exist testdata\param\%testname% goto SKIPPRM

copy testenv\initprm.txt+testdata\param\%testname% testenv\varset.bat >NUL
call testenv\varset.bat
del /Q testenv\varset.bat

goto RUNTEST

:SKIPPRM
set testprm=

:RUNTEST
%1 %testprm% < testdata\in\%testname% > testdata\res\%testname%
testenv\cmp testdata\res\%testname% testdata\ok\%testname% testdata\res\%testname%.cmp
del /Q testdata\res\%testname%.cmp

if errorlevel 1 goto FAILED
echo Test %testname% PASSED
goto PASSED
:FAILED
echo Test %testname% FAILED
echo ****** EXPECTED OUTPUT ********
type testdata\ok\%testname%
echo:
echo ******* ACTUAL OUTPUT *********
type testdata\res\%testname%
echo:
:PASSED