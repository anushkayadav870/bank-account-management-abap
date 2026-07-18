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
      ( client = sy-mandt branch_id = 'BR001' branch_name = 'Mannheim Central'  city = 'Mannheim'  contact_phone = '0621-1234567' is_active = 'X' )
      ( client = sy-mandt branch_id = 'BR002' branch_name = 'Heidelberg Branch' city = 'Heidelberg' contact_phone = '06221-987654' is_active = 'X' )
      ( client = sy-mandt branch_id = 'BR003' branch_name = 'Frankfurt Branch'  city = 'Frankfurt'  contact_phone = '069-5551234'  is_active = '' )
    ) ).

    " 2. Account Types
    DELETE FROM zbank_accttype.
    INSERT zbank_accttype FROM TABLE @( VALUE #(
      ( client = sy-mandt account_type = 'SAV'  description = 'Savings Account' min_balance = '1000.00' interest_rate = '4.50' )
      ( client = sy-mandt account_type = 'CUR'  description = 'Current Account' min_balance = '0.00'    interest_rate = '0.00' )
    ) ).

    " 3. Customers
    DELETE FROM zbank_cust.
    INSERT zbank_cust FROM TABLE @( VALUE #(
      ( client = sy-mandt customer_id = 'CUST0001' first_name = 'Anushka' last_name = 'Yadav' date_of_birth = '19990101' phone = '9876543210' email = 'anushka@example.com' address = 'Mannheim, Germany' )
      ( client = sy-mandt customer_id = 'CUST0002' first_name = 'Rahul'   last_name = 'Sharma' date_of_birth = '19980512' phone = '9876500000' email = 'rahul@example.com'   address = 'Heidelberg, Germany' )
    ) ).

    " 4. Accounts
    DELETE FROM zbank_acct.
    INSERT zbank_acct FROM TABLE @( VALUE #(
      ( client = sy-mandt account_id = 'ACC000001' customer_id = 'CUST0001' account_type = 'SAV' branch_id = 'BR001' balance = '5000.00' status = 'A' open_date = cl_abap_context_info=>get_system_date( ) )
      ( client = sy-mandt account_id = 'ACC000002' customer_id = 'CUST0002' account_type = 'CUR' branch_id = 'BR002' balance = '2000.00' status = 'A' open_date = cl_abap_context_info=>get_system_date( ) )
    ) ).

   " 5. Sample Transactions
    DELETE FROM zbank_txn.
    INSERT zbank_txn FROM TABLE @( VALUE #(
      ( client = sy-mandt transaction_id = '0000000001' account_id = 'ACC000001' txn_type = 'DEPOSIT'  amount = '5000.00' txn_date = cl_abap_context_info=>get_system_date( ) txn_time = cl_abap_context_info=>get_system_time( ) )
      ( client = sy-mandt transaction_id = '0000000002' account_id = 'ACC000002' txn_type = 'DEPOSIT'  amount = '2000.00' txn_date = cl_abap_context_info=>get_system_date( ) txn_time = cl_abap_context_info=>get_system_time( ) )
    ) ).

    out->write( 'Demo data created successfully: 3 branches, 2 account types, 2 customers, 2 accounts, 2 transactions.' ).

  ENDMETHOD.

ENDCLASS.

