#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script/"
LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "Please login to root ruser" | tee -a $LOG_FILE
    exit 1
fi

mkdir= -p $LOG_FOLDER
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2....$R FAILD $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2....$G SUCESS $N" | tee -a $LOG_FILE
    fi
}


dnf module disable redis -y &>>LOG_FILE
dnf module enable redis:7 -y &>>LOG_FILE

VALIDATE $? "Enable redis:7"

dnf install redis -y &>>LOG_FILE
VALIDATE $? "Installed redis 7"

sed -i -c "s/127.0.0.1/0.0.0.0/g" -c "/protected-mode/c /protected-no" /etc/redis/redis.conf
VALIDATE $? "Allowing remote connection"
systemctl enable redis &>>LOG_FILE
VALIDATE $? "Enabled redis"

systemctl start redis &>>LOG_FILE 
VALIDATE $? "Started redis?