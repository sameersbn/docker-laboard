# Table of Contents

- [Introduction](#introduction)
  - [Version](#version)
  - [Changelog](Changelog.md)
- [Contributing](#contributing)
- [Reporting Issues](#reporting-issues)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Data Store](#data-store)
  - [Database](#database)
    - [MySQL](#mysql)
      - [External MySQL Server](#external-mysql-server)
      - [Linking to MySQL Container](#linking-to-mysql-container)
  - [Putting it all together](#putting-it-all-together)
  - [Available Configuration Parameters](#available-configuration-parameters)
- [Shell Access](#shell-access)
- [Upgrading](#upgrading)
- [Announcements](https://github.com/sameersbn/docker-laboard/issues/1)
- [References](#references)

# Introduction

Dockerfile to build a [Laboard](https://gitlab.com/laboard/laboard) container image.

## Version

Current Version: **1.0.2**

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/sameersbn/docker-laboard/issues) they may encounter
- Send me a tip via [Bitcoin](https://www.coinbase.com/sameersbn) or using [Gratipay](https://gratipay.com/sameersbn/)

# Reporting Issues

Docker is a relatively new project and is active being developed and tested by a thriving community of developers and testers and every release of docker features many enhancements and bugfixes.

Given the nature of the development and release cycle it is very important that you have the latest version of docker installed because any issue that you encounter might have already been fixed with a newer docker release.

For ubuntu users I suggest [installing docker](https://docs.docker.com/installation/ubuntulinux/) using docker's own package repository since the version of docker packaged in the ubuntu repositories are a little dated.

Here is the shortform of the installation of an updated version of docker on ubuntu.

```bash
sudo apt-get purge docker.io
curl -s https://get.docker.io/ubuntu/ | sudo sh
sudo apt-get update
sudo apt-get install lxc-docker
```

Fedora and RHEL/CentOS users should try disabling selinux with `setenforce 0` and check if resolves the issue. If it does than there is not much that I can help you with. You can either stick with selinux disabled (not recommended by redhat) or switch to using ubuntu.

If using the latest docker version and/or disabling selinux does not fix the issue then please file a issue request on the [issues](https://github.com/sameersbn/docker-laboard/issues) page.

In your issue report please make sure you provide the following information:

- The host ditribution and release version.
- Output of the `docker version` command
- Output of the `docker info` command
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Installation

Pull the latest version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull sameersbn/laboard:latest
```

You can pull a particular version of Laboard by specifying the version number. For example,

```bash
docker pull sameersbn/laboard:1.0.2
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/sameersbn/docker-laboard.git
cd docker-laboard
docker build --tag="$USER/laboard" .
```

# Quick Start

Before you can start the Laboard image you need to make sure you have a [GitLab](https://www.gitlab.com/) server running. Checkout the [docker-gitlab](https://github.com/sameersbn/docker-gitlab) project for getting a GitLab server up and running.

You need to provide the URL of the GitLab server while running Laboard using the `GITLAB_URL` environment configuration. For example if the location of the GitLab server is `172.17.0.2`. Additionally you also need to provide the GitLab API version via the `GITLAB_API_VERSION` option.

You also require a MySQL database. Please refer to [Database](#database) for instructions on provisioning a MySQL database provider. The following example assumes that you are using a [linked MySQL](#linking-to-mysql-container) container.

```bash
docker run --name=laboard -it --rm -p 10080:80 --link mysql:mysql \
-e 'GITLAB_URL=http://172.17.0.2' -e 'GITLAB_API_VERSION=7.2' \
  sameersbn/laboard:1.0.2
```

*add '-e NODE_TLS_REJECT_UNAUTHORIZED=0' if your GitLab server uses self-signed SSL certificates*

Alternately, if the GitLab and Laboard servers are running on the same host, you can take advantage of docker links. Lets consider that the GitLab server is running on the same host and has the name **gitlab**, then using docker links:

```bash
docker run --name=laboard -it --rm -p 10080:80 --link mysql:mysql \
-link gitlab:gitlab -e 'GITLAB_API_VERSION=7.2' \
sameersbn/laboard:1.0.2
```

Point your browser to `http://localhost:10080`.

You should now have Laboard ready for testing. If you want to use this image in production the please read on.

# Configuration

## Data Store

For storage of the application data, you should mount a volume at

* `/home/laboard/data`

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /opt/laboard/data
sudo chcon -Rt svirt_sandbox_file_t /opt/laboard/data
```

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
docker run --name=laboard -it --rm \
  -v /opt/laboard/data:/home/laboard/data \
  sameersbn/laboard:1.0.2
```

## Database

Laboard uses a database backend to store its data.

### MySQL

#### External MySQL Server

The image can be configured to use an external MySQL database. The database configuration should be specified using environment variables while starting the Laboard image.

Before you start the Laboard image create user and database for Laboard.

```sql
CREATE USER 'laboard'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `laboard_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `laboard_production`.* TO 'laboard'@'%.%.%.%';
CREATE TABLE `laboard_production`.`moves` (`namespace` varchar(255) DEFAULT NULL, `project` varchar(255) DEFAULT NULL, `issue` int(11) DEFAULT NULL,   `from` varchar(255) DEFAULT NULL,   `to` varchar(255) DEFAULT NULL, `date` datetime DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
FLUSH PRIVILEGES;
```

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run --name=laboard -it --rm \
  -e 'GITLAB_URL=http://172.17.0.2' \
  -e 'DB_HOST=192.168.1.100' -e 'DB_NAME=laboard_production' \
  -e 'DB_USER=laboard' -e 'DB_PASS=password' \
  sameersbn/laboard:1.0.2
```

#### Linking to MySQL Container

You can link this image with a mysql container for the database requirements. The alias of the mysql server container should be set to **mysql** while linking with the Laboard image.

If a mysql container is linked, only the `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a mysql container, we will use the [sameersbn/mysql](https://github.com/sameersbn/docker-mysql) image. When using docker-mysql in production you should mount a volume for the mysql data store. Please refer the [README](https://github.com/sameersbn/docker-mysql/blob/master/README.md) of docker-mysql for details.

First, lets pull the mysql image from the docker index.

```bash
docker pull sameersbn/mysql:latest
```

For data persistence lets create a store for the mysql and start the container.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /opt/mysql/data
sudo chcon -Rt svirt_sandbox_file_t /opt/mysql/data
```

The updated run command looks like this.

```bash
docker run --name mysql -d \
  -v /opt/mysql/data:/var/lib/mysql \
  sameersbn/mysql:latest
```

You should now have the mysql server running. By default the sameersbn/mysql image does not assign a password for the root user and allows remote connections for the root user from the `172.17.%.%` address space. This means you can login to the mysql server from the host as the root user.

Now, lets login to the mysql server and create a user and database for the GitLab application.

```bash
docker run -it --rm sameersbn/mysql:latest mysql -uroot -h$(docker inspect --format {{.NetworkSettings.IPAddress}} mysql)
```

```sql
CREATE USER 'laboard'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `laboard_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `laboard_production`.* TO 'laboard'@'%.%.%.%';
CREATE TABLE `laboard_production`.`moves` (`namespace` varchar(255) DEFAULT NULL, `project` varchar(255) DEFAULT NULL, `issue` int(11) DEFAULT NULL,   `from` varchar(255) DEFAULT NULL,   `to` varchar(255) DEFAULT NULL, `date` datetime DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
FLUSH PRIVILEGES;
```

We are now ready to start the Laboard application.

```bash
docker run --name=laboard -it --rm --link mysql:mysql \
  -e 'GITLAB_URL=http://172.17.0.2' -e 'GITLAB_API_VERSION=7.2' \
  -e 'DB_USER=laboard' -e 'DB_PASS=password' \
  -e 'DB_NAME=laboard_production' \
  sameersbn/laboard:1.0.2
```

### Putting it all together

```bash
docker run --name=laboard -d -\
  -v /opt/laboard/data:/home/laboard/data \
  -e 'GITLAB_URL=http://172.17.0.2' -e 'GITLAB_API_VERSION=7.2' \
  -e 'DB_HOST=192.168.1.100' -e 'DB_NAME=laboard_production' \
  -e 'DB_USER=laboard' -e 'DB_PASS=password' \
  sameersbn/laboard:1.0.2
```

### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command.*

Below is the complete list of available options that can be used to customize your Laboard installation.

- **GITLAB_URL**: Url of the GitLab server to allow connections from. No defaults. Automatically configured when a GitLab server is linked using docker links feature.
- **GITLAB_API_VERSION**: GitlLab API version, defaults to `7.2`.
- **DB_HOST**: The database server hostname. Defaults to `localhost`.
- **DB_PORT**: The database server port. Defaults to `3306`.
- **DB_NAME**: The database database name. Defaults to `laboard_production`
- **DB_USER**: The database database user. Defaults to `root`
- **DB_PASS**: The database database password. Defaults to no password
- **DB_POOL**: The database database connection pool count. Defaults to `10`.
- **CA_CERTIFICATES_PATH**: List of SSL certificates to trust. Defaults to `/home/laboard/data/certs/ca.crt`.
- **NODE_TLS_REJECT_UNAUTHORIZED**: Disable rejection of self-signed SSL certificates. Defaults to `1`. Set this option to `0` if your gitlab server uses self-signed SSL certificates.

# Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it laboard bash
```

If you are using an older version of docker, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install `nsenter` execute the following command on your host,

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter laboard
```

For more information refer https://github.com/jpetazzo/nsenter

# Upgrading

To upgrade to newer Laboard releases, simply follow this 3 step upgrade procedure.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/laboard:1.0.2
```

- **Step 2**: Stop and remove the currently running image

```bash
docker stop laboard
docker rm laboard
```

- **Step 3**: Start the image

```bash
docker run --name=laboard -d [OPTIONS] sameersbn/laboard:1.0.2
```

# References
  * https://gitlab.com/laboard/laboard
  * https://gitlab.com/laboard/laboard/blob/master/README.md
