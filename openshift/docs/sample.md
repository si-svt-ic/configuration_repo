## Sample

### Chapter 1 

  .vimrc
  autocmd FileType yaml setlocal ai ts=2 sts=2 sw=2 sws=2 etset cursorcolumn

  yum install -y httpd-tools
  htpasswd -b -B -c /tmp/capsule-htpasswd-users capsule01 capsule01
  for i in 2 3 4 5 6 7 8 9 ; do httpasswd -B -b /tmp/capsule-htpasswd-users capsule0${i} capsule0${i} ; done
  oc create secret generic myhtpasswd --from-file htpasswd=/tmp/capsule-htpasswd-users -n openshift-config

  vim /tmp/oauth.yaml
 
  spec:
	  identityProviders:
	  - htpasswd:
	      fileData:
	        name: localusers
	    mappingMethod: claim
	    name: myusers
	    type: HTPasswd
  
  oc replace -f /tmp/oauth.yaml
  oc get pods -n openshift-authentication 

### Chapter 2

  