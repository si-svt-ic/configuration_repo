#

## tree = 1

  kubectl config use-context k8s
  kubectl create clusterrole deployment-clusterrole --verb=create --ressource=Deployment,StatefulSet,DeploymentSet
  
  kubectl create sa cicd-token -n app-team1

  kubectl create rolebinding -n app-team1 --clusterrole=deployment-clusterrole --serviceaccount=app-team1:cicd-token

  kubectl auth can-i create deployment -n app-team1 --as system:serviceaccount:app-team1:cicd-token
  kubectl auth can-i create deployment -n default --as system:serviceaccount:app-team1:cicd-token

## tree = 2

  kubectl get nodes 
  