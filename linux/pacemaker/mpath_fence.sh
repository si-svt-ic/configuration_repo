pcs resource cleanup
defaults {
      user_friendly_names yes
      find_multipaths yes
      reservation_key 0x1
}
Ex: node2
defaults {
      user_friendly_names yes
      find_multipaths yes
      reservation_key 0x2
}
pcs stonith create clu58_scsi fence_scsi \
 pcmk_host_list="node5 node8" pcmk_reboot_action="off" devices="/dev/mapper/clu58--ssd_vg-clu58--ssd_lv,/dev/mapper/clu58--hdd_vg-clu58--hdd_lv" \
 meta provides="unfencing"  --force
 
pcs stonith delete clu58_scsi

pcs stonith create clu58_scsi fence_scsi \
pcmk_host_list="node1 node2" pcmk_reboot_action="off" devices="/dev/mapper/mpathb,/dev/mapper/mpathc" meta provides="unfencing" --force

mpathpersist -i -r -d /dev/mapper/clu58-ssd
mpathpersist -i -r -d /dev/mapper/clu58-hdd

pcs stonith create mpath fence_mpath devices="/dev/mapper/clu58--ssd_vg-clu58--ssd_lv,/dev/mapper/clu58--hdd_vg-clu58--hdd_lv" \
 pcmk_host_map="node5:1;node8:2" \
pcmk_monitor_action="metadata" pcmk_reboot_action="off" pcmk_host_argument="key" meta provides=unfencing --force

pcs stonith level add 1 node5 mpath node5-ilo5_fence
pcs stonith level add 1 node8 mpath node8-ilo5_fence

pcs stonith create mpath fence_mpath devices="/dev/mapper/clu58--ssd_vg-clu58--ssd_lv,/dev/mapper/clu58--hdd_vg-clu58--hdd_lv" \
 pcmk_host_map="node5:1;node8:2" pcmk_monitor_action="metadata" pcmk_reboot_action="off" pcmk_host_argument="key" meta provides=unfencing --force
 
 ===
 
 
 
 Ex: node3
 pcs resource cleanup
 vi /etc/multipath.conf
 
defaults {
      user_friendly_names yes
      find_multipaths yes
      reservation_key 0x3
}
Ex: node7
defaults {
      user_friendly_names yes
      find_multipaths yes
      reservation_key 0x4
}
systemctl reload multipathd

mpathpersist -i -r -d /dev/mapper/clu37-ssd
mpathpersist -i -r -d /dev/mapper/clu37-hdd



pcs stonith create mpath_clu37 fence_mpath devices="/dev/mapper/clu37--hdd_vg-clu37--hdd_lv" \
 pcmk_host_map="node3:1;node7:2" pcmk_monitor_action="metadata" pcmk_reboot_action="off" pcmk_host_argument="key" meta provides=unfencing --force
 
 
 
pcs stonith level add 1 node3 mpath_clu37 node3-ilo5_fence
pcs stonith level add 1 node7 mpath_clu37 node7-ilo5_fence
 
