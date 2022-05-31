from bitcoinlib.services.bitcoind import BitcoindClient
from bitcoinlib.wallets import Wallet, wallet_create_or_open
from bitcoinlib.transactions import Transaction

# (0) Bitcoinノードの設定
base_url = 'http://user:pass@0.0.0.0:18443'
node1 = BitcoindClient(network="regtest", base_url=base_url)

# (1) blockcountの確認
count = node1.blockcount()
print("BLOCK COUNT: %s" % count)


# (2) wallet3の作成
# wallet3 = Wallet.create('wallet7')
# wallet3 = Wallet('wallet3')
# wallet3_balance = wallet3.balance()
# print("WALLET3 BALANCE: %s" % wallet3_balance)
# wallet3_utxos = wallet3.utxos()
# print("WALLET3 UTXO: %s" % wallet3_utxos)
# print(wallet3.addresslist())

# (3) walet2で
wallet1 = wallet_create_or_open('wallet1', network='regtest')
wallet1_balance = wallet1.balance()
print("WALLET1 BALANCE: %s" % wallet1_balance)
wallet1_utxos = wallet1.utxos()
print("WALLET1 UTXO: %s" % wallet1_utxos)
print(wallet1.addresslist())


#