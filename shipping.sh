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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "System useradded"
else
    echo -e "ROBOSHOP user alread exist ..$Y SKIPPING $N"
fi

mkdir /app &>>$LOG_FILE
VALIDATE $? "Making app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading code"

cd /app &>>$LOG_FILE
VALIDATE $? "Changing the directory"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the code"

cd /app &>>$LOG_FILE
VALIDATE $? "Changing to app directory"

mvn clean package  &>>$LOG_FILE
VALIDATE $? "Maven clean"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "Renaming to Shipping.jar"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Restarting the Daemon"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enableing the shipping service"

systemctl start shipping  &>>$LOG_FILE
VALIDATE $? "Starting the shipping service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/schema.sql  &>>$LOG_FILE
VALIDATE $? "Mysql Schema creating"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
VALIDATE $? "Adding mysql app-user"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
VALIDATE $? "Loading master data to mysql"

systemctl restart shipping &>>$LOG_FILE
VALIDATE$? "Restarting the shipping service"