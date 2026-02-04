USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script/"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
$MYSQL_HOST="mysql.nagababu.online"

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


dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disableing Nginx Module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enableing Nginx 1.24 Modules"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? " Installing Nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx  &>>$LOG_FILE

VALIDATE $? " Enableing and Starting Nginx" 

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removeing default html from nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the code"

cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unziping the code"

cp $SCRIPT_DIR/ginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Downloading the code"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restared Nginx "