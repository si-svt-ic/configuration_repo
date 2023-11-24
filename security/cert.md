#

## certificate in .pem format

How to save public key from a certificate in .pem format

  openssl x509 -pubkey -noout -in cert.pem  > pubkey.pem

decode certificates on your own computer

  openssl x509 -in certificate.crt -text -noout

Check match pubkey.pem and private,key at url 