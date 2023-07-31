DO280

Table of contents prelude
1、Create OpenShift users
2、Configure persistent storage for the local registry
3、Create OpenShift Enterprise projects
4、Create an application from a Git repository
5、Create an application using Docker images and definition files
6、Create an application with a secure edgeterminated route
7、Configure OpenShift quotas for a project
8、Create an application from a third party template
9、Scale an application
10、Install OpenShift metrics

## prelude
 	#Installation command completion
 	yum -y install bash-completion
 	source /etc/profile.d/bash_completion.sh
 	 
 	#Build a cluster (not tested)
 	[root@foundation0 ~]# echo y | rht-vmctl reset all
 	[root@foundation0 ~]# ssh student@workstation
 	[student@workstation ~]$ lab install-prepare setup
 	[student@workstation ~]$ cd /home/student/do280-ansible
 	[student@workstation do280-ansible]$ ./install.sh
 	 
 	#Deploy successfully execute the following script
 	[student@workstation do280-ansible]$ lab install-metrics setup
 	[root@foundation0 ~]# scp -r files/ root@master:~
 	 
 	#examination notes
 	Relevant node passwords are given in the exam instructions;
 	OpenShift has been deployed in the test environment, it is recommended to check
 	1. Openshift has been installed on each node.
 	2. During the exam, most of the operations are completed on the master, the storage space of the master node is limited, and the push image is completed on the node
 	3. The physical machine directly accesses the route in the ocp as a node outside the cluster, and the workstation in the practice environment can directly access the route in the ocp (the same method is used to check the document)
 	4. There is no workstation virtual machine during the exam
 	5. All exercises are basically completed in the master node
 	6. No need to manage firewalls
 	7. The deployed website in the practice environment must be verified on the browser in the workstation node (directly verify on the host machine during the exam)

## 1、Create OpenShift users
 	#original title
 	Create additional OpenShift users with the following characteristics:
 	Create additional OpenShift users with the following characteristics:
 	1、The regular user joe with password redhat;
 	2、The regular user lene with password redhat;
 	3、You must use the existing authentication file at /etc/origin/master/htpasswd while preserving its original content;
 	The existing authentication file of /etc/origin/master/htpasswd must be used while retaining its original content;
 	4、Both users must be able to authenticate to the OpenShift instance via CLI and on the web console at https://master.lab.example.com:443;
 	Both users must be able to authenticate to the OpenShift instance through the CLI and the web console https://master.lab.example.com:443;
 	5、Regular users must NOT be able to create projects themselves
 	Ordinary users cannot create projects by themselves
 	 
 	[root@foundation0 ~]# ssh root@master
 	[root@master ~]# rpm -qa httpd-tools
 	[root@master ~]# yum -y install httpd-tools
 	[root@master ~]# oc get nodes
 	[root@master ~]# oc get pods
 	[root@master ~]# oc whoami
 	system:admin
 	===============================================================
 	hint:
 	The system root user of the master node is the cluster administrator by default
 	Authorize cluster management permissions to ordinary users
 	[root@master ~]# oc adm policy add-cluster-role-to-user [ system:admin | cluster-admin ] admin
 	===============================================================
 	#Determine the storage location of the password file as required
 	[root@master ~]# grep -A3 prov /etc/origin/master/master-config.yaml
 	#Confirm user and password configuration file
 	[root@master ~]# cat /etc/origin/master/htpasswd
 	#create user
 	[root@master ~]# htpasswd -b /etc/origin/master/htpasswd joe redhat
 	[root@master ~]# htpasswd -b /etc/origin/master/htpasswd lene redhat
 	 
 	#Remove the role of the cluster for the group (all users are not allowed to create projects)
 	Note: There are examples in the 6.2.2 Disabling Self-provisioning section of the help documentation
 	[root@master ~]# oc adm policy remove-cluster-role-from-group \
 	self-provisions \
 	system:authenticated \
 	system:authenticated:oauth
 	# verify
 	[root@master ~]# oc login -u joe -p redhat
 	[root@master ~]# oc login -u lene -p redhat
 	Note: It is correct if it prompts that you can log in successfully but cannot create a project

## 2、Configure persistent storage for the local registry
 	#original title
 	Configure nfs persistent storage on services.lab.example.com,that does thefollowing:
 	1、Create and share /OCP_mysql;
 	2、Create and share /OCP_wordpress;
 	3、Create and share /OCP_registry;
 	4、Create and share /OCP_metrics;
 	5、Associate the share named /OCP_registry to the builtin registry running within your OpenShift Enterprise instance so that it will be used for permanent storage
 	Associate the share/OCP_registry to the registry of the OpenShift Enterprise instance
 	6、Use train-registry-volume for the volume name and train-registry-claim for the claim name
 	Use train-registry-volume as volume name and train-registry-claim as claim name
 	7、You can find sample YAML files on http://classroom.example.com/materials/exam/storage/
 	Example YAML files can be found at http://classroom.example.com/materials/exam/storage/
 	(Note: This task needs to be solved before any applications are created)
 	8. All shares can be shared by users in the 172.25.250.0/255.255.255.0 network segment (check the hosts file to define the specific network segment during the test)
 	 
 	 
 	#solve problems
 	First create nfs, then create pv, pv will be associated with nfs, then create pvc, pvc will be automatically bound to pv. Then associate the pod with pvc, so that the content of the pod is written to the nfs path
 	nfs--pv
 	|
 	pvc <-- pod
 	 
 	[root@foundation0 ~]# ssh root@services
 	[root@services ~]# mkdir /OCP_{mysql,wordpress,registry,metrics}
 	[root@services ~]# chown nfsnobody.nfsnobody /OCP_*
 	[root@services ~]# chmod 700 /OCP_*
 	 
 	 
 	[root@services ~]# man exports View setting examples
 	[root@services ~]# vim /etc/exports
 	/OCP_metrics 172.25.250.0/24(rw,async,all_squash)
 	/OCP_mysql 172.25.250.0/24(rw,async,all_squash)
 	/OCP_registry 172.25.250.0/24(rw,async,all_squash)
 	/OCP_wordpress 172.25.250.0/24(rw,async,all_squash)
 	 
 	[root@services ~]# exportfs -r
 	[root@services ~]# showmount -e | grep OCP
 	 
 	 
 	#Associate the share to the instance mirror warehouse (need to switch to the master node)
 	[root@master ~]# oc login -u system:admin
 	[root@master ~]# oc project default
 	[root@master ~]# cd files/2/
 	Note: The corresponding files will be provided during the exam, just wget the files
 	#Create pv and pvc
 	[root@master 2]# vim sample-pv.yml
 	apiVersion: v1
 	kind: PersistentVolume
 	metadata:
 	name: train-registry-volume # volume name
 	spec:
 	capacity:
 	storage: 5Gi
 	accessModes:
 	- ReadWriteMany # access mode
 	nfs:
 	path: /OCP_registry # shared directory
 	server: services.lab.example.com # Where is the shared server
 	persistentVolumeReclaimPolicy: Recycle
 	 
 	[root@master 2]# vim sample-pvc.yml
 	apiVersion: v1
 	kind: PersistentVolumeClaim
 	metadata:
 	name: train-registry-claim # pvc name
 	spec:
 	accessModes:
 	- ReadWriteMany # access mode
 	resources:
 	requests:
 	storage: 5Gi # The size of the requested resource
 	 
 	#Creating pv can only be an administrator user
 	[root@master 2]# oc whoami
 	system:admin
 	[root@master 2]# oc create -f sample-pv.yml -n default
 	#Because this pvc also belongs to the cluster, it is also managed by the cluster administrator
 	[root@master 2]# oc create -f sample-pvc.yml -n default
 	[root@master 2]# oc get pods
 	[root@master 2]# oc get pv
 	[root@master 2]# oc get pvc
 	Note: The success of the association does not mean that it can be written to the shared storage, because if the nfs is wrongly configured, it will lead to failure to write in and the container to fail to start, etc.
 	 
 	#Associate pod with pvc
 	[root@master 2]# oc get dc
 	NAME REVISION DESIRED CURRENT TRIGGERED BY
 	docker-registry 1 2 2 config
 	 
 	[root@master 2]# oc describe dc/docker-registry | grep -A8 Vol
 	Volumes:
 	registry-storage: # Set this Volumes, the --name in the next command is the name used
 	Type: PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
 	ClaimName: registry-claim
 	ReadOnly: false
 	 
 	[root@master 2]# oc set volume dc/docker-registry --add --overwrite --name=registry-storage -t pvc --claim-name=train-registry-claim
 	# Verify again
 	[root@master 2]# oc describe dc/docker-registry | grep -A8 Vol
 	[root@master 2]# oc get pods

## 3、Create OpenShift Enterprise projects
Create an OpenShift enterprise project

 	#original title
 	On your OpenShift Enterprise instance create the following projects:
 	1、raleigh
 	2、lobster
 	3、farm
 	4、ditto
 	5、samples
 	 
 	Additionally, configure the projects as follows:
 	1、For all of the projects, set the description to 'This is a DO280 project';
 	2、Make joe the admin of project raleigh and ditto;
 	3、The user lene must be able to view the project raleigh but not administer or delete it;
 	4、Make lene the admin of projects farm,lobster and samples。
 	 
 	 
 	#solve problems
 	[root@master 2]# oc whoami
 	system:admin
 	[root@master 2]# for i in raleigh lobster farm ditto samples;do oc new-project $i --description="This is a DO280 project";done
 	[root@master 2]# for i in raleigh lobster farm ditto samples;do oc get project $i|grep -v ^NAME;done
 	# # joe user is the administrator of the following 2 projects
 	[root@master 2]# oc adm policy add-role-to-user admin joe -n raleigh
 	[root@master 2]# oc adm policy add-role-to-user admin joe -n ditto
 	# # lene users can only view raleigh projects
 	[root@master 2]# oc adm policy add-role-to-user view lene -n raleigh
 	# # The lene user is an administrator for the following projects
 	[root@master 2]# oc adm policy add-role-to-user admin lene -n farm
 	[root@master 2]# oc adm policy add-role-to-user admin lene -n lobster
 	[root@master 2]# oc adm policy add-role-to-user admin lene -n samples
 	 
 	Delete format: oc adm policy remove-role-from-user <role> <username> -n <item>
 	Example of removal: oc adm policy remove-role-from-user admin lene -n ​​farm
 	 
 	[root@master 2]# oc get rolebinding -n {farm | lobster...}

## 4、Create an application from a Git repository
Create an application from a Git repository

 	Use the S2I functionality of your OpenShift instance to build an application in the raleigh project
 	Build applications in the raleigh project using the S2I capabilities of an OpenShift instance
 	Use the Git repository at http://services.lab.example.com/php-helloworld for theapplication source
 	Use the Git repository at http://services.lab.example.com/php-helloworld as the application source
 	1、Use the Docker image labeled openshift/php:5.6;
 	Use the Docker image tagged openshift/php:5.6;
 	2、Once deployed, the application must be reachable(and browsable)at the following address: http://helloworld.raleigh.apps.lab.example.com;
 	Once deployed, the application must be accessible at http://…
 	3、Update the original repository so that the index.php file contains the text "This is a DO280 exam" instead of the word 'Hello, World! php version is';
 	Update the content of the index.php file in the original repository so that its content becomes "This is a DO280 test" to replace the original text
 	4、Trigger a rebuild so that when browsing http://helloworld.raleigh.apps.lab.example.com it will display the new text
 	Trigger a rebuild so that the new text appears when browsing http://helloworld.raleigh.apps.lab.example.com
 	 
 	 
 	#Check if the local warehouse has the image
 	[root@services ~]# docker-registry-cli services.lab.example.com [list all] | <[search IMAGE_NAME]> ssl
 	#View public is (openshift project is public)
 	[root@master ~]# oc get is -n openshift | grep php
 	 
 	#Start creating the application
 	Because the joe user is the administrator of the raleigh project, to switch users, you need to operate on the master node
 	[root@master 2]# oc login -u joe
 	[root@master 2]# oc project raleigh
 	[root@master 2]# oc new-app openshift/php:5.6~http://services.lab.example.com/php-helloworld --name=hello # php:5.6 is the is address
 	[root@master 2]# oc get build
 	[root@master 2]# oc logs -f bc/hello
 	Note: If there is an error in push here, it means that the permanent volume configuration of the second question registry is wrong, reset the environment and redo
 	 
 	# is verification of raleigh project after push
 	[root@master 2]# oc get is -n raleigh | grep hello
 	hello docker-registry.default.svc:5000/raleigh/hello latest 20 minutes ago
 	 
 	#Verify the storage result after push
 	[root@services ~]# ll /OCP_registry/docker/registry/v2/repositories/raleigh
 	 
 	# create route
 	[root@master 2]# oc get svc
 	NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
 	hello ClusterIP 172.30.196.16 <none> 8080/TCP,8443/TCP 26m
 	 
 	[root@master 2]# oc expose svc hello --hostname=helloworld.raleigh.apps.lab.example.com
 	Note: helloworld.raleigh.apps.lab.example.com is given in the title
 	[root@master 2]# oc get route
 	NAME HOST/PORT PATH SERVICES PORT TERMINATION WILDCARD
 	hello helloworld.raleigh.apps.lab.example.com hello 8080-tcp None
 	[root@master 2]# curl helloworld.raleigh.apps.lab.example.com
 	Hello, World! php version is 5.6.25
 	 
 	#update source code
 	[root@master 2]# cd
 	[root@master ~]# git clone http://services.lab.example.com/php-helloworld
 	[root@master ~]# cd php-helloworld/
 	[root@master php-helloworld]# vim index.php
 	<?php
 	print "This is a DO280 test\n";
 	?>
 	 
 	[root@master php-helloworld]# git add .
 	[root@master php-helloworld]# git commit -m "xxx"
 	[root@master php-helloworld]# git push
 	 
 	#Manually trigger rebuild
 	[root@master php-helloworld]# oc start-build hello
 	[root@master php-helloworld]# oc logs -f bc/hello
 	[root@master php-helloworld]# curl helloworld.raleigh.apps.lab.example.com
 	This is a DO280 test
 	[root@master php-helloworld]# cd

## 5、Create an application using Docker images and definition files
Create an application using a Docker image and definition file

 	Using the example files from the wordpress directory under http://classroom.example.com/materials/exam/wordpress
 	Use the example files in the wordpress directory under http://classroom.example.com/materials/exam/wordpress
 	1、create a WordPress application in the farm project;
 	Create a WordPress application in the farm project;
 	2、For permanent storage use the the NFS shares /OCP_wordpress and /OCP_mysql from services.lab.example.com
 	For permanent storage, use the NFS shares /OCP_wordpress and /OCP_mysql from services.lab.example.com
 	Use the files from http://classroom.example.com/materials/exam/wordpress for the volumes.
 	Use the file from http://classroom.example.com/materials/exam/wordpress as volume
 	3、For the WordPress pod,use the Docker image from http://classroom.example.com/materials/exam/wordpress/wordpress.tar;
 	For the WordPress pod, use the Docker image from http://classroom.example.com/materials/exam/wordpress/wordpress.tar;
 	(Note: It is normal if the WordPress pod initially restarts a couple of times due to permission issues)
 	(Note: It is normal if the WordPress pod restarts a few times initially, due to permissions issues)
 	4、For the MySQL pod use the Docker image openshift3/mysql-55-rhel7;
 	For the MySQL pod, use the Docker image openshift3/mysql-55-rhel7;
 	5、Once deployed, the application must be reachable at the following address: http://shining.farm.apps.lab.example.com;
 	After deployment, the application must be accessible at: http://shining.farm.apps.lab.example.com;
 	6、Finally, complete the WordPress installation by setting lene as the admin user with password redhat and lene@master.lab.example.com for the email address;
 	Finally complete the WordPress installation, set lene as the admin user, the password is redhat, and the email is lene@master.lab.example.com;
 	7、Set the blog name to do280 blog;
 	Set the blog name as do280 blog;
 	8、Create your first post with title "My first post"。The text in the post does not matter
 	Create your first post titled "My first post", the text in the post doesn't matter
 	 
 	 
 	The administrator of the farm project is the lene user, so use the lene user and switch to the farm
 	[root@master ~]# oc login -u lene -p redhat
 	[root@master ~]# oc project farm
 	[root@master ~]# cd files/5
 	 
 	First create 2 pv--> 2 pvc--->load WP image-->create MySQL pod-->MySQL service-->create WP pod-->WP service-->point to WP service -->|
 	When creating, it needs to be a pv and a pvc, and a pv and a pvc are created. If the pv is created first and then the pvc is created in a unified way, it may not match (chaos)
 	 
 	[root@master 5]# mv pv-1.yaml pv-wp.yaml
 	[root@master 5]# mv pv-2.yaml pv-mysql.yaml
 	===================================================
 	[root@master 5]# vim pv-mysql.yaml
 	apiVersion: v1
 	kind: PersistentVolume
 	metadata:
 	name: pv-mysql # The name can be customized
 	spec:
 	capacity:
 	storage: 3Gi # size 3G is enough
 	accessModes:
 	- ReadWriteMany # The access mode is written as ReadWriteMany
 	persistentVolumeReclaimPolicy: Recycle
 	nfs:
 	server: services.lab.example.com
 	path: /OCP_mysql
 	 
 	 
 	[root@master 5]# vim pvc-mysql.yaml
 	kind: PersistentVolumeClaim
 	apiVersion: v1
 	metadata:
 	name: claim-mysql
 	spec:
 	accessModes:
 	- ReadWriteMany # The access mode is written as ReadWriteMany
 	resources:
 	requests:
 	storage: 3Gi
 	===================================================
 	 
 	[root@master 5]# vim pv-wp.yaml
 	apiVersion: v1
 	kind: PersistentVolume
 	metadata:
 	name: pv-wordpress # The name can be customized
 	spec:
 	capacity:
 	storage: 1Gi
 	accessModes:
 	- ReadWriteMany # The access mode is written as ReadWriteMany
 	persistentVolumeReclaimPolicy: Recycle
 	nfs:
 	server: services.lab.example.com
 	path: /OCP_wordpress
 	 
 	[root@master 5]# vim pvc-wp.yaml
 	kind: PersistentVolumeClaim
 	apiVersion: v1
 	metadata:
 	name: claim-wp
 	spec:
 	accessModes:
 	- ReadWriteMany # The access mode is written as ReadWriteMany
 	resources:
 	requests:
 	storage: 1Gi
 	 
 	 
 	#Create 2 pvcs
 	[root@master 5]# oc create -f pvc-mysql.yaml
 	[root@master 5]# oc create -f pvc-wp.yaml
 	 
 	#Create 2 pvs (cut to the cluster administrator user)
 	[root@master 5]# oc login -u system:admin
 	[root@master 5]# oc project farm
 	[root@master 5]# oc create -f pv-mysql.yaml
 	[root@master 5]# oc create -f pv-wp.yaml
 	# check
 	[root@master 5]# oc get pvc
 	 
 	#Import the image and push it to the internal mirror warehouse
 	[root@master 5]# docker load -i wordpress.tar
 	[root@master 5]# docker tag docker.io/wordpress:latest registry.lab.example.com/wordpress:latest
 	[root@master 5]# docker push registry.lab.example.com/wordpress:latest # The address of the registry in the hosts file can be viewed for the first time
 	[root@master 5]# docker rmi -f 4ad4
 	 
 	#Build the pod of the MySQL database
 	[root@master 5]# vim pod-mysql.yaml
 	apiVersion: v1
 	kind: Pod
 	metadata:
 	name: mysql
 	labels:
 	name: mysql # This labels will be used below
 	spec:
 	containers:
 	- resources:
 	limits :
 	cpu: 0.5
 	image: openshift3/mysql-55-rhel7 # Modify to the provided image
 	....
 	....
 	volumes:
 	- name: mysql-persistent-storage
 	persistentVolumeClaim:
 	claimName: claim-mysql # Already correct, if not correct, modify it according to the name of oc get pvc (MySQL's pvc name)
 	 
 	[root@master 5]# oc create -f pod-mysql.yaml
 	[root@master 5]# oc get pods
 	 
 	 
 	#Create a service corresponding to MySQL
 	[root@master 5]# vim service-mysql.yaml
 	....
 	....
 	selector:
 	name: mysql # Need to match the above labels (pod name)
 	 
 	[root@master 5]# oc create -f service-mysql.yaml
 	[root@master 5]# oc get svc
 	 
 	#Create a WordPress pod
 	[root@master 5]# vim pod-wordpress.yaml
 	apiVersion: v1
 	kind: Pod
 	metadata:
 	name: wordpress
 	labels:
 	name: wordpress
 	spec:
 	containers:
 	- image: wordpress # The default is to find the image in the internal image warehouse. The image is imported with docker load and then pushed to the internal warehouse, so there is no need to modify it here
 	....
 	....
 	- name: WORDPRESS_DB_HOST
 	# this is the name of the mysql service fronting the mysql pod in the same namespace
 	# expands to mysql.<namespace>.svc.cluster.local - where <namespace> is the current namespace
 	value: mysql.farm.svc.cluster.local # explained above
 	 
 	# create scc
 	[root@master 5]# oc login -u system:admin # very important step
 	[root@master 5]# oc adm policy add-scc-to-user anyuid -z default -n farm # very important step
 	Interpretation:
 	Give the default user in the farm project, no matter what the name of the default user is, it is the serviceaccount of the execution program
 	In other words, sometimes you have to name a serviceaccount yourself. For example, if you are not the root user when executing the program, I will give it a name.
 	For example called xiaoming, I can use oc adm policy add-scc-to-user anyuid -z xiaoming -n farm
 	But now I don't want to know what name he gave in this program, and I don't want to look it up. No matter what name you use, I will use default instead.
 	 
 	 
 	[root@master 5]# oc login -u lene
 	[root@master 5]# oc create -f pod-wordpress.yaml
 	[root@master 5]# oc get pods
 	NAME READY STATUS RESTARTS AGE
 	mysql 1/1 Running 0 19m
 	wordpress 1/1 Running 2 3m
 	 
 	 
 	#Create a service for wp
 	[root@master 5]# vim service-wp.yaml # No need to modify, just default
 	[root@master 5]# oc create -f service-wp.yaml
 	[root@master 5]# oc get svc
 	NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
 	mysql ClusterIP 172.30.139.14 <none> 3306/TCP 12m
 	wpfrontend LoadBalancer 172.30.140.86 172.29.227.62,172.29.227.62 80:32247/TCP 2s
 	 
 	#Create a route for wp's service
 	[root@master 5]# oc expose svc wpfrontend --hostname=shining.farm.apps.lab.example.com
 	Note: wpfrontend is the name of svc, --hostname is given in the title
 	[root@master 5]# oc get route
 	NAME HOST/PORT PATH SERVICES PORT TERMINATION WILDCARD
 	wpfrontend shining.farm.apps.lab.example.com wpfrontend 80 None
 	 
 	Go to workstations to operate graphically....
## 6、Create an application with a secure edgeterminated route
Create an application with secure edge-terminate routing

 	Create an application greeter in the project samples, which uses the Docker image
 	registry.lab.example.com/openshift/hello-openshift so that it is reachable at the following address only: https://greeter.samples.apps.lab.example.com
 	(Note you can use the script http://classroom.example.com/materials/exam/cert/gencert.sh to generate the necessary certificate files)
 	#translation _
 	Create an application greeter in the samples project, which uses the registry.lab.example.com/openshift/hello-openshift image, and the application can be accessed through: https://greeter.samples.apps.lab.example.com
 	(Note, use /files/6/gencert.sh to create the necessary certificate files)
 	The lene user is the administrator of the samples project
 	[root@master 5]# cd ../6/
 	[root@master 6]# oc login -u lene
 	[root@master 6]# oc project samples
 	[root@master 6]# oc new-app --docker-image=registry.lab.example.com/openshift/hello-openshift --name=greeter
 	[root@master 6]# oc get pods
 	[root@master 6]# oc get svc
 	# # create certificate
 	[root@master 6]# bash gencert.sh greeter
 	# # create route
 	[root@master 6]# oc create route edge --help
 	[root@master 6]# oc create route edge \
 	--cert=greeter.crt \
 	--key=greeter.key \
 	--service=greeter \
 	--hostname=greeter.samples.apps.lab.example.com
 	 
 	[root@master 6]# oc get route
 	NAME HOST/PORT PATH SERVICES PORT TERMINATION WILDCARD
 	greeter greeter.samples.apps.lab.example.com greeter 8080-tcp edge None
 	 
 	[root@master 6]# cd
 	 
 	Note: Access the address in the HOST/PORT column on workstation, https://greeter.samples.apps.lab.example.com
 	Then click Advanced---Add Exception---Confirm Security Exception---see the final result is Hello OpenShift!


## 7、Configure OpenShift quotas for a project
Configure quotas for a project of openshift

 	Configure quotas and limits for project lobster so that:
 	Configure quotas and limits for the lobster project:
 	The ResourceQuota resource is named do280-quota
 	ResourceQuota resource named do280-quota
 	 
 	1、The amount of memory consumed across all containers may not exceed 1Gi;
 	All container memory consumption cannot exceed 1Gi
 	2、The total amount of CPU usage consumed across all containers may not exceed 2 Kubernetes compute units;
 	The total CPU usage consumed by all containers must not exceed 2 Kubernetes compute units;
 	3、The maximum number of replication controllers does not exceed 3 The maximum number of pods does not exceed 3;
 	The number of ReplicationControllers and Pods cannot exceed 3;
 	4、The maximum number of services does not exceed 6
 	Services cannot exceed 6
 	 
 	The LimitRange resource is named do280-limits
 	LimitRange resource name: do280-limits
 	1、The amount of memory consumed by a single pod is between 5Mi and 300Mi;
 	The memory usage of a single pod is between 5Mi-300Mi
 	2、The amount of memory consumed by a single container is between 5Mi and 300Mi with a default request value of 100Mi;
 	The amount of memory consumed by a single container is between 5Mi-300Mi, and the default request value is 100Mi;
 	3、The amount of cpu consumed by a single pod is between 10m and 500m;
 	The amount of cpu consumed by a single pod is between 10m and 500m;
 	4、The amount of cpu consumed by a single container is between 10m and 500m with a default request value of 100m
 	The amount of cpu consumed by a single container is between 10m-500m, and the default request value is 100m
 	 
 	 
 	Note: A cluster administrator is required to configure quota, and the project administrator has no permission to do so
 	[root@master 6]# cd
 	[root@master ~]# oc login -u system:admin
 	[root@master ~]# oc project lobster
 	#Create quota for lobster project
 	[root@master ~]# vim do280-quota.yaml
 	apiVersion: v1
 	kind: ResourceQuota
 	metadata:
 	  name: do280-quota # ResourceQuota resource name
 	spec:
    hard:
      services: "6" # Services cannot exceed 6
      pods: "3" # Pods cannot exceed 3
      limits.cpu: "2" # CPU usage up to 2Kubernetes units
      limits.memory: 1Gi # The memory consumption of all containers cannot exceed 1Gi
      replicationcontrollers: "3" # The maximum number of RCs cannot exceed 3
    
 	[root@master ~]# oc create -f do280-quota.yaml
 	[root@master ~]# oc describe quota -n lobster
 	 
 	 
 	#Create limits for the lobster project
 	[root@master ~]# vim do280-limits.yaml
 	kind: "LimitRange"
 	metadata:
 	  name: "do280-limits"
 	spec:
    limits:
      - type: "Pod"
        max:
          cpu: "500m"
          memory: "300Mi"
        min:
          cpu: "10m"
          memory: "5Mi"
      - type: "Container"
        max:
          cpu: "500m"
          memory: "300Mi"
        min:
          cpu: "10m"
          memory: "5Mi"
    defaultRequest:
      cpu: "100m"
      memory: "100Mi"
 	 
 	[root@master ~]# oc create -f do280-limits.yaml
 	[root@master ~]# oc describe limitrange
  
## 8、Create an application from a third party template
Create applications from third-party templates

 	On master.lab.example.com using the template file in http://classroom.example.com/materials/exam/gogs as a basis, install an application in the ditto project according to the following requirements:
 	Use the template file (gogs-template.yaml) in http://classroom.example.com/materials/exam/gogs on master.lab.example.com to install an application in the ditto project, based on the following requirements:
 	⚫ All of the registry entries must point to your local registry at registry.lab.example.com。The version in the ImageStream line for the postgresql image must be changed from postgresql:9.2 to postgresql:9.5;
 	All registries must point to your local registry at registry.lab.example.com, the postgresql image version in ImageStream must be changed from postgresql:9.2 to postgresql:9.5
 	⚫ for the Gogs pod,use the Docker image from http://classroom.example.com/materials/exam/gogs/gogs.tar and make sure it is tagged as registry.lab.example.com/openshiftdemos/gogs:0.9.97 and pushed to your local registry vm;
 	The image of the gogs pod comes from the Docker image of http://classroom.example.com/materials/exam/gogs.tar, and make sure its tag is changed to registry.lab.example.com/openshiftdemos/gogs:0.9.97, and pushed to the registry
 	⚫ Make the template gogs available across all projects and for all users;
 	Make template gogs available to all projects and all users (just import into openshift project)
 	⚫ Deploy the application using the template, setting the parameter HOSTNAME to gogs.ditto.apps.lab.example.com;
 	Use the template to deploy the application, set the parameter HOSTNAME to gogs.ditto.apps.lab.example.com;
 	⚫ Create a user joe with password redhat and email address joe@master.lab.example.com on the application frontend (use the Register link on the top right of the page at http://gogs.ditto.apps.lab.example.com) and, as this user, create a Git repository named do280;
 	Create user joe on the application frontend with password redhat and email address joe@master.lab.example.com, (use the registration link http://gogs.ditto.apps.lab.example.com in the upper right corner of the page) and start with Create a Git repository named do280 as this user;
 	⚫ If there isn't one already, create a file named README.md in the repository do280 and put the line "do280 is fun" in it and commit it;
 	If you haven't already, create a file called README.md in the repository do280 and put the line "do280 is fun" in it and commit;
 	⚫The repository must be visible and accessible
 	The repository must be visible and accessible
 	 
 	 
 	#Authorize SCC
 	[root@master ~]# oc login -u system:admin
 	[root@master ~]# oc adm policy add-scc-to-user anyuid -z default -n ditto
 	#import image
 	[root@master ~]# docker load -i ~/files/8/gogs.tar
 	[root@master ~]# docker images
 	[root@master ~]# docker tag docker.io/openshiftdemos/gogs:latest registry.lab.example.com/openshiftdemos/gogs:0.9.97
 	[root@master ~]# docker push registry.lab.example.com/openshiftdemos/gogs:0.9.97
 	[root@master ~]# docker rmi -f 3ca
 	 
 	#Check if it has been uploaded to the internal mirror warehouse
 	[root@services ~]# ll /var/lib/registry/docker/registry/v2/repositories/openshiftdemos
 	 
 	#Verify in local warehouse
 	[student@workstation ~]$ docker-registry-cli registry.lab.example.com search gogs ssl
 	[student@workstation ~]$ docker-registry-cli registry.lab.example.com search postgresql ssl
 	 
 	#Check if there is in is, if yes, you can directly use the image name in the following template file, if not, you need to write the complete address
 	[root@master ~]# oc get is -n openshift| grep gogs
 	[root@master ~]# oc get is -n openshift| grep pos
 	postgresql docker-registry.default.svc:5000/openshift/postgresql 9.5,9.2,9.4 + 1 more... 2 weeks ago
 	 
 	 
 	#Modify the template according to the title (use system:admin user)
 	[root@master ~]# oc project ditto
 	[root@master ~]# vim files/8/gogs-template.yaml
 	....
 	....
 	- kind: DeploymentConfig
 	apiVersion: v1
 	metadata:
 	annotations:
 	description: Defines how to deploy the database
 	name: ${APPLICATION_NAME}-postgresql
 	....
 	image: 'rhscl/postgresql-95-rhel7' # searched by docker-registry-cli on workstation
 	....
 	triggers:
 	- imageChangeParams:
 	automatic: true
 	containerNames:
 	- postgresql
 	from:
 	kind: ImageStreamTag
 	name: postgresql:9.5 # Here is 9.2 in the exam, it needs to be changed to 9.5, don't use it in practice
 	....
 	....
 	- kind: DeploymentConfig
 	apiVersion: v1
 	metadata:
 	labels:
 	app: ${APPLICATION_NAME}
 	....
 	spec:
 	serviceAccountName: ${APPLICATION_NAME}
 	containers:
 	- image: "registry.lab.example.com/openshiftdemos/gogs:0.9.97" # Change the mirror address, because there is no is, so write the complete address
 	....
 	....
 	- kind: ImageStream
 	apiVersion: v1
 	metadata:
 	labels:
 	app: ${APPLICATION_NAME}
 	name: ${APPLICATION_NAME}
 	spec:
 	tags:
 	- name: "${GOGS_VERSION}"
 	from:
 	kind: DockerImage
 	# Change the built-in docker.io to registry.lab.example.com
 	name: registry.lab.example.com/openshiftdemos/gogs:${GOGS_VERSION}
 	....
 	....
 	parameters:
 	name: HOSTNAME
 	required: true
 	value: gogs.ditto.apps.lab.example.com # is the route created later
 	 
 	 
 	#Because only cluster administrators can upload templates to the openshift project, you need to use the system:admin user to log in to the cluster (all templates in the openshift project can be used by all users)
 	#create template
 	[root@master ~]# oc login -u system:admin
 	[root@master ~]# oc create -f files/8/gogs-template.yaml -n openshift
 	[root@master ~]# oc get template -n openshift | grep gogs
 	 
 	[root@master ~]# oc login -u joe -p redhat
 	[root@master ~]# oc project ditto
 	[root@master ~]# oc process openshift//gogs | oc create -f - # Ordinary users cannot process templates in openshift, they must add // to
 	[root@master ~]# oc get pods
 	[root@master ~]# oc get route
 	NAME HOST/PORT PATH SERVICES PORT TERMINATION WILDCARD
 	gogs gogs.ditto.apps.lab.example.com gogs <all> None
 	 
 	Visit the web page on workstation, or add hosts mapping to visit on foundation0. http://gogs.ditto.apps.lab.example.com/
    Register
    Create a Repository


    [root@master ~]# mkdir test && cd test
 	[root@master test]# echo "do280 is fun" >> README.md
 	[root@master test]# git init
 	[root@master test]# git add README.md
 	[root@master test]# git commit -m "do280 is fun"
 	[root@master test]# git remote add origin http://gogs.ditto.apps.lab.example.com/joe/do280.git
 	[root@master test]# git push -u origin master
 	Username for 'http://gogs.ditto.apps.lab.example.com': Username is joe
 	Password for 'http://joe@gogs.ditto.apps.lab.example.com': password is redhat


## 9、Scale an application
 	Scale the application greeter in the project samples to a total of 5 replicas
 	 
 	 
 	[root@master test]# oc login -u lene # If you want to enter the password, it is redhat
 	[root@master test]# oc project samples
 	[root@master test]# oc get dc
 	NAME REVISION DESIRED CURRENT TRIGGERED BY
 	greeter 1 1 1 config,image(greeter:latest)
 	 
 	[root@master test]# oc scale --replicas=5 dc/greeter
 	[root@master test]# oc get pods

## 10、Install OpenShift metrics
 	On workstation.lab.example.com install the OpenShift Metrics component with the following requirements:
 	Install the OpenShift Metrics component on workstation.lab.example.com with the following requirements:
 	⚫ Use the storage /OCP_metrics for cassandra storage。You can use the files on http://classroom.example.com/materials/exam/metrics for the pv sample;
 	Cassandra storage uses storage/OCP_metrics, pv examples can use the files on http://classroom.example.com/materials/exam/metrics; (refer to the pv sample files in files/10)
 	⚫ Use the file /home/student/DO280/labs/installmetrics/host for the inventory。Use the playbook /usr/share/ansible/openshiftansible/playbooks/openshiftmetrics/config.yml for the installation;
 	Use the inventory file in the /home/student/DO280/labs/install-metrics/ directory.
 	The playbook is in /usr/share/ansible/openshiftansible/playbooks/openshiftmetrics/config.yml;
 	⚫ Use the following environment variables:
 	Use the following environment variables:
 	openshift_metrics_image_version=v3.9
 	openshift_metrics_heapster_requests_memory=300M
 	openshift_metrics_hawkular_requests_memory=750M
 	openshift_metrics_cassandra_requests_memory=750M
 	openshift_metrics_cassandra_storage_type=pv
 	openshift_metrics_cassandra_pvc_size=5Gi
 	openshift_metrics_cassandra_pvc_prefix=metrics
 	openshift_metrics_install_metrics=True
 	 
 	 
 	[root@master ~]# oc login -u system:admin
 	[root@master ~]# vim files/10/sample-pv.yml
 	apiVersion: v1
 	kind: PersistentVolume
 	metadata:
 	name: metrics # The name needs to be changed
 	spec:
 	capacity:
 	storage: 5Gi
 	accessModes:
 	- ReadWriteOnce # can only be Once
 	nfs:
 	path: /OCP_metrics # Share to change
 	server: services.lab.example.com # share to be changed
 	persistentVolumeReclaimPolicy: Recycle
 	 
 	[root@master test]# oc create -f files/10/sample-pv.yml
 	[root@master test]# oc get pv | grep metrics
 	 
 	# switch machines
 	[root@foundation0 ~]# ssh student@workstation
 	[student@workstation ~]# cd DO280/labs/install-metrics/
 	[student@workstation install-metrics]# vim inventory # Add the following content to the file
 	openshift_metrics_image_version=v3.9
 	openshift_metrics_heapster_requests_memory=300M
 	openshift_metrics_hawkular_requests_memory=750M
 	openshift_metrics_cassandra_requests_memory=750M
 	openshift_metrics_cassandra_storage_type=pv
 	openshift_metrics_cassandra_pvc_size=5Gi
 	openshift_metrics_cassandra_pvc_prefix=metrics
 	openshift_metrics_install_metrics=True
 	openshift_metrics_image_prefix=registry.lab.example.com/openshift3/ose- # There are examples in this file, simply modify/copy
 	 
 	 
 	[student@workstation install-metrics]# ansible-playbook -i inventory /usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml
 	 
 	 
 	#Switch to the master node
 	[root@master ~]# oc project openshift-infra
 	[root@master ~]# oc get pods
 	[root@master ~]# oc get route
 	NAME HOST/PORT PATH SERVICES PORT TERMINATION WILDCARD
 	hawkular-metrics hawkular-metrics.apps.lab.example.com hawkular-metrics <all> reencrypt None
 	 
 	 
 	Visit https://hawkular-metrics.apps.lab.example.com with a browser on workstations, and you will be successful if you see the eagle head