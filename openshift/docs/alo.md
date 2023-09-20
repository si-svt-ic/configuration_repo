 
## alo-1

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

## alo-2

  oc create quota moon-quota --hard cpu=2,memory=2Gi,replicationcontrollers=2,services=4 -n moon

## alo-3

  oc scale --replicase=5 dc/moon-1 -n moon-1
  oc autoscale --min=1 --max=2 --cpu-percent=50 dc/moon-1 
  oc set resources deployment hello-world-nginx --requests cpu=10m,memory=20Mi --limits cpu=80m,memory=100Mi

## alo-4 

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
      defaultRequest:
        cpu: 200m
        memory: 100Mi

    - type: pod
      max:
        cpu: 3
        memory: 2Gi
      min:
        cpu: 200m
        memory: 8Mi
      defaultRequest:
        cpu: 200m
        memory: 100Mi

## alo-5

  template:
    spec:
      tolerations:
      - effect: NoSchedule
        key: app
        operator: Equal
        value: frontend