#!/bin/sh

# initial system updates and installs
apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean

apt-get -y install build-essential binutils gcc make git htop nethogs tmux

# installing PostgreSQL and preparing the database / VERSION 9.5 (or higher)
apt-get -y install postgresql postgresql-contrib libpq-dev postgresql-client postgresql-client-common

echo "CREATE USER airflow PASSWORD 'airflow'; CREATE DATABASE airflow; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow;" | sudo -u postgres psql
sudo -u postgres sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|" /etc/postgresql/9.5/main/postgresql.conf
sudo -u postgres sed -i "s|127.0.0.1/32|0.0.0.0/0|" /etc/postgresql/9.5/main/pg_hba.conf
sudo -u postgres sed -i "s|::1/128|::/0|" /etc/postgresql/9.5/main/pg_hba.conf
service postgresql restart

# installing Redis and setting up the configurations
apt-get -y install redis-server

sed -i "s|bind |#bind |" /etc/redis/redis.conf
sed -i "s|protected-mode yes|protected-mode no|" /etc/redis/redis.conf
sed -i "s|supervised no|supervised systemd|" /etc/redis/redis.conf
service redis restart

# installing python 3.x and dependencies
sudo apt-get update
apt-get -y install python3 python3-dev python3-pip python3-wheel
apt install python3-pip
pip3 install --upgrade pip
pip install pandas SQLAlchemy psycopg2 celery redis flower flask-bcrypt boto3 ldap3 pymssql azure-servicebus flask_cache

# create airflow user with sudo capability
adduser airflow --gecos "airflow,,," --disabled-password
echo "airflow:airflow" | chpasswd
usermod -aG sudo airflow 
echo "airflow ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# install Airflow 1.9.0rc8
mkdir /usr/local/airflow
curl -L -o /usr/local/airflow/1.9.0rc8.tar.gz https://dist.apache.org/repos/dist/dev/incubator/airflow/1.9.0rc8/apache-airflow-1.9.0rc8+incubating-bin.tar.gz
pip install /usr/local/airflow/1.9.0rc8.tar.gz

# create a log folder for airflow
mkdir /var/log/airflow
chown airflow /var/log/airflow

# create a persistent varable for AIRFLOW_HOME across all users env
echo export AIRFLOW_HOME=/home/airflow > /etc/profile.d/airflow.sh

# setting up Airflow
su -c ip4addr="$(ip route get 8.8.8.8 | awk '{print $NF; exit}')" - airflow
su -c AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2airflow:airflow@$ip4addr:5432/airflow - airflow
export AIRFLOW__CORE__SQL_ALCHEMY_CONN
sudo airflow initdb

# upgradedb airflow upgradedb and start airflow
sudo airflow upgradedb
sudo airflow webserver -p 8080
