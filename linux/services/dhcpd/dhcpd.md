### arp
To view the ARP cache:
Open a terminal prompt
Become root on your machine
Run command: arp -n
Clear ARP cache and validate:
Run command: ip -s -s neigh flush all
Run command: arp -n
Compare the last command results to the first (should have less rows)
Clear the DNS cache:
Run command: service nscd restart
Should response with stopping and starting the service (see screen shot)