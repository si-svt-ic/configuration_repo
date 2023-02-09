
========================= sansw1 ==============================
---- alias ----

alicreate "node1_fc_1","50:01:43:80:33:14:f3:e4"
alicreate "node2_fc_1","50:01:43:80:24:28:c5:c4"
alicreate "node3_fc_1","50:01:43:80:33:14:f7:a4"
alicreate "node4_fc_1","50:01:43:80:16:7c:76:30"
alicreate "node5_fc_1","50:01:43:80:28:ca:8b:90"
alicreate "node6_fc_1","50:01:43:80:02:3c:bf:68"
alicreate "node7_fc_1","50:01:43:80:33:14:f8:70"
alicreate "node8_fc_1","50:01:43:80:28:cc:35:10"
alicreate "storage1_can1_p1_1","50:05:07:68:0d:75:d1:42"
alicreate "storage1_can1_p1_2","50:05:07:68:0d:05:d1:42"
alicreate "storage1_can2_p1_1","50:05:07:68:0d:75:d1:43"
alicreate "storage1_can2_p1_2","50:05:07:68:0d:05:d1:43"


--- zone ---
zonecreate "node1_storage1","node1_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node2_storage1","node2_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node3_storage1","node3_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node4_storage1","node4_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node5_storage1","node5_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node6_storage1","node6_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node7_storage1","node7_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"
zonecreate "node8_storage1","node8_fc_1;storage1_can1_p1_1;storage1_can1_p1_2;storage1_can2_p1_1;storage1_can2_p1_2"

--- config ---
cfgcreate "mobilitic_sansw1","node1_storage1"
cfgadd "mobilitic_sansw1","node2_storage1"
cfgadd "mobilitic_sansw1","node3_storage1"
cfgadd "mobilitic_sansw1","node4_storage1"
cfgadd "mobilitic_sansw1","node5_storage1"
cfgadd "mobilitic_sansw1","node6_storage1"
cfgadd "mobilitic_sansw1","node7_storage1"
cfgadd "mobilitic_sansw1","node8_storage1"

cfgsave
cfgenable mobilitic_sansw1

====================== sansw2 ================================
--- alias ---
alicreate "node1_fc_2","50:01:43:80:33:14:f3:e6"
alicreate "node2_fc_2","50:01:43:80:24:28:c5:c6"
alicreate "node3_fc_2","50:01:43:80:33:14:f7:a6"
alicreate "node4_fc_2","50:01:43:80:16:7c:76:32"
alicreate "node5_fc_2","50:01:43:80:28:ca:8b:92"
alicreate "node6_fc_2","50:01:43:80:02:3c:bf:6a"
alicreate "node7_fc_2","50:01:43:80:33:14:f8:72"
alicreate "node8_fc_2","50:01:43:80:28:cc:35:12"
alicreate "storage1_can1_p2_1","50:05:07:68:0d:79:d1:42"
alicreate "storage1_can_p2_2","50:05:07:68:0d:09:d1:42"
alicreate "storage1_can2_p2_1","50:05:07:68:0d:79:d1:43"
alicreate "storage1_can2_p2_2","50:05:07:68:0d:09:d1:43"

--- zone ---
zonecreate "node1_storage1","node1_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node2_storage1","node2_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node3_storage1","node3_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node4_storage1","node4_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node5_storage1","node5_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node6_storage1","node6_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node7_storage1","node7_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"
zonecreate "node8_storage1","node8_fc_2;storage1_can1_p2_1;storage1_can1_p2_2;storage1_can2_p2_1;storage1_can2_p2_2"

--- config ---
cfgcreate "mobilitic_sansw2","node1_storage1"
cfgadd "mobilitic_sansw2","node2_storage1"
cfgadd "mobilitic_sansw2","node3_storage1"
cfgadd "mobilitic_sansw2","node4_storage1"
cfgadd "mobilitic_sansw2","node5_storage1"
cfgadd "mobilitic_sansw2","node6_storage1"
cfgadd "mobilitic_sansw2","node7_storage1"
cfgadd "mobilitic_sansw2","node8_storage1"

cfgsave
cfgenable mobilitic_sansw2


=======================> end <=============================
