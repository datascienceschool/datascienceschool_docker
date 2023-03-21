
CONTAINER_NAME=jupyter
IMAGE_NAME=datascienceschool/datascienceschool_docker

echo "Stop Container..."
if docker ps -aqf "name=$CONTAINER_NAME" --format "{{.Names}}" | grep $CONTAINER_NAME ; then
  running=$(docker inspect --format="{{ .State.Running }}" $CONTAINER_NAME)
  if [ "$running" == "true" ] ; then
    docker stop $CONTAINER_NAME
  fi
fi

echo "Delete Container..."
if docker ps -aqf "name=$CONTAINER_NAME" --format "{{.Names}}" | grep $CONTAINER_NAME ; then
  docker rm -fv $CONTAINER_NAME
else
  echo "No container $CONTAINER_NAME exists."
fi

echo "Delete Image..."
imageId=$(docker images -q $IMAGE_NAME)
if [ -z $imageId ] ; then
  echo "No image $IMAGE_NAME exists."
else
  docker rmi $imageId
fi

echo "Build Image..."
export DOCKER_SCAN_SUGGEST=false
docker build --progress=plain -t $IMAGE_NAME .
