#!/usr/bin/python

node_name=os.environ['NODE_NAME']
dns_name=os.environ['DNS_NAME']
node_listen_port=os.environ['NODE_LISTEN_PORT']
node_manager_port=os.environ['NODE_MANAGER_PORT']
cluster_name=os.environ['CLUSTER_NAME']

connect('weblogic','welcome1', 't3://wls-admin:7001')

edit()
startEdit()
 
# Machine-1 = the new WebLogic Machine
cmo.createUnixMachine(node_name)
 
cd('/Machines/'+node_name+'/NodeManager/'+node_name)
cmo.setNMType('Plain')
cmo.setListenAddress(dns_name) 
cmo.setListenPort(int(node_manager_port))
 
cd('/')
cmo.createServer(node_name)

cd('Servers/'+node_name)
cmo.setListenAddress(dns_name) 
cmo.setListenPort(int(node_listen_port))
cmo.setMachine(getMBean('/Machines/'+node_name))
cmo.setCluster(getMBean('/Clusters/'+cluster_name))

cd('/Servers/ms01/SSL/ms01')
cmo.setEnabled(false)

activate()