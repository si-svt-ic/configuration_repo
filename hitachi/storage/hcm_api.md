10.1.20.1
storagenavigator/Admin@123
10.1.20.2/10.1.20.7
api/Admin@123
10.1.20.3-4
maintenance/$VPdkc95FFA

## Khai báo Storage 

Register API với Storage (thông tin lưu trên API Server) 

Trên API 1
Khai báo targetCtl = CTL1
    curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X POST --data-binary @./InputParameters_targetctl_ctl1.json https://10.1.20.2:23451/ConfigurationManager/v1/objects/storages

Khai báo targetCtl = CTL2
    curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X POST --data-binary @./InputParameters_targetctl_ctl2.json https://10.1.20.7:23451/ConfigurationManager/v1/objects/storages

Khai báo targetCtl = CTL2
    curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X POST --data-binary @./InputParameters_targetctl_ctl2.json https://10.1.20.7:23451/ConfigurationManager/v1/objects/storages


Khai báo targetCtl = CTL1, Connection Mode = FC
    curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X POST --data-binary @./FCModeInput.json https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages


Trên API 1
Khai báo targetCtl = CTL1

 curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X POST --data-binary @./InputParameters_targetctl_ctl1.json https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages

## GET storage info
  
  curl -v -k -H "Accept: application/json" -X GET https://10.1.20.2:23451/ConfigurationManager/v1/objects/storages
  {
  "data" : [ {
    "storageDeviceId" : "934000614394", <<< copy Storage ID để sử dụng
    "model" : "VSP E590H",
    "serialNumber" : 614394,
    "ctl1Ip" : "10.1.20.3",
    "ctl2Ip" : "10.1.20.4",
    "targetCtl" : "CTL1"
  } ]


  curl -v -k -H "Accept: application/json" -X GET https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages
  {
  "data" : [ {
    "storageDeviceId" : "934000614394", <<< copy Storage ID để sử dụng
    "model" : "VSP E590H",
    "serialNumber" : 614394,
    "ctl1Ip" : "10.1.20.3",
    "ctl2Ip" : "10.1.20.4",
    "targetCtl" : "CTL1"
  } ]


change targetctl
  
  curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X PUT https://10.1.20.2:23451/ConfigurationManager/v1/objects/storages/934000614394 -d '{"targetCtl" : "CTL1"}'


DELETE ( Unregistry API khỏi Storage )
  
  curl -v -k -u maintenance:'$VPdkc95FFA' -H "Accept: application/json" -X DELETE https://10.1.20.2:23451/ConfigurationManager/v1/objects/storages/934000614394

curl -v -k -u maintenance:'$VPdkc95FFA' -H "Accept: application/json" -X DELETE https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages/934000614394


## Tương tác với storage

### GET infor pool

Gửi lệnh API 1 - Get info pool 
  
  curl -v -k -u maintenance:'$VPdkc95FFA' -H "Accept: application/json" -X GET https://10.1.20.2:23451/ConfigurationManager/v1/objects/storages/934000614394/pools/1

  curl -v -k -H "Accept:application/json" -H "ContentType:application/json" -u api:Admin@123 -X POST http://10.1.20.2:23451/ConfigurationManager/v1/objects/storages/sessions/ 

Gửi lệnh API 2 - Get info pool 
  
  curl -v -k -u maintenance:'$VPdkc95FFA' -H "Accept: application/json" -X GET https://10.1.20.7:23451/ConfigurationManager/v1/objects/storages/934000614394/pools/1





Gửi lệnh Relay 1 - Get storage info

  curl -v -k -u maintenance:'$VPdkc95FFA' -H "Accept: application/json" -X GET https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages/934000614394/
{
  "storageDeviceId" : "934000614394",
  "model" : "VSP E590H",
  "serialNumber" : 614394,
  "svpIp" : "10.1.20.1",
  "mappWebServerHttpsPort" : 443,
  "rmiPort" : 1099,
  "ctl1Ip" : "10.1.20.3",
  "ctl2Ip" : "10.1.20.4",
  "dkcMicroVersion" : "93-07-24/10",
  "communicationModes" : [ {
    "communicationMode" : "lanConnectionMode"
  } ],
  "isSecure" : true,
  "lanConnectionProtocol" : "DTLS SVP",
  "targetCtl" : "CTL1",
  "usesSvp" : true
* Connection #0 to host 10.1.41.10 left intact
}

Gửi lệnh Relay 1 - Get info pool 

  curl -v -k -u maintenance:'$VPdkc95FFA' -H "Accept: application/json" -X GET https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages/934000614394/pools/1

### Communication Mode

Gửi lệnh API 1 - Kiểm tra Communication Mode

  curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X GET https://10.1.20.2:23451/ConfigurationManager/v1/objects/storages/934000614394
 {
  "storageDeviceId" : "934000614394",
  "model" : "VSP E590H",
  "serialNumber" : 614394,
  "svpIp" : "10.1.20.1",
  "mappWebServerHttpsPort" : 443,
  "rmiPort" : 1099,
  "ctl1Ip" : "10.1.20.3",
  "ctl2Ip" : "10.1.20.4",
  "dkcMicroVersion" : "93-07-24/10",
  "communicationModes" : [ {
    "communicationMode" : "lanConnectionMode"
  } ],
  "isSecure" : true,
  "lanConnectionProtocol" : "DTLS SVP",
  "targetCtl" : "CTL1",
  "usesSvp" : true

Gửi lệnh Relay 1 - Kiểm tra Communication Mode

  curl -v -k -H "Accept:application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X GET https://10.1.41.10:23451/ConfigurationManager/v1/objects/storages/934000614394
{
  "storageDeviceId" : "934000614394",
  "model" : "VSP E590H",
  "serialNumber" : 614394,
  "svpIp" : "10.1.20.1",
  "mappWebServerHttpsPort" : 443,
  "rmiPort" : 1099,
  "ctl1Ip" : "10.1.20.3",
  "ctl2Ip" : "10.1.20.4",
  "dkcMicroVersion" : "93-07-24/10",
  "communicationModes" : [ {
    "communicationMode" : "fcConnectionMode"
  } ],
  "isSecure" : true,
  "lanConnectionProtocol" : "DTLS SVP",
  "targetCtl" : "CTL1",
  "usesSvp" : true
* Connection #0 to host 10.1.41.10 left intact
}

Change connection mode:

ProxyMode
  curl -v -k -H "Accept: application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X PUT --data-binary @./ProxyModeInput.json https://10.1.20.2:23451/ConfigurationManager/v1/934000614394/services/communication-mode/actions/change/invoke

MultiMode

  curl -v -k -H "Accept: application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X PUT --data-binary @./MultipleModeInput.json https://10.1.20.2:23451/ConfigurationManager/v1/934000614394/services/communication-mode/actions/change/invoke

FC Mode

  curl -v -k -H "Accept: application/json" -H "Content-Type:application/json" -u maintenance:'$VPdkc95FFA' -X PUT --data-binary @./FCModeInput.json https://10.1.41.10:23451/ConfigurationManager/v1/934000614394/services/communication-mode/actions/change/invoke


