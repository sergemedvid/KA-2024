@echo off
if exist testenv\locker.exe goto SKIPBUILD
cd testenv
tasm locker.asm
tlink locker
cd ..
:SKIPBUILD
testenv\locker %1.bin %1.asm %2