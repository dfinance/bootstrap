#!/bin/sh

# set -x

DNODE_SEEDS="${DNODE_SEEDS}"
DNODE_MONIKER="${DNODE_MONIKER:-ba-dum-tss-node}"
CHAIN_ID=${CHAIN_ID:-dn-testnet}

ALLOW_DUPLICATE_IP="${ALLOW_DUPLICATE_IP:-true}"
VM_ADDRESS="${VM_ADDRESS:-dvm-node:50051}"
VM_DATA_LISTEN="${VM_DATA_LISTEN:-0.0.0.0:50052}"

function iprintf {
  echo -e "\033[0;32m$(date +"%Y.%m.%d %H:%M:%S")\t$@\033[0m"
}

_dnode_path='/root/.dnode'
_priv_validator_state_file="${_dnode_path}/data/priv_validator_state.json"
_dnode_config_path="${_dnode_path}/config"
_genesis_file="${_dnode_config_path}/genesis.json"
_app_file="${_dnode_config_path}/app.toml"
_config_file="${_dnode_config_path}/config.toml"
_vm_file="${_dnode_config_path}/vm.toml"
_node_key_file="${_dnode_config_path}/node_key.json"

mkdir -p ${_dnode_config_path} ${_dnode_path}/data

# check if first run
if [ ! -f ${_node_key_file} ]; then
  iprintf "Not found node_key.json"
  iprintf "Remove old configs"
  rm -rf ${_dnode_config_path}/*

  iprintf "Generate new configs"
  dnode init ${DNODE_MONIKER} --chain-id ${CHAIN_ID}

fi

if [ ! -f ${_priv_validator_state_file} ]; then
  iprintf "Create priv_validator_state.json"
  mkdir -p ${_dnode_path}/data
  cat << EOF > ${_priv_validator_state_file}
{
  "height": "0",
  "round": "0",
  "step": 0
}
EOF
fi

iprintf "Download actual genesis.json file"
wget -q ${GENESIS_RPC_ENDPOINT} -O - | jq -r '.result.genesis' > ${_genesis_file}

iprintf "Configure vm.toml from variables"
if [ ! -z "${VM_ADDRESS}" ]; then
  sed -i "s|vm_address =.*|vm_address = \"${VM_ADDRESS}\"|g" "${_vm_file}"
fi
if [ ! -z "${VM_DATA_LISTEN}" ]; then
  sed -i "s|vm_data_listen =.*|vm_data_listen = \"${VM_DATA_LISTEN}\"|g" "${_vm_file}"
fi

iprintf "Configure config.toml from variables"
if [ ! -z "${ALLOW_DUPLICATE_IP}" ]; then
  sed -i "s|allow_duplicate_ip =.*|allow_duplicate_ip = \"${ALLOW_DUPLICATE_IP}\"|g" "${_config_file}"
fi
if [ ! -z "${DNODE_MONIKER}" ]; then
  sed -i "s|moniker =.*|moniker = \"${DNODE_MONIKER}\"|g" "${_config_file}"
fi
if [ ! -z "${DNODE_SEEDS}" ]; then
  sed -i "s|seeds =.*|seeds = \"${DNODE_SEEDS}\"|g" "${_config_file}"
fi

iprintf "Change RPC laddr from 'tcp://.*:26657' to 'tcp://0.0.0.0:26657'"
sed -i 's|^laddr =.*:26657.*|laddr = "tcp://0.0.0.0:26657"|g' "${_config_file}"

iprintf "Start dnode"
exec "$@"
