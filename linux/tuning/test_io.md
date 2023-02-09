 
https://woshub.com/check-disk-performance-iops-latency-linux/

    yum install epel-release -y
    yum install fio -y
 
# Random Read/Write Operation Test
When running the test, an 8 GB file will be created. Then fio will read/write a 4KB block (a standard block size) with the 75/25% by the number of reads and writes operations and measure the performance. The command is as follows:

    fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fiotest --filename=testfio --bs=4k --iodepth=64 --size=8G --readwrite=randrw --rwmixread=75

# Test with 10.1.0.23 
## Test with sda (local ssd) 
Result: read 22000 iops, write 7000 iops

    fiotest: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
    fio-3.19
    Starting 1 process
    fiotest: Laying out IO file (1 file / 8192MiB)
    Jobs: 1 (f=0): [f(1)][100.0%][r=124MiB/s,w=41.9MiB/s][r=31.7k,w=10.7k IOPS][eta 00m:00s]
    fiotest: (groupid=0, jobs=1): err= 0: pid=68001: Mon Jan 30 15:14:28 2023
    read: IOPS=22.0k <<<<<, BW=86.0MiB/s (90.2MB/s)(6141MiB/71368msec)
    bw (  KiB/s): min=35325, max=126331, per=99.96%, avg=88079.67, stdev=23662.89, samples=141
    iops        : min= 8831, max=31582, avg=22019.53, stdev=5915.70, samples=141
    write: IOPS=7356 <<<<<, BW=28.7MiB/s (30.1MB/s)(2051MiB/71368msec); 0 zone resets
    bw (  KiB/s): min=12243, max=42195, per=99.95%, avg=29411.03, stdev=7893.65, samples=141
    iops        : min= 3060, max=10548, avg=7352.38, stdev=1973.39, samples=141
    cpu          : usr=11.50%, sys=36.20%, ctx=169303, majf=0, minf=9
    IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
        issued rwts: total=1572145,525007,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=64

    Run status group 0 (all jobs):
    READ: bw=86.0MiB/s (90.2MB/s), 86.0MiB/s-86.0MiB/s (90.2MB/s-90.2MB/s), io=6141MiB (6440MB), run=71368-71368msec
    WRITE: bw=28.7MiB/s (30.1MB/s), 28.7MiB/s-28.7MiB/s (30.1MB/s-30.1MB/s), io=2051MiB (2150MB), run=71368-71368msec

    Disk stats (read/write):
        dm-0: ios=1567349/522952, merge=0/0, ticks=2488901/1563185, in_queue=4052086, util=97.51%, aggrios=1576294/525773, aggrmerge=5/196, aggrticks=2489556/1560637, aggrin_queue=4050193, aggrutil=97.41%
    sda: ios=1576294/525773, merge=5/196, ticks=2489556/1560637, in_queue=4050193, util=97.41%


## Test with /mnt (ssd through NFS)
Result: read 3600 iops, write 1200 iops ( CPU 2 8GB Memory )

    [root@compute-1 ~]# fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fiotest --filename=/mnt/testfio --bs=4k --iodepth=64 --size=8G --readwrite=randrw --rwmixread=75
    fiotest: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
    fio-3.19
    Starting 1 process
    fiotest: Laying out IO file (1 file / 8192MiB)
    Jobs: 1 (f=1): [m(1)][100.0%][r=18.1MiB/s,w=6163KiB/s][r=4640,w=1540 IOPS][eta 00m:00s]
    fiotest: (groupid=0, jobs=1): err= 0: pid=85028: Mon Jan 30 15:29:52 2023
    read: IOPS=3593 <<<<<, BW=14.0MiB/s (14.7MB/s)(6141MiB/437453msec)
    bw (  KiB/s): min= 4308, max=24224, per=100.00%, avg=14401.39, stdev=3508.91, samples=871
    iops        : min= 1077, max= 6056, avg=3600.28, stdev=877.26, samples=871
    write: IOPS=1200 <<<<< , BW=4801KiB/s (4916kB/s)(2051MiB/437453msec); 0 zone resets
    bw (  KiB/s): min= 1426, max= 8000, per=100.00%, avg=4809.01, stdev=1173.90, samples=871
    iops        : min=  356, max= 2000, avg=1202.18, stdev=293.51, samples=871
    cpu          : usr=2.90%, sys=8.22%, ctx=763787, majf=0, minf=8
    IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
        issued rwts: total=1572145,525007,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=64

    Run status group 0 (all jobs):
    READ: bw=14.0MiB/s (14.7MB/s), 14.0MiB/s-14.0MiB/s (14.7MB/s-14.7MB/s), io=6141MiB (6440MB), run=437453-437453msec
    WRITE: bw=4801KiB/s (4916kB/s), 4801KiB/s-4801KiB/s (4916kB/s-4916kB/s), io=2051MiB (2150MB), run=437453-437453msec
    [root@compute-1 ~]# 

## Test with /mnt (ssd through NFS)
Result: read 6889 iops, write 2300 iops ( CPU 32 64GB Memory )

    [root@compute-1 ~]# fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fiotest --filename=/mnt/testfio --bs=4k --iodepth=64 --size=8G --readwrite=randrw --rwmixread=75
    fiotest: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
    fio-3.19
    Starting 1 process
    fiotest: Laying out IO file (1 file / 8192MiB)
    Jobs: 1 (f=1): [m(1)][99.6%][r=27.7MiB/s,w=9734KiB/s][r=7102,w=2433 IOPS][eta 00m:01s] 
    fiotest: (groupid=0, jobs=1): err= 0: pid=93721: Mon Jan 30 16:02:25 2023
    read: IOPS=6889, BW=26.9MiB/s (28.2MB/s)(6141MiB/228191msec)
    bw (  KiB/s): min= 7480, max=47376, per=100.00%, avg=27641.13, stdev=8244.46, samples=453
    iops        : min= 1870, max=11844, avg=6910.20, stdev=2061.20, samples=453
    write: IOPS=2300, BW=9203KiB/s (9424kB/s)(2051MiB/228191msec); 0 zone resets
    bw (  KiB/s): min= 2240, max=15928, per=100.00%, avg=9229.62, stdev=2767.56, samples=453
    iops        : min=  560, max= 3982, avg=2307.32, stdev=691.95, samples=453
    cpu          : usr=4.16%, sys=11.81%, ctx=420157, majf=0, minf=6
    IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
        submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
        complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
        issued rwts: total=1572145,525007,0,0 short=0,0,0,0 dropped=0,0,0,0
        latency   : target=0, window=0, percentile=100.00%, depth=64

    Run status group 0 (all jobs):
    READ: bw=26.9MiB/s (28.2MB/s), 26.9MiB/s-26.9MiB/s (28.2MB/s-28.2MB/s), io=6141MiB (6440MB), run=228191-228191msec
    WRITE: bw=9203KiB/s (9424kB/s), 9203KiB/s-9203KiB/s (9424kB/s-9424kB/s), io=2051MiB (2150MB), run=228191-228191msec

## Test with an folder in Virtual machine of openstack cloud (volume through NFS)
Result: read 6889 iops, write 2300 iops ( CPU 32 64GB Memory )
    read: IOPS=710
    write: IOPS=230

# Test with 10.1.17.41



# Io requiment Cloudpak

Disk requirements
To prepare your storage disks, ensure that you have good I/O performance, and prepare the disks for encryption.

I/O performance
When I/O performance is not sufficient, services can experience poor performance or cluster instability when the services are handling a heavy load, such as functional failures with timeouts. The following I/O performance requirements are based on repeated workloads that test performance on the platform and validated in various cloud environments. The current requirements are based on the performance of writing data to representative storage locations using two chosen block sizes (4 KB and 1 GB). These tests use the dd command-line utility. Use the MB/sec metric from the tests and ensure that your test result is comparable to or better than the targets.

To ensure that the storage partition has good disk I/O performance, run the following tests.

Disk latency test
dd if=/dev/zero of=/PVC_mount_path/testfile bs=4096 count=1000 oflag=dsync

The value must be comparable to or better than: 2.5 MB/s.

Disk throughput test
dd if=/dev/zero of=/PVC_mount_path/testfile bs=1G count=1 oflag=dsync

The value must be comparable to or better than: 209 MB/s.

Dynamic variations in workloads, access patterns in your environment, and the impact of the network on accessing your volumes can impact results. Repeat these tests at different times to understand the I/O performance patterns. For details, see Testing I/O performance for IBM Cloud Pak for Data.