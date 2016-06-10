# solr-clouds for aws

## required

+ aws key pair (devenv-key.pem)

+ configure hosts file

## provisioning
```sh
ansible-playbook -i hosts --private-key=devenv-key.pem provisioning.yml -v
```

## start
```sh
ansible-playbook -i hosts --private-key=devenv-key.pem up.yml -v
```

## restart
```sh
ansible-playbook -i hosts --private-key=devenv-key.pem up.yml --extra-vars 'restart=y' -v
```

## update solr config sample
```sh
ansible-playbook -i hosts --private-key=devenv-key.pem solr_config.yml -v
```

## create collection
```
http://[hostname]:8983/solr/admin/collections?action=CREATE&name=test&replicationFactor=1&numShards=2&collection.configName=test
```

## delete collection
```
http://[hostname]:8983/solr/admin/collections?action=DELETE&name=test
```

## add field type sample
```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field-type" : {
     "name":"myTxtField",
     "class":"solr.TextField",
     "positionIncrementGap":"100",
     "analyzer" : {
        "tokenizer":{
           "class":"solr.JapaneseTokenizerFactory" }
        }
    }
}' http://[hostname]:8983/solr/test/schema
```

## add field sample
```
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"test_text",
     "type":"myTxtField",
     "indexed":true ,
     "stored":true ,
     "multiValued":true ,
     "termOffsets":true ,
     "termPositions":true ,
     "termVectors":true
  }
}' http://[hostname]:8983/solr/test/schema
```
