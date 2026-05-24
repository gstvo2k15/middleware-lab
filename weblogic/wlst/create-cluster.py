admin_url='t3://localhost:7001'
admin_user='weblogic'
admin_pass='Welcome1'

cluster_name='LabCluster'
ms1='ManagedServer1'
ms2='ManagedServer2'

connect(admin_user, admin_pass, admin_url)

edit()
startEdit()

def exists(path):
    try:
        return getMBean(path) is not None
    except:
        return False

cd('/')

if not exists('/Clusters/' + cluster_name):
    print('Creating cluster ' + cluster_name)
    cmo.createCluster(cluster_name)

if not exists('/Servers/' + ms1):
    print('Creating ' + ms1)
    cmo.createServer(ms1)

cd('/Servers/' + ms1)
cmo.setListenAddress('')
cmo.setListenPort(8001)
cmo.setCluster(getMBean('/Clusters/' + cluster_name))

cd('/')

if not exists('/Servers/' + ms2):
    print('Creating ' + ms2)
    cmo.createServer(ms2)

cd('/Servers/' + ms2)
cmo.setListenAddress('')
cmo.setListenPort(8002)
cmo.setCluster(getMBean('/Clusters/' + cluster_name))

save()
activate(block='true')

disconnect()
exit()