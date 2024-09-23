#!/bin/bash
#Autor: Rhomael Pinheiro

# Upgrade do SO
apt update
cd /tmp
rm *deb*
rm /tmp/finish

# Instalação dependencias bibliotecas essenciais
apt install -y wget build-essential
apt install -y apache2 apache2-utils
apt install -y libapache2-mod-php php php-mysql php-cli php-pear php-gmp php-gd
apt install -y php-bcmath  php-curl php-xml php-zip
apt install -y mariadb-server mariadb-client
apt install -y snmpd snmp snmptrapd libsnmp-base libsnmp-dev
apt install -y screen figlet toilet cowsay
useradd zabbix

# Download do Zabbix
cd /tmp
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-5+debian12_all.deb
dpkg -i zabbix-release_6.0-5+debian12_all.deb
sleep 3
apt update 
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Criar o Banco de Dados
export DEBIAN_FRONTEND=noninteractive
mariadb -uroot -e "create database zabbix character set utf8mb4 collate utf8mb4_bin";
mariadb -uroot -e "create user 'zabbix'@'localhost' identified by 'p455w0rd'";
mariadb -uroot -e "grant all privileges on zabbix.* to 'zabbix'@'localhost'";
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -uzabbix -pp455w0rd zabbix
echo 'Populando base de dados zabbix, pode demorar um pouco dependendo do hardware'
sleep 10
sed -i 's/# DBPassword=/DBPassword=p455w0rd/' /etc/zabbix/zabbix_server.conf

# Timezone e edição do apache.conf
timedatectl set-timezone America/Sao_Paulo
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/g' /etc/apache2/conf-enabled/zabbix.conf
systemctl enable zabbix-server zabbix-agent
systemctl restart zabbix-server zabbix-agent apache2
systemctl status zabbix-server

# Grafana Install oficial repo
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_9.1.2_amd64.deb
sudo dpkg -i grafana-enterprise_9.1.2_amd64.deb

# Instalando Datasource Zabbix
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
grafana-cli plugins install alexanderzobnin-zabbix-app
systemctl restart grafana-server
touch /tmp/finish

# Instalação do MIBS SNMP
wget http://ftp.de.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.5_all.deb
sleep 20
apt-get -y install smistrip
sleep 20
dpkg -i snmp-mibs-downloader_1.5_all.deb


clear
figlet -c senha BD p455w0rd
figlet -c FINALIZADO!
systemctl status zabbix-server | grep Active
