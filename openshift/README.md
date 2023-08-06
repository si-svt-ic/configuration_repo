## Prepare kolla-ansible environment

Prepare kolla-ansible

    ansible-galaxy collection install community.vmware
    pip3 install "kolla-ansible==13.7.0"
    pip3 install git+https://opendev.org/openstack/kolla-ansible@stable/xena

## Provisioning Openstack for cluster with kolla-ansible

### Operate a cluster

Reference document do180 
    [Following steps in docs/do180.md to operate the cluster](docs/do180.md)
Reference document do280 
		[Following steps in docs/do280.md to operate the cluster](docs/do280.md)
