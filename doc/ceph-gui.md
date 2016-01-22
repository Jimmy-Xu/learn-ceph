# Ceph GUI
- [Ceph GUI list](#ceph-gui-list)
  - [(official)Ceph Calamari](#officialceph-calamari)
  - [ceph-dash](#ceph-dash)
  - [krakendash](#krakendash)
  - [ceph-web](#ceph-web)

- [Usage](#usage)
  - [Install and use Ceph Calamari](#install-and-use-ceph-calamari)
    - [install](#install)
      - [install dependency](#install-dependency)
      - [install calamari-server](#install-calamari-server)
      - [install calamari-client](#install-calamari-client)

    - [Config](#config)
      - [modify /etc/calamari/calamari.conf](#modify-etccalamaricalamariconf)
      - [modify /opt/calamari/salt-local/postgres.sls](#modify-optcalamarisalt-localpostgressls)

    - [Init](#init)
      - [create database and user](#create-database-and-user)
      - [re-create postgresql data file(optional)](#re-create-postgresql-data-fileoptional)
      - [init calamari database](#init-calamari-database)

    - [After install](#after-install)
      - [check serivce status](#check-serivce-status)
      - [connect postgresql](#connect-postgresql)
      - [change web port from 80 to 8888](#change-web-port-from-80-to-8888)

    - [Use calamari console](#use-calamari-console)

  - [Use Crapworks/ceph-dash](#use-crapworksceph-dash)
  - [Use krakendash/krakendash(incomplete)](#use-krakendashkrakendashincomplete)
  - [Use tobegit3hub/ceph-web(incomplete)](#use-tobegit3hubceph-webincomplete)

## Ceph GUI list
### (official)Ceph Calamari

```shell
* https://github.com/ceph/calamari
* Written in python
* Use Calamari REST API
```

### ceph-dash

```shell
* https://github.com/Crapworks/ceph-dash
* Written in python(django)
* Don't rely on ceph-rest-api and access librados directory
```

### krakendash

```shell
* https://github.com/krakendash/krakendash
* Written in python
* Use it's python library to access ceph-rest-api
```

### ceph-web

```shell
* https://github.com/tobegit3hub/ceph-web
* written in go
```

## Usage
> change default port from 5000 to 5500, then rebuild

### Install and use Ceph Calamari
> [http://calamari.readthedocs.org/en/latest/operations/index.html](http://calamari.readthedocs.org/en/latest/operations/index.html)

#### install
##### install dependency

```shell
$ apt-get install -y apache2 libapache2-mod-wsgi libcairo2 supervisor python-cairo libpq5 postgresql
$ apt-get install -y salt-minion salt-master
$ apt-get install -y psmisc pciutils
```

##### install calamari-server

```shell
// download deb
$ wget http://download.ceph.com/calamari/1.3.1/ubuntu/trusty/pool/main/c/calamari/calamari-server_1.3.1.1-1trusty_amd64.deb
$ wget http://download.ceph.com/calamari/1.3.1/ubuntu/trusty/pool/main/c/calamari-clients/calamari-clients_1.3.1.1-1trusty_all.deb

$ apt-get install -y  python-pyasn1 python-zope.interface \
  python-twisted python-twisted-conch python-twisted-bin python-twisted-core python-twisted-mail python-twisted-lore python-twisted-names python-twisted-news python-twisted-runner python-twisted-web python-twisted-words \
  python-sqlalchemy python-gevent python-txamqp python-greenlet

$ dpkg -i calamari-server*.deb
  ...
  salt-master: no process found
   * Starting salt master control daemon salt-master
     ...done.
  Stopping supervisor: supervisord.
  Starting supervisor: supervisord.
   * Stopping web server apache2
   *
   * Starting web server apache2
  AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
   *
  Thank you for installing Calamari.
  Please run 'sudo calamari-ctl initialize' to complete the installation.
```

##### install calamari-client

```shell
$ dpkg -i calamari-clients*.deb
  (Reading database ... 37442 files and directories currently installed.)
  Preparing to unpack calamari-clients_1.3.1.1-1trusty_all.deb ...
  Unpacking calamari-clients (1.3.1.1-1trusty) over (1.3.1.1-1trusty) ...
  Setting up calamari-clients (1.3.1.1-1trusty) ...
```

#### Config
##### modify /etc/calamari/calamari.conf

```shell
$ cat /etc/calamari/calamari.conf | grep -i db
  db_path = postgresql://calamari:27HbZwr*g@localhost/calamari
  db_log_level = WARN
  db_engine = django.db.backends.postgresql_psycopg2
  db_name = calamari
  db_user = calamari
  db_password = 27HbZwr*g
  db_host = localhost

//replace default password from '27HbZwr*g' to 'aaa123aa'
$ sed -i 's/27HbZwr\*g/aaa123aa/' /etc/calamari/calamari.conf

//check
$ grep 'aaa123aa' /etc/calamari/calamari.conf
  db_path = postgresql://calamari:aaa123aa@localhost/calamari
  db_password = aaa123aa
```

##### modify /opt/calamari/salt-local/postgres.sls

```shell
//change systemctl to service
$ sed -i 's/- name: systemctl enable postgresql.*/- name: service postgresql stop || true; service postgresql start || true/' /opt/calamari/salt-local/postgres.sls

//change path of pg_hba.conf
$ sed -i 's#/var/lib/pgsql/data/pg_hba.conf#/etc/postgresql/9.3/main/pg_hba.conf#' /opt/calamari/salt-local/postgres.sls

//change default password from '27HbZwr*g' to 'aaa123aa'
$ sed -i 's/- password.*/- password: aaa123aa/' /opt/calamari/salt-local/postgres.sls

//check
$ grep -E "(- password:|\/pg_hba.conf|service postgresql stop)" /opt/calamari/salt-local/postgres.sls
  /etc/postgresql/9.3/main/pg_hba.conf:
          - name: service postgresql stop || true; service postgresql start || true
              - file: /etc/postgresql/9.3/main/pg_hba.conf
          - password: aaa123aa
  /etc/postgresql/9.3/main/pg_hba.conf:
          - file: /etc/postgresql/9.3/main/pg_hba.conf
          - password: aaa123aa
  /etc/postgresql/9.3/main/pg_hba.conf:
              - file: /etc/postgresql/9.3/main/pg_hba.conf
          - password: aaa123aa
          - password: aaa123aa
```

#### Init
##### create database and user

```shell
$ salt-call --local state.template /opt/calamari/salt-local/postgres.sls
  ...
  [ERROR   ] stderr: ERROR:  invalid locale name: "en_US.UTF8"
  [ERROR   ] Failed to create database calamari
  ...

$ locale-gen en_US.UTF-8
$ dpkg-reconfigure locales

$ salt-call --local state.template /opt/calamari/salt-local/postgres.sls
  ...
  [INFO    ] {'calamari': 'Present'}
  local:
      ----------
      postgres_database_|-calamaridb_|-calamari_|-present:
          ----------
          __run_num__:
              2
          changes:
              ----------
              calamari:
                  Present
          comment:
              The database calamari has been created
          name:
              calamari
          result:
              True
      postgres_user_|-calamariuser_|-calamari_|-present:
          ----------
          __run_num__:
              1
          changes:
              ----------
          comment:
              User calamari is already present
          name:
              calamari
          result:
              True
      service_|-postgresql_|-postgresql_|-running:
          ----------
          __run_num__:
              0
          changes:
              ----------
          comment:
              Service postgresql is already enabled, and is in the desired state
          name:
              postgresql
          result:
              True
```

##### re-create postgresql data file(optional)

```shell
//stop postgresql service
$ service postgresql stop

//clear old db file
$ rm -rf /var/lib/postgresql/9.3/main/*
$ chown postgres:postgres /var/lib/postgresql/9.3/main
$ chmod 700 /var/lib/postgresql/9.3/main

//re-create postgresql db
$ su postgres -c "/usr/lib/postgresql/9.3/bin/initdb -D /var/lib/postgresql/9.3/main"

//start postgresql service
$ service postgresql start
```

##### init calamari database

```shell
//init calamari again
$ calamari-ctl initialize
  [INFO] Loading configuration..
  [INFO] Starting/enabling salt...
  [INFO] Starting/enabling postgres...
  [INFO] Initializing database...
  [INFO] You will now be prompted for login details for the administrative user account.
         This is the account you will use to log into the web interface once setup is complete.
  Username: admin
  Email address: xjimmyshcn@gmail.com
  Password: aaa123aa
  Password (again): aaa123aa
  Superuser created successfully.
  [INFO] Initializing web interface...
  [INFO] Starting/enabling services...
  [INFO] Restarting services...
  [INFO] Complete.
```

#### After install
##### check serivce status

```shell
$ service apache2 status
$ service postgresql status
$ supervisorctl status
  carbon-cache          RUNNING    pid 4443, uptime 0:21:52
  cthulhu               RUNNING    pid 5881, uptime 0:00:37
```

##### connect postgresql

```shell
$ su postgres -c  psql
or
$ sudo -u postgres psql

$ su postgres -c "psql -U postgres calamari -W"
  Password for user postgres:aaa123aa
  psql (9.3.10)
  Type "help" for help.
  calamari=#
```

##### change web port from 80 to 8888

```shell
//change port in apache config file
$ sed -i 's/^Listen .*/Listen 8888/' /etc/apache2/ports.conf
$ sed -i 's/^<VirtualHost .*/<VirtualHost \*:8888>/' /etc/apache2/sites-enabled/calamari.conf

//check
$ grep 8888 /etc/apache2 -R
  /etc/apache2/ports.conf:Listen 8888
  /etc/apache2/sites-enabled/calamari.conf:<VirtualHost *:8888>

//restart apache
$ service apache2 restart
```

#### Use calamari console

```shell
open http://<host_ip>:8888 in web browser
login with admin:aaa123aa
```

### Use Crapworks/ceph-dash

```shell
//enter ceph-demo container
$ docker exec -it ceph-demo bash
$ git clone https://github.com/Crapworks/ceph-dash.git
$ cd ceph-dash

//change port from 5000 to 8888
$ sed "s/app.run.*/app.run(host='0.0.0.0',port=8888,debug=True)/" ceph-dash.py
$ grep run ceph-dash.py
  app.run(host='0.0.0.0',port=8888,debug=True)

//start Ceph Dashboard
$ python ceph-dash.py
 * Running on http://0.0.0.0:8888/
 * Restarting with reloader
```

### Use krakendash/krakendash(incomplete)

```shell
$ git clone https://github.com/krakendash/krakendash.git
$ cd krakendash
$ cp krakendash/contrib/*.sh .
$ cd krakendash
$ apt-get install -y python-pip python-dev libxml2-dev libxslt1-dev zlib1g-dev
$ pip install -r requirements.txt

//change port from 5000 to 5500
$ sed -i "s#CEPH_BASE_URL.*#CEPH_BASE_URL = 'http://127.0.0.1:5500/api/v0.1/'#" kraken/settings.py
$ grep CEPH_BASE_URL kraken/settings.py
  CEPH_BASE_URL = 'http://127.0.0.1:5500/api/v0.1/'

//start web server
$ cd ..
$ ./jdango.sh
$ ps -ef | grep krakendash/
  root      8980     1  2 11:12 pts/0    00:00:00 python krakendash/manage.py runserver 0.0.0.0:8000
  root      8991  8980  3 11:12 pts/0    00:00:00 /usr/bin/python krakendash/manage.py runserver 0.0.0.0:8000
```

### Use tobegit3hub/ceph-web(incomplete)

```shell
$ git clone https://github.com/tobegit3hub/ceph-web.git
$ cd ceph-web

$ sed -i 's#baseUrl := "http://127.0.0.1:5000/api/v0.1"#baseUrl := "http://127.0.0.1:5500/api/v0.1"#' controllers/default.go
$ grep 5500 controllers/default.go
  baseUrl := "http://127.0.0.1:5500/api/v0.1"

$ sed -i 's/FROM golang:1.4/FROM golang:1.5.3/' Dockerfile
$ grep 1.5.3 Dockerfile
  FROM golang:1.5.3

$ docker build -t xjimmyshcn/ceph .
```
