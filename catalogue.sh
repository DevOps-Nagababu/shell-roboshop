#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script/"
LOG_FILE="$LOG_FOLDER/$0.log"
# SCRIPT_DIR=$$PWD
MONGODB_HOST=mongodb.nagababu.online

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e $R"Please login to root user and execute $G $0" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ....$R FAILED" | tee -a $LOG_FILE
        exit 1
    else    
        echo -e "$2....$G SUCCESS" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabled Nodejs Module"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enableing nodjs module"

dnf install nodejs -y $>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop $>>$LOG_FILE
    VALIDATE $? "System useradded"
else
    echo -e "ROBOSHOP user alread exist ..$Y SKIPPING"

mkdir -p /app $>>$LOG_FILE
VALIDATE $? "Making the app folder"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  $>>$LOG_FILE
VALIDATE $? "Downloading the code from git"


# cd /app $>>$LOG_FILE
# unzip /tmp/catalogue.zip $>>$LOG_FILE
# VALIDATE $? "Copying code to app direcotry"

# cd /app  $>>$LOG_FILE
# VALIDATE $? "Moving to app directory"

# rm -rf /app/*
# VALIDATE $? "Removing the default code from app directory"

# unzip /tmp/catalogue.zip &>>$LOG_FILE
# VALIDATE $? "Uzip catalogue code"

# npm install $>>$LOG_FILE
# VALIDATE $? "Installing node moudles"

# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
# VALIDATE $? "Created systemctl service"

# systemctl daemon-reload $>>$LOG_FILE
# VALIDATE $? "Restarting the deamon"

# systemctl enable catalogue $>>$LOG_FILE
# VALIDATE $? "Enableing the catalogue"

# systemctl start catalogue $>>$LOG_FILE
# VALIDATE $? "Starting the catalogue"

# cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
# dnf install mongodb-mongosh -y &>>$LOG_FILE

# INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

# if [ $INDEX -le 0 ]; then
#     mongosh --host $MONGODB_HOST </app/db/master-data.js
#     VALIDATE $? "Loading products"
# else
#     echo -e "Products already loaded ... $Y SKIPPING $N"
# fi

# systemctl restart catalogue
# VALIDATE $? "Restarting catalogue"

