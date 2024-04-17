@echo off
if exist testenv\locker.exe goto SKIPBUILD
cd testenv
tasm locker.asm
tlink locker
cd ..
:SKIPBUILD
testenv\locker.exe %1.bin %1.asm %2

cd testdata\bin
..\..\testenv\locker.exe %101.bin %101.tmp %2
copy %101.tmp ..\in\%101
del /Q %101.tmp

..\..\testenv\locker.exe %102.bin %102.tmp %2
copy %102.tmp ..\in\%102
del /Q %102.tmp

..\..\testenv\locker.exe %103.bin %103.tmp %2
copy %103.tmp ..\in\%103
del /Q %103.tmp

..\..\testenv\locker.exe %104.bin %104.tmp %2
copy %104.tmp ..\in\%104
del /Q %104.tmp

..\..\testenv\locker.exe %105.bin %105.tmp %2
copy %105.tmp ..\in\%105
del /Q %105.tmp

cd ..\bok

..\..\testenv\locker.exe %101.bin %101.tmp %2
copy %101.tmp ..\ok\%101
del /Q %101.tmp

..\..\testenv\locker.exe %102.bin %102.tmp %2
copy %102.tmp ..\ok\%102
del /Q %102.tmp

..\..\testenv\locker.exe %103.bin %103.tmp %2
copy %103.tmp ..\ok\%103
del /Q %103.tmp

..\..\testenv\locker.exe %104.bin %104.tmp %2
copy %104.tmp ..\ok\%104
del /Q %104.tmp

..\..\testenv\locker.exe %105.bin %105.tmp %2
copy %105.tmp ..\ok\%105
del /Q %105.tmp

cd ..\..\