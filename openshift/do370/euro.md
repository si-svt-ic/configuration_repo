# Solution

## 1 setup

  oc get node
  oc describe node/worker01
	oc get nodes -l node-role.kubernetes.io/worker=
	oc label nodes -l node-role.kubernetes.io/worker= cluster.ocs.openshift.io/openshift-storage=
  
## 2 image registry

---
apiVersion: imageregistry.operator.openshift.io/v1
kind: Config
metadata:
	name: cluster
spec:
	storage:
		managementState: Managed
		pvc: null
		s3:
			bucket: noobaa-registry-038ca5ee-d9ed-4b20-997a-c72058af2426
			region: us-east-1
			regionEndpoint: https://s3-openshift-storage.apps.ocp4.example.com


Create a object storage claim (a secret is created also): noobaa-registry
name: noobaa-registry
generateBucketName: obc-openshift-image-registry-noobaa-registry

---
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: noobaa-registry
  namespace: openshift-image-registry
spec:
  additionalConfig:
    bucketclass: noobaa-default-bucket-class
  generateBucketName: obc-openshift-image-registry-noobaa-registry
  storageClassName: openshift-storage.noobaa.io

---

Create a secret 
  
  image-registry-private-configuration-user 
  REGISTRY_STORAGE_S3_ACCESSKEY
  REGISTRY_STORAGE_S3_SECRETKEY

  oc extract secret/noobaa-registry -n openshift-image-registry
	oc create secret generic image-registry-private-configuration-user -n openshift-image-registry \
	--from-literal=REGISTRY_STORAGE_S3_ACCESSKEY="$(cat AWS_ACCESS_KEY_ID)"  \ <<<<<<<<
	--from-literal=REGISTRY_STORAGE_S3_SECRETKEY="$(cat AWS_SECRET_ACCESS_KEY)" 

Patch the image registry cluster config 	

## 3 resource management 

Request:
  
	In Project project-1, user-1 can oc get all, but cannot create resource, edit and delete existing resource	 
	In Project project-1, user-2 can create SA
	In Project project-1, user-2 cannot elevate the priviliges of the user-1 ( ko có quyền cấp quyền)
	In Project project-1, minimum of an invidiual PVC is 1Gi maximum is 3Gi 

Solution:

	oc login -u khanh.chu -p admin123 api.ocp5.svtech.gay:6443
	
  oc create role create-service-account --verb=create --resource=serviceaccount -n human-resource
  oc adm policy add-role-to-user view anne -n human-resource
  oc adm policy add-role-to-user create-service-account anne -n human-resource

oc create role role-1
  --verb=
  --resource=

  oc login -u user-2 -p redhat123 api.ocp5.svtech.gay:6443
	oc create serviceaccount gitlab-sb

Validate user-2 right to impersonate to user-1 

	oc get all -n project-1 --as user-1

Impersonate rule 

=== a.yaml ===

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: impersonate-user-1
rules:
- apiGroups: [""]
  resources: ["users"]
  verbs: ["impersonate"]

=== b.yaml ===

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: impersonate-user-1-binding
subjects:
- kind: User
  name: user-2
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: impersonate-user-1
  apiGroup: rbac.authorization.k8s.io

=== limitrange.yaml ===

apiVersion: v1
kind: LimitRange
metadata:
  name: storagelimits
	namespace: 1
spec:
  limits:
  - type: PersistentVolumeClaim
    max:
      storage: 2Gi
    min:
      storage: 1Gi


## 4 prometheus
(co huong dan trong tai lieu)

prometheusK8s:
  retention: 7d
  volumeClaimTemplate:
    spec:
      storageClassName: ocs-storagecluster-ceph-rbd
      resources:
        requests:
          storage: 40Gi
alertmanagerMain:
  volumeClaimTemplate:
    spec:
      storageClassName: ocs-storagecluster-ceph-rbd
      resources:
        requests:
          storage: 20Gi

 oc create -n openshift-monitoring configmap cluster-monitoring-config --from-file config.yaml=metrics-storage.yml

## 5 storageclass

  volumeBindingMode: WaitForFirstConsumer 

## 6 quota
(co huong dan trong giao dien)
Request:

  In Project 2, create up to 2 PVC, up to 5Gi
	In Project 2, for storageclass silver, create up to 1 PVC, up to 2Gi 

Solution:

apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-consumption
	namespace: 2
spec:
  hard:
    persistentvolumeclaims: "2" 
    requests.storage: "5Gi" 
    silver.storageclass.storage.k8s.io/persistentvolumeclaims: "1" 
		silver.storageclass.storage.k8s.io/requests.storage: "1Gi" 

## 8 filestorage
  
  - write a deployment with volumemounts
  - pod log shows : port 5000 => target port: 5000 service, route   
    
## 7 troubleshoot
  
  - write a deployment with volumemounts, pvc: Mode:Filesystem/rbd 
  - dashy-pvc should bigger than 500Gb

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
	name: alo
spec:
	accessModes:
	- ReadWriteMany
	storageClassName: ocs-storagecluster-rbd
	resources:
		requests:
			storage: 1Gi


apiversion: apps/v1
kind: Deployment
metadata:
	name: fs-tool-pvc
spec:
	template:
		metadata:
			labels:
				app: fs-tool-pvc
		spec:
			containers:
        image: 'registry.access.redhat.com/ubi9/httpd-24@sha256:d510a6343350ac054279a6a1155f2713f3b7ed035190ccd7901dfc368a493ced' 
				volumeMounts:
        - name: vol-data
          mountPath: /data
        - name: vol-cm-file1
          mountPath: /data/file1
      volumes:
        - name: vol-data
          persistentVolumeClaim:
            claimName: pvc-data
        - name: vol-cm-file1
          configMap:
            name: cm-file1



## 9 snapshot

	
	oc create secret generic secret1 --from-file my_abc=/path/to/abc.txt 
  oc create configmap secret1 --from-file cm-file1

gpg --import tadminsec.key
gpg --list-public-keys
gpg -d -o secrets.txt secrets.txt.gpg

kind: ConfigMap
apiVersion: v1
metadata:
  name: cm-file1
  namespace: test-pvc-filesystem
data:
  chk: chuhakhanh truong pho thong co so tay son
  nvd: nguyenvanduc que quan quoc oai

ps -aux
cat /etc/paswd ==> uid, gui

$ oc create sa sa-with-anyuid
$ oc adm policy add-scc-to-user anyuid -z sa-with-anyuid


apiversion: apps/v1
kind: Deployment
metadata:
	labels:
		app: fs-tool-pvc
	name: fs-tool-pvc
spec:
	template:
		metadata:
			labels:
				app: fs-tool-pvc
		spec:
      serviceAccount: sa-with-anyuid
      serviceAccountName: sa-with-anyuid
			containers:
        securityContext:
          runAsUser: 1000
          runAsGroup: 3000
          fsGroup: 2000
        image: 'registry.access.redhat.com/ubi9/httpd-24@sha256:d510a6343350ac054279a6a1155f2713f3b7ed035190ccd7901dfc368a493ced' 
				volumeMounts:
        - name: vol-data
          mountPath: /data
        - name: vol-cm-folder1
          mountPath: /data/folder1
      volumes:
        - name: vol-data
          persistentVolumeClaim:
            claimName: pvc-data
        - name: vol-cm-folder1
          configMap:
            name: cm-folder1
					 
  $ df -h /data/folder1/
  chk
  nvd

## 10 clone

