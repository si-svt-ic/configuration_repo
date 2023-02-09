getniccfg
setniccfg -s 192.168.127.81 255.255.255.0 192.168.127.1

ssh -t vnpt@192.168.127.80 'setniccfg -s 192.168.127.80 255.255.255.0 192.168.127.1'
ssh -t vnpt@192.168.127.80 'getniccfg'


ANSIBLE_CALLBACK_WHITELIST=json ANSIBLE_STDOUT_CALLBACK=json ansible-playbook -i inventory.ini get_info.yaml > out.json