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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disableing Node Modules"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enableing Nodejs : 20 Module"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "System useradded"
else
    echo -e "ROBOSHOP user alread exist ..$Y SKIPPING $N"
fi

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the backend code to app directory"

cd /app &>>$LOG_FILE
VALIDATE $? "Chanding the directory to app"

unzip -n /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unziping the user.zip code"

cp /home/ec2-user/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "Copied user.service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon restarting"

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enableing the User services"

systemctl start user &>>$LOG_FILE
VALIDATE $? "Starting the user"