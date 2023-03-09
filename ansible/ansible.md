[lisa@drdev1 ~]$ vim /home/lisa/ansible/ansible.cfg
[defaults]
inventory=/home/lisa/ansible/inventory
roles_path=/home/lisa/ansible/roles
ask_pass=false
remote_user=root

[privilege_escalation]
become=true
become_method=sudo
become_user=root
become_ask_pass=false

[lisa@drdev1 ansible]$ ansible --version

ansible 2.8.18
  config file = /home/lisa/ansible/ansible.cfg
  configured module search path = ['/home/lisa/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.6/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.6.8 (default, Oct 11 2019, 15:04:54) [GCC 8.3.1 20190507 (Red Hat 8.3.1-4)]