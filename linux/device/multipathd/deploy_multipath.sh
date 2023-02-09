yum install -y sysfsutils sg3_utils 
systool -c fc_host -v  | grep port_name

vi /etc/multipath.conf 

multipaths {
        multipath {
                wwid    360050763808104009800000000000000
                alias   clu58-ssd
                  }
        multipath {
                wwid    360050763808104009800000000000001
                alias   clu58-hdd
                  }
            }


echo "- - -" > /sys/class/scsi_host/host2/scan
echo "- - -" > /sys/class/scsi_host/host0/scan
echo "- - -" > /sys/class/scsi_host/host1/scan

fdisk -l 
systemctl enable multipathd.service
systemctl start multipathd.service
mpathconf --enable
mpathconf --enable --user_friendly_names n						
systemctl restart multipathd.service
multipath -ll

