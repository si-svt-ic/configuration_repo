# do180

## Lab Environment

Username					RHT_OCP4_DEV_USER		uubpeq
Password					RHT_OCP4_DEV_PASSWORD	99eeb99dfff04b639639
API Endpoint				RHT_OCP4_MASTER_API		https://api.ap46.prod.nextcle.com:6443
Console Web Application		https://console-openshift-console.apps.ap46.prod.nextcle.com
Cluster Id					a1a309ab-5cfd-4531-b83a-7bbf9b2cc853

QuayIO: 
khanh_chu/admin123

chuhakhanh/Bieutinh@123

Github:
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


git clone https://github.com/chuhakhanh/DO180-apps

# podman operation
	
	podman ps -a --format "{{.ID}} {{.Image}} {{.Names}} {{.Ports}}"
	
	# run as root/user 
		# run as root
		sudo podman run --rm --name asroot -ti registry.access.redhat.com/ubi8:latest /bin/bash
		[root@f95d16108991 /]# whoami
		# root
		[root@f95d16108991 /]# id
		# uid=0(root) gid=0(root) groups=0(root)
		[root@f95d16108991 /]# sleep 1000
		[student@workstation ~]$ sudo ps -ef | grep "sleep 1000"
		# root   <<<<<     3137    3117  0 10:18 pts/0    00:00:00 /usr/bin/coreutils --coreutils-prog-shebang=sleep /usr/bin/sleep 1000
		
		# run as user
		podman run --rm --name asuser -ti registry.access.redhat.com/ubi8:latest /bin/bash
		[root@d289dccd5285 /]# whoami
		# root
		[root@d289dccd5285 /]# id
		# uid=0(root) gid=0(root) groups=0(root)
		[root@d289dccd5285 /]# sleep 2000
		[student@workstation ~]$ sudo ps -ef | grep "sleep 2000" | grep -v grep
		# student <<<<<    3345    3325  0 10:24 pts/0    00:00:00 /usr/bin/coreutils --coreutils-prog-shebang=sleep /usr/bin/sleep 2000

# mysql
	
	# start mysql
	podman run --name mysql-custom \
	> -e MYSQL_USER=redhat -e MYSQL_PASSWORD=r3dh4t \
	> -e MYSQL_ROOT_PASSWORD=r3dh4t \
	> -d registry.redhat.io/rhel8/mysql-80
	
	# use mysql> 
	podman exec -it mysql-basic /bin/bash
	mysql -u root
	mysql -uroot
	mysql> show databases;
	mysql> use items;
	mysql> CREATE TABLE Projects (id int NOT NULL,
		-> name varchar(255) DEFAULT NULL,
		-> code varchar(255) DEFAULT NULL,
		-> PRIMARY KEY (id));
	mysql> show tables;
	mysql> insert into Projects (id, name, code) values (1,'DevOps','DO180');
	mysql> select * from Projects;
    
	# cp file db.sql into container
	podman cp /home/student/DO180/labs/manage-lifecycle/db.sql mysql-basic:/
	
	# use CLI 
	podman exec mysql-basic /bin/bash -c 'mysql -uuser1 -pmypa55 items < /db.sql'
	podman exec mysql-basic /bin/bash -c 'mysql -uuser1 -pmypa55 -e "select * from items.Projects;"'
	
	podman exec -it mysqldb-port mysql -uroot items -e "SELECT * FROM Item"
	mysql -uuser1 -h 127.0.0.1 -pmypa55 -P13306 items < /home/student/DO180/labs/manage-networking/db.sql
	mysql -uuser1 -h 127.0.0.1 -pmypa55 -P13306 items -e "SELECT * FROM Item"
	
# port 

	[student@workstation ~]$ podman run -d -p 8080:80 --name httpd-basic quay.io/redhattraining/httpd-parent:2.4
	bash-4.4# echo "Hello World" > /var/www/html/index.html
	podman port -l
	# 80/tcp -> 0.0.0.0:8080
	curl http://0.0.0.0:8080
	Hello World

# volume 
	
	# set selinux	
	mkdir -pv /home/student/local/mysql	
	sudo semanage fcontext -a -t container_file_t '/home/student/local/mysql(/.*)?'
	sudo restorecon -R /home/student/local/mysql
	ls -ldZ /home/student/local/mysql
	drwxrwxr-x. 2 student student unconfined_u:object_r:container_file_t:s0 6 May 26 14:33 /home/student/local/mysql
	The user running processes in the container must be capable of writing files to the directory.
	
	# set permission
    /* The permission should be defined with the numeric user ID (UID) from the container. 
	For the MySQL service provided by Red Hat, the UID is 27. 
	The podman unshare command provides a session to execute commands within the same user namespace as the process running inside the container. */
	
	podman unshare chown 27:27 /home/student/local/mysql #  MySQL service provided by Red Hat, the UID is 27
	sudo ls -ldZ /home/student/local/mysql
	>>> 100026 100026 unconfined_u:object_r:container_file_t:s0 
	podman unshare ls -ld /home/student/local/mysql
	>>> 27 27 unconfined_u:object_r:container_file_t:s0 
	
	# run
	podman run --name persist-db \
	> -d -v /home/student/local/mysql:/var/lib/mysql/data \
	> -e MYSQL_USER=user1 -e MYSQL_PASSWORD=mypa55 \
	> -e MYSQL_DATABASE=items -e MYSQL_ROOT_PASSWORD=r00tpa55 \
	> registry.redhat.io/rhel8/mysql-80:1

# images

	/etc/containers/registries.conf 
	[registries.search]
	registries = ["registry.redhat.io", "registry.access.redhat.com", "quay.io"]
	
	curl -Ls https://myserver/v2/_catalog?n=3 | python -m json.tool
	curl -Ls https://quay.io/v2/redhattraining/httpd-parent/tags/list | python -m json.tool
	podman login -u username -p password registry.access.redhat.com
	curl -u username:password -Ls "https://sso.redhat.com/auth/realms/rhcc/protocol/redhat-docker-v2/auth?service=docker-registry"
	
	# pull to local /var/lib/containers/storage/overlay-images
	podman login registry.redhat.io
	podman search rhel
	podman pull quay.io/bitnami/nginx
	podman pull registry.redhat.io/rhel8/mysql-80:1 # tag :1
	podman images
	podman save -o mysql.tar registry.redhat.io/rhel8/mysql-80
	podman load -i mysql.tar
	
	podman diff mysql-basic # show CLI history
	podman inspect -f "{{range .Mounts}}{{println .Destination}}{{end}}" mysqldb
	
	podman tag mysql-custom devops/mysql 
	podman tag mysql-custom devops/mysql:snapshot # tag snapshot
	podman rmi devops/mysql:snapshot
	podman push quay.io/bitnami/nginx
	
	podman stop official-httpd
	podman commit -a 'Your Name' official-httpd do180-custom-httpd # container to image 
	podman images
	# REPOSITORY                            TAG      IMAGE ID       CREATED   SIZE
	# localhost/do180-custom-httpd          latest   31c3ac78e9d4   ...       ...
	# quay.io/redhattraining/httpd-parent   latest   2cc07fbb5000   ...       ...
	source /usr/local/etc/ocp4.config
	podman tag do180-custom-httpd quay.io/${RHT_OCP4_QUAY_USER}/do180-custom-httpd:v1.0
	podman images 
	# REPOSITORY                                         TAG      IMAGE ID       ...
	# localhost/do180-custom-httpd                       latest   31c3ac78e9d4   ...
	# quay.io/${RHT_OCP4_QUAY_USER}/do180-custom-httpd   v1.0     31c3ac78e9d4   ...
	# quay.io/redhattraining/httpd-parent                latest   2cc07fbb5000   ...
	podman push quay.io/${RHT_OCP4_QUAY_USER}/do180-custom-httpd:v1.0

# containerfile
	

	# FROM instruction declares that the new container image extends ubi8/ubi:8.3 container base image. Containerfiles can use any other container image as a base image, not only images from operating system distributions. Red Hat provides a set of container images that are certified and tested and highly recommends using these container images as a base.
	# LABEL is responsible for adding generic metadata to an image. A LABEL is a simple key-value pair.
	# MAINTAINER indicates the Author field of the generated container image's metadata. You can use the podman inspect command to view image metadata.
	
	# ADD instruction copies files or folders from a local or remote source and adds them to the container's file system. 
	# 	If used to copy local files, those must be in the working directory. ADD instruction unpacks local .tar files to the destination image directory.
	# COPY copies files from the working directory and adds them to the container's file system. 
	# 	It is not possible to copy a remote file using its URL with this Containerfile instruction.
	
	# USER specifies the username or the UID to use when running the container image for the RUN, CMD, and ENTRYPOINT instructions. 
	# 	It is a good practice to define a different user other than root for security reasons.
	
	# RUN executes commands in a new layer on top of the current image. The shell that is used to execute commands is /bin/sh.
	# ENTRYPOINT specifies the default command to execute when the image runs in a container. If omitted, the default ENTRYPOINT is /bin/sh -c.
	# CMD provides the default arguments for the ENTRYPOINT instruction. If the default ENTRYPOINT applies (/bin/sh -c), then CMD forms an executable command and parameters that run at container start.

	# EXPOSE indicates that the container listens on the specified network port at runtime. The EXPOSE instruction defines metadata only; it does not make ports accessible from the host. The -p option in the podman run command exposes container ports from the host.
	# ENV is responsible for defining environment variables that are available in the container. You can declare multiple ENV instructions within the Containerfile. You can use the env command inside the container to view each of the environment variables.
	
	# create file0
	FROM ubi8/ubi:8.3 
	LABEL description="This is a custom httpd container image" 
	MAINTAINER John Doe <jdoe@xyz.com> 
	RUN yum install -y httpd 
	EXPOSE 80 
	ENV LogLevel "info" 
	ADD http://someserver.com/filename.pdf /var/www/html 
	COPY ./src/ /var/www/html/ 
	USER apache 
	ENTRYPOINT ["/usr/sbin/httpd"]  # ENTRYPOINT ["command", "param1", "param2"] 
	CMD ["-D", "FOREGROUND"] 		# CMD ["param1","param2"]
	sudo podman run -it do180/rhel +%A
	
	# create File1
	vim /home/student/DO180/labs/dockerfile-create/Containerfile
	
		FROM ubi8/ubi:8.3
		MAINTAINER Your Name  <_youremail_>
		LABEL description="A custom Apache container based on UBI 8"
		RUN yum install -y httpd && \
			yum clean all
		RUN echo "Hello from Containerfile" > /var/www/html/index.html
		EXPOSE 80
		CMD ["httpd", "-D", "FOREGROUND"]
	
	cd /home/student/DO180/labs/dockerfile-create 
	podman build --layers=false -t do180/apache .
	
	# create File2
	vim /home/student/DO180/labs/dockerfile-review/Containerfile
		
		FROM ubi8/ubi:8.3
		MAINTAINER Your Name  <_youremail_>
		LABEL description="A custom Apache container based on UBI 8"
		ENV PORT 8080
		RUN yum install -y httpd && \
			yum clean all
		RUN sed -ri -e "/^Listen 80/c\Listen ${PORT}" /etc/httpd/conf/httpd.conf && \
			chown -R apache:apache /etc/httpd/logs/ && \
			chown -R apache:apache /run/httpd/
		USER apache
		EXPOSE ${PORT}
		COPY ./src/ /var/www/html/
		CMD ["httpd", "-D", "FOREGROUND"]
	
	podman build --layers=false -t do180/custom-apache .
	podman run -d --name containerfile -p 20080:8080 do180/custom-apache
	podman ps
	... IMAGE COMMAND ... PORTS NAMES
	... do180/custom... "httpd -D ..." ... 0.0.0.0:20080->8080/tcp containerfile

# ====================================================================================================================================
# PART 2

# github
	git clone https://github.com/chuhakhanh/DO180-apps
	cd DO180-apps/
	git status

# logic switch to branch_November21
	git branch branch_November21
	git checkout -b branch_November21
	git push --set-upstream origin branch_November21
	Username for `https://github.com`:  chuhakhanh 
	Password for `https://_yourgituser_@github.com`: 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

	git push -u origin branch_November21
	git push origin branch_November21

# operation 
Ccreate some files in current folders

	# edit
	git add .
	
	# save at local
	git commit -am "first commit"
	
	# save online
	git push

# openshift
	# Pods (po): Represent a collection of containers that share resources, such as IP addresses and persistent storage volumes. It is the basic unit of work for Kubernetes.
	# Services (svc): Define a single IP/port combination that provides access to a pool of pods. By default, services connect clients to pods in a round-robin fashion.
	# Replication Controllers (rc): A Kubernetes resource that defines how pods are replicated (horizontally scaled) into different nodes. Replication controllers are a basic Kubernetes service to provide high availability for pods and containers.
	# Persistent Volumes (pv): Define storage areas to be used by Kubernetes pods.
	# Persistent Volume Claims (pvc): Represent a request for storage by a pod. PVCs links a PV to a pod so its containers can make use of it, usually by mounting the storage into the container's file system.
	# ConfigMaps (cm) and Secrets: Contains a set of keys and values that can be used by other resources. ConfigMaps and Secrets are usually used to centralize configuration values used by several resources. Secrets differ from ConfigMaps maps in that Secrets' values are always encoded (not encrypted) and their access is restricted to fewer authorized users.

# pods

	apiVersion: v1
	kind: Pod
	metadata:
	  name: wildfly
	  labels:
	    name: wildfly
	spec:
	  containers:
		- resources:
			limits :
			  cpu: 0.5
		  image: do276/todojee
		  name: wildfly
		  ports:
			- containerPort: 80804
			  name: wildfly
		  env:
			- name: MYSQL_ENV_MYSQL_DATABASE
			  value: items
			- name: MYSQL_ENV_MYSQL_USER
			  value: user1
			- name: MYSQL_ENV_MYSQL_PASSWORD
			  value: mypa55

# service

	{
		"kind": "Service", 
		"apiVersion": "v1",
		"metadata": {
			"name": "quotedb" 
		},
		"spec": {
			"ports": [ 
				{
					"port": 3306,
					"targetPort": 3306
				}
			],
			"selector": {
				"name": "mysqldb" 
			}
		}
	}

# pv

	oc get pv
	NAME     CAPACITY  ACCESS MODES  RECLAIM POLICY   STATUS      CLAIM   ...
	pv0001   1Mi       RWO           Retain           Available           ...
	pv0002   10Mi      RWX           Recycle          Available           ...

	[admin@host ~]$ oc get pv pv0001 -o yaml
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	creationTimestamp: ...value omitted...
	finalizers:
	- kubernetes.io/pv-protection
	labels:
		type: local
	name: pv0001
	resourceVersion: ...value omitted...
	selfLink: /api/v1/persistentvolumes/pv0001
	uid: ...value omitted...
	spec:
	accessModes:
	- ReadWriteOnce
	capacity:
		storage: 1Mi
	hostPath:
		path: /data/pv0001
		type: ""
	persistentVolumeReclaimPolicy: Retain
	status:
	phase: Available

# pvc

	apiVersion: v1
	kind: PersistentVolumeClaim
	metadata:
	  name: myapp
	spec:
	  accessModes:
	  - ReadWriteOnce
	  resources:
		requests:
		  storage: 1Gi

	oc create -f pvc.yaml
	[admin@host ~]$ oc get pvc
	NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
	myapp     Bound    pv0001   1Gi        RWO                           6s

	kind: "Pod"
	metadata:
	  name: "myapp"
	  labels:
	    name: "myapp"
	spec:
	  containers:
		- name: "myapp"
		  image: openshift/myapp
		  ports:
			- containerPort: 80
			  name: "http-server"
		  volumeMounts:
			- mountPath: "/var/www/html"
			  name: "pvol" 
	  volumes:
	    - name: "pvol" 
	      persistentVolumeClaim:
		    claimName: "myapp"


#
	oc get pods
	oc get all

# create a project
	source /usr/local/etc/ocp4.config
	oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
	oc new-project ${RHT_OCP4_DEV_USER}-mysql-openshift
	oc new-app --template=mysql-persistent -p MYSQL_USER=user1 -p MYSQL_PASSWORD=mypa55 -p MYSQL_DATABASE=testdb -p MYSQL_ROOT_PASSWORD=r00tpa55 -p VOLUME_CAPACITY=10Gi # <<<<<<<<<<< 

	[student@workstation ~]$ oc get pods
	NAME                       READY   STATUS      RESTARTS   AGE
	mysql-1-5vfn4    1/1     Running     0          109s
	[student@workstation ~]$ oc describe pod mysql-1-5vfn4
	IP:           10.10.0.34

	[student@workstation ~]$ oc get svc
	NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
	mysql           ClusterIP   172.30.151.91   <none>        3306/TCP   10m
	
	[student@workstation ~]$ oc describe service mysql
	Type:              ClusterIP
	IP:                172.30.151.91
	Port:              3306-tcp  3306/TCP
	TargetPort:        3306/TCP
	Endpoints:         10.10.0.34:3306

	[student@workstation ~]$ oc get pvc
	NAME    STATUS   VOLUME                                     CAPACITY   ...   STORAGECLASS
	mysql   Bound    pvc-e9bf0b1f-47df-4500-afb6-77e826f76c15   10Gi       ...   standard

	[student@workstation ~]$ oc describe pvc/mysql

	[student@workstation ~]$ oc expose service mysql  # <<<<<<<<<<<
	route.route.openshift.io/mysql exposed
	[student@workstation ~]$ oc get routes
	NAME              HOST/PORT                                       ...   PORT
	mysql             mysql-${RHT_OCP4_DEV_USER}-mysql...   ...   3306-tcp

	[student@workstation ~]$ oc port-forward mysql-1-5vfn4 3306:3306 # openshift 3306 --> workstation 3306 # <<<<<<<<<<<
	Forwarding from 127.0.0.1:3306 -> 3306
	Forwarding from [::1]:3306 -> 3306

	[student@workstation ~]$ mysql -uuser1 -pmypa55 --protocol tcp -h localhost

	{
		"apiVersion": "v1",
		"kind": "Route",
		"metadata": {
			"name": "quoteapp"
		},
		"spec": {
			"host": "quoteapp.apps.example.com",
			"to": {
				"kind": "Service",
				"name": "quoteapp"
			}
		}
	}

# router

	oc new-app --image-stream php:7.3~https://github.com/${RHT_OCP4_GITHUB_USER}/DO180-apps --name php-helloworld
	oc get pods -w
	oc logs -f bc/php-helloworld # Setup Log 
	oc logs -f php-helloworld-598b4c66bc-g8l9w 
	
	[student@workstation ~]$ oc describe svc/php-helloworld
	Name:              php-helloworld
	Namespace:         ${RHT_OCP4_DEV_USER}-route
	Labels:            app=php-helloworld
					app.kubernetes.io/component=php-helloworld
					app.kubernetes.io/instance=php-helloworld
	Annotations:       openshift.io/generated-by: OpenShiftNewApp
	Selector:          deployment=php-helloworld
	Type:              ClusterIP
	IP:                172.30.228.124
	Port:              8080-tcp  8080/TCP
	TargetPort:        8080/TCP
	Endpoints:         10.10.0.35:8080
	Port:              8443-tcp  8443/TCP
	TargetPort:        8443/TCP
	Endpoints:         10.10.0.35:8443
	Session Affinity:  None
	Events:            <none>

# create router pod 
	
	[student@workstation ~]$ oc expose svc/php-helloworld
	route.route.openshift.io/php-helloworld exposed

	[student@workstation ~]$ oc describe route
	Name:             php-helloworld
	Namespace:        extrdp-route
	Created:          16 seconds ago
	Labels:           app=php-helloworld
					app.kubernetes.io/component=php-helloworld
					app.kubernetes.io/instance=php-helloworld
	Annotations:      openshift.io/host.generated=true
	Requested Host:   php-helloworld-extrdp-route.apps.na46-stage2.dev.nextcle.com
						exposed on router default (host apps.na46-stage2.dev.nextcle.com) 16 seconds ago
	Path:             <none>
	TLS Termination:  <none>
	Insecure Policy:  <none>
	Endpoint Port:    8080-tcp

	Service:    php-helloworld
	Weight:     100 (100%)
	Endpoints:  10.129.5.124:8080

# delete router pod and re-create pods

	[student@workstation ~]$ oc delete route/php-helloworld
	route.route.openshift.io "php-helloworld" deleted

	[student@workstation ~]$ oc expose svc/php-helloworld --name=${RHT_OCP4_DEV_USER}-xyz
	route.route.openshift.io/${RHT_OCP4_DEV_USER}-xyz exposed

	[student@workstation ~]$ oc describe route
	Name:             extrdp-xyz
	Namespace:        extrdp-route
	Created:          23 seconds ago
	Labels:           app=php-helloworld
					app.kubernetes.io/component=php-helloworld
					app.kubernetes.io/instance=php-helloworld
	Annotations:      openshift.io/host.generated=true
	Requested Host:   extrdp-xyz-extrdp-route.apps.na46-stage2.dev.nextcle.com
						exposed on router default (host apps.na46-stage2.dev.nextcle.com) 22 seconds ago
	Path:             <none>
	TLS Termination:  <none>
	Insecure Policy:  <none>
	Endpoint Port:    8080-tcp

	Service:	   php-helloworld
	Weight:     100 (100%)
	Endpoints:  10.129.5.124:8080

NOTE
The DNS server that hosts the wildcard domain knows nothing about route host names. 
It merely resolves any name to the configured IP addresses. 
Only the OpenShift router knows about route host names, treating each one as an HTTP virtual host. 
The OpenShift router blocks invalid wildcard domain host names that do not correspond to any route and returns an HTTP 404 error.

An important consideration for OpenShift administrators is that the public DNS host names configured 
for routes need to point to the public-facing IP addresses of the nodes running the router. 
Router pods, unlike regular application pods, bind to their nodes s public IP addresses instead of to the internal pod SDN.

	$ oc get pod --all-namespaces | grep router
	openshift-ingress  router-default-746b5cfb65-f6sdm 1/1    Running  1         4d
	Note that you can query information on the default router using the associated label as shown here.

	$ oc describe pod router-default-746b5cfb65-f6sdm
	Name:               router-default-746b5cfb65-f6sdm
	Namespace:          openshift-ingress
	...output omitted...
	Containers:
	router:
	...output omitted...
		Environment:
		STATS_PORT:                 1936
		ROUTER_SERVICE_NAMESPACE:   openshift-ingress
		DEFAULT_CERTIFICATE_DIR:    /etc/pki/tls/private
		ROUTER_SERVICE_NAME:        default
		ROUTER_CANONICAL_HOSTNAME:  apps.cluster.lab.example.com
	...output omitted...


	oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}

	oc new-app php:7.3 --name=php-helloworld https://github.com/${RHT_OCP4_GITHUB_USER}/DO180-apps#s2i --context-dir php-helloworld

# s2i
The BuildConfig pod is responsible for creating the images in OpenShift and pushing them to the internal container registry. 
Any source code or content update typically requires a new build to guarantee the image is updated.

The Deployment pod is responsible for deploying pods to OpenShift. 
The outcome of a Deployment pod execution is the creation of pods with the images deployed in the internal container registry. 
Any existing running pod may be destroyed, depending on how the Deployment resource is set.

## Context subdirectory

	oc new-app https://github.com/openshift/sti-ruby.git --context-dir=2.0/test/puma-test-app

## Branch branch4

	oc new-app https://github.com/openshift/sti-ruby.git#branch4

Create a new project 

	oc new-project ${RHT_OCP4_DEV_USER}-s2i
	oc new-app php:7.3 --name=php-helloworld https://github.com/${RHT_OCP4_GITHUB_USER}/DO180-apps#s2i --context-dir php-helloworld
	oc expose service php-helloworld --name ${RHT_OCP4_DEV_USER}-helloworld
	oc get route -o jsonpath='{..spec.host}{"\n"}' ${RHT_OCP4_DEV_USER}-helloworld-${RHT_OCP4_DEV_USER}-s2i.${RHT_OCP4_WILDCARD_DOMAIN}

	oc -o json new-app php~http://services.lab.example.com/app --name=myapp > s2i.json

Create a new project test-s2i

	oc new-project test-s2i
	oc new-app php:7.3 --name=php-helloworld https://github.com/chuhakhanh/DO180-apps#s2i --context-dir php-helloworld
	oc logs --all-containers -f php-helloworld-1-build
	oc describe deployment/php-helloworld
	oc expose service php-helloworld --name test-helloworld
	oc get route -o jsonpath='{..spec.host}{"\n"}'

	curl http://test-helloworld-test-s2i.apps.ocp4.example.com/
	Hello, World! php version is 7.3.29

	cd ~/DO180-apps/php-helloworld

Edit index.php
	<?php
	print "Hello, World! php version is " . PHP_VERSION . "\n";
	print "A change is a coming!\n";
	?>

	git add .
	git commit -m 'Changed index page contents.'
	git push origin s2i

	oc start-build php-helloworld
	oc get pods
	oc logs php-helloworld-2-build -f
	curl http://test-helloworld-test-s2i.apps.ocp4.example.com/
	Hello, World! php version is 7.3.29
	A change is a coming!

	10.1.17.253 console-openshift-console.apps.ocp4.example.com oauth-openshift.apps.ocp4.example.com rails-postgresql-example-test.apps.ocp4.example.com test-helloworld-test-s2i.apps.ocp4.example.com php-helloworld-test-console.apps.ocp4.example.com todoapi-test-s2i.apps.ocp4.example.com
	
	oc create -f todo-app.yml
	oc port-forward mysql 3306:3306
	mysql -uuser1 -h 127.0.0.1 -pmypa55 -P3306 items < db.sql
	oc expose service todoapi
	
	http://todoapi-test-s2i.apps.ocp4.example.com/todo/

	
## Template

	oc get templates -n openshift	
	cd /home/student/DO180/labs/multicontainer-openshift
	
	oc process --parameters mysql-persistent -n openshift
	oc process -o yaml -f mysql.yaml -p MYSQL_USER=dev -p MYSQL_PASSWORD=$P4SSD -p MYSQL_DATABASE=bank -p VOLUME_CAPACITY=10Gi > mysqlProcessed.yaml
	oc create -f mysqlProcessed.yaml
	oc process -f mysql.yaml -p MYSQL_USER=dev -p MYSQL_PASSWORD=$P4SSD -p MYSQL_DATABASE=bank -p VOLUME_CAPACITY=10Gi | oc create -f -
	oc process -f todo-template.json | oc create -f -

	oc get builds
	oc logs build/myapp-1
	oc get buildconfig
	oc start-build myapp

# Quick Run

## 
	cd /home/student/DO180/labs/comprehensive-review/image

	FROM ubi8/ubi:8.3
	MAINTAINER username <username@example.com>
	ARG NEXUS_VERSION=2.14.3-02
	ENV NEXUS_HOME=/opt/nexus
	RUN yum install -y --setopt=tsflags=nodocs java-1.8.0-openjdk-devel \
	&& yum clean all -y
	RUN groupadd -r nexus -f -g 1001 \
	&& useradd -u 1001 -r -g nexus -m -d ${NEXUS_HOME} -s /sbin/nologin \
	-c "Nexus User" nexus \
	&& chown -R nexus:nexus ${NEXUS_HOME} \
	&& chmod -R 755 ${NEXUS_HOME}
	USER nexus
	ADD nexus-${NEXUS_VERSION}-bundle.tar.gz ${NEXUS_HOME}
	ADD nexus-start.sh ${NEXUS_HOME}/
	RUN ln -s ${NEXUS_HOME}/nexus-${NEXUS_VERSION} ${NEXUS_HOME}/nexus2
	WORKDIR ${NEXUS_HOME}
	VOLUME ["/opt/nexus/sonatype-work"]
	CMD ["sh", "nexus-start.sh"]

	podman build --layers=false -t nexus .

	podman login -u ${RHT_OCP4_QUAY_USER} quay.io
	podman push localhost/nexus:latest quay.io/${RHT_OCP4_QUAY_USER}/nexus:latest
	cd ~/DO180/labs/comprehensive-review/deploy/openshift
	oc login -u ${RHT_OCP4_DEV_USER} -p ${RHT_OCP4_DEV_PASSWORD} ${RHT_OCP4_MASTER_API}
	oc new-project ${RHT_OCP4_DEV_USER}-review
	export RHT_OCP4_QUAY_USER
	envsubst < resources/nexus-deployment.yaml | oc create -f -
	oc expose svc/nexus

	oc new-app -i php http://my.git.server.lab.example.com/app --name=myapp
	oc -o json new-app -i php http://services.lab.example.com/app --name=myapp > s2i.json

	oc get templates -n openshift
	oc describe template mysql-persistent -n openshift
	oc get template mysql-persistent -n openshift -o yaml

##

	oc create -f todo-template.yaml

##

	oc process -o yaml -f mysql.yaml -p MYSQL_USER=dev -p MYSQL_PASSWORD=$P4SSD -p MYSQL_DATABASE=bank \
	-p VOLUME_CAPACITY=10Gi > mysqlProcessed.yaml
	oc create -f mysqlProcessed.yaml

##

	oc get template mysql-persistent -o yaml -n openshift > mysql-persistent-template.yaml
	oc process -f mysql-persistent-template.yaml -p MYSQL_USER=dev -p MYSQL_PASSWORD=$P4SSD -p MYSQL_DATABASE=bank \
	-p VOLUME_CAPACITY=10Gi > mysqlProcessed.yaml 
	oc create -f mysqlProcessed.yaml 

## 