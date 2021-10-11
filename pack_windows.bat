@echo off
set BUILD_MODE=Release
if %1==debug BUILD_MODE=Debug
if not exist .\build\windows\out mkdir .\build\windows\out
cd .\build\windows\runner
tar -a -c -f ..\out\%BUILD_MODE%.zip .\%BUILD_MODE%
cd ..\..\..\