#!/bin/bash

# Database credentials
DB_USER="root"
DB_PASS="aryan2005"
DB_NAME="dbms"


clear
echo " ________              __________          __                 "
echo " \______ \   _______  _\______   \___.__._/  |_  ____   ______"
echo "  |    |  \_/ __ \  \/ /|    |  _<   |  |\   __\/ __ \ /  ___/"
echo "  |    \   \  ___/\   / |    |   \\\___  | |  | \  ___/ \___ \ "
echo " /_______  /\___  >\_/  |______  // ____| |__|  \___  >____  >"
echo "         \/     \/             \/ \/                \/     \/ "
sleep 2


whiptail --title "Welcome" --msgbox "Welcome to the General Billing Management System\n\nDeveloped by Team: DevBytes" 12 60

# Function to execute a custom SQL query
execute_query() {
    QUERY=$(whiptail --inputbox "Enter your SQL query" 10 60 3>&1 1>&2 2>&3)
    RESULT=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "$QUERY")
    whiptail --title "Query Result" --msgbox "$RESULT" 20 60
}

# Function to add a customer
add_customer() {
    NAME=$(whiptail --inputbox "Enter customer name:" 10 60 3>&1 1>&2 2>&3)
    PHONE=$(whiptail --inputbox "Enter customer phone:" 10 60 3>&1 1>&2 2>&3)
    ADDRESS=$(whiptail --inputbox "Enter customer address:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$NAME" ] && [ -n "$PHONE" ] && [ -n "$ADDRESS" ]; then
        mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "INSERT INTO customers (name, phone, address) VALUES ('$NAME', '$PHONE', '$ADDRESS');" 2>/tmp/mysql_error.log
        if [ $? -ne 0 ]; then
            whiptail --msgbox "Failed to insert customer. Check /tmp/mysql_error.log for details." 10 60
            return
        fi
        whiptail --msgbox "Customer added successfully!" 10 60
    else
        whiptail --msgbox "Please fill in all fields." 10 60
    fi
}

# Function to delete a customer
delete_customer() {
    CUSTOMER_ID=$(whiptail --inputbox "Enter customer ID to delete:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$CUSTOMER_ID" ]; then
        mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "DELETE FROM customers WHERE id = $CUSTOMER_ID;"
        whiptail --msgbox "Customer deleted successfully!" 10 60
    else
        whiptail --msgbox "Customer ID cannot be empty. Please enter a valid customer ID." 10 60
    fi
}

# Function to show customers details
show_customers() {
    CUSTOMERS=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT * FROM customers;")
    CUSTOMER_DETAILS+=$(echo "$CUSTOMERS" | awk -F'\t' '{printf "%-12s %-20s %-15s %-30s\n", $1, $2, $3, $4}')
    whiptail --title "Customers Details" --msgbox "$CUSTOMER_DETAILS" 20 120
    CUSTOMERS=""
    CUSTOMER_DETAILS=""
}

# Function to add a product
add_product() {
    NAME=$(whiptail --inputbox "Enter product name:" 10 60 3>&1 1>&2 2>&3)
    PRICE=$(whiptail --inputbox "Enter product price:" 10 60 3>&1 1>&2 2>&3)
    STOCK=$(whiptail --inputbox "Enter product stock quantity:" 10 60 3>&1 1>&2 2>&3)
    if [ -n "$NAME" ] && [ -n "$PRICE" ] && [ -n "$STOCK" ]; then
        mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "INSERT INTO products (name, price, stock) VALUES ('$NAME', $PRICE, $STOCK);" 2>/tmp/mysql_error.log
        if [ $? -ne 0 ]; then
            whiptail --msgbox "Failed to insert product. Check /tmp/mysql_error.log for details." 10 60
            return
        fi
        whiptail --msgbox "Product added successfully!" 10 60
    else
        whiptail --msgbox "Please fill in all fields." 10 60
    fi
}

# Function to show products
show_products() {
    PRODUCTS=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT * FROM products;")
    PRODUCT_DETAILS+=$(echo "$PRODUCTS" | awk -F'\t' '{printf "%-12s %-20s %-10s %-10s\n", $1, $2, $3, $4}')
    whiptail --title "Products List" --msgbox "$PRODUCT_DETAILS" 20 120
    PRODUCTS=""
    PRODUCT_DETAILS=""
}

update_product_stock() {
    PRODUCT_ID=$(whiptail --inputbox "Enter product ID to update stock:" 10 60 3>&1 1>&2 2>&3)
    if [ -z "$PRODUCT_ID" ]; then
        whiptail --msgbox "Product ID cannot be empty." 10 60
        return
    fi
    PRODUCT_INFO=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT name, stock FROM products WHERE id = $PRODUCT_ID;" -s -N)
    if [ -z "$PRODUCT_INFO" ]; then
        whiptail --msgbox "Invalid product ID." 10 60
        return
    fi
    PRODUCT_NAME=$(echo $PRODUCT_INFO | awk '{print $1}')
    CURRENT_STOCK=$(echo $PRODUCT_INFO | awk '{print $2}')
    NEW_STOCK=$(whiptail --inputbox "Current stock for $PRODUCT_NAME: $CURRENT_STOCK\nEnter new stock quantity:" 10 60 3>&1 1>&2 2>&3)
    if ! [[ "$NEW_STOCK" =~ ^[0-9]+$ ]]; then
        whiptail --msgbox "Stock must be a non-negative integer." 10 60
        return
    fi
    mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "UPDATE products SET stock = $NEW_STOCK WHERE id = $PRODUCT_ID;"
    whiptail --msgbox "Stock updated for $PRODUCT_NAME. New stock: $NEW_STOCK" 10 60
}

# Function to show bills
show_bills() {
    BILLS=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT * FROM bills;")
    BILL_DETAILS+=$(echo "$BILLS" | awk -F'\t' '{printf "%-8s %-12s %-12s %-10s\n", $1, $2, $3, $4}')
    whiptail --title "Bills List" --msgbox "$BILL_DETAILS" 20 80
    BILLS=""
    BILL_DETAILS=""
}

# Function to show tables
show_tables() {
    TABLES=("customers" ""
            "products" ""
            "bills" "")
    SELECTED_TABLE=$(whiptail --title "Select a table" --menu "Choose a table" 20 80 10 "${TABLES[@]}" 3>&1 1>&2 2>&3)
    if [ -n "$SELECTED_TABLE" ]; then
        TABLE_DATA=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT * FROM \`$SELECTED_TABLE\`;")
        if [ -n "$TABLE_DATA" ]; then
            whiptail --title "Table: $SELECTED_TABLE" --msgbox "$(echo "$TABLE_DATA" | sed 's/\t/ /g')" 20 120
        else
            whiptail --msgbox "No data available in the selected table." 10 60
        fi
    else
        whiptail --msgbox "No table selected." 10 60
    fi
}


# Function to search customer by name and select ID
search_customer() {
    NAME=$(whiptail --inputbox "Enter customer name to search:" 10 60 3>&1 1>&2 2>&3)
    if [ -z "$NAME" ]; then
        whiptail --msgbox "Name cannot be empty." 10 60
        return 1
    fi
    RESULT=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT id, name, phone FROM customers WHERE name LIKE '%$NAME%';" -s -N)
    if [ -z "$RESULT" ]; then
        whiptail --msgbox "No customer found with that name." 10 60
        return 1
    fi
    OPTIONS=()
    while read -r ID NAME PHONE; do
        OPTIONS+=("$ID" "$NAME ($PHONE)")
    done <<< "$RESULT"
    SELECTED_ID=$(whiptail --title "Select Customer" --menu "Matching customers:" 20 60 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
    if [ -z "$SELECTED_ID" ]; then
        whiptail --msgbox "No customer selected." 10 60
        return 1
    fi
    echo "$SELECTED_ID"
    return 0
}

# Modified generate_bill to allow searching customer by name
generate_bill() {
    CHOOSE_METHOD=$(whiptail --title "Customer Selection" --menu "How do you want to select the customer?" 15 60 2 \
        "1" "By Customer ID" \
        "2" "Search by Name" 3>&1 1>&2 2>&3)
    if [ "$CHOOSE_METHOD" = "2" ]; then
        CUSTOMER_ID=$(search_customer)
        [ $? -ne 0 ] && return
    else
        CUSTOMER_ID=$(whiptail --inputbox "Enter customer ID to generate bill:" 10 60 3>&1 1>&2 2>&3)
        if [ -z "$CUSTOMER_ID" ]; then
            whiptail --msgbox "Customer ID cannot be empty." 10 60
            return
        fi
    fi

    CUSTOMER_NAME=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT name FROM customers WHERE id=$CUSTOMER_ID;" -s -N)
    if [ -z "$CUSTOMER_NAME" ]; then
        whiptail --msgbox "Invalid customer ID." 10 60
        return
    fi

    BILL_ITEMS=""
    TOTAL=0
    BILL_ITEMS_SQL=""
    declare -A STOCK_UPDATES

    while true; do
        PRODUCT_ID=$(whiptail --inputbox "Enter product ID to add to bill (leave empty to finish):" 10 60 3>&1 1>&2 2>&3)
        if [ -z "$PRODUCT_ID" ]; then
            break
        fi
        QUANTITY=$(whiptail --inputbox "Enter quantity for product ID $PRODUCT_ID:" 10 60 3>&1 1>&2 2>&3)
        if ! [[ "$QUANTITY" =~ ^[1-9][0-9]*$ ]]; then
            whiptail --msgbox "Quantity must be a positive integer." 10 60
            continue
        fi
        PRODUCT_INFO=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT name, price, stock FROM products WHERE id = $PRODUCT_ID;" -s -N)
        if [ -z "$PRODUCT_INFO" ]; then
            whiptail --msgbox "Invalid product ID." 10 60
            continue
        fi
        PRODUCT_NAME=$(echo $PRODUCT_INFO | awk '{print $1}')
        PRODUCT_PRICE=$(echo $PRODUCT_INFO | awk '{print $2}')
        PRODUCT_STOCK=$(echo $PRODUCT_INFO | awk '{print $3}')
        if [ "$QUANTITY" -gt "$PRODUCT_STOCK" ]; then
            whiptail --msgbox "Not enough stock for $PRODUCT_NAME. Available: $PRODUCT_STOCK" 10 60
            continue
        fi
        ITEM_TOTAL=$(echo "$PRODUCT_PRICE * $QUANTITY" | bc)
        TOTAL=$(echo "$TOTAL + $ITEM_TOTAL" | bc)
        BILL_ITEMS+="$PRODUCT_NAME x $QUANTITY = $ITEM_TOTAL\n"
        BILL_ITEMS_SQL+="INSERT INTO bill_items (bill_id, product_id, quantity, price) VALUES (BILL_ID, $PRODUCT_ID, $QUANTITY, $PRODUCT_PRICE);"
        STOCK_UPDATES["$PRODUCT_ID"]=$QUANTITY
    done

    if [ -z "$BILL_ITEMS" ]; then
        whiptail --msgbox "No items added to bill." 10 60
        return
    fi

    DATE=$(date +"%Y-%m-%d")
    mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "INSERT INTO bills (customer_id, date, total) VALUES ($CUSTOMER_ID, '$DATE', $TOTAL);"
    BILL_ID=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT MAX(id) FROM bills;" -s -N)

    # Insert bill items and update stock only now
    BILL_ITEMS_SQL="${BILL_ITEMS_SQL//BILL_ID/$BILL_ID}"
    echo "$BILL_ITEMS_SQL" | mysql -u $DB_USER -p$DB_PASS -D $DB_NAME

    for PID in "${!STOCK_UPDATES[@]}"; do
        QTY=${STOCK_UPDATES[$PID]}
        mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "UPDATE products SET stock = stock - $QTY WHERE id = $PID;"
    done

    whiptail --title "Bill Generated" --msgbox "Bill ID: $BILL_ID\nCustomer: $CUSTOMER_NAME\n$BILL_ITEMS\nTotal: $TOTAL" 20 80
}

# Show bills with customer names
show_bills() {
    BILLS=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT b.id, c.name, b.date, b.total FROM bills b JOIN customers c ON b.customer_id = c.id;")
    BILL_DETAILS+=$(echo "$BILLS" | awk -F'\t' '{printf "%-8s %-20s %-12s %-10s\n", $1, $2, $3, $4}')
    whiptail --title "Bills List" --msgbox "$BILL_DETAILS" 20 100
    BILLS=""
    BILL_DETAILS=""
}

# Show bill details (items) for a selected bill
show_bill_details() {
    BILL_ID=$(whiptail --inputbox "Enter Bill ID to view details:" 10 60 3>&1 1>&2 2>&3)
    if [ -z "$BILL_ID" ]; then
        whiptail --msgbox "Bill ID cannot be empty." 10 60
        return
    fi
    BILL_INFO=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT b.id, c.name, b.date, b.total FROM bills b JOIN customers c ON b.customer_id = c.id WHERE b.id = $BILL_ID;" -s -N)
    if [ -z "$BILL_INFO" ]; then
        whiptail --msgbox "No such bill." 10 60
        return
    fi
    # Format bill info
    BILL_INFO_FORMATTED=$(echo "$BILL_INFO" | awk -F'\t' '{printf "Bill ID: %s\nCustomer: %s\nDate: %s\nTotal: %s\n", $1, $2, $3, $4}')
    # Get and format bill items
    BILL_ITEMS=$(mysql -u $DB_USER -p$DB_PASS -D $DB_NAME -e "SELECT p.name, bi.quantity, bi.price FROM bill_items bi JOIN products p ON bi.product_id = p.id WHERE bi.bill_id = $BILL_ID;" -s -N)
    if [ -z "$BILL_ITEMS" ]; then
        BILL_ITEMS_FORMATTED="No items found for this bill."
    else
        BILL_ITEMS_FORMATTED=$'Product\tQuantity\tPrice\n'
        while IFS=$'\t' read -r NAME QTY PRICE; do
            BILL_ITEMS_FORMATTED+=$(printf "%-20s %-10s %-10s\n" "$NAME" "$QTY" "$PRICE")
        done <<< "$BILL_ITEMS"
    fi
    whiptail --title "Bill Details" --msgbox "$BILL_INFO_FORMATTED\n\nItems:\n$BILL_ITEMS_FORMATTED" 20 100
}

# Main menu loop
while true; do
    CHOICE=$(whiptail --title "General Billing Management System" --menu "Choose an option" 20 60 12 \
    "1" "Add Customer" \
    "2" "Delete Customer" \
    "3" "Show Customers" \
    "4" "Add Product" \
    "5" "Update Product Stock" \
    "6" "Show Products" \
    "7" "Generate Bill" \
    "8" "Show Bills" \
    "9" "View Tables" \
    "10" "Execute Custom Query" \
    "11" "Show Bill Details" \
    "12" "Search Customer by Name" \
    "13" "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) add_customer ;;
        2) delete_customer ;;
        3) show_customers ;;
        4) add_product ;;
        5) update_product_stock ;;
        6) show_products ;;
        7) generate_bill ;;
        8) show_bills ;;
        9) show_tables ;;
        10) execute_query ;;
        11) show_bill_details ;;
        12) search_customer ;;
        13) exit ;;
        *) whiptail --msgbox "Invalid option, please try again." 10 60 ;;
    esac
done