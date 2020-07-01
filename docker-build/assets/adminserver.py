#!/usr/bin/python

cluster_name=os.environ['CLUSTER_NAME']
dns_name=os.environ['DNS_NAME']


wls_jar='/u01/oracle/wlserver/common/templates/wls/wls.jar'
domain_path='/u01/oracle/wlserver/user_projects/domains/domain'
username='weblogic'
password='welcome1'


readTemplate(wls_jar)

# AdminServer settings.
cd('/Security/base_domain/User/' + username)
cmo.setPassword(password)

cd('/Server/AdminServer')
cmo.setName('AdminServer')
cmo.setListenPort(7001)
# cmo.setListenAddress(dns_name)
cmo.setTunnelingEnabled(true)

# cmo.createNetworkAccessPoint('Admin')

# cd('NetworkAccessPoints/Admin')
# channel.setProtocol('t3')
# channel.setEnabled(true)
# channel.setListenAddress(true)
# channel.setHttpEnabledForThisProtocol(true)
# channel.setTunnelingEnabled(false)
# channel.setOutboundEnabled(false)
# channel.setTwoWaySSLEnabled(false)
# channel.setClientCertificateEnforced(false)


cd('/')
create(cluster_name, 'Cluster')
cd('Cluster/'+cluster_name)
cmo.setClusterMessagingMode('unicast')

# If the domain already exists, overwrite the domain
setOption('OverwriteDomain', 'true')

writeDomain(domain_path)
closeTemplate()

exit()

