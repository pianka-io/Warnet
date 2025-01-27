# Packer

You must first build init6 and place the `init6.tar.gz` in the `ansible/resources` folder.

```sh
packer build -var-file=warnet.pkrvars.hcl warnet.pkr.hcl
```
