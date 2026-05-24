admin_url='t3://localhost:7001'
admin_user='weblogic'
admin_pass='Welcome1'

cluster_name='LabCluster'
app_name='sample'
app_path='/u01/oracle/deployments/sample.war'

connect(admin_user, admin_pass, admin_url)

try:
    undeploy(app_name, timeout=60000)
except:
    print('Application was not previously deployed')

deploy(app_name, app_path, targets=cluster_name, timeout=120000)

disconnect()
exit()