@echo off

set CONTAINER_NAME=datascienceschool
set IMAGE_NAME=datascienceschool/datascienceschool_docker

SETLOCAL ENABLEDELAYEDEXPANSION

ECHO Stop Container...
SET cmd='docker container ls -af "name=%CONTAINER_NAME%"'
FOR /f %%i in (%cmd%) DO set containerId=%%i
if "%containerId%" == "" (
  echo No container %CONTAINER_NAME% running.
) else (
  SET cmd='docker container inspect -f "{{.State.Running}}" %CONTAINER_NAME%'
  for /f %%i in (%cmd%) do set containerId=%%i
  if "%containerId%" == "" (
    echo No container %CONTAINER_NAME% running.
  ) else (
    docker stop %CONTAINER_NAME%
  )
)

echo Delete Container...
SET cmd='docker ps -qaf "name=$CONTAINER_NAME$"'
for /f %%i in (%cmd%) do set containerId=%%i
If "%containerId%" == "" (
  echo No container %CONTAINER_NAME% exists.
) ELSE (
  docker rm -fv %CONTAINER_NAME%
)

echo Run Image...
for %%i in ("%~dp0\..\..\..") do set "dir_code=%%~fi"
echo "volume : /Code=%dir_code%"
docker run ^
    -itd ^
    --name %CONTAINER_NAME% ^
    --publish 8888:8888 ^
    --publish 8050:8050 ^
    --volume D:\Code\:/home/jovyan/Code ^
    --restart unless-stopped ^
    %IMAGE_NAME%
