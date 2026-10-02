#!/bin/bash

run_sql() {
  psql --username=freecodecamp --dbname=salon -X -q -t --no-align -c "$1"
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"
run_sql "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
read SERVICE_ID_SELECTED

while [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]] || [[ -z "$(run_sql "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")" ]]; do
  echo -e "\nI could not find that service. What would you like today?"
  run_sql "SELECT service_id || ') ' || name FROM services ORDER BY service_id"
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$(run_sql "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$(run_sql "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z "$CUSTOMER_ID" ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_ID=$(run_sql "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id")
else
  CUSTOMER_NAME=$(run_sql "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
run_sql "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."