#

#
kubectl cluster-info
kubectl get nodes
kubectl describe node servera

#
kubectl exec test-nginx-59ffd87f5-nvtnp -- env
kubectl get pods

# ReplicationController and Deployment
#
kubectl create deploy test-nginx --image=nginx
kubectl expose deploy test-nginx --type="NodePort" --port 80
kubectl scale deploy test-nginx --replicas=3

# 
kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1
kubectl expose rc kubia --type=LoadBalancer --name kubia-http

# Service
kubectl get svc -A
kubectl get svc test-nginx

# nginx-test2
kubectl create deploy nginx-test2 --image=nginx 

cat << EOF > nginx-test2_svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-test2
spec:
  selector:
    app: nginx
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 31042
EOF

kubectl create -f nginx-test2_svc.yaml

# CKA

## maintenance

### etcd

dxd@dxd-virtual-machine:~$ kubectl -n kube-system exec -it etcd-k8s-master-1 -- sh -c "ETCDCTL_API=3 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key etcdctl endpoint health"
127.0.0.1:2379 is healthy: successfully committed proposal: took = 24.778122ms

dxd@dxd-virtual-machine:~$   kubectl -n kube-system exec -it etcd-k8s-master-1 -- sh -c "ETCDCTL_API=3 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key etcdctl --endpoints=https://127.0.0.1:2379 member list"
4a63ebb863366c15, started, k8s-master-1, https://10.1.16.200:2380, https://10.1.16.200:2379, false
eac4f292489ceaa8, started, k8s-master-3, https://10.1.16.202:2380, https://10.1.16.202:2379, false
f90b011eb7d42283, started, k8s-master-2, https://10.1.16.201:2380, https://10.1.16.201:2379, false

dxd@dxd-virtual-machine:~$   kubectl -n kube-system exec -it etcd-k8s-master-1 -- sh -c "ETCDCTL_API=3 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key etcdctl --endpoints=https://127.0.0.1:2379 member list -w table"
+------------------+---------+--------------+--------------------------+--------------------------+------------+
|        ID        | STATUS  |     NAME     |        PEER ADDRS        |       CLIENT ADDRS       | IS LEARNER |
+------------------+---------+--------------+--------------------------+--------------------------+------------+
| 4a63ebb863366c15 | started | k8s-master-1 | https://10.1.16.200:2380 | https://10.1.16.200:2379 |      false |
| eac4f292489ceaa8 | started | k8s-master-3 | https://10.1.16.202:2380 | https://10.1.16.202:2379 |      false |
| f90b011eb7d42283 | started | k8s-master-2 | https://10.1.16.201:2380 | https://10.1.16.201:2379 |      false |
+------------------+---------+--------------+--------------------------+--------------------------+------------+

dxd@dxd-virtual-machine:~$   kubectl -n kube-system exec -it etcd-k8s-master-1 -- sh -c "ETCDCTL_API=3 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key etcdctl --endpoints=https://127.0.0.1:2379 snapshot save /var/lib/etcd/snapshot.db"
{"level":"info","ts":"2023-11-11T06:00:39.037Z","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/var/lib/etcd/snapshot.db.part"}
{"level":"info","ts":"2023-11-11T06:00:39.049Z","logger":"client","caller":"v3@v3.5.6/maintenance.go:212","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2023-11-11T06:00:39.049Z","caller":"snapshot/v3_snapshot.go:73","msg":"fetching snapshot","endpoint":"https://127.0.0.1:2379"}
{"level":"info","ts":"2023-11-11T06:00:39.450Z","logger":"client","caller":"v3@v3.5.6/maintenance.go:220","msg":"completed snapshot read; closing"}
{"level":"info","ts":"2023-11-11T06:00:39.905Z","caller":"snapshot/v3_snapshot.go:88","msg":"fetched snapshot","endpoint":"https://127.0.0.1:2379","size":"38 MB","took":"now"}
{"level":"info","ts":"2023-11-11T06:00:39.905Z","caller":"snapshot/v3_snapshot.go:97","msg":"saved","path":"/var/lib/etcd/snapshot.db"}
Snapshot saved at /var/lib/etcd/snapshot.db

student@cp: ̃$ mkdir $HOME/backup
student@cp: ̃$ sudo cp /var/lib/etcd/snapshot.db $HOME/backup/snapshot.db-$(date +%m-%d-%y)
student@cp: ̃$ sudo cp /root/kubeadm-config.yaml $HOME/backup/
student@cp: ̃$ sudo cp -r /etc/kubernetes/pki/etcd $HOME/backup/

### 

kubectl --v=10 get pods
kubectl config view 

Config loaded from file /home/student/.kube/config 
Without the certificate authority, key and certificate from this file, only insecure curl commands can be used, which will not expose much due to security settings. We will use curl to access our cluster using TLS in an upcoming la

certificate-authority-data
client-certificate-data
client-key-data

The "certificate-authority-data" field contains the following components:
  Public Key: This is the CA's public key, which is used for verifying the digital signatures of certificates issued by the CA. It allows the recipient of a certificate to validate its authenticity and integrity.
  CA Information: This includes details about the CA, such as its name, organization, location, and contact information. It helps identify and provide context about the CA that issued the certificate.
  Digital Signature: The certificate-authority-data field also includes a digital signature created by the CA using its private key. The signature ensures the integrity of the certificate and verifies that it has been issued by the specified CA.

~/.kube/config
Take a look at the output below:

  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority-data: LS0tLS1CRUdF.....
      server: ht‌tps://10.128.0.3:6443 ;
      name: kubernetes
  contexts:
  - context:
      cluster: kubernetes
      user: kubernetes-admin
    name: kubernetes-admin@kubernetes
  current-context: kubernetes-admin@kubernetes
  kind: Config
  preferences: {}
  users:
  - name: kubernetes-admin
    user:
      client-certificate-data: LS0tLS1CRUdJTib.....
      client-key-data: LS0tLS1CRUdJTi....


$ curl --cert /tmp/client.pem --key /tmp/client-key.pem \
--cacert /tmp/ca.pem -v -XGET \ 
 ht‌tps://10.128.0.3:6443/api/v1/namespaces/default/pods/firstpod/log

This would be the same as the following. If the container does not have any standard out, there would be no logs:

$ kubectl logs firstpod

There are other calls you could make, following the various API groups on your cluster: 

  GET /api/v1/namespaces/{namespace}/pods/{name}/exec
 GET /api/v1/namespaces/{namespace}/pods/{name}/log
  GET /api/v1/watch/namespaces/{namespace}/pods/{name}

