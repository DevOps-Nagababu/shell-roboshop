USERID=$(id -u)
LOG_FOLDER="/var/log/shell_script/"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD

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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Added reabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enableing and Startign rabbitmq server"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Created user and given permissions"