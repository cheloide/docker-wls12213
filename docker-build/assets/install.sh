#!/bin/bash


export ORACLE_HOME=/u01/oracle
export USER_MEM_ARGS="-Djava.security.egd=file:/dev/./urandom"
export JAVA_HOME=/opt/java/

TEMP_JAVA_FOLDER=$(mktemp -d)

yum install unzip openssh-server openssh-clients  -y

mkdir -p /opt/java
mkdir -p /u01

useradd -b /u01 -m -d $ORACLE_HOME -s /bin/bash oracle
echo oracle:oracle | chpasswd


mkdir -p /opt/java
mkdir -p /var/run/sshd
mkdir $ORACLE_HOME/.ssh

ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

chmod 644 /etc/ssh/sshd_config
chmod 644 /etc/ssh/ssh_host_rsa_key
chmod 755 /var/run/sshd

ssh-keygen -t rsa -f $ORACLE_HOME/.ssh/id_rsa -N ''
cat $ORACLE_HOME/.ssh/id_rsa.pub | tee $ORACLE_HOME/.ssh/authorized_keys

#EXTRACT FILES
unzip /assets/fmw_12.2.1.3.0_wls_Disk1_1of1.zip -d /assets/
tar -C $TEMP_JAVA_FOLDER -zxf /assets/server-jre-8u*-linux-x64.tar.gz
mv $TEMP_JAVA_FOLDER/*/* $JAVA_HOME

alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000
alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000
alternatives --install /usr/bin/jar jar $JAVA_HOME/bin/jar 20000

alternatives  --set java    $JAVA_HOME/bin/java
alternatives  --set javac   $JAVA_HOME/bin/javac
alternatives  --set jar     $JAVA_HOME/bin/jar

mv /assets/adminserver.py $ORACLE_HOME/adminserver.py
mv /assets/nodeserver.py $ORACLE_HOME/nodeserver.py
mv /assets/start-admin-server.sh $ORACLE_HOME/start-admin-server.sh
mv /assets/start-node-server.sh $ORACLE_HOME/start-node-server.sh
mv /assets/start-wsl.sh $ORACLE_HOME/start-wsl.sh

chmod +x $ORACLE_HOME/start-wsl.sh
chmod +x $ORACLE_HOME/start-node-server.sh
chmod +x $ORACLE_HOME/start-admin-server.sh

#Install weblogic
chown oracle:oracle -R /u01

su oracle -l -c 'java -jar /assets/fmw_12.2.1.3.0_wls.jar \
-ignoreSysPrereqs \
-novalidation \
-silent \
-responseFile /assets/install.file \
-invPtrLoc /assets/oraInst.loc \
-jreLoc $0 \
ORACLE_HOME=$1 \
INSTALL_TYPE="WebLogic Server"' "$JAVA_HOME" "$ORACLE_HOME"

rm -rf /run/nologin
rm -rf /assets
rm -rf $TEMP_JAVA_FOLDER