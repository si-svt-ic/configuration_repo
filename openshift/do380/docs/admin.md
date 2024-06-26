2) Alertmanager mail
Can you please paste the output of the following commands from a worker node?
sh-4.4# FROM="Noreply <noreply@example.com>"
sh-4.4# TO="Admin <admin@example.com>"
sh-4.4# SMARTHOST="smtp.example.com"
sh-4.4# AUTH_USERNAME="Username"
sh-4.4# AUTH_PASSWORD="Password"
sh-4.4# cat << EOF > email.txt
From: $FROM
To: $TO
Subject: Test email with curl
Test email

EOF
sh-4.4# curl -sv smtp://$SMARTHOST --mail-from $FROM --mail-rcpt $TO --upload-file email.txt

## Operation task worker

Edit node worker for balance

  nmcli c show bond0 
  nmcli c mod bond0 +bond.option xmit_hash_policy=layer3+4
