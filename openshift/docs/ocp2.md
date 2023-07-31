

####################################### do280 #####################################################################################################################

## Chapter 1 - 2

	oc get nodes
	oc adm top nodes
	oc describe node node1

	oc get clusterrolebinding -o wide | grep -E 'NAME|self-provisioners'
	NAME                                                                        ROLE                                                                                    AGE   USERS                                                            GROUPS                                         SERVICEACCOUNTS
	self-provisioners                                                           ClusterRole/self-provisioner                                                            37d                                                                    system:authenticated:oauth                     
	
	oc describe clusterrolebindings self-provisioners
	Name:         self-provisioners
	Labels:       <none>
	Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
	Role:
	Kind:  ClusterRole
	Name:  self-provisioner
	Subjects:
	Kind   Name                        Namespace
	----   ----                        ---------
	Group  system:authenticated:oauth  
	
	oc get rolebindings -o wide
	NAME                    ROLE                               AGE   USERS          GROUPS                            SERVICEACCOUNTS
	admin                   ClusterRole/admin                  28d   system:admin                                     
	system:deployers        ClusterRole/system:deployer        28d                                                    test-s2i/deployer
	system:image-builders   ClusterRole/system:image-builder   28d                                                    test-s2i/builder
	system:image-pullers    ClusterRole/system:image-puller    28d                  system:serviceaccounts:test-s2i

	oc get clusteroperators

#### Get logs

	oc adm node-logs -u crio my-node-name
	oc adm node-logs -u kubelet my-node-name	   
	oc adm node-logs my-node-name

	oc debug node/my-node-name
	sh-4.4# chroot /host
	sh-4.4# systemctl is-active kubelet
	sh-4.4# crictl ps

## Verify health of cluster

	crictl ps --name openvswitch
	oc get events
	oc get pod --loglevel 10
	oc whoami -t

	skopeo inspect docker://registry.redhat.io/rhel8/postgresq-13:1
	oc get pods

### Openshift Dynamic Storage 
	
	oc get storageclass
	oc new-app --name postgresql-persistent \
	--docker-image registry.redhat.io/rhel8/postgresql-13:1-7 \
	-e POSTGRESQL_USER=redhat \
	-e POSTGRESQL_PASSWORD=redhat123 \
	-e POSTGRESQL_DATABASE=persistentdb

Create the persistent volume claim

	oc set volumes deployment/postgresql-persistent --add \
	--type pvc \
	--name postgresql-storage \
	--claim-class nfs-storage \
	--claim-mode rwo \
	--claim-size 10Gi \
	--mount-path /var/lib/pgsql \
	--claim-name postgresql-storage

	oc get pvc
	NAME STATUS ... CAPACITY ACCESS MODES STORAGECLASS AGE
	postgresql-storage Bound ... 10Gi RWO nfs-storage 25s

	oc get pv
	NAME 									 CLAIM
	pvc-65c3cce7-45eb-482d-badf-a6469640bd75 postgresql-storage

	oc delete all -l app=postgresql-persistent
	oc new-app --name postgresql-persistent2 \
    --docker-image registry.redhat.io/rhel8/postgresql-13:1-7 \
    -e POSTGRESQL_USER=redhat \
    -e POSTGRESQL_PASSWORD=redhat123 \
    -e POSTGRESQL_DATABASE=persistentdb

## Chapter 3

### Password 
	
	htpasswd -c -B -b ~/DO280/labs/auth-provider/htpasswd admin redhat
	htpasswd -b ~/DO280/labs/auth-provider/htpasswd developer developer
	cat ~/DO280/labs/auth-provider/htpasswd 

Create secret

	oc create secret generic localusers --from-file htpasswd=/home/student/DO280/labs/auth-provider/htpasswd -n openshift-config
		
	oc adm policy add-cluster-role-to-user cluster-admin admin
				
	oc get oauth cluster -o yaml > ~/DO280/labs/auth-provider/oauth.yaml

		apiVersion: config.openshift.io/v1
		kind: OAuth
		...output omitted...
		spec:
		  identityProviders:
		  - htpasswd:
		      fileData:
		        name: localusers
		    mappingMethod: claim
		    name: myusers
		    type: HTPasswd

	oc replace -f ~/DO280/labs/auth-provider/oauth.yaml
		
	oc extract secret/localusers -n openshift-config --to ~/DO280/labs/auth-provider/ --confirm
	htpasswd -b ~/DO280/labs/auth-provider/htpasswd manager redhat
	
Update secret 	
	
	oc set data secret/localusers --from-file htpasswd=/home/student/DO280/labs/auth-provider/htpasswd -n openshift-config

Delete user

	oc delete user manager
	oc delete user --all

Delete identity

	oc delete identity "myusers:manager"
	oc delete identity --all

	oc get clusterrolebinding -o wide | grep -E 'NAME|self-provisioners'
		
		NAME 				  ROLE 
		self-provisioners ... ClusterRole/self-provisioner ...
	
	oc describe clusterrolebindings self-provisioners

		Role:
		  Kind: ClusterRole
		  Name: self-provisioner
		Subjects:
		  Kind Name Namespace
		  ---- ---- ---------
		  Group system:authenticated:oauth

	oc login -u leader -p redhat
	oc new-project test
	Error from server (Forbidden): You may not request a new project via this API

	oc login -u admin -p redhat
	oc new-project auth-rbac
	oc policy add-role-to-user admin leader
	oc adm groups new dev-group
	oc adm groups add-users dev-group developer
	oc adm groups new qa-group
	oc adm groups add-users qa-group qa-engineer
	oc get groups

	oc policy add-role-to-group edit dev-group
	oc policy add-role-to-group view qa-group
	oc get rolebindings -o wide

	oc login -u developer -p developer
	oc new-app --name httpd httpd:2.4
	oc policy add-role-to-user edit qa-engineer
	oc login -u qa-engineer -p redhat
	oc scale deployment httpd --replicas 3

	oc login -u admin -p redhat
	oc adm policy add-cluster-role-to-group --rolebinding-name self-provisioners self-provisioner system:authenticated:oauth

#### Create authentication

Create user into tmp_users

	for NAME in tester leader admin developer
	do
    htpasswd -b ~/DO280/labs/auth-review/tmp_users ${NAME} 'L@bR3v!ew'
    done

Create secret auth-review by using file tmp_users

	oc create secret generic <name> --from-file my_abc=/path/to/abc.txt | --from-literal key1=secret1
	oc create secret generic auth-review --from-file htpasswd=/home/student/DO280/labs/auth-review/tmp_users -n openshift-config

Export OAuth resource 

	oc get oauth cluster  -o yaml > ~/DO280/labs/auth-review/oauth.yaml

Edit oauth.yaml
	apiVersion: config.openshift.io/v1
	kind: OAuth
	...output omitted...
	spec:
	  identityProviders:
	    - htpasswd:
	        fileData:
	          name: auth-review
	      mappingMethod: claim
	      name: htpasswd
	      type: HTPasswd


Apply oauth.yaml

	oc replace -f ~/DO280/labs/auth-review/oauth.yaml

Test RBAC

	oc login -u admin -p 'L@bR3v!ew'
	oc get nodes
	oc login -u developer -p 'L@bR3v!ew'
	oc get nodes

	oc login -u admin -p 'L@bR3v!ew'
	oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
	oc adm groups new managers
	oc adm groups add-users managers leader
	oc adm policy add-cluster-role-to-group self-provisioner managers
	oc login -u leader -p 'L@bR3v!ew'
	oc new-project auth-review
	
	oc login -u admin -p 'L@bR3v!ew'
	oc adm groups new developers
	oc adm groups add-users developers developer
	oc policy add-role-to-group edit developers
	
	oc adm groups new qa
	oc adm groups add-users qa tester
	oc policy add-role-to-group view qa


## Chapter 4
### Secret and ConfigMap

Create a secret for Pod

	oc create secret generic demo-secret \
	> --from-literal user=demo-user
	> --from-literal root_password=zT1KTgk

	env:
	  - name: MYSQL_ROOT_PASSWORD
		valueFrom:
		  secretKeyRef:
		    name: demo-secret
		    key: root_password

Modify secret by add a prefix

	oc set env deployment/demo --from secret/demo-secret --prefix MYSQL_

Add a secret as file to a volume

	oc set volume deployment/demo --add --type secret --secret-name demo-secret --mount-path /app-secrets

	cat /app-secrets/user 
	demo-user
	cat /app-secrets/root_password
	zT1KTgk

Create a Configuration Maps

	oc create configmap my-config \
	> --from-literal key1=config1 
	> --from-literal key2=config2

Edit secret 

	oc extract secret/htpasswd-ppklq -n openshift-config --to /tmp/ --confirm
	oc set data secret/htpasswd-ppklq -n openshift-config --from-file /tmp/htpasswd

### Sample creat a secret for Project

	oc new-project authorization-secrets
	oc create secret generic mysql \
	--from-literal user=myuser \
	--from-literal password=redhat123 \
    --from-literal database=test_secrets \
	--from-literal hostname=mysql
	
	oc edit secrets mysql
	apiVersion: v1
	data:
	  database: dGVzdF9zZWNyZXRz
	  hostname: bXlzcWw=
	  password: cmVkaGF0MTIz
	  user: bXl1c2Vy
	kind: Secret
	metadata:
	  creationTimestamp: "2022-10-28T03:19:51Z"
	  name: mysql
	  namespace: authorization-secrets
	  resourceVersion: "33615454"
	  uid: e74232e1-8abc-40f9-ad66-8dbe9011cdde
	type: Opaque

	oc new-app --name mysql --docker-image registry.redhat.io/rhel8/mysql-80:1
	oc get all
	oc logs  pod/mysql-865989c47c-d9t7r

    oc set env pod/mysql-56865ffd8-h5fkd --list
    # pods/mysql-56865ffd8-h5fkd, container mysql
    # MYSQL_DATABASE from secret mysql, key database
    # MYSQL_HOSTNAME from secret mysql, key hostname
    # MYSQL_PASSWORD from secret mysql, key password
    # MYSQL_USER from secret mysql, key user

Update env by add a prefix

	oc set env deployment/mysql --from secret/mysql --prefix MYSQL_
	oc set volume deployment/mysql --add --type secret --mount-path /run/secrets/mysql --secret-name mysql

	oc get pods
	oc rsh mysql-7cd7499d66-gm2rh

		for FILE in $(ls /run/secrets/mysql)
		do
		echo "${FILE}: $(cat /run/secrets/mysql/${FILE})"
		done
		database: test_secrets
		hostname: mysql
		password: redhat123
		user: myuse
		mysql -u myuser --password=redhat123 test_secrets -e 'show databases;'

Use the mysql secret to initialize the following environment variables that the quotes application needs to connect to the database: QUOTES_USER,
QUOTES_PASSWORD, QUOTES_DATABASE, and QUOTES_HOSTNAME, which correspond to the user, password, database, and hostname keys of the mysql
secret.

	oc new-app --name quotes --docker-image quay.io/redhattraining/famous-quotes:2.1
	oc set env deployment/quotes --from secret/mysql --prefix QUOTES_
	oc expose service quotes --hostname quotes.apps.ocp4.example.com
	oc get route quotes

	oc logs quotes-77df54758b-mqdtf | head -n2

### SCC

OpenShift provides eight default SCCs:

	• anyuid
	• hostaccess
	• hostmount-anyuid
	• hostnetwork
	• node-exporter
	• nonroot
	• privileged
	• restricted

For example, a container image that requires running as a specific user ID can fail because the restricted SCC runs the container using a random user ID. A container image that listens on port 80 or port 443 can fail for a related reason.

	oc get scc
	oc describe scc hostaccess

Use the scc-subject-review subcommand to list all the security context constraints that can overcome the limitations of a container:

	oc get pod mysql-78f46b7b5-7zdr4 -o yaml | oc adm policy scc-subject-review -f -
	RESOURCE                    ALLOWED BY   
	Pod/mysql-78f46b7b5-7zdr4   anyuid 

For the anyuid SCC, the run as user strategy is defined as RunAsAny, which means that the pod can run as any user ID available in the container. This strategy allows containers that require a specific user to run the commands using a specific user ID.

To change the container to run using a different SCC, you must create a service account bound to a pod. Use the oc create serviceaccount command to create the service account, and use the -n option if the service account must be created in a namespace different than the current one:

	oc new-project authorization-scc
	oc new-app --name gitlab --docker-image quay.io/redhattraining/gitlab-ce:8.4.3-ce.0
	oc get pod/gitlab-6d7895868d-4rhs9 -o yaml | oc adm policy scc-subject-review -f -

	oc create sa gitlab-sa
	oc adm policy add-scc-to-user anyuid -z gitlab-sa
	oc set sa deployment/gitlab gitlab-sa

	oc expose service/gitlab --port 80 --hostname gitlab.apps.ocp4.example.com
	oc get route


### Sample Review

	oc create secret generic review-secret \
	> --from-literal user=wpuser 
	> --from-literal password=redhat123 
	> --from-literal database=wordpress

Deploy MySQL

	oc new-app --name mysql --docker-image registry.redhat.io/rhel8/mysql-80:1
	oc set env deployment/mysql --prefix MYSQL_ --from secret/review-secret

Deploy WordPress

	oc new-app --name wordpress --docker-image quay.io/redhattraining/wordpress:5.7-php7.4-apache \
	> -e WORDPRESS_DB_HOST=mysql \
	> -e WORDPRESS_DB_NAME=wordpress \
	> -e WORDPRESS_TITLE=auth-review \
	> -e WORDPRESS_USER=wpuser \
	> -e WORDPRESS_PASSWORD=redhat123 \
	> -e WORDPRESS_EMAIL=student@redhat.com \
	> -e WORDPRESS_URL=wordpress-review.apps.ocp4.example.com

	oc set env deployment/wordpress --prefix WORDPRESS_DB_ --from secret/review-secret

	oc get pod/wordpress-68c49c9d4-wq46g -o yaml | oc adm policy scc-subject-review -f -
	RESOURCE ALLOWED BY
	Pod/wordpress-68c49c9d4-wq46g anyuid

	oc create serviceaccount wordpress-sa
	oc adm policy add-scc-to-user anyuid -z wordpress-sa
	oc set serviceaccount deployment/wordpress wordpress-sa

	oc expose service/wordpress --hostname wordpress-review.apps.ocp4.example.com


## Chapter 5
### TLS

The --key option requires the certificate private key, and the --cert option requires the
certificate that has been signed with that key

Create a route

	oc create route edge \
	> --service api-frontend --hostname api.apps.acme.com \
	> --key api.key --cert api.crt

Open a new terminal tab and run the tcpdump command with the following options
to intercept the traffic on port 80:
	• -i eth0 intercepts traffic on the main interface.
	• -A strips the headers and prints the packets in ASCII format.
	• -n disables DNS resolution.
	• port 80 is the port of the application

	tcpdump -i eth0 -A -n port 80 | grep js

### Sample

	oc create -f todo-app-v1.yaml
	oc expose svc todo-http --hostname todo-http.apps.ocp4.example.com

Go to http://todohttp.apps.ocp4.example.com

	tcpdump -i eth0 -A -n port 80 | grep js

	oc create route edge todo-https --service todo-http --hostname todo-https.apps.ocp4.example.com

	curl -I -v https://todo-https.apps.ocp4.example.com

	* Server certificate:
	* subject: O=EXAMPLE.COM; CN=.api.ocp4.example.com
	* start date: May 10 11:18:41 2021 GMT
	* expire date: May 10 11:18:41 2026 GMT
	* subjectAltName: host "todo-https.apps.ocp4.example.com" matched cert's
	"*.apps.ocp4.example.com"
	* issuer: O=EXAMPLE.COM; CN=Red Hat Training Certificate Authority
	* SSL certificate verify ok

	oc get svc todo-http -o jsonpath="{.spec.clusterIP}{'\n'}"
	172.30.102.29

	oc debug -t deployment/todo-http --image registry.access.redhat.com/ubi8/ubi:8.4
	sh-4.4$ curl -v 172.30.102.29
	oc delete route todo-https

### Sample route with Certificate

On client, create private key

	openssl genrsa -out training.key 2048

Create Request

	openssl req -new \
	> -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat/\
	> CN=todo-https.apps.ocp4.example.com" \
	> -key training.key -out training.csr

On the CA, approve the request

	openssl x509 -req -in training.csr \
	> -passin file:passphrase.txt \
	> -CA training-CA.pem -CAkey training-CA.key -CAcreateserial \
	> -out training.crt -days 1825 -sha256 -extfile training.ext

Create secret for route

	oc create secret tls todo-certs --cert certs/training.crt --key certs/training.key
	oc create -f todo-app-v2.yaml
	oc describe pod \
	> todo-https-59d8fc9d47-265ds | grep Mounts -A2
	Mounts:
		/usr/local/etc/ssl/certs from tls-certs (ro)
		/var/run/secrets/kubernetes.io/serviceaccount from default-token-gs7gx


	oc create route passthrough todo-https \
	> --service todo-https --port 8443 \
	> --hostname todo-https.apps.ocp4.example.com

	curl -vvI \
	> --cacert certs/training-CA.pem \
	> https://todo-https.apps.ocp4.example.com
	...output omitted...
	* Server certificate:
	* subject: C=US; ST=North Carolina; L=Raleigh; O=Red Hat; CN=todohttps.apps.ocp4.example.com
	* start date: Jun 15 01:53:30 2021 GMT
	* expire date: Jun 14 01:53:30 2026 GMT
	* subjectAltName: host "todo-https.apps.ocp4.example.com" matched cert's
	"*.apps.ocp4.example.com"
	* issuer: C=US; ST=North Carolina; L=Raleigh; O=Red Hat; CN=ocp4.example.com
	* SSL certificate verify ok

	oc get svc todo-https \
	> -o jsonpath="{.spec.clusterIP}{'\n'}"
	172.30.121.154

	oc debug -t deployment/todo-https \
	> --image registry.access.redhat.com/ubi8/ubi:8.4

	sh-4.4$ curl -I http://172.30.121.154
	HTTP/1.1 301 Moved Permanently
	Server: nginx/1.14.1
	Date: Tue, 15 Jun 2021 02:01:19 GMT
	Content-Type: text/html
	Connection: keep-alive
	Location: https://172.30.121.154:8443/

	sh-4.4$ curl -s -k https://172.30.121.154:8443 | head -n5


## Network Policy

Policy for network-1 

	kind: NetworkPolicy
	apiVersion: networking.k8s.io/v1
	metadata:
	name: network-1-policy
	spec:
	podSelector:
		matchLabels:
		deployment: product-catalog
	ingress:
	- from:
		- namespaceSelector:
			matchLabels:
			name: network-2
		podSelector:
			matchLabels:
			role: qa
	ports:
		- port: 8080
		protocol: TCP

Policy for network-1  for network-2

    kind: NetworkPolicy
    apiVersion: networking.k8s.io/v1
    metadata:
      name: network-2-policy
    spec:
      podSelector: {}
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              name: network-1

The fields in the network policy that take a list of objects can either be combined in the same object or listed as multiple objects. 
- If combined, the conditions are combined with a logical AND.
- If separated in a list, the conditions are combined with a logical OR. The logic options allow you to create very specific policy rules.

This is an example of a logical OR

	ingress:
	- from:
		- namespaceSelector: << OR 
			matchLabels:
			name: dev
		- podSelector:       << OR 
			matchLabels:
			app: mobile

This is an example of a logical AND

	...output omitted...
	ingress:
	- from:
		- namespaceSelector:
			matchLabel
				name: dev
			podSelector:
				matchLabels:
					app: mobile
Block all traffic

	kind: NetworkPolicy
	apiVersion: networking.k8s.io/v1
	metadata:
		name: default-deny
	spec:
		podSelector: {}

### Sample network review

	oc create -f php-http.yaml
	oc expose svc php-http --hostname php-http.apps.ocp4.example.com

Policy deny all

	kind: NetworkPolicy
	apiVersion: networking.k8s.io/v1
	metadata:
	  name: deny-all
	spec:
	  podSelector: {}

Policy allow ingress

	kind: NetworkPolicy
	apiVersion: networking.k8s.io/v1
	metadata:
	  name: deny-all
	spec:
	  podSelector: {}
	  ingress:
	  - from:
	      - namepsaceSelector:
		      matchLabels:
			    network.openshift.io/policy-group: ingress
	
	oc create -f allow-from-openshift-ingress.yaml
    oc label namespace default network.openshift.io/policy-group=ingress

	curl -s http://php-http.apps.ocp4.example.com | grep "PHP"

Generate request

	openssl req -new -key training.key \
	> -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat/\
	> CN=php-https.apps.ocp4.example.com" \
	> -out training.csr

Create certificate from request

	openssl x509 -req -in training.csr \
	> -CA training-CA.pem -CAkey training-CA.key -CAcreateserial \
	> -passin file:passphrase.txt \
	> -out training.crt -days 3650 -sha256 -extfile training.ext

Create secret

	oc create secret tls php-certs \
	> --cert certs/training.crt \
	> --key certs/training.key

	vi  php-https.yaml
	image: 'quay.io/redhattraining/php-ssl:v1.1'
	volumes:
	- name: tls-certs
	  secret:
		secretName: php-certs

	 oc create -f php-https.yaml
	 oc create route passthrough php-https --service php-https --port 8443 --hostname php-https.apps.ocp4.example.com


	oc get routes
	NAME HOST/PORT ... SERVICES PORT TERMINATION
	php-http php-http.apps.ocp4.example.com ... php-http 8080
	php-https php-https.apps.ocp4.example.com ... php-https 8443 passthrough

	curl -v --cacert certs/training-CA.pem https://php-https.apps.ocp4.example.com


## Chapter 6
## Pod Placement

### Pod Scheduling

Config label for depployment

	oc edit deployment/myapp

	spec:
	  nodeSelector:
		env: dev

		
	oc patch deployment/myapp --patch '{"spec":{"template":{"spec":{"nodeSelector":{"env":"dev"}}}}}'

	oc adm new-project demo --node-selector "tier=1"
	oc annotate namespace demo openshift.io/node-selector="tier=2" --overwrite
	oc scale --replicas 3 deployment/myapp

#### Sample Project

	oc new-project schedule-pods
	oc new-app --name hello --docker-image quay.io/redhattraining/hello-world-nginx:v1.0
	oc expose svc/hello
	oc scale --replicas 4 deployment/hello

	oc get nodes -L env
	oc label node master01 env=dev
	oc label node master02 env=prod

	oc login -u developer -p developer
	oc edit deployment/hello

		...output omitted...
			terminationMessagePath: /dev/termination-log
			terminationMessagePolicy: File
		  dnsPolicy: ClusterFirst
		  nodeSelector:
		    env: dev  <<<<

Remove label env

	oc label node -l env env

#### Limit Resource 

	resources:
		requests:            <<<<<<< MIN
			cpu: "10m"
			memory: 20Mi
		limits:				 <<<<<<< MAX
			cpu: "80m"
			memory: 100Mi


	oc set resources deployment hello-world-nginx --requests cpu=10m,memory=20Mi --limits cpu=80m,memory=100Mi

Viewing Requests, Limits, and Actual Usage 

	oc describe node node1.us-west-1.compute.internal
	oc adm top nodes -l node-role.kubernetes.io/worker

Create Quota

	apiVersion: v1
	kind: ResourceQuota
	metadata:
		name: dev-quota
	spec:
		hard:
			services: "10"
			cpu: "1300m"
			memory: "1.5Gi"

	oc create quota dev-quota --hard services=10,cpu=1300,memory=1.5Gi
	oc get resourcequota
	oc describe quota

Create Limit Range

	apiVersion: "v1"
	kind: "LimitRange"
	metadata:
	  name: "dev-limits"
	spec:
    limits:
      - type: "Pod"
        max:
          cpu: "500m"
          memory: "750Mi"
        min:
          cpu: "10m"
          memory: "5Mi"
      - type: "Container"
        max:
          cpu: "500m"
          memory: "750Mi"
        min:
          cpu: "10m"
          memory: "5Mi"
        default:
          cpu: "100m"
          memory: "100Mi"
        defaultRequest:
          cpu: "20m"
          memory: "20Mi"
      - type: openshift.io/Image
        max:
          storage: 1Gi
      - type: openshift.io/ImageStream
        max:
          openshift.io/image-tags: 10
          openshift.io/images: 20
      - type: "PersistentVolumeClaim"
        min:
          storage: "1Gi"
        max:
          storage: "50Gi"

  
   oc create --save-config -f dev-limits.yml
   oc describe limitrange dev-limits

Create cluster resource quotas 

Use Project Annotation

  oc create clusterquota user-qa --project-annotation-selector openshift.io/requester=qa --hard pods=12,secrets=20

User Project Label

  oc create clusterquota env-qa --project-label-selector environment=qa --hard pods=10,services=5

Add to Deployment

- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: ${PROJECT_NAME}-quota
  spec:
    hard:
      cpu: "3"
      memory: 10Gi
      pods: "10

#### Sample Quota

Create Project with CPU resource

  oc new-project schedule-limit
  oc create deployment hello-limit --image quay.io/redhattraining/hello-world-nginx:v1.0 --dry-run=client -o yaml > ~/DO280/labs/schedule-limit/hello-limit.yaml

  vim ~/DO280/labs/schedule-limit/hello-limit.yaml
    spec:
      containers:
      - image: quay.io/redhattraining/hello-world-nginx:v1.0
        name: hello-world-nginx
        resources:
          requests:
            cpu: "3"
            memory: 20Mi

  oc create --save-config -f ~/DO280/labs/schedule-limit/hello-limit.yaml
  oc get events --field-selector type=Warning

  vim ~/DO280/labs/schedule-limit/hello-limit.yaml
    spec:
      containers:
      - image: quay.io/redhattraining/hello-world-nginx:v1.0
        name: hello-world-nginx
        resources:
          requests:
            cpu: "1200m"
            memory: 20Mi

  oc apply -f ~/DO280/labs/schedule-limit/hello-limit.yaml
  oc scale --replicas 4 deployment/hello-limit

Create Project with memory resource

  oc create --save-config -f ~/DO280/labs/schedule-limit/loadtest.yaml
  curl -X GET http://loadtest.apps.ocp4.example.com/api/loadtest/v1/mem/150/6
  
  oc get pods
  oc adm top pod

Create Project with Count Quota

  oc create quota project-quota --hard cpu="3",memory="1G",configmaps="3" -n schedule-limit
  for X in {1..4}
  > do
  > oc create configmap my-config${X} --from-literal key${X}=value${X}
  > done
  configmap/my-config1 created 
  configmap/my-config2 created
  configmap/my-config3 created
  Error from server (Forbidden): configmaps "my-config4" is forbidden: exceeded quota: project-quota, requested: configmaps=1, used: configmaps=3, limited: configmaps=3 <<<<<<<<<

Create Project with 

  oc adm create-bootstrap-project-template -o yaml > /tmp/project-template.yaml

## Scaling an Application

Create with deployment

  apiVersion: apps/v1
  kind: Deployment
  ...output omitted...
  spec:
    replicas: 1
    selector:
      matchLabels:
        deployment: scale
    strategy: {}
    template:
      metadata:
        labels:
          deployment: scale
      spec:
        containers:

  oc scale --replicas 5 deployment/scale
  oc autoscale deployment/hello --min 1 --max 10 --cpu-percent 80

Create a sample Project

  oc new-project schedule-scale  
  vim ~/DO280/labs/schedule-scale/loadtest.yaml
  oc create --save-config -f ~/DO280/labs/schedule-scale/loadtest.yaml
  oc describe pod/loadtest-5f9565dbfb-jm9md | grep -A2 -E "Limits|Requests"
  oc scale --replicas 5 deployment/loadtest
  oc scale --replicas 1 deployment/loadtest
  oc autoscale deployment/loadtest --min 2 --max 10 --cpu-percent 50
  
Create a 

  oc new-app --name scaling --docker-image quay.io/redhattraining/scaling:v1.0
  oc expose svc/scaling
  oc scale --replicas 3 deployment/scaling
  oc get pods -o wide -l deployment=scaling
  oc get route/scaling

#### Create a Sample Scheduling

  