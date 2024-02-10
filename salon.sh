#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

MAIN_MENU() {
if [[ $1 ]]
  then
  echo -e "$1"
  else
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"
  fi


  $PSQL "SELECT service_id, name FROM services" | while read SERVICE_ID TAB NAME
do
if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
then
echo "$SERVICE_ID) $NAME"
fi
done
read SERVICE_ID_SELECTED

if [[ -z $($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
then
MAIN_MENU "\nI could not find that service. What would you like today?"
else GET_INPUTS
fi
}

GET_INPUTS() {
SERVICE=$1

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE


if [[ -z $($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'") ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
$PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null 2>&1
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

echo -e "\nWhat time would you like your cut,$NAME?"
read SERVICE_TIME
$PSQL "INSERT INTO appointments(service_id, time, customer_id) VALUES($SERVICE_ID_SELECTED, '$SERVICE_TIME', $CUSTOMER_ID)" > /dev/null 2>&1

SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
TIME=$SERVICE_TIME

echo -e "\nI have put you down for a$SERVICE at $TIME,$NAME."
}


MAIN_MENU