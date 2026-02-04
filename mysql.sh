#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script/"
LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please login to root ruser $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2....$R FAILD $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2....$G SUCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? " Installing Mysql Server"

systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "Enabling Mysqld service"

systemctl start mysqld &>>LOG_FILE
VALIDATE $? "Starting the mysqld Service" 

mysql_secure_installation --set-root-pass RoboShop@1 &>>LOG_FILE
VALIDATE $? "Setting the root passpowrd"