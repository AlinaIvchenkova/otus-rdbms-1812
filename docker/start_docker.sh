#!/bin/bash

#если необходимо, указать другой порт
port=12345

#создаем образ файла из Dockerfile:
sudo docker build -t pg_alina_db .

#запускаем новый контейнер
sudo docker run -d -p $port:5432 --name pg_alina_db pg_alina_db
