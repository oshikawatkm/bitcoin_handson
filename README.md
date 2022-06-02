
# Bitcoin ハンズオン

本ハンズオンではDockerを用いて2角bitcoindノードを建て、それぞれに作成したwalletで送受金、JSON-RPCを用いてプログラムを書きながらBitcoinの動きを学ぶ。

```
$ git clone https://github.com/oshikawatkm/bitcoin_handson.git
```
## Bitcoin CLI

Bitcoin CLIは以下のような構成で入力します。
```
$ bitcoin-cli [options] <command>  
```

使用可能なコマンドは以下で確認できる。
https://bitcoincore.org/en/doc/0.20.0/rpc/

**体で覚えるためにコピペをするのではなく手入力しましょう**

### (bitcoin_1) 環境確認 & 準備

dockerコンテナを起動
```
$ docker-compose up
```

`bitcoin_1`のコンテナ内に入って操作する。
```
$ docker exec -it bitcoin_1 bash
```

ブロック数を確認。もちろん"0"
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockcount
0
```

`wallet1`という名前のwalletを作成。（一つのノードに複数のwalletを作成することもできます）
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass createwallet "wallet1"
{
  "name": "wallet1",
  "warning": ""
}
```

`wallet1`の所有BTCを確認。もちろんまだ0BTC。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 getbalance
0.00000000
```

`wallet1`のUTXOを確認。もちろん空。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 listunspent
[
]
```


`wallet1`でaddressを生成する。
何かしらの文字列の部分が表示される。それがwallet1のアドレス。（何度実行してもよい。毎回別のアドレスが返ってくるはず。）
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1  getnewaddress
< wallet1のアドレス >
```

### (bitcoin_2) 環境確認 & 準備

ターミナルで別のタブを開く。
`bitcoin_2`のコンテナ内に入って操作する。
```
$ docker exec -it bitcoin_2 bash
```

`wallet2`という名前のwallet作成。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass createwallet "wallet2"
{
  "name": "wallet2",
  "warning": ""
}
```

`wallet2`でaddressを生成する。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet2 getnewaddress 
< wallet2のアドレス >
```

### (bitcoin_1) マイニングの実行

bitcoin_1のターミナルに戻る。
101ブロックの生成を行い、マイニング報酬を`wallet1`で受け取る。
実行すると大量(101個)の文字列が配列で帰ってくるはず。この文字列はブロックヘッダー。

```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 generatetoaddress 101 < wallet1のアドレス >
[
  "4ece5b5701a76f99fb3d823447773f648baf0f61835f5e11f4585044889df07b",
  "16be9944002f88d2d86a9601d38c374467e62cab53bc7b93cd7d46002e0c0e29",
  "124b00eba3bff1b2a50cb6bcc0b6d5ff3d04b3aafee89958427974fcc6aa715a",
  "6250b1f1bd7bdf63e4c7f74014ddfdfa75e04a87cb89803d0db1198cc883c8d3",
  "6a7fb4ee42207b729423912c6561fcc0275fec052334623eec05c0978f05379f",
  "17f0df8e506b4b07128d11f2d5f59677d6d2777a6687350e77e1e7889d20.............
```

ブロックカウントを確認してみる。101なはず。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockcount
101
```

wallet1の残高を確認してみる。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 getbalance
50.00000000
```

`wallet1`のUTXOを確認。マイニング報酬を確認できる。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 listunspent
[
  {
    "txid": "25d4893b0d83ae2980bd3a82537420246fe9274f54fbabafa93bd8673b97c69c",
    "vout": 0,
    "address": "bcrt1q6m75utlsfgct7g2xcdtrghaynxc88532g55xjs",
    "label": "",
    "scriptPubKey": "0014d6fd4e2ff04a30bf2146c356345fa499b073d22a",
    "amount": 50.00000000,
    "confirmations": 101,
    "spendable": true,
    "solvable": true,
    "desc": "wpkh([2bbfacf4/0'/0'/0']03fcc2873c31bfbb3d81b069d6abd3d4ffa43d6a1d1e93408e1d0bf7013ff4573b)#ez49ra2j",
    "safe": true
  }
]
```

### (bitcoin_1) 送金
Bitcoinの送金には以下の2つの方法がある。
* sendtoaddress: 使用するUTXOの選択などを自動で行い、transaction作成&ブロードキャストするお手軽な送金方法
* createrowtransaction & broadcasttransaction: UTXO, Scriptなどを指定しtransactionを作成。transactionを選択し、ブロードキャスト。
ここでは`sendtoaddress`のみを確認。

`wallet2のアドレス`と`送金額(0.01BTC)`を指定し、`sendtoaddress`を実行.
実行すると文字列が帰ってくる。これはtransaction id。あとで使うので控えておく。

```
$ bitcoin-cli -rpcwallet=wallet1 sendtoaddress <wallet2のアドレス> 0.01
76e72b6683b7a408f884cd5dd4cee5050d360cb8f32f5bb8627c7c64d6b89926
```

### (bitcoin_2) 着金確認(失敗)

bitcoin_2のターミナルを開き、まずは`bitcoin_1`で生成したブロックが同期されているかを確認する。


101なはず。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockcount
101
```

`wallet2`の残高を確認する。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet2 getbalance
0.00000000
```

残高は0BTCのまま。
送金transactionはブロードキャストされているが、**マイニングによる承認を受けていないため、まだ着金は確認できない**


### (bitcoin_1) マイニングによる送金トランザクションの承認

bitcoin_1のターミナルを開き、マイニングを行う。

```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 generatetoaddress 6 < wallet1のアドレス >
[
  "4ece5b5701a76f99fb3d823447773f648baf0f61835f5e11f4585044889df07b",
  "16be9944002f88d2d86a9601d38c374467e62cab53bc7b93cd7d46002e0c0e29",
  "124b00eba3bff1b2a50cb6bcc0b6d5ff3d04b3aafee89958427974fcc6aa715a",
  "6250b1f1bd7bdf63e4c7f74014ddfdfa75e04a87cb89803d0db1198cc883c8d3",
  "6a7fb4ee42207b729423912c6561fcc0275fec052334623eec05c0978f05379f",
  "17f0df8e506b4b07128d11f2d5f59677d6d2777a6687350e77e1e7889d20379f"
]
```

先頭に表示されたblockhashは後で使うためメモしておく。(上の例では: "4ece5b5701a76f99fb3d823447773f648baf0f61835f5e11f4585044889df07b")


### (bitcoin_2) 着金確認(成功)


bitcoin_2のターミナルを開き、`wallet2`の残高を確認する。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet2 getbalance
0.01000000
```

`wallet2`のUTXOを確認する。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet2 listunspent
[
  {
    "txid": "c3a1e3051156d9ef64af3070382023e214642461be2e00dca734ac361a8dc82d",
    "vout": 1,
    "address": "bcrt1qhhrhxveqhyhch8mu83jx08cszxd9d9wq3rr93n",
    "label": "",
    "scriptPubKey": "0014bdc7733320b92f8b9f7c3c64679f10119a5695c0",
    "amount": 0.01000000,
    "confirmations": 6,
    "spendable": true,
    "solvable": true,
    "desc": "wpkh([f5462cff/0'/0'/0']0388bd7d31168cc8ec710ca8a920d49579f50b48cd5a1b71ac8704a3318bcc9ce6)#yf2mpas5",
    "safe": true
  }
]
```

### ブロック＆トランザクションの確認


ブロック情報の確認。
txの配列に送金トランザクションと報酬トランザクションの２つがあることを確認。
```
$ bitcoin-cli -regtest  -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 getblock < 控えたblockhash >
{
  "hash": "50470b6c06ec75d26786038ff1e77278ca84db8ff690e46f4209232abe7aa2d9",
  "confirmations": 6,
  "strippedsize": 327,
  "size": 472,
  "weight": 1453,
  "height": 103,
  "version": 536870912,
  "versionHex": "20000000",
  "merkleroot": "a1a218b96cd33aaac26905e3130e382311b1f0d3a80f32d564e3a984aada456b",
  "tx": [
    "dcf9f810aabce38e8564bea35cfba75fe7e0a735cbe69c6a8352461819a52e8f",
    "c3a1e3051156d9ef64af3070382023e214642461be2e00dca734ac361a8dc82d"
  ],
  "time": 1653716676,
  "mediantime": 1653713107,
  "nonce": 0,
  "bits": "207fffff",
  "difficulty": 4.656542373906925e-10,
  "chainwork": "00000000000000000000000000000000000000000000000000000000000000d0",
  "nTx": 2,
  "previousblockhash": "7901b8276863095a735c85f57ebfe8da685c333f85dbc0b008ade5626ddeab93",
  "nextblockhash": "64c4d29732f81325dfe538576a19843709566ce67a448f0818d1c9b02d079ee7"
}

```

トランザクション情報の確認
```
$ bitcoin-cli -regtest  -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 gettransaction < 控えたtransactionid >
{
  "amount": -0.01000000,
  "fee": -0.00002820,
  "confirmations": 6,
  "blockhash": "50470b6c06ec75d26786038ff1e77278ca84db8ff690e46f4209232abe7aa2d9",
  "blockheight": 103,
  "blockindex": 1,
  "blocktime": 1653716676,
  "txid": "c3a1e3051156d9ef64af3070382023e214642461be2e00dca734ac361a8dc82d",
  "walletconflicts": [
  ],
  "time": 1653716145,
  "timereceived": 1653716145,
  "bip125-replaceable": "no",
  "details": [
    {
      "address": "bcrt1qhhrhxveqhyhch8mu83jx08cszxd9d9wq3rr93n",
      "category": "send",
      "amount": -0.01000000,
      "vout": 1,
      "fee": -0.00002820,
      "abandoned": false
    }
  ],
  "hex": "020000000001015e9d203e02c89f087556537b91bf54e4ed4bc035e35c863fb513e761acb260aa0000000000feffffff02bca4f62901000000160014709e4bb0727dc45e24776ec57c789ff9996753b040420f0000000000160014bdc7733320b92f8b9f7c3c64679f10119a5695c00247304402202cf01f9b13caa725dcd7ae8008d7f5c861c7eaa574cacd2806853365e30d7f22022009d6c98e726dda3986bc69ef8d8946acae695aa39edd4ff9155e2e37aa2b409d012103fcc2873c31bfbb3d81b069d6abd3d4ffa43d6a1d1e93408e1d0bf7013ff4573b66000000"
}
```

## RPC接続

bitcoindは[JSON-RPC](https://www.jsonrpc.org/) を用いたRPC (Remote Procedure Call) ができる。
ここでは**curlコマンド**と**プログラム(python)**を用いたRPCを試してみる。


### curlコマンド

curlを用いて`bitcoin_1`で`getblockchaininfo`呼び出し。
```
$ curl --user user:pass --data-binary '{"jsonrpc": "1.0", "id": "curltest", "method": "getblockchaininfo", "params": []}' -H 'content-type: text/plain;' http://0.0.0.0:18443/
```

### プログラム(ruby)

rubyのコードを用いてトランザクションの生成。
`handson_finished.rb`を`main.rb`に写経してください。

```
$ ruby handson_finished.rb
```

生成したトランザション`bitcoin_1`で確認。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass decoderawtransaction "<生成したトランザクション>"
```

トランザションを`wallet1`の鍵で署名。
`hex`に署名済みのトランザクションが表示される。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 signrawtransactionwithwallet "<生成したトランザクション>"
{
  "hex": "010000000001012d5473b68d749532e093b30c5df2d7e351a8c0b0006bae662d9ef8565f8c62b30000000000ffffffff0164000000000000000451529387024730440220135a1a56b61e5e30c715397415fa084d07144f8ec243627d72687d234c531b6602207e715601428020da75e21a45bad99ac1f7c1991b5c4f3aa2d9e869b1e5922f4d012103fcc2873c31bfbb3d81b069d6abd3d4ffa43d6a1d1e93408e1d0bf7013ff4573b00000000",
  "complete": true
}
```

ブロードキャストする。
```
$ bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=wallet1 sendrawtransaction "<生成した署名済みトランザクション>"
{
  "hex": "010000000001012d5473b68d749532e093b30c5df2d7e351a8c0b0006bae662d9ef8565f8c62b30000000000ffffffff0164000000000000000451529387024730440220135a1a56b61e5e30c715397415fa084d07144f8ec243627d72687d234c531b6602207e715601428020da75e21a45bad99ac1f7c1991b5c4f3aa2d9e869b1e5922f4d012103fcc2873c31bfbb3d81b069d6abd3d4ffa43d6a1d1e93408e1d0bf7013ff4573b00000000",
  "complete": true
}
```

## クイズ
### クイズ1
`bitcoin_3`というbitcoinノードのコンテナを作成する。このノードはまだ`bitcoin_1`, `bitcoin_2`のコンテナネットワークに接続はしていない。
`bitcoin_3`でブロックを1000個生成した後、`bitcoin_1`, `bitcoin_2`ネットワークに接続する。
最新のブロックカウント、今までの取引はどうなるでしょう？
時間あったら試してみてください。

### クイズ2
rubyのコードでは`50BTC`をインプットに取り、`10BTC`をアウトプットに指定しました。
残りの`40BTC`はどうなったでしょうか？

### クイズ3
rubyで生成したトランザクションをインプットにしたトランザクションを作成、ブロードキャストしてみてください。

## まとめ
mainnetやtestnetはregtestと全く違った面白さがあるため、ぜひ別のネットワークでも試してみてほしい

以下の資料はBitcoinの操作を網羅的に解説している
https://github.com/BlockchainCommons/Learning-Bitcoin-from-the-Command-Line