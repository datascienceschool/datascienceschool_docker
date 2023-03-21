export CONTAINER_NAME=datascienceschool
export IMAGE_NAME=datascienceschool/datascienceschool_docker

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

docker run \
    -itd \
    --name $CONTAINER_NAME \
    --publish 8888:8888 \
    --volume /Users/joelkim/Code:/home/jovyan/Code \
    --restart unless-stopped \
    $IMAGE_NAME
