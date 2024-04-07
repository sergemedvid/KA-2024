@echo off
if exist testenv\cmp.exe goto SKIPCMP
cd testenv
tasm cmp.asm
tlink cmp
cd ..

:SKIPCMP

tasm %1.asm
tlink %1

cls

for %%A in (testdata\in\%1*) do echo call testenv\runtest.bat %1 %%A >> runtests.bat
call runtests.bat
del /Q runtests.bat