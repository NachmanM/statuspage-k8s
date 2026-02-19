# First Thoughts
DB's : redis / firebase / rds / mongoDB / dynamoDB / postgressql / mysql 
CiCD : jenkins / argoCD 
HA : k8s multi x
Monitoring : promethues & grafana 
logging : ekl / loki 
Security : rules + firebase auth & 2fa

what we need : 
k8s to run application + webapp(status page) on a ec2 ,
the application itself 

1. k8s cluster on aws ec2 
2. put webapp(status page) as a deployment 
3. expose it via api gateaway 
4. check that the webapp works & opening ports
5. make a loadbalancer that connects api gateaway (port)
6. making the actual application 
7. autoscaler  when x+ usage/traffic scale when below x downscale 
8. userdata executes a script on master node ```sudo kubeadm token create --print-join-command``` >> retrevies output and runs on newly made node . and for scaling master nodes ```sudo kubeadm init phase upload-certs --upload-certs``` to print join command with cert ```kubeadm token create --print-join-command --certificate-key <certificate-key>```
9. 



# simplified flow 
user talks to api gateway 
api gateway talks to alb
alb talks to k8s workers(pods)
workers talks to rds


1 t3.micro control plane (fixed)
workers in ASG t3.micro min workers = 1 max workers = 3 
no need for NAT Gateway 
we put Nodes in public subnet 
sg used to isolate everything
rds in private subnet 
redis runs in the cluster(cheaper than running elastiCache service)

db we using rds with prostgressSQL
cache/queue we use redis(in cluster to save money)
auth: firebase auth + 2fa
CI/CD we using jenkins to build image push to ecr and maybe argoCD to deploy
monitoring we using prometheus + grafana (make it light to be able to run on t3.micro)

for the cluster on ec2 using kubeadm
vpc 
2 public subnets for control plane & workers
2 private subnets for rds and alb or vpc link(aws requires DB subnet that has 2 subnets in 2 AZs )
internet Gateway attached to vpc 
route tables for public subnet 0.0.0.0/0 to Internet Gateway
no nat gaveway 
we dont need nat because rds doesnt need internet 

properly settings up Security groups (IMPORTANT)

# Security Groups
SG-Control-Plane
inbound:
22(SSH) only from our ip
6443(kubenetes api) only from workers 

outbound:
allow all

SG-Workers
inbound:
22(not really needed) but if we want only from our ip
10250(kubelet) from SG-Control-Plane
30080(NodePort for Status Page) from SG-ALB

outbound:
allow all

SG-RDS
inbound:
5432(PostgreSQL) only from SG-Workers

outbound:
allow all

SG-ALB
2 options

if we use internal ALB + VPC link
inbound:
80/443 from SG-VPC-Link

if we use public ALB
inbound: 
80/443 from 0.0.0.0/0 (alb is reachable directly!!!)

outbound:
30080 to SG-Workers

SG-VPC-Link(only for internal ALB)
inbound handled by aws we use it as a "who can reach ALB" identity

outbound:
80/443 to SG-ALB

control plane 
t3.micro
subnet public
sg: SG-Control-Plane
IAM role : allow ssm:GetParameter,ssm:PutParameter for the join cluster command & ECR read if we needed

on control plane we need 
continer runtime (docker)
kubeadm
disable swap(usally causes issues with kubeadm . its the standard kubeadm requirment thats what i found)

webapp as a deployment
we containerize it and store the image in ec3
build docker image for our status page
push it to ecr

create manifests 
deployment we start with 1 replica on min=1 worker
service NodePort will work with ASG & ALB

expose it via API Gateway

2 options

option 1 
API Gateway to VPC Link to internal ALB
this makes it so ALB is not reachable to everyone 
how ? 
create internal ALB in vpc with private subnets
create vpc link in API Gateway attached to SG-VPC-Link
create API Gateway integration(?) pointing to ALB listner (ALB listen receives HTTP requests and forwards to the target group)
routes ANY/{proxy+}(REST API Its the common pattery Method: ANY Resource: /{proxy+} meaing forward every path to backend) to ALB itergration

So only the API Gateway can reach ALB because ALB inbound is only the SG-VPC-Link

option 2
API Gateway to Public ALB URl (without VPC Link)
makes it so ALB is publicly reachable not so good but auth still protects 



making ALB connect to the API Gateway 

ALB to ASG to NodePort
how ?
create ALB
create Target group:
Target type: instance
port:30080
Health check path : / or some script to check health
attach Target group to the worker ASG
makes it so when ASG adds instances they auto register to target group
ALB Listen 80/443 forwards to the Target group

ALB forwards to NodePort on all worker nodes

small app we make 
just an app the writes status / incidents to DB

for k8s objects we need just Deployment & Service

Application:
App to DB:(RDS Postgress) Via SG-Workers to SG-RDS
Status page to DB:(RDS Postgress) 
Status page/app to Redis(in cluster)

Autoscaler 
scale up when traffic is high 
scale down when traffic is low

2 AutoScalers 

1 for pod autoscaling 
Horizontal Pod Autoscaler (HPA)
with metrics server (cluster addon )
Create HPA:
scale pods up when CPU > X (example 70%)
scale pods down when CPU < X

1 for Node autoscaling
Cluster autoscaler installed inside the cluster(cluster addon)
configured to manage WOrker ASG (min=1 max=3)
when pods cant schedule it wil increate ASG desired capacity

will gives us 

if Traffic is up -> HPA adds pods -> cluster runs out of room -> Cluster Autoscaler adds EC2 workers(Node)

if Traffic is down -> HPA reduces pods -> Cluster Autoscaler removes EC2 workers(Node)

USERDATA Script for automatically joining new worker nodes with kubeadm join command 

we create join command with token from control plane and store it in ssm
```kubeadm token create --print-join-command```

we can make a token with long ttl so it doesnt break mid demo ttl= time to live

worker userdata pulls from ssm and joins cluster
in USERDATA(ASG Launch Template)
install container runtime(docker) 
install kubeadm/kubelet
we fetch join command from ssm
and execute it 

for scaling master nodes
we use 
```kubeadm init phase upload-certs --upload-certs``` to print a certificate key
and we generate join command normally with 
```kubeadm token create --print-join-command```
and we add the flags to the join command
```kubeadm join ... --control-plane --certificate-key <key>```

for saving purposes i think we should keep control plane fixed at 1 node and not scale it 

all the platform finishes(platform features)

# RDS
RDS Postgres in Private subnet
so its not publicly reachable
SG allows only SG-Workers on port 5432(PostgreSQL)

# CICD
Jenkinds 
builds docker image
push to ecr

and we can add argo cd that watches the git repo for manifests 
and syncs to the cluster automatically 

# monitoring and logging
Prometheus(with short retention)
Grafana
Loki + promtail(agent collects logs and labels them with metadata so we can look through(index& query) them efficiently )

# Security 
Firebase Auth 2FA for the app
k8s RBAC (so we dont jsut have kubeconfig everywhere)
and our Properly made Security Groups 


# small things that are important 

since we dont have a NAT and workers still need to do pull 
workers need public up or VPC endpoints/NAT
so we can just do public ips and block inbound in the SG rules

we also need a way to make worker to worker traffic work
so we need a CNI (Container Network Interface)
add in SG-Workers add inbound to all traffic from SG-Workers (self reference)
only all nodes with in the same SG to talk to each other


Prometheus Grafana and loki are kinda heavy on ram so we have a couple options 

1.Keep monitoring minimal at first (metrics-server + Grafana only, or Prometheus with very short retention + low scrape)

2. make worker bigger type t3.small and not t3.micro 

3. run monitoring on a seprate small instance during demo(showcase) X i dont like this 

we need to choose between 1/2

