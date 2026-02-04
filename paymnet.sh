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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "System useradded"
else
    echo -e "ROBOSHOP user alread exist ..$Y SKIPPING $N"
fi

dnf install python3 gcc python3-devel -y  &>>$LOG_FILE
VALIDATE $? "Installing Python3"

mkdir /app &>>$LOG_FILE
VALIDATE $? "Making app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downlaoding the code"

cd /app &>>$LOG_FILE
unzip -n /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the code"

cd /app &>>$LOG_FILE
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing pip3"


cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Restarting the daemon"

systemctl enable payment &>>$LOG_FILE
systemctl start payment &>>$LOG_FILE
VALIDATE $? "Enableing the startting the payment service"