#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# tilte
echo -e "\n~~~~~ MY SALON ~~~~~\n"
# welcome text
echo -e "Welcome to My Salon, how can I help you?\n"

# main menu function
MAIN_MENU () {
  # show status if exists
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  # show services
  GET_SERVICES_RES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$GET_SERVICES_RES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  
  # read service_id
  read SERVICE_ID_SELECTED
  # get service
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if service is not available
  if [[ -z $SELECTED_SERVICE ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  # if service is available
  else
    # ask phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # get name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if name is not found
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      
      # insert name to customers table
      INSERT_NAME_RES=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # ask for time
    echo -e "\nWhat time would you like your $(echo $SELECTED_SERVICE | sed -E 's/^ +| +$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')?"
    read SERVICE_TIME

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # set appointment
    SET_TIME_RES=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # return to main menu
    echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE | sed -E 's/^ +| +$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
  fi
}

MAIN_MENU 

