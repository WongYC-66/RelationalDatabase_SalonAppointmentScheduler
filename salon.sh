#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# echo $($PSQL "truncate appointments, customers")


echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  echo "$($PSQL "select * from services")" | while read service_id bar service_name
    do
      echo "$service_id) $service_name"
    done
 
  read SERVICE_ID_SELECTED  # read user input
  SERVICE_ID_SELECTED=$(echo $SERVICE_ID_SELECTED | sed -E "s/[‘|’|']//g")  # cleanse input data

  VERIFY_MENU
}
VERIFY_MENU(){

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] # if is not number
  then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
  else
    # check if found in services table
    SERVICE_NAME_RESULT="$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")"
    # if no service found  
    if [[ -z  $SERVICE_NAME_RESULT  ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      MAIN_MENU
    else
      #good input and service found
      REGISTER_CUSTOMER
    fi
  fi
}
REGISTER_CUSTOMER(){
  SERVICE_NAME_RESULT=$(echo $SERVICE_NAME_RESULT | sed -E 's/ //')  # trim off whitespace

  echo -e "\nWhat's your phone number?"
  
  read CUSTOMER_PHONE    # read user input
  CUSTOMER_PHONE=$(echo $CUSTOMER_PHONE | sed -E "s/[‘|’|']//g")  # cleanse input data

  # check if found in customer table
  CUSTOMER_ID="$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")"
  # if no customer found 
  if [[ -z  $CUSTOMER_ID  ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME   # read user input
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E "s/[‘|’|']//g")  # cleanse input data

    # Register NEW CUSTOMER 
    INSERT_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")"
    # get new customer id
    CUSTOMER_ID="$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")"
  else
    # get customer id
    CUSTOMER_NAME="$($PSQL "select name from customers where customer_id='$CUSTOMER_ID'")"
    # remove space
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/ //') 
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME_RESULT, $CUSTOMER_NAME?"
  read SERVICE_TIME  # read user input
  SERVICE_TIME=$(echo $SERVICE_TIME | sed -E "s/[‘|’|']//g")  # cleanse input data


  # insert into appoinment table
  INSERT_APPOINMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values($CUSTOMER_ID,(SELECT service_id from services where name='$SERVICE_NAME_RESULT'),'$SERVICE_TIME')")"
  echo -e "\nI have put you down for a $SERVICE_NAME_RESULT at $SERVICE_TIME, $CUSTOMER_NAME.\n"

}

MAIN_MENU


