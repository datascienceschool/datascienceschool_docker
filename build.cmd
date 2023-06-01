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
    docker stop %containerId%
  )
)

echo Delete Container...
SET cmd='docker ps -qaf "name=$CONTAINER_NAME$"'
for /f %%i in (%cmd%) do set containerId=%%i
If "%containerId%" == "" (
  echo No container %CONTAINER_NAME% exists.
) ELSE (
  docker rm -fv %containerId%
)

echo Delete Image...
SET cmd='docker images -q %IMAGE_NAME%'
for /f %%i in (%cmd%) do set imageId=%%i
If "%imageId%" == "" (
  echo No image %IMAGE_NAME% exists.
) ELSE (
  docker rmi %imageId%
)

echo Build Image...
set DOCKER_SCAN_SUGGEST=false
docker build --progress=plain -t %IMAGE_NAME% .

exit /B 1
