
./stopNetwork.sh
sudo ./teardown.sh

../bin/cryptogen generate --config=./artifacts/crypto-config.yaml --output=./artifacts/network/crypto-config

export FABRIC_CFG_PATH=${PWD}/artifacts
export SYS_CHANNEL=syschannel
export IMAGE_TAG=latest

../bin/configtxgen -profile TraceOrdererGenesis -outputBlock ./artifacts/network/genesis.block -channelID $SYS_CHANNEL

export CHANNEL_NAME=supplychainchannel

../bin/configtxgen -profile TraceOrgsChannel -outputCreateChannelTx ./artifacts/network/channel.tx -channelID $CHANNEL_NAME

../bin/configtxgen -profile TraceOrgsChannel -outputAnchorPeersUpdate ./artifacts/network/ManufacturerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ManufacturerMSP

../bin/configtxgen -profile TraceOrgsChannel -outputAnchorPeersUpdate ./artifacts/network/MiddleMenMSPanchors.tx -channelID $CHANNEL_NAME -asOrg MiddleMenMSP

../bin/configtxgen -profile TraceOrgsChannel -outputAnchorPeersUpdate ./artifacts/network/ConsumerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ConsumerMSP

export MANUFACTURER_CA_PRIVATE_KEY=$(cd ./artifacts/network/crypto-config/peerOrganizations/manufacturer.example.com/ca && ls *_sk)

export MIDDLEMEN_CA_PRIVATE_KEY=$(cd ./artifacts/network/crypto-config/peerOrganizations/middlemen.example.com/ca && ls *_sk)

export CONSUMER_CA_PRIVATE_KEY=$(cd ./artifacts/network/crypto-config/peerOrganizations/consumer.example.com/ca && ls *_sk)

docker-compose -p supplychain -f artifacts/docker-compose.yaml up -d

docker exec -it cli bash

#====================================== STOP HERE, CONTINUE WHEN INSIDE CLI ======================================


export CHANNEL_NAME=supplychainchannel

peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel join -b supplychainchannel.block

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp CORE_PEER_ADDRESS=peer0.middlemen.example.com:8051 CORE_PEER_LOCALMSPID="MiddleMenMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer0.middlemen.example.com/tls/ca.crt peer channel join -b $CHANNEL_NAME.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp CORE_PEER_ADDRESS=peer1.middlemen.example.com:9051 CORE_PEER_LOCALMSPID="MiddleMenMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer1.middlemen.example.com/tls/ca.crt peer channel join -b $CHANNEL_NAME.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp CORE_PEER_ADDRESS=peer2.middlemen.example.com:10051 CORE_PEER_LOCALMSPID="MiddleMenMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer2.middlemen.example.com/tls/ca.crt peer channel join -b $CHANNEL_NAME.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp CORE_PEER_ADDRESS=peer0.consumer.example.com:11051 CORE_PEER_LOCALMSPID="ConsumerMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/peers/peer0.consumer.example.com/tls/ca.crt peer channel join -b $CHANNEL_NAME.block
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp CORE_PEER_ADDRESS=peer0.manufacturer.example.com:7051 CORE_PEER_LOCALMSPID="ManufacturerMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/ManufacturerMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp CORE_PEER_ADDRESS=peer0.middlemen.example.com:8051 CORE_PEER_LOCALMSPID="MiddleMenMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer0.middlemen.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/MiddleMenMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp CORE_PEER_ADDRESS=peer0.consumer.example.com:11051 CORE_PEER_LOCALMSPID="ConsumerMSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/peers/peer0.consumer.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/ConsumerMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp CORE_PEER_ADDRESS=peer0.manufacturer.example.com:7051 

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp 
CORE_PEER_ADDRESS=peer0.manufacturer.example.com:7051 
CORE_PEER_LOCALMSPID="ManufacturerMSP" 
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt
# CORE_PEER_LOCALMSPID="ManufacturerMSP" 
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt 

cd /opt/gopath/src/github.com/chaincode/supplychain
export GO111MODULE=on
export GOFLAGS='-mod=vendor'
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# go mod tidy
# go mod vendor
peer chaincode install -n supplychaincc -v 1.0 -p github.com/chaincode/supplychain
# peer chaincode install -n supplychaincc -v 1.0 -p github.com/chaincode/
peer lifecycle chaincode package supplychain.tar.gz \
  --path github.com/chaincode/supplychain \
  --lang golang \
  --label supplychain_1
peer lifecycle chaincode install supplychain.tar.gz
peer lifecycle chaincode queryinstalled

#====================================== STOP HERE, COPY THE RETURED CHAINCODE PAKAGE ID AND PASE BELOW ======================================
# export CCPID=<PAKAGEID HERE> ie. export CCPID=supplycyhian123456
export CCPID=
peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 \
  --channelID supplychainchannel \
  --name supplychaincc \
  --version 1.0 \
  --package-id $CCPID \
  --sequence 1 \
  --init-required \
  --signature-policy "OR('ManufacturerMSP.peer')" \
  --tls \
  --cafile $ORDERER_CA \
  --peerAddresses peer0.manufacturer.example.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt

export CORE_PEER_LOCALMSPID="MiddleMenMSP"
export CORE_PEER_ADDRESS=peer0.middlemen.example.com:8051
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer0.middlemen.example.com/tls/ca.crt

# peer lifecycle chaincode install supplychain.tar.gz

peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 \
  --channelID supplychainchannel \
  --name supplychaincc \
  --version 1.0 \
  --package-id $CCPID \
  --sequence 1 \
  --init-required \
  --signature-policy "OR('ManufacturerMSP.peer')" \
  --tls \
  --cafile $ORDERER_CA \
  --peerAddresses $CORE_PEER_ADDRESS \
  --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

export CORE_PEER_LOCALMSPID="ConsumerMSP"
export CORE_PEER_ADDRESS=peer0.consumer.example.com:11051
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/peers/peer0.consumer.example.com/tls/ca.crt

# peer lifecycle chaincode install supplychain.tar.gz
peer lifecycle chaincode approveformyorg \
  -o orderer.example.com:7050 \
  --channelID supplychainchannel \
  --name supplychaincc \
  --version 1.0 \
  --package-id $CCPID \
  --sequence 1 \
  --init-required \
  --signature-policy "OR('ManufacturerMSP.peer')" \
  --tls \
  --cafile $ORDERER_CA \
  --peerAddresses $CORE_PEER_ADDRESS \
  --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE


CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp 
CORE_PEER_ADDRESS=peer0.manufacturer.example.com:7051 
CORE_PEER_LOCALMSPID="ManufacturerMSP" 
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt


peer lifecycle chaincode commit \
  -o orderer.example.com:7050 \
  --channelID supplychainchannel \
  --name supplychaincc \
  --version 1.0 \
  --sequence 1 \
  --init-required \
  --signature-policy "OR('ManufacturerMSP.peer')" \
  --tls \
  --cafile $ORDERER_CA \
  --peerAddresses peer0.manufacturer.example.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt \
  --peerAddresses peer0.middlemen.example.com:8051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer0.middlemen.example.com/tls/ca.crt \
  --peerAddresses peer0.consumer.example.com:11051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/peers/peer0.consumer.example.com/tls/ca.crt


peer chaincode invoke \
  -o orderer.example.com:7050   \
  --isInit   \
  --tls \
  --cafile $ORDERER_CA   \
  --peerAddresses peer0.manufacturer.example.com:7051   \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt   \
  -C supplychainchannel   \
  -n supplychaincc   \
  -c '{"Args":["initLedger"]}'

peer chaincode invoke \
  -o orderer.example.com:7050 \
  --isInit \
  --tls \
  --cafile $ORDERER_CA \
  --peerAddresses peer0.manufacturer.example.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt \
  --peerAddresses peer0.middlemen.example.com:8051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/middlemen.example.com/peers/peer0.middlemen.example.com/tls/ca.crt \
  --peerAddresses peer0.consumer.example.com:11051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/consumer.example.com/peers/peer0.consumer.example.com/tls/ca.crt \
  -C supplychainchannel \
  -n supplychaincc \
  -c '{"Args":["initLedger"]}'

peer chaincode invoke \
  -o orderer.example.com:7050 \
  --tls true \
  --cafile $ORDERER_CA \
  --peerAddresses peer0.manufacturer.example.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt \
  -C $CHANNEL_NAME \
  -n supplychaincc \
  -c '{"Args":["createUser","kuldeep1","kk@asdf.asdf","manufacturer","rajapur","password"]}'

peer chaincode invoke \
  -o orderer.example.com:7050 \
  --tls true \
  --cafile $ORDERER_CA \
  --peerAddresses peer0.manufacturer.example.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt \
  -C $CHANNEL_NAME \
  -n supplychaincc \
  -c '{"Args":["queryAll","User"]}'

peer chaincode invoke \
  -o orderer.example.com:7050 \
  --tls true \
  --cafile $ORDERER_CA \
  --peerAddresses peer0.manufacturer.example.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/manufacturer.example.com/peers/peer0.manufacturer.example.com/tls/ca.crt \
  -C $CHANNEL_NAME \
  -n supplychaincc \
  -c '{"Args":["signIn","User1","password"]}'


  peer chaincode invoke -o orderer.example.com:7050 --tls true 
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
  -C $CHANNEL_NAME -n supplychaincc -c '{"Args":["queryAll","User"]}'

