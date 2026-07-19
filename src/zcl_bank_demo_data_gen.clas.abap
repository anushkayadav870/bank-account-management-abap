CLASS zcl_bank_demo_data_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_bank_demo_data_gen IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. Branches
    DELETE FROM zbank_branch.
    INSERT zbank_branch FROM TABLE @( VALUE #(
      ( client = sy-mandt branch_id = 'BR001' branch_name = 'Mannheim Central'  city = 'Mannheim'   contact_phone = '0621-1234567' is_active = 'X' )
      ( client = sy-mandt branch_id = 'BR002' branch_name = 'Heidelberg Branch' city = 'Heidelberg' contact_phone = '06221-987654' is_active = 'X' )
      ( client = sy-mandt branch_id = 'BR003' branch_name = 'Frankfurt Branch'  city = 'Frankfurt'  contact_phone = '069-5551234'  is_active = '' )
    ) ).

    " 2. Account Types (with interest rates)
    DELETE FROM zbank_accttype.
    INSERT zbank_accttype FROM TABLE @( VALUE #(
      ( client = sy-mandt account_type = 'SAV'  description = 'Savings Account' min_balance = '1000.00' interest_rate = '4.50' )
      ( client = sy-mandt account_type = 'CUR'  description = 'Current Account' min_balance = '0.00'    interest_rate = '0.00' )
    ) ).

    " 3. Customers
    DELETE FROM zbank_cust.
    INSERT zbank_cust FROM TABLE @( VALUE #(
      ( client = sy-mandt customer_id = 'CUST0001' first_name = 'Anushka' last_name = 'Yadav'   date_of_birth = '19990101' phone = '9876543210' email = 'anushka@example.com' address = 'Mannheim, Germany' )
      ( client = sy-mandt customer_id = 'CUST0002' first_name = 'Rahul'   last_name = 'Sharma'  date_of_birth = '19980512' phone = '9876500000' email = 'rahul@example.com'   address = 'Heidelberg, Germany' )
      ( client = sy-mandt customer_id = 'CUST0003' first_name = 'Priya'   last_name = 'Nair'    date_of_birth = '20000823' phone = '9876511111' email = 'priya@example.com'   address = 'Mannheim, Germany' )
      ( client = sy-mandt customer_id = 'CUST0004' first_name = 'Marco'   last_name = 'Fischer' date_of_birth = '19951130' phone = '9876522222' email = 'marco@example.com'   address = 'Heidelberg, Germany' )
      ( client = sy-mandt customer_id = 'CUST0005' first_name = 'Lena'    last_name = 'Weber'   date_of_birth = '19970404' phone = '9876533333' email = 'lena@example.com'    address = 'Mannheim, Germany' )
      ( client = sy-mandt customer_id = 'CUST0006' first_name = 'Arjun'   last_name = 'Mehta'   date_of_birth = '19921215' phone = '9876544444' email = 'arjun@example.com'   address = 'Heidelberg, Germany' )
    ) ).

    " 4. Accounts
    DELETE FROM zbank_acct.
    INSERT zbank_acct FROM TABLE @( VALUE #(
      ( client = sy-mandt account_id = 'ACC000001' customer_id = 'CUST0001' account_type = 'SAV' branch_id = 'BR001' balance = '6225.00' status = 'A' open_date = '20260701' )
      ( client = sy-mandt account_id = 'ACC000002' customer_id = 'CUST0002' account_type = 'CUR' branch_id = 'BR002' balance = '4000.00' status = 'A' open_date = '20260702' )
      ( client = sy-mandt account_id = 'ACC000003' customer_id = 'CUST0003' account_type = 'SAV' branch_id = 'BR001' balance = '1200.00' status = 'A' open_date = '20260705' )
      ( client = sy-mandt account_id = 'ACC000004' customer_id = 'CUST0004' account_type = 'CUR' branch_id = 'BR002' balance = '500.00'  status = 'A' open_date = '20260708' )
      ( client = sy-mandt account_id = 'ACC000005' customer_id = 'CUST0005' account_type = 'SAV' branch_id = 'BR001' balance = '15000.00' status = 'A' open_date = '20260703' )
      ( client = sy-mandt account_id = 'ACC000006' customer_id = 'CUST0006' account_type = 'CUR' branch_id = 'BR002' balance = '2750.00'  status = 'A' open_date = '20260710' )
    ) ).

    " 5. Sample Transactions (transaction_id must stay purely numeric, zero-padded)
    DELETE FROM zbank_txn.
    INSERT zbank_txn FROM TABLE @( VALUE #(
      ( client = sy-mandt transaction_id = '0000000001' account_id = 'ACC000001' txn_type = 'DEPOSIT'  amount = '5000.00' txn_date = '20260701' txn_time = '090000' )
      ( client = sy-mandt transaction_id = '0000000002' account_id = 'ACC000001' txn_type = 'WITHDRAW' amount = '1000.00' txn_date = '20260705' txn_time = '113000' )
      ( client = sy-mandt transaction_id = '0000000003' account_id = 'ACC000001' txn_type = 'DEPOSIT'  amount = '2000.00' txn_date = '20260710' txn_time = '150000' )
      ( client = sy-mandt transaction_id = '0000000004' account_id = 'ACC000001' txn_type = 'DEPOSIT'  amount = '225.00'  txn_date = '20260717' txn_time = '083000' )

      ( client = sy-mandt transaction_id = '0000000005' account_id = 'ACC000002' txn_type = 'DEPOSIT'  amount = '2000.00' txn_date = '20260702' txn_time = '100000' )
      ( client = sy-mandt transaction_id = '0000000006' account_id = 'ACC000002' txn_type = 'DEPOSIT'  amount = '1500.00' txn_date = '20260706' txn_time = '134500' )
      ( client = sy-mandt transaction_id = '0000000007' account_id = 'ACC000002' txn_type = 'DEPOSIT'  amount = '500.00'  txn_date = '20260712' txn_time = '110000' )

      ( client = sy-mandt transaction_id = '0000000008' account_id = 'ACC000003' txn_type = 'DEPOSIT'  amount = '1200.00' txn_date = '20260705' txn_time = '091500' )

      ( client = sy-mandt transaction_id = '0000000009' account_id = 'ACC000004' txn_type = 'DEPOSIT'  amount = '800.00'  txn_date = '20260708' txn_time = '083000' )
      ( client = sy-mandt transaction_id = '0000000010' account_id = 'ACC000004' txn_type = 'WITHDRAW' amount = '300.00'  txn_date = '20260716' txn_time = '164500' )

      ( client = sy-mandt transaction_id = '0000000011' account_id = 'ACC000005' txn_type = 'DEPOSIT'  amount = '10000.00' txn_date = '20260703' txn_time = '093000' )
      ( client = sy-mandt transaction_id = '0000000012' account_id = 'ACC000005' txn_type = 'DEPOSIT'  amount = '5000.00'  txn_date = '20260709' txn_time = '121500' )

      ( client = sy-mandt transaction_id = '0000000013' account_id = 'ACC000006' txn_type = 'DEPOSIT'  amount = '3000.00' txn_date = '20260710' txn_time = '100000' )
      ( client = sy-mandt transaction_id = '0000000014' account_id = 'ACC000006' txn_type = 'WITHDRAW' amount = '250.00'  txn_date = '20260715' txn_time = '141500' )
    ) ).

    out->write( 'Demo data created successfully: 3 branches, 2 account types, 6 customers, 6 accounts, 14 transactions.' ).

  ENDMETHOD.

ENDCLASS.
