## capsule

### Capsule 1 

  .vimrc
  autocmd FileType yaml setlocal ai ts=2 sts=2 sw=2 sws=2 et
  set cursorcolumn

#### Cretea users

  yum install -y httpd-tools
  htpasswd -b -B -c /tmp/capsule-htpasswd-users capsule01 capsule01
  for i in 2 3 4 5 6 7 8 9 ; do httpasswd -B -b /tmp/capsule-htpasswd-users capsule0${i} capsule0${i} ; done
  
  oc create secret generic myhtpasswd --from-file htpasswd=/tmp/capsule-htpasswd-users -n openshift-config
  
  oc get oauth cluster -o yaml > /tmp/oauth.yaml
  vim /tmp/oauth.yaml
 
  spec:
	  identityProviders:
	  - htpasswd:
	      fileData:
	        name: myhtpasswd
	    mappingMethod: claim
	    name: myusers
	    type: HTPasswd
  
  oc replace -f /tmp/oauth.yaml
  oc get pods -n openshift-authentication 

### Capsule 2

#### Remove kubeadmin

  oc login -u kubeadmin -p ${KUBEADM_PASSWD} ${MASTER_API}
  oc adm policy add-cluster-role-to-user cluster-admin capsule01
  oc login -u capsule01 -p capsule01 ${MASTER_API}
  oc whoami
  oc delete secret kubeadmin -n kube-system

#### Disable role to create project

  oc login -u capsule02 -p capsule02 ${MASTER_API}
  oc new-project capsule02-project

  oc login -u capsule01 -p capsule01 ${MASTER_API}
  oc adm policy add-cluster-role-to-user self-provisioner capsule03
  
  oc get clusterrolebinding -o wide | grep -E 'NAME|self-provisioners'
  oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth

#### Create groups
  
  oc login -u capsule01 -p capsule01 ${MASTER_API}
  for i in 1 2 3 4 5 ; do oc adm groups new capsule-g${i} ; done
  oc new-project capsule03-project
  oc new-project capsule04-project
  oc new-project capsule05-project

  oc policy add-role-to-group edit capsule-g03 -n capsule03-project
  oc policy add-role-to-group view capsule-g04 -n capsule04-project
  oc policy add-role-to-group admin capsule-g05 -n capsule04-project

  oc adm groups add-users capsule-g03 capsule03 capsule06
  oc adm groups add-users capsule-g04 capsule04 capsule07
  oc adm groups add-users capsule-g05 capsule05 capsule08
  oc get groups

### Capsule 3

  oc new-app --name capsule-repicas-tomcat1 registry.redhat.io/jboss-webserver-5/webserver50-tomcat9-openshift 
  oc scale --replicas=4 deploymnent/capsule-replicas-tomcat1
  oc get pods -o wide

### Capsule 4

  oc create quota capsule-quota --hard=cpu=1,memory=1G,pods=8,services=15,secrets=10 -n capsule01-project
  oc get quota capsule-quota

### Capsule 5

  cat /tmp/oc-edit-xn2lc.yaml
  ---
  apiVersion: v1
  kind: Pod
  metadata:
    namespace: capsule-replicas
    name: capsule-replicas-tomcat2
  spec:
    nodeSelector:
      env: dev
    containers:
      - image: registry.redhat.io/jboss-webserver-5/webserver50-tomcat9-openshift 

  oc create -f /tmp/oc-edit-xn2lc.yaml
  oc get node -l env=dev
  oc label node master01 env=dev
  oc label node master01 env
  oc label node master01 env=Dev
  oc label node master02 env=dev
    
### Capsule 6

  cpu: 100G --> 300m
  oc replace -f /tmp/oc-big-app.yaml --force

### Capsule 7

  cat /tmp/oc-limitrange1.yaml
  ---
  apiVersion: v1
  kind: LimitRange
  metadata:
    name: resource-limits
  spec:
    limits:
    - type: container
      max:
        cpu: 2
        memory: 1Gi
      min:
        cpu: 100m
        memory: 4Mi
      default:
        cpu: 300m
        memory: 200Mi
      defaultRequest:
        cpu: 200m
        memory: 100Mi
      maxLimitRequestRatio:
        cpu: 10

    - type: pod
      max:
        cpu: 3
        memory: 2Gi
      min:
        cpu: 200m
        memory: 8Mi
      maxLimitRequestRatio:
        cpu: 10

    oc apply -f /tmp/oc-limitrange1.yaml
    oc describe limitranges resource-limits    
      
### Capsule 8

  oc new-project capsule-taint
  oc adm taint node master01 env=prod:NoSchedule

  /tmp/oc-taint.yaml
  spec:
    nodeSelector:
      myname: master01

  tolerations:
  - effect: NoSchedule
    key: env
    operator: Equal
    value: prod

  oc replace -f /tmp/oc-taint.yaml --force
  oc get events

### Capsule 9

  oc new-project capsule-secure
  cat /tmp/capsule-todo.yaml
  ---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: capsule-todo
    labels:
      app: capsule-todo
      name: capsule-todo
    namespace: capsule-todo
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: capsule-todo
        name: capsule-todo
    template:
      metadata:
        labels:
          app: capsule-todo
          name: capsule-todo
      spec:
        containers:
        - resources:
            limits:
              cpu: 0.5
          image: quay.io/todo-angular:v1.1
          name: capsule-todo
          ports:
          - containerPort: 8080
            name: capsule-todo
  ----
  apiVersion: v1
  kind: Service
  metadata
    labels:
      app: capsule-todo
      name: capsule-todo
    name: capsule-todo
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
    selector:
      name: capsule-todo

  oc create -f capsule-todo.yaml
  openssl req -nodes -x509 -newkey rsa:4096 -keyout cert.key -out cert.crt -days 3650 -sha256 -subj "/C=US/ST=North Carolina/L=Raleigh/O=Capsules/CN=capsule-todo.example.com"     
  oc delete route capsule-todo
  oc create route edge capsule-todo --service capsule-todo --hostname capsule-todo.example.com --cert cert.crt --key cert.key

### Capsule 10 

  oc describe service capsule-todo
  ==> check selector
  
  oc describe deployment capsule-todo
  ==> check labels
  
  oc edit service capsule-todo

### Capsule 11

  oc new-project 
  oc new-app --name capsule-mysql registry.redhat.io/mysql-80:1 
  oc get pods
  oc logs capsule-mysql-xyz

  oc create secret generic capsule-mysql --from-literal user=capsuleuser --from-literal password=capsulepasswd --from-literal database=capsuledb
  oc set env deployment/capsule-mysql --from secret/capsule-mysql --prefix MYSQL_
  oc rsh capsule-mysql-xyz
  mysql -u capsuleuser -p capsulepasswd capsuledb -e 'show databases;'

### Capsule 12

  oc new-app --name capsule-wordpress quay.io/wordpress:5 -e WORDPRESS_DB_HOST=capsule-mysql -e WORDPRESS_DB_NAME=capsuledb -e WORDPRESS_TITLE=capsule-scc -e \
  WORDPRESS_USER=capsuleuser -e WORDPRESS_PASSWORD=capsulepasswd -e WORDPRESS_EMAIL=a@b.com -e WORDPRESS_URL=capsule-wordpress.example.com
  oc get pods
  oc logs capsule-wordpress-xyz
  oc set env deployment/capsule-wordpress --from secret/capsule-mysql --prefix WORDPRESS_DB_
  
  oc get pods capsule-wordpress-xyz -o yaml | oc adm policy scc-subject-review -f -
  --> Pod use by anyuid

  oc create serviceaccount capsule-scc-sa 
  oc adm policy add-scc-to-user anyuid -z capsule-scc-sa
  oc set sa deployment/capsule-wordpress capsule-scc-sa

  oc expose svc capsule-wordpress --hostname capsule-wordpress.example.com

## moon 280



### Moon 1 - htpasswd

  yum install httpd-tools

  htpasswd -c -B -b htpasswd armstrong indionce
  htpasswd -B -b htpasswd jobs demo123
  htpasswd -B -b htpasswd wozniak veresa

  oc create secret generic test-htpasswd --from-file=htpasswd=htpasswd_file_name -n openshift-config 
  
  oc explain oauth
  oc edit oauth

  ---
  spec:
    identityProviders:
    - htpasswd:
        fileData:
          name: htpasswd
      mappingMethod: claim
      name: test-htpasswd
      type: HTPasswd

  ---

### Moon 2 - Create group

  oc adm groups new apollo
  oc adm groups new ops

  oc adm policy add-role-to-user cluster-admin jobs
  oc adm policy add-role-to-user self-provisioner wozniak
  

  oc edit clusterrolebinding self-provisioners
  ---
  delete all subjects
  ---

  oc adm groups add-user apollo armstrong
  oc adm groups add-user ops wozniak 

  oc adm policy add-role-to-group admin apollo -n moon
  oc adm policy add-role-to-group view ops -n moon

  oc secret delete kubeadmin -n kube-system

### Moon 6 - Create quota

For total all pods, use requests.cpu, requests.memory
For limit every single pod, usse limits.cpu, litmits.memory
  
  oc create quota moon-quota --hard cpu=2,memory=2Gi,replicationcontrollers=2,services=4 -n moon

### LimitRange

apiVersion: v1
kind: LimitRange
metadata:
  name: limit-moon
spec:
  limits:
  - type: "Pod"
    max:
      cpu:
      memory:
    min:
      cpu:
      memory:
    defaultRequest:
      cpu:
      memory:
  - type: "Container"
    max:
      cpu:
      memory:
    min:
      cpu:
      memory:

### Moon 7 - Create scale

  oc scale --replicase=5 dc/moon-1 -n moon-1
  oc autoscale --min=1 --max=2 --cpu-percent=50 dc/moon-1 
  
  oc set resources deployment hello-world-nginx --requests cpu=10m,memory=20Mi --limits cpu=80m,memory=100Mi


### Moon 8 - Route

  oc create route edge --name route-moon --key --cert --service xyz -n moon-1
  
### Moon 9 - Secret

  oc create secret generic abc --from-literal a=1 --from-literal b=2
  oc set env dc/abc --from secret/abc -n moon-9

### Moon 13 - Taint and Label

13) service use wrong selector to select application.

  oc annotate namespace demo openshift.io/node-selector="tier=2" --overwrite

### Moon 14 - scc anyuid
14) oc logs pod -> permission deny -> fix by assigned scc anyuid to SA

  oc get pod/moon-4rhs9 -o yaml | oc adm policy scc-subject-review -f -
  oc create sa moon-sa
  
  oc adm policy add-scc-to-user anyuid -z moon-sa
  oc set sa dc/moon-1 -n moon-sa
  oc get sa -n moon-sa

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx1
  labels:
    app: nginx1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx1
  template:
    metadata:
      labels:
        app: nginx1
    spec:
      serviceAccountName: nginx-serviceaccount
      containers:
      - name: nginx1
        image: nginx
        ports:
        - containerPort: 80

### Moon 15 - Taint and Label
15) their have taint on node -> deploymentconfig didn't set toleration -> set it or delete taint

  template:
    spec:
      tolerations:
      - effect: NoSchedule
        key: app
        operator: Equal
        value: frontend

  oc adm taint node node1 key1=value1:NoSchedule
  oc adm taint node node1 key1-
  
  oc label node master01 env=dev
  oc label node master01 env-
  oc get node -l env=dev

  ingress

  
16) memory request in deploymentconfig set to 80G no any node can handle this.

