#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER="roboshop"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 .. $R FAILED $N"
    else
        echo -e "$2 .. $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: provide root access to the script$N"
    exit 1 
fi

# disable default nodejs module
dnf module disable nodejs -y
VALIDATE $? "disable nodejs process"

# enable default nodejs 1.18 module
dnf module enable nodejs:18 -y
VALIDATE $? "enable nodejs 1.18 versioprocess"

# check nodejs installed already
yum list installed nodejs
if [ $? -eq 0 ]
then 
    echo -e "nodejs already installed so $Y SKIPPED $N"
    # exit 1
fi

# install nodejs
dnf install nodejs -y
VALIDATE $? "Install Nodejs process"

# add roboshop user but before check it 
id roboshop
if [ $? -ne 0 ]
then 
    useradd $USER
else   
    echo -e "User roboshop Already exist : $Y SKIPPED $N"
fi

# make directiory with the name of APP
mkdir -p /app

# Download application code
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

# change directory to app
cd /app 

# unzip code file
unzip -o /tmp/catalogue.zip

# change directory app
cd /app

# Install all dependencies
install npm
VALIDATE $? "Install dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy catelogue server to systemd file"

systemctl daemon-reload
VALIDATE $? "daemon-reload process"

systemctl enable catalogue
VALIDATE $? "enable catalogue process"

systemctl start catalogue
VALIDATE $? "start catalogue process"

cp /home/centos/project-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy mongorepo process"

# Install mongodb client
dnf install mongodb-org-shell -y
VALIDATE $? "mongodb clinet install"

# load scema 
mongo --host mongodb.royalreddy.co.in </app/schema/catalogue.js
VALIDATE $? "mongodb schema loaded"