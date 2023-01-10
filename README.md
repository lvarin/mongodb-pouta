# MongoDB in Pouta

## Install

* [Install the terraform](https://developer.hashicorp.com/terraform/downloads) client

```sh
pip install ansible
terraform -chdir=terraform init
```

* Create `group_vars/all` from the `group_vars/all-TEMPLATE` file. You must fill up the `keypair` with the name of the key you uploaded to Pouta and set the `network` to the correct one at Pouta.

* Apply:

```sh
. project_YYYXXXX-openrc.sh
ansible-playbook site.yaml
```

### Adding users

By default the security is enabled, this means a user must be created. Log in the mongoDB machine and run `mongosh`, this will open a mongo shell:

* Change to the `admin` DB:

```sh
test> use admin
switched to db admin
```

* Then create the user:

```sh
admin> db.createUser(
...   {
...     user: "myUserAdmin",
...     pwd: passwordPrompt(), // or cleartext password
...     roles: [
...       { role: "userAdminAnyDatabase", db: "admin" },
...       { role: "readWriteAnyDatabase", db: "admin" }
...     ]
...   }
... )
Enter password
************{ ok: 1 }
```

The user creste will be called `myUserAdmin` and the password will be the one you entered.

### Connect

```sh
IP=<MONGODB_IP>
mongosh mongodb://$IP:27017 -u myUserAdmin -p
```

## Destroy

```sh
terraform -chdir=terraform destroy -var 'flavor=standard.medium' -var 'keypair=alvaro-key' -var 'ssh_user=ubuntu' -var 'private_key_path=~/.ssh/id_rsa' -var 'cidr_ssh=0.0.0.0/0' -var 'image=Ubuntu-22.04'
```

