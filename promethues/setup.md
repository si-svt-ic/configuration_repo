## Introduction

    Setup a external monitoring system which gather metrics from node-exporter to trigger basic alert for host. Example: CPU alert, Memory alert. 

## Setup promethues

Prepare
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld

    timedatectl set-timezone Asia/Ho_Chi_Minh
    yum -y install chrony
    systemctl enable chronyd.service
    systemctl restart chronyd.service
    chronyc sources
    timedatectl set-local-rtc 0

Generate token
    
    oc get sa -n openshift-monitoring | grep prometheus-k8s
    oc describe sa prometheus-k8s -n openshift-monitoring | grep Tokens
    secret=$(oc describe sa prometheus-k8s -n openshift-monitoring | grep Tokens | awk {'print $2'})
    oc describe secret $secret -n openshift-monitoring

Test token

    tk=$(sudo cat /home/prometheus/token.txt)
    sudo curl -H "Authorization: Bearer $tk" https://master01:9100/metrics -k
    sudo chown prometheus:prometheus /home/prometheus/token.txt

Download at https://prometheus.io/download/
    
    wget https://github.com/prometheus/prometheus/releases/download/v2.42.0/prometheus-2.42.0.linux-amd64.tar.gz
    sudo tar -xzvf prometheus-2.42.0.linux-amd64.tar.gz 
    sudo mv prometheus-2.42.0.linux-amd64 prometheuspackage
    sudo cp prometheuspackage/prometheus /usr/local/bin/
    sudo cp prometheuspackage/promtool /usr/local/bin/
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
    sudo cp -r prometheuspackage/consoles /etc/prometheus
    sudo cp -r prometheuspackage/console_libraries /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

Edit following https://prometheus.io/docs/prometheus/latest/configuration/configuration/

    sudo vi /etc/prometheus/prometheus.yml
    sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
    sudo promtool check config /etc/prometheus/prometheus.yml

Run service

    sudo vi /etc/systemd/system/prometheus.service
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl status prometheus
    systemctl status prometheus -l --no-pager    # so you don't get truncated lines
    journalctl -eu prometheus    # scroll sideways if necessary

Login at
    http://10.144.101.111:9090/graph
    
## Setup alertmanager

Download at https://prometheus.io/download/
    
    sudo wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
    sudo useradd --no-create-home --shell /bin/false alertmanager
    sudo cd /opt
    
    sudo tar xvf alertmanager-0.25.0.linux-amd64.tar.gz
    sudo mv alertmanager-0.25.0.linux-amd64/alertmanager /usr/local/bin/
    sudo mv alertmanager-0.25.0.linux-amd64/amtool /usr/local/bin/
    sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
    sudo chown alertmanager:alertmanager /usr/local/bin/amtool
    sudo cd -
    sudo mkdir /etc/alertmanager
    sudo chown alertmanager:alertmanager /etc/alertmanager
    sudo mv alertmanager.yml /etc/alertmanager/
    sudo chown alertmanager:alertmanager /etc/alertmanager/alertmanager.yml
    sudo vi /etc/systemd/system/alertmanager.service
    sudo systemctl daemon-reload
    sudo systemctl enable alertmanager
    sudo systemctl status alertmanager

    sudo vi /etc/prometheus/rules.yml 
    sudo /usr/local/bin/promtool check rules /etc/prometheus/rules.yml 
    sudo systemctl restart prometheus

Login at
    http://10.144.101.111:9093


## config

### config telegram

    export http_proxy=http://{Proxy-User-Name}:{Proxy-Password}@<Proxy-Server-IP-Address>:<Proxy-Port>
    export https_proxy= http://{Proxy-User-Name}:{Proxy-Password}@<Proxy-Server-IP-Address>:<Proxy-Port>
    export ftp_proxy= http://{Proxy-User-Name}:{Proxy-Password}@<Proxy-Server-IP-Address>:<Proxy-Port>
    export no_proxy=127.0.0.1,localhost

   yum install git golang -y
   go get github.com/inCaller/prometheus_bot
   cd go/src/github.com/inCaller/prometheus_bot/
   make clean
   make
   cp prometheus_bot /usr/bin

   /etc/systemd/system/prometheus-bot.service

## Manual

    To change data file folder
    sudo vi /etc/systemd/system/prometheus.service

    Set 

## References

Guide to setup promethues and alerting

    https://news.cloud365.vn/prometheus-phan-1-huong-dan-cai-dat-prometheus-tren-centos-7/
    https://hocchudong.com/huong-dan-cau-hinh-prometheus-thu-thap-metric-tren-centos7-phan-2/
    https://hocchudong.com/huong-dan-cau-hinh-prometheus-tich-hop-canh-bao-qua-slack-phan-5/
    https://awesome-prometheus-alerts.grep.to/rules.html

Guide to config 

    https://prometheus.io/docs/alerting/latest/configuration/
    https://access.redhat.com/solutions/4373331
    Add option:
    --storage.tsdb.path /var/lib/prometheus/
