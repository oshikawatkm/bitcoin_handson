require 'bitcoin'

Bitcoin.chain_params = :regtest

config = {
  schema: 'http',
  host: 'node-1',
  port: 18443,
  user: 'user',
  password: 'pass'
}

bitcoin_1 = Bitcoin::RPC::BitcoinCoreClient.new(config)
bitcoin_1.config[:wallet] = "wallet1"

# wallet1のUTXOを表示
puts "============================= ↓ WALLET1 UTXO ↓ ==============================="
puts bitcoin_1.listunspent
puts "============================= ↑ WALLET1 UTXO ↑ ==============================="


# トランザクションの作成
tx = Bitcoin::Tx.new
tx.version = 1

# 最初のUTXOをトランザクションのinputとして設定
tx.in << Bitcoin::TxIn.new(out_point: Bitcoin::OutPoint.from_txid(bitcoin_1.listunspent[0]["txid"], bitcoin_1.listunspent[0]["vout"]))
# wallet2のアドレスに送金するアウトプットを生成
tx.out << Bitcoin::TxOut.new(value: 4999990000, script_pubkey: Bitcoin::Script.parse_from_addr('＜wallet2のアドレスに変更してください＞'))

puts "============================= ↓ NEW TRANSACTION ↓ ==============================="
puts tx.to_hex
puts "============================= ↑ NEW TRANSACTION ↑ ==============================="