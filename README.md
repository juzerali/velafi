# Velafi Assignment

A terraform repository that provisions an RDS and web server in a secure, fault tolerant AWS cluster.

## Decisions
### Network

#### 2✕2 subnets
This solution features 2 private and 2 public subnets distributed across 2 different availability zones. This was mentioned in the
problem statement itself, but worth mentioning that this improves fault tolerance in case one of the availability zones goes down.

Future Upgrade: Spread infrastructure across 2 different geographic regions.

### RDS

#### Security
* Only allows traffic on 5432 port from within the private subnet. No external inbound or outbound network access.
* DB password is defaulted with an inline value. This is only for making the assignment run and not recommended for production. In production no default value should be used and failure to supply a secret should fail the plan.

#### Backups
Backups have been disabled in production for simplicity and reducing scope in the assignment. In production, a regular backup plan should be added as per the project needs.

#### IOPS
Default values used for assignment. For highly scalable applications it should be configured appropriately as per the read/write workload.

#### Auto upgrades
Disabled for stability

#### Deletion protection
Not added due to experimental use. Always add in production.