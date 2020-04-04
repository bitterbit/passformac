# Using GPG
- sender encrypts a message with the public key of the receiver
- receiver decrypts the message with his private key

###  Encrypt / Decrypt in Unix
encrypt: `gpg --encrypt <filename> --recipient <name or id of recepient>`
decrypt: `gpg <filename>` might need to enter passphrase 


### Get PGP Textual (armor) Key
public key:  `gpg --armor --export {keyname} > {keyname}.gpg`
private key: `gpg --armor --export-secret-keys {keyname} > {keyname}.secret.gpg`

### Other useful commands

**list all keys**
ID: `0FA76A144E3DA5E68B4FAD04ACB2B175912CCA25`
Recepaient name: `username`
```bash
$ gpg --list-keys
/Users/username/.gnupg/pubring.kbx
-----------------------------
pub   rsa2048 2020-01-01 [SC]
      0FA76A144E3DA5E68B4FAD04ACB2B175912CCA25
uid           [ultimate] username
sub   rsa2048 2020-04-03 [E]
```

https://developer.rackspace.com/blog/introduction-to-pgp-encryption-and-decryption/