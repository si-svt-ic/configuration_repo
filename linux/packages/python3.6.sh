########################## install python3.6 and other packages : pandas, psycopg2, scikit-learn, scipy on REDHAT 7.5 ##############################

# --proxy http://10.3.60.168:3128
# install epel repository and then install pip
# https://www.tecmint.com/install-pip-in-linux/

yum install epel-release 
yum install python-pip

# download python3.6 and scp to VM
# intall python-3.6 from that package
# https://tecadmin.net/install-python-3-6-on-centos/

tar xzf Python-3.6.9.tgz
cd Python-3.6.9
./configure --enable-optimizations
make altinstall
python3.6 -V


yum install scipy

/usr/local/bin/python-3.6 -m  pip --proxy http://10.3.60.168:3128 install pandas
/usr/local/bin/python3.6 -m pip --proxy http://10.3.60.168:3128 install psycopg2

/usr/local/bin/python3.6 -m pip --proxy http://10.3.60.168:3128 install --upgrade pip

/usr/local/bin/python3.6 -m pip --proxy http://10.3.60.168:3128 install psycopg2-binary

[root@rt-etl1 ~]# /usr/local/bin/python3.6 -m pip list
Package         Version
--------------- -------
joblib          0.14.0 
numpy           1.17.4 
pandas          0.25.3 
pip             19.3.1 
psycopg2-binary 2.8.4  
python-dateutil 2.8.1  
pytz            2019.3 
scikit-learn    0.21.3 
scipy           1.3.3  
setuptools      40.6.2 
six             1.13.0 






