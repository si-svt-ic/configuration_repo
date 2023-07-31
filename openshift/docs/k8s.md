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