
https://stackoverflow.com/questions/71844906/how-to-reuse-variables-across-different-playbook-tasks-using-set-stats-in-ansibl

Playbook1:

    - name: PLaybook to generate set_stats
      hosts: localhost
      gather_facts: true
      tasks:
        - name: check google
          uri:
            url: http://www.google.com
            return_content: yes
          register: this

        - set_fact:  
            this_local: "{{ this.url }}"   

        - set_stats:
            data:
              test_stat: "{{ this_local }}"

        - name: debug set fact
          debug:
            msg: "{{ this.url}}"
Playbook2:

    - name: PLaybook to check set_stats
      hosts: localhost
      gather_facts: true
      tasks:   
        - name: content of set_stats
          debug:
            msg: "{{ test_stat }}"  
Result:

PLAY [PLaybook to check set_stats] *********************************************
TASK [Gathering Facts] *********************************************************
ok: [localhost]
TASK [content of set_stats] ****************************************************
ok: [localhost] => {
    "msg": "http://www.google.com"
}
PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 