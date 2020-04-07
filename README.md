# dfinance testnet bootstrap

If you're willing to try our testnet it's the right place to start. With this code you can run your first blockchain node in 4 steps.

## What you'll get

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
curl localhost:1317/node_info # just checking
curl localhost:1317/blocks/latest # get last block
```

See [Swagger UI](https://swagger.testnet.dfinance.co) for full API reference.
