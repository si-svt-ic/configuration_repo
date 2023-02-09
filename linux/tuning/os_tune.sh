----------------------------- Tuning -------------------------------------
--------------------------------------------------------------------------
vi /etc/sysctl.conf

# Maximum number of remembered connection requests, which did not yet
# receive an acknowledgment from connecting client.
net.ipv4.tcp_max_syn_backlog =	8192

# Increase the maximum total buffer-space allocatable 
# This is measured in units of pages (4096 bytes) 
net.ipv4.tcp_mem = 2015436 2225152 2539724
net.ipv4.udp_mem = 1887436 2097152 2411724

# Increase the read-buffer space allocatable (minimum size, 
# initial size, and maximum size in bytes)
net.ipv4.tcp_rmem = 4096 262144 16777216

# Increase the write-buffer-space allocatable 
net.ipv4.tcp_wmem = 4096 262144 16777216

net.ipv4.tcp_low_latency = 1

# Increase number of incoming connections backlog queue 
# Sets the maximum number of packets, queued on the INPUT 
# side, when the interface receives packets faster than
# kernel can process them.
net.core.netdev_max_backlog = 250000

# Default Socket Receive Buffer
net.core.rmem_default = 16777216

# Maximum Socket Receive Buffer
net.core.rmem_max = 100663296

# Default Socket Send Buffer 
net.core.wmem_default = 16777216

# Maximum Socket Send Buffer 
net.core.wmem_max = 16777216

# Increase the maximum amount of option memory buffers 
net.core.optmem_max = 16777216

## Decrease swapping ##
vm.swappiness = 0

# Allowed local port range 
net.ipv4.ip_local_port_range = 18000 65535

---------------------------------------------------------------------------
vi /etc/security/limits.conf 


*	soft	*	999999
*	hard	*	999999


--------------------------------------------------------------------------
vi  /proc/sys/fs/file-max
6815744

-------------------------------------------------------------
ref:
all options	https://docs.continuent.com/tungsten-clustering-6.0/performance-networking.html
swappiness	https://cloudcraft.info/huong-dan-toi-uu-linux-kernel/
ulimit		https://access.redhat.com/solutions/61334


