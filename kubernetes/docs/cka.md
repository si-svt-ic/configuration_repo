# water 

Water is foundation of life. 

## water = 1

Solution

  ~/.vimrc
  set tabstop=2
  set expandtab
  set shiftwidth=2

  alias k=kubectl                         # will already be pre-configured
  export do="--dry-run=client -o yaml"    # k create deploy nginx --image=nginx $do
  export now="--force --grace-period 0"   # k delete pod x $now

## water = 2

Solution

  k config get-contexts
  k config use-context k8s-c1-H
  k config current-context

## water = 3

Solution

  k get pod -A --sort-by=.metadata.uid  

  k exec -it -n kube-system kube-proxy-9mzzz -- sh

## water = 4
  
  export client=$(grep client-cert $HOME/.kube/config |cut -d" " -f 6)
  export key=$(grep client-key-data $HOME/.kube/config |cut -d " " -f 6)
  export auth=$(grep certificate-authority-data $HOME/.kube/config |cut -d " " -f 6)
  echo $client | base64 -d - > ./client.pem
  echo $key | base64 -d - > ./client-key.pem
  echo $auth | base64 -d - > ./ca.pem

  curl --cert ./client.pem --key ./client-key.pem --cacert ./ca.pem https://k8scp:6443/api/v1/pods
  
# tree scope

Plant trees for a better future. 

## tree = 1

Task

  Create a new ClusterRole named deployment-clusterrole, which only allows to create the following resource types:
  ✑ Deployment
  ✑ Stateful Set
  ✑ DaemonSet
  Create a new ServiceAccount named cicd-token in the existing namespace app-team1.
  Bind the new ClusterRole deployment-clusterrole to the new ServiceAccount cicd-token, limited to the namespace app-team1.

Solution 

  k config use-context k8s

  k create clusterrole deployment-clusterrole --verb=create --resource=deployments,statefulsets,deamonsets
  k create rolebinding deploy-b -n app-team1 --clusterrole=deployment-clusterrole --serviceaccount=app-team1:cicd-token

  k auth can-i create deployment -n app-team1 --as system:serviceaccount:app-team1:cicd-token
  k auth can-i create deployment -n default --as system:serviceaccount:app-team1:cicd-token


## tree = 2

Task

  Set the node named ek8s-node-0 as unavailable and reschedule all the pods running on it.

Solution

  k config use-context k8s
  k get nodes
  k drain worker0 --ignore-deamonsets
  k drain worker0 --ignore-deamonsets --delete-emptydir-data
  k get nodes -> Scheduling disabled on worker0

## tree = 3

Task

  Given an existing Kubernetes cluster running version 1.22.1, upgrade all of the Kubernetes control plane and node components on the master node only to version 1.22.2.
  Be sure to drain the master node before upgrading it and uncordon it after the upgrade.

Solution

Follow https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/#upgrading-control-plane-nodes

  k get nodes 
  k drain master0 --ignore-deamonsets 
  k get nodes => Scheduling disabled on master0
  ssh master0
  
  sudo -i
  apt-mark unhold kubeadm kubelet k 
  apt install kubeadm=1.22.2-0 kubelet=1.22.2-0 k=1.22.2-0
  kubeadm upgrade plan
  kubeadm upgrade apply v1.22.2
  sudo systemctl daemon-reload
  systemctl restart kubelet
  exit

  k get nodes
  k uncordon master0
  k get nodes

## tree = 4

Task

  First, create a snapshot of the existing etcd instance running at https://127.0.0.1:2379, saving the snapshot to /var/lib/backup/etcd-snapshot.db.
  Next, restore an existing, previous snapshot located at /var/lib/backup/etcd-snapshot-previous.db.
  Use certificates provied inlcues:
  - CA Certificate
  - Client certificate: for server trust client
  - Client key: for client-server transportation data

Note: 

  Public key is used to check certificate to verify that certificate is valid or not.

  First you and your server have a same common public key. Then both of you use the CA cert and the share common public key to trust the CA. Then the server have public key of the CA. 

  The Client certificate is generated with above CA. Then you provide this client certificate to server for server to trust you ( he use the public key of the CA). Then he has your public key.

  And then you send him the client key (encrypted by the private key). He can verify by use the public key. Then he use the client key to trasmit data with you. 


Solution

  export ETCDCTL_API=3
  HOST_1=192.168.30.123
  HOST_2=192.168.30.124
  HOST_3=192.168.30.125
  ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
  export ETCDCTL_API=3
  etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/opt/ca.crt --cert=/opt/etcd-client.crt --key=/opt/etcd-client.key snapshot save /data/backup/etcd-snapshot.db

  etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/opt/ca.crt --cert=/opt/etcd-client.crt --key=/opt/etcd-client.key snapshot status /data/backup/etcd-snapshot.db

  sudo systemctl stop etcd
 
  sudo chmod u+r /var/lib/backup/etcd-snapshot-previous.db
  mv $DATA_DIR_PATH/member $SOME_OTHER_LOCATION
  
  etcdctl --data-dir $DATA_DIR_PATH snapshot restore /var/lib/backup/etcd-snapshot-previous.db
  etcdctl snapshot restore /data/backup/etcd-snapshot.db
  sudo systemctl restart etcd

## tree = 5

Task 

	Create a new NetworkPolicy named allow-port-from-namespace in the existing namespace fubar.
	Ensure that the new NetworkPolicy allows Pods in namespace internal to connect to port 9000 of Pods in namespace fubar.
	Further ensure that the new NetworkPolicy:
	✑ does not allow access to Pods, which don't listen on port 9000
	✑ does not allow access from Pods, which are not in namespace internal

Solution

	k config use-context hk8s
	k label ns internal tier=internal

	vi ingress.yaml

	apiVersion: networking.k8s.io/v1
	kind: NetworkPolicy
	metadata:
		name: allow-port-from-namespace
		namespace: fubar
	spec:
		podSelector: {}
		policyTypes:
			- Ingress
		ingress:
			- from:
				- namespaceSelector:
						matchLabels:
							tier: internal
				ports:
					- protocol: TCP
						port: 9000


## tree = 6

Task 

	Reconfigure the existing deployment front-end and add a port specification named http exposing port 80/tcp of the existing container nginx.
	Create a new service named front-end-svc exposing the container port http.
	Configure the new service to also expose the individual Pods via a NodePort on the nodes on which they are scheduled.

Solution

	k config use-context hk8s
	k get deployments
	k edit deployments front-end

	template:
		...
		specs:
			containers:
			- image: nginx:1.14.2
			  ...
				name: nginx
				ports:                
				- containerPorts: 80  <<<<<
				  name: http 
	
	k expose deployment front-end --name=front-end-svc --type=NodePort 


## tree = 7

	k scale deployment presentation --replicas=3

## tree = 8

Task 

	Schedule a pod as follows:
	✑ Name: nginx-kusc00401
	✑ Image: nginx
	✑ Node selector: disk=ssd

Solution

	https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/
	k label nodes worker0 disk=ssd

	pod.yaml
	apiVersion: v1
	kind: Pod
	metadata:
		name: nginx-kusc00401
	spec:
		containers:
		- name: nginx
			image: nginx
			imagePullPolicy: IfNotPresent
		nodeSelector:
			disk: ssd
	
	k create -f node.yaml
	k get pods

  kubectl get nodes -L beta.kubernetes.io/arch
  NAME          STATUS                     ROLES                  AGE   VERSION   ARCH
  nvd-master1   Ready,SchedulingDisabled   control-plane,master   64d   v1.20.7   amd64
  nvd-master2   Ready                      control-plane,master   64d   v1.20.7   amd64
  nvd-master3   Ready                      control-plane,master   64d   v1.20.7   amd64
  nvd-worker1   Ready                      <none>                 64d   v1.20.7   amd64
  nvd-worker2   Ready                      <none>                 64d   v1.20.7   amd64
  nvd-worker3   Ready                      <none>                 64d   v1.20.7   amd64

## tree = 9

Task 

	Check to see how many nodes are ready (not including nodes tainted NoSchedule) and write the number to /opt/KUSC00402/kusc00402.txt.

Solution

	Search: k Cheat Sheet
	
	# View existing taints on which exist on current nodes
	k get nodes -o='custom-columns=NodeName:.metadata.name,TaintKey:.spec.taints[*].key,TaintValue:.spec.taints[*].value,TaintEffect:.spec.taints[*].effect'
	k get nodes -o='custom-columns=Name:.metadata.name,Taint:.spec.taints[*].effect,Ready:'{.status.conditions[?(@.reason == "KubeletReady")].type}' | grep -v NoSchedule

## tree = 10

Task 

	Schedule a Pod as follows:
	✑ Name: kucc8
	✑ App Containers: 2
	✑ Container Name/Images:
	- nginx
	- consul

Solution

	kucc8.yaml
	apiVersion: v1
	kind: Pod
	metadata:
		name: kucc8
	spec:
		containers:
		- name: nginx
			image: nginx
		- name: consul
			image: consul

	
	k create -f kucc8.yaml
	k get pods

## tree = 11

Task 

	Create a persistent volume with name app-data, of capacity 2Gi and access mode ReadOnlyMany. The type of volume is hostPath and its location is /srv/app- data.

Solution

	https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume

	apiVersion: v1
	kind: PersistentVolume
	metadata:
		name: app-data
	spec:
		storageClassName: manual
		capacity:
			storage: 2Gi
		accessModes:
			- ReadOnlyMany
		hostPath:
			path: "/srv/app-data"

	
	k apply -f pv-volume.yaml

## tree = 12

Task 

	Monitor the logs of pod foo and:
	✑ Extract log lines corresponding to error file-not-found
	✑ Write them to /opt/KUTR00101/foo

Solution

	k logs foo | grep -i "error file-not-found"  > /opt/KUTR00101/foo

## tree = 13

Task 

	An existing Pod needs to be integrated into the Kubernetes built-in logging architecture (e.g. k logs). Adding a streaming sidecar container is a good and common way to accomplish this requirement.
	Add a sidecar container named sidecar, using the busybox image, to the existing Pod big-corp-app. The new sidecar container has to run the following command:
	/bin/sh -c "tail n+1 -f /var/log/big-corp-app.log"
  Use a Volume, mounted at /var/log, to make the log file big-corp-app.log available to the sidecar container.

Solution

Search: sidecar

	apiVersion: v1
	kind: Pod
	metadata:
		name: counter
	spec:
		containers:
		- name: count
			image: busybox:1.28
			args: [/bin/sh, -c, 'tail n+1 -f /var/log/big-corp-app.log']
			volumeMounts:
			- mountPath: /var/log/
			  name: logs
		volumes:
		- name: logs
			emptyDir: {}
			
	k apply -f counter-pod.yaml

## tree = 14

Task

	From the pod label name=overloaded-cpu, find pods running high CPU workloads and write the name of the pod consuming most CPU to the file /opt/
	KUTR00401/KUTR00401.txt (which already exists).

Solution

	k top pod -l name=overloaded-cpu --sort-by=cpu
	echo "pod-abc" > /opt/KUTR00401/KUTR00401.txt

## tree = 15

Task

	A Kubernetes worker node, named wk8s-node-0 is in state NotReady.
	Investigate why this is the case, and perform any appropriate steps to bring the node to a Ready state, ensuring that any changes are made permanent.

Solution

	k describe node w8ks-node-0
	ssh w8ks-node-0
	sudo -i 
	systemctl enable --now kubelet
	systemctl restart kubelet
	systemctl status kubelet

## tree = 16

Task

	Create a new PersistentVolumeClaim:
	✑ Name: pv-volume
	✑ Class: csi-hostpath-sc
	✑ Capacity: 10Mi
	Create a new Pod which mounts the PersistentVolumeClaim as a volume:
	✑ Name: web-server
	✑ Image: nginx
	✑ Mount path: /usr/share/nginx/html
	Configure the new Pod to have ReadWriteOnce access on the volume.
	Finally, using k edit or k patch expand the PersistentVolumeClaim to a capacity of 70Mi and record that change.

Solution

	apiVersion: v1
		kind: PersistentVolumeClaim
	metadata:
		name: pv-volume
	spec:
		accessModes:
			- ReadWriteOnce
		resources:
			requests:
				storage: 10Mi
		storageClassName: csi-hostpath-sc

apiVersion: v1
	kind: Pod
metadata:
  name: web-server
spec:
  containers:
    - name: web-server
      image: nginx
      volumeMounts:
      - mountPath: "/usr/share/nginx/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: pv-volume
	
	k edit pvc pv-volume
	-> 70 Mi

	k get pvc

## tree = 17

Task

	Create a new nginx Ingress resource as follows:
	✑ Name: pong
	✑ Namespace: ing-internal
	✑ Exposing service hello on path /hello using service port 5678

Solution

	apiVersion: networking.k8s.io/v1
	kind: Ingress
	metadata:
		name: pong
		namespace: ing-internal
		annotations:
			nginx.ingress.kubernetes.io/rewrite-target: /
	spec:
		rules:
			- http:
					paths:
						- path: /hello
							pathType: Prefix
							backend:
								service:
									name: hello
									port:
										number: 5678

## tree = 18

Task

	Create a new nginx Ingress resource as follows:

	• Name: ping
	• Namespace: ing-internal
	• Exposing service hi on path /hi using service port 5678

Solution

	k create ns ing-internal
	k create ingress ping --rule="/hi=hi:5678"
	curl -kL <cluster-IP>/hi

# ground scope
You also need grounds for kids do hide and seeks. 

## ground = 1

  kubectk get pods -A --sort=.metadata.createTimestamp




  