# Основы оркестрации контейнеров.

## Part 1. Запуск нескольких docker-контейнеров с использованием docker compose.

1) Для каждого сервиса напишем свой `Dockerfile`, который будет выполнять установку зависимостей проекта в отдельном контейнере, далее копировать исходный код проекта в новый контейнер и собирать проект.

    * Для RabbitMQ будем использовать готовый образ: <https://hub.docker.com/_/rabbitmq>.

    * Dockerfile для сервиса, управляющего резервированием.
    ![booking-service](pictures/booking-service-dockerfile.png)<br>*booking-service*</br>

    * Dockerfile для базы данных postgres.
    ![database](pictures/database-dockerfile.png)<br>*database*</br>

    * Dockerfile для фасада для взаимодействия с остальными микросервисами.
    ![gateway-service](pictures/gateway-service-dockerfile.png)<br>*gateway-service*</br>

    * Dockerfile для сервиса, управляющего сущностью отелей.
    ![hotel-service](pictures/hotel-service-dockerfile.png)<br>*hotel-service*</br>

    * Dockerfile для сервиса, управляющего программой лояльности.
    ![loyalty-service](pictures/loyalty-service-dockerfile.png)<br>*loyalty-service*</br>

    * Dockerfile для сервиса, управляющего оплатой.
    ![payment-service](pictures/payment-service-dockerfile.png)<br>*payment-service*</br>

    * Dockerfile для сервиса, осуществляющего сбор статистики.
    ![report-service](pictures/report-service-dockerfile.png)<br>*report-service*</br>

    * Dockerfile для сервиса, управляющего сессиями пользователей.
    ![session-service](pictures/session-service-dockerfile.png)<br>*session-service*</br>

2) Собираем образы из каждого Dockerfile командами `docker build -t <name>:<tag> <path>`. Проверяем все образы и их размеры командой `docker images`.
![images](pictures/docker-images.png)<br>*docker images*</br>

3) Напишем `docker-compose файл`, который осуществляет корректное взаимодействие сервисов. Пробросим порты для доступа к `gateway service` и `session service` из локальной машины. С помощью команд `docker-compose build` и `docker-compose up -d` соберем и запустим наши контейнеры. Флаг `-d` указываем для того, чтобы скрыть логи.
![compose](pictures/docker-compose.png)<br>*Смотрим контейнеры*</br>

4) Прогоним тесты через `Postman` и убедимся что все они проходят успешно.
![tests](pictures/tests1.png)<br>*Тесты проходят успешно*</br>

## Part 2. Создание виртуальных машин

1) Устанавливаем `VirtualBox` с официального сайта <https://www.virtualbox.org/>.

2) Устанавливаем `Vagrant` (в моем случае MacOS) командами: `brew tap hashicorp/tap`, `brew install hashicorp/tap/hashicorp-vagrant`. Проверяем успешную установку: `vagrant -v`. Для создания `Vagrantfile`, в корне проекта прописываем `vagrant init`. Внесем изменения в `Vagrantfile` для создания виртуальной машины и переноса исходного веб-сервиса в рабочую директорию виртуальной.
![vagrant1](pictures/vagrant1.png)<br>*Изменения в Vagrantfile*</br>

3) Запустим машину командой `vagrant up`.
![up](pictures/vagrant-up.png)<br>*Успешное создание машины*</br>

4) Подключаемся к машине с помощью `vagrant ssh` и проверяем что исходный код встал куда нужно.
![ssh](pictures/vagrant-ssh.png)<br>*Подключаемся к машине и проверяем наличие сервисов*</br>

5) Останавливаем машину `vagrant halt` проверяем что она остановлена `vagrant status` и уничтожаем `vagrant destroy -f`.
![check](pictures/vagrant-check.png)<br>*Уничтожаем машину*</br>

## Part 3. Создание простейшего docker swarm.

1) Модифицируем Vagrantfile для создания трех машин: manager01, worker01, worker02.
![vagrant2](pictures/vagrant2.png)<br>*Изменения в Vagrantfile*</br>

2) Напишем shell-скрипты для установки `docker` внутрь машин, инициализации и подключения к `docker swarm`.
    * Для менеджера:
    ![setup](pictures/setup.png)<br>*Скрипт для менеджера*</br>

    * Для воркера:
    ![worker](pictures/worker.png)<br>*Скрипт для воркера*</br>

3) Запускаем машины командой `vagrant up` и проверяем их статусы:
![status](pictures/status.png)<br>*Статусы машин*</br>

4) Подключаемся к нашему менеджеру `vagrant ssh manager01` и проверяем что всё успешно завершилось.
![check](pictures/docker-check.png)<br>*Проверяем разделение задач*</br>

5) Загрузим собранные образы на `dockerhub` командами `docker tag <name>:<tag> <your_dockerhub_username>/<name><tag>`, `docker push <your_dockerhub_username>/<name><tag>`. Модифицируем `docker-compose.yml` для подгрузки расположенных на docker hub образов. Проверим, что файл корректен командой `docker-compose config`.

6) Перенесем `docker-compose.yml` на `manager1`:
![upload](pictures/vagrand-upload.png)<br>*Проверяем, что файл перенесен*</br>

7) Запустим стек сервисов, используя написанный docker-compose файл `sudo docker stack deploy -c docker-compose.yml <name>`, и проверим состояни.
![stack](pictures/docker-stack.png)<br>*Состояние сервисов*</br>

8) Настроим прокси на базе `nginx`для доступа к `gateway-service` и `session-service` по оверлейной сети. И так же грузим данный образ на `dockerhub`.
![nginx-conf](pictures/nginx.png)<br>*Файл nginx.conf*</br>

![proxy](pictures/proxy.png)<br>*Файл proxy.conf*</br>

![nginx-dockerfile](pictures/nginx-dockerfile.png)<br>*Dockerfile для сервиса nginx*</br>

![nginx-script](pictures/nginx-script.png)<br>*Скрипт для сервиса nginx*</br>

![nginx-compose](pictures/nginx-compose.png)<br>*Добавим изменения в docker-compose.yml*</br>

9) Проверяем стек сервисов, после добавления `nginx-service`.
![new-stack](pictures/new-stack.png)<br>*Проверяем стек сервисов*</br>

10) Прогоним тесты через `Postman` и убедимся что все они проходят успешно.
![tests](pictures/tests2.png)<br>*Тесты проходят успешно*</br>

11) Используя команды `docker`, отобразим в отчете распределение контейнеров по узлам. `sudo docker node ls` и `sudo docker stack ps <name>`
![commands](pictures/docker-commands.png)<br>*Распределение контейнеров*</br>

12) Создадим файл для настройки `portainer`.
![portainer](pictures/portainer.png)<br>*Файл portainer-stack.yml*</br>

13) Перенесем `portainer-stack.yml` на `manager01` и запустим его.
![portainer-vagrant](pictures/portainer-vagrant.png)<br>*Проверяем что все успешно*</br>

14) Получим доступ по [адресу](http://192.168.50.10:9000) для входа в `portainer`.
![site](pictures/site.png)<br>*Сайт*</br>

15) Отобразятся наши сервисы.
![services](pictures/services.png)

16) Получим визуализацию распределения задач по узлам.
![visualization](pictures/visualization.png)