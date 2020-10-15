# dfinance testnet bootstrap

If you're willing to try our testnet it's the right place to start. With this code you can run your first blockchain node in 4 steps.

## What you get

- **dnode** - blockchain daemon connected to testnet; you've probably seen it but here's [official repository](https://github.com/dfinance/dnode)
- **dvm** - [dfinance vm](https://github.com/dfinance/dvm) - essential component to our blockchain
- **dnode-rest** - rest-server to provide simpler interface to blockchain storage. See [swagger here](https://swagger.testnet.dfinance.co).
- **compiler** - local instance of dvm compiler; by default accessible on port :50053, you can use it with [Move IDE](https://github.com/damirka/vscode-move-ide)

**Important:** all of the containers used in this composition are already on Docker hub, so if you want to try it yourself - [here's the link](https://hub.docker.com/u/dfinance).

## Four step guide into testnet

### Step 1 - Check requirements

For this option to work you'll need [Docker](https://www.docker.com/products/docker-desktop) (v18.06.0+)

### Step 2 - Clone this repo

```bash
git clone git@github.com:dfinance/testnet-bootstrap.git dfinance-testnet
cd dfinance-testnet
```

### Step 3 - Set environment in .env

Application uses *.env* file as config. First let's copy example:
```bash
cp .env.example .env
```
You can customize it, but for the first run it's not that important.
```bash
nano .env # or vi .env # or any editor you choose
```

### Step 4 - Run node

```bash
docker-compose pull && docker-compose up -d
```

To check if it works let's do few simple requests:

```bash
curl localhost:1317/node_info     # node info check
curl localhost:1317/blocks/latest # get last block
```

See [Swagger UI](https://swagger.testnet.dfinance.co) for full API reference.

## Additional commands

Pull newest version and restart containers

```bash
docker-compose pull && docker-compose up -d
```

Stop everything

```bash
docker-compose down
```

Open terminal inside running container

```bash
docker-compose exec PUT_SERVICE_HERE bash

docker-compose exec dnode bash
docker-compose exec dvm bash
```

## Advanced use (optional)

### Initialization of dnode config

```sh
docker-compose run --rm --no-deps --entrypoint '' dnode dnode init my-node-name --chain-id dn-testnet
```

- `--rm` - remove container after it's been used
- `--no-deps` - run without dependencies
- `--entrypoint ''` - disabling entry point for this run
- `dnode` - docker-compose service name
- `dnode init my-node-name --chain-id dn-testnet` - init command which is run in container
- `my-node-name` - node name/moniker

### Custom Configuration

In case you're running a local network or experimenting with setup, you can use these configuration variables:

- `REGISTRY_HOST` - (default: `registry.hub.docker.com`) Docker registry address
- `REGISTRY_GROUP` - (default: `dfinance`) Docker registry user/group
- `CHAIN_ID` - (default: `dn-testnet`)
- `GENESIS_RPC_ENDPOINT` - (default: `https://rpc.testnet.dfinance.co/genesis`) Url for download genesis
- `EXTERNAL_ADDRESS` - (default: `none`) Address to advertise to peers for them to dial (Set your public IP, example: `tcp://x.x.x.x:26656`)
- `DNODE_MONIKER` - (default: `my-first-dfinance-node`) Node name/moniker
- `DNODE_TAG` - (default: `latest`)  Docker version tag for dnode
- `DVM_TAG` - (default: `latest`) Docker version tag for dvm

Additional configuration options can be found in `config/*.toml` files.

## Easy-fast deployment of the validator
You need to have installed:
- [docker](https://docs.docker.com/engine/install/)
- [docker-compose](https://docs.docker.com/compose/install/)

And execute the following commands, substituting the required values:

```sh
cd /opt
git clone https://github.com/dfinance/testnet-bootstrap.git
cd testnet-bootstrap

# Generate .env file
cat << EOF > .env
REGISTRY_HOST=registry.hub.docker.com
REGISTRY_GROUP=dfinance
DNODE_SEEDS=b57d87dac7a9f77fbb11eb0f137a922fcc44cf0c@pub.testnet.dfinance.co:26656
DNODE_TAG=latest
DVM_TAG=latest
EXTERNAL_ADDRESS=tcp://<YOU_PUBLIC_IP>:26656
DNODE_MONIKER=<you_moniker>
EOF

# add alias
cat << EOF >> ~/.profile
alias dnode="docker-compose -f /opt/testnet-bootstrap/docker-compose.yml exec dnode dnode"
alias dncli="docker-compose -f /opt/testnet-bootstrap/docker-compose.yml exec dnode-rest dncli"
EOF

# start node
docker-compose pull	# Get latest docker container
docker-compose up -d

# show logs
docker-compose logs -f --tail 10

# generate new mnemonic
dncli keys mnemonic

# create account
dncli keys add -i <my-account>

# show pubkey
dnode tendermint show-validator

# add validator
dncli tx staking create-validator \
  --amount=2500000000000000000000sxfi \
  --pubkey=<pub_key> \
  --moniker=<moniker> \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="2500000000000000000000" \
  --from <my-account>
```

## Contribution

If you've got any questions or if something went wrong, feel free to [open an issue](https://github.com/dfinance/testnet-bootstrap/issues/new).

