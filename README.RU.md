# Инициализация конфигурации
Выполняйте следующие команды для первоначальной конфигурации ноды.
 ##### Шаг 1. Инициализируем файлы конфигураций ноды для первого запуска (необязательный шаг)
 ```sh
 docker-compose run --rm --no-deps --entrypoint '' dnode dnode init my-node-name --chain-id dn-testnet
 ```
 - `--rm` - Удаляет контейнер после его использования
 - `--no-deps` - Отключает запуск зависимых контейнеров
 - `--entrypoint ''` - Отключаем entrypoint для текущего запуска
 - `dnode` - Имя сервиса в docker-compose
 - `dnode init my-node-name --chain-id dn-testnet` - Команда которая выполняется внутри контейнера, для инициализации
 - `my-node-name` - Имя ноды (moniker)

NOTE: Шаг является важным, но не обязательным.

 ##### Шаг 2. Задайте параметры конфигураций (необязательный шаг)
 Создайте файл `.env` с необходимыми параметрами для `docker-compose`.
 Как пример можете использовать `.env.example`
 - `REGISTRY_HOST` - (default: `registry.hub.docker.com`) Docker registry address
 - `REGISTRY_GROUP` - (default: `dfinance`) Docker registry user/group
 - `CHAIN_ID` - (default: `dn-testnet`) 
 - `GENESIS_RPC_ENDPOINT` - (default: `https://rpc.testnet.dfinance.co/genesis`) Url for download genesis
 - `DNODE_MONIKER` - (default: `my-first-dfinance-node`) Имя ноды (moniker)
 - `DNODE_TAG` - (default: `latest`)  Docker version tag for dnode
 - `DVM_TAG` - (default: `latest`) Docker version tag for dvm

NOTE: Все остальные параметры конфигураций задаются в файлах конфигураций `config/*.toml`

##### Шаг 3. Запуск ноды
```sh
docker-compose up -d
```

##### Дополнительные команды
- `docker-compose up -d` - Запуск всех сервисов
- `docker-compose down` - Останавливаем все сервисы
- `docker-compose run --rm --no-deps --entrypoint '' dnode bash` - Запуск контейнера перед стартом всех сервисов (для выполнения каких либо команд в ручном режиме перед стартом ноды)
- `docker-compose exec dnode bash` - Подключиться к уже работающему контейнеру для выполнения команд в ручном режиме
