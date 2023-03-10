How to push docker images to openshift internal registry and create application from it
=======================================================================================

> Assuming you have the OCP (openshift container platform) cluster ready and the user has image push permissions on a namespace (ex:-  dev)

> TL;DR       

*  Grab the Cluster IP Address of internal docker registry 
*  tag the local image to internal docker registry 
*  grab the auth token and login to inter docker registry
*  push the tagged image to internal registry



#### Grab the cluster ip address provided for openshift internal registry
* `oc get svc -n default | grep registry`  #172.30.43.173

#### Create a new project to test
* `oc new-project test`

#### Tag your local image to remote reg
* `docker tag localimage 172.30.43.173:5000/test/localimage`  #WTmRhkFBQS9WD1PzzUDpp_JPygROAOMZa8R67j586P8

#### login to internal docker reg
* `docker login -p  WTmRhkFBQS9WD1PzzUDpp_JPygROAOMZa8R67j586P8 -e unused -u unused 172.30.43.173:5000`

#### Push image to internal registry 
* `docker push 172.30.43.173:5000/test/localimage`

#### Create a new app 'myapp' using the pushed image
* `oc new-app test/localimage --name=myapp`