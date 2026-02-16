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