# solr-clouds for aws

## required

+ aws key pair (devenv-key.pem)

+ configure hosts file

## provisioning
```sh
ansible-playbook -i hosts --private-key=devenv-key.pem solr.yml -v
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
