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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? " Disableing Nodejs Modules"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enableing Nodejs : 20 Modules"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Adding System User"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Making the Directory of APP"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading the code from git"

cd /app &>>$LOG_FILE
VALIDATE $? "Changing the directory to app"

unzip -n /tmp/cart.zip  &>>$LOG_FILE
VALIDATE $? "Unziping the code"

cd /app &>>$LOG_FILE
npm install  &>>$LOG_FILE
VALIDATE $? "Installing the Node modules"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? " Restarting the deamon"

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enabling the Cart Service"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting the Cart Service"


