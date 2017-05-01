postgres streaming replication for vagrant

## required

+ Vagrant
+ Virtual Box

## vagrant up

```
cd vagrant/
vagrant up --provider virtualbox
```

※以下は全て仮想OS上で実行する

## pg1(host) with vagrant(user)

```
git clone https://github.com/Thirosue/ansible-samples.git
cd ansible-sample/postgres-streaming-replication
ansible-playbook -i hosts main.yml -vv
```
