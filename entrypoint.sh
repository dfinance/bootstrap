#!/bin/bash

# set -x
set -e

DNODE_MONIKER="${DNODE_MONIKER:-my-first-dfinance-node}"
CHAIN_ID="${CHAIN_ID:-dn-testnet}"
GENESIS_RPC_ENDPOINT="${GENESIS_RPC_ENDPOINT:-https://rpc.testnet.dfinance.co/genesis}"

ALLOW_DUPLICATE_IP="${ALLOW_DUPLICATE_IP:-false}"
VM_ADDRESS="${VM_ADDRESS:-dvm:50051}"
VM_DATA_LISTEN="${VM_DATA_LISTEN:-0.0.0.0:50052}"
RPC_LISTEN_ADDRESS="${RPC_LISTEN_ADDRESS:-0.0.0.0}"

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
_priv_validator_key_file="${_dnode_config_path}/priv_validator_key.json"

mkdir -p ${_dnode_config_path} ${_dnode_path}/data

# check if first run
if [[ ! -f "${_node_key_file}" || ! -f "${_priv_validator_key_file}" ]]; then
  iprintf "Not found 'node_key.json' or/and 'priv_validator_key.json'"
  # iprintf "Remove old configs"
  # rm -rf ${_dnode_config_path}/*

  if [[ ! -z "$(ls ${_dnode_config_path})" ]]; then
    _old_folder_path="${_dnode_config_path}/old_$(date +'%Y.%m.%d_%H%M%S')"
    mkdir -p ${_old_folder_path}
    iprintf "Copy old files to path: ${_old_folder_path##*/}"
    cp ${_dnode_config_path}/*.{json,toml} ${_old_folder_path}
  fi

  iprintf "Generate new configs"
  dnode init ${DNODE_MONIKER} --chain-id ${CHAIN_ID}
fi


if [[ ! -f "${_priv_validator_state_file}" ]]; then
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

if [ -z "${DNODE_SEEDS}" ]; then
  DNODE_SEEDS=$(jq -r '
            [
              .app_state.genutil.gentxs[]
              | .value.memo
            ] | join(",")
            ' ${_genesis_file})
  iprintf "Use the following DNODE_SEEDS: ${DNODE_SEEDS}"
fi

iprintf "Configure vm.toml from variables"
if [[ ! -z "${VM_ADDRESS}" ]]; then
  sed -i "s|vm_address =.*|vm_address = \"${VM_ADDRESS}\"|g" "${_vm_file}"
fi
if [[ ! -z "${VM_DATA_LISTEN}" ]]; then
  sed -i "s|vm_data_listen =.*|vm_data_listen = \"${VM_DATA_LISTEN}\"|g" "${_vm_file}"
fi

iprintf "Configure config.toml from variables"
if [[ ! -z "${ALLOW_DUPLICATE_IP}" ]]; then
  sed -i "s|allow_duplicate_ip =.*|allow_duplicate_ip = \"${ALLOW_DUPLICATE_IP}\"|g" "${_config_file}"
fi
if [[ ! -z "${DNODE_MONIKER}" ]]; then
  sed -i "s|moniker =.*|moniker = \"${DNODE_MONIKER}\"|g" "${_config_file}"
fi
if [[ ! -z "${DNODE_SEEDS}" ]]; then
  sed -i "s|seeds =.*|seeds = \"${DNODE_SEEDS}\"|g" "${_config_file}"
fi
if [[ ! -z "${RPC_LISTEN_ADDRESS}" ]]; then
  iprintf "Change RPC laddr from 'tcp://.*:26657' to 'tcp://${RPC_LISTEN_ADDRESS}:26657'"
  sed -i "s|^laddr =.*:26657.*|laddr = \"tcp://${RPC_LISTEN_ADDRESS}:26657\"|g" "${_config_file}"
fi

iprintf "Start dnode"
exec "$@"
