CLASS lhc_transaction DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS recalcBalance FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Transaction~recalcBalance.

    METHODS checkPositiveAmount FOR VALIDATE ON SAVE
      IMPORTING keys FOR Transaction~checkPositiveAmount.

ENDCLASS.

CLASS lhc_transaction IMPLEMENTATION.

  METHOD recalcBalance.
    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Transaction
      FIELDS ( txn_type amount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(transactions).

    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Transaction BY \_Account
      FIELDS ( account_id balance )
      WITH CORRESPONDING #( keys )
      RESULT DATA(accounts)
      LINK DATA(links).

    DATA account_update TYPE TABLE FOR UPDATE ZI_BANKACCOUNT.

    LOOP AT keys INTO DATA(key).
      READ TABLE transactions INTO DATA(txn) WITH KEY %tky = key-%tky.
      READ TABLE links INTO DATA(link) WITH KEY source-%tky = key-%tky.
      IF sy-subrc = 0.
        READ TABLE accounts INTO DATA(account) WITH KEY %tky = link-target-%tky.
        IF sy-subrc = 0.
          DATA(lv_delta) = COND #( WHEN txn-txn_type = 'DEPOSIT' THEN txn-amount ELSE txn-amount * -1 ).
          APPEND VALUE #( %tky = account-%tky balance = account-balance + lv_delta ) TO account_update.
        ENDIF.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      UPDATE FIELDS ( balance )
      WITH account_update.
  ENDMETHOD.

  METHOD checkPositiveAmount.
    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Transaction
      FIELDS ( amount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(transactions).

    LOOP AT transactions INTO DATA(txn).
      IF txn-amount <= 0.
        APPEND VALUE #( %tky = txn-%tky ) TO failed-transaction.
        APPEND VALUE #( %tky = txn-%tky
                         %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Transaction amount must be greater than zero' )
        ) TO reported-transaction.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Account DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Account RESULT result.

    METHODS closeAccount FOR MODIFY
      IMPORTING keys FOR ACTION Account~closeAccount RESULT result.

    METHODS deposit FOR MODIFY
      IMPORTING keys FOR ACTION Account~deposit RESULT result.

    METHODS withdraw FOR MODIFY
      IMPORTING keys FOR ACTION Account~withdraw RESULT result.
    METHODS setAccountDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Account~setAccountDefaults.

    METHODS checkActiveBranch FOR VALIDATE ON SAVE
      IMPORTING keys FOR Account~checkActiveBranch.

    METHODS checkMinBalance FOR VALIDATE ON SAVE
      IMPORTING keys FOR Account~checkMinBalance.
    METHODS transfer FOR MODIFY
      IMPORTING keys FOR ACTION Account~transfer RESULT result.

ENDCLASS.

CLASS lhc_Account IMPLEMENTATION.

  METHOD get_global_authorizations.
    " left empty on purpose - no restrictions for this project
  ENDMETHOD.

  METHOD deposit.
    DATA txn_create TYPE TABLE FOR CREATE ZI_BANKACCOUNT\_Transaction.
    DATA(lv_next_id) = 1.

    SELECT SINGLE MAX( transaction_id ) FROM zbank_txn INTO @DATA(lv_max_id).
    IF lv_max_id IS NOT INITIAL.
      lv_next_id = lv_max_id + 1.
    ENDIF.

    LOOP AT keys INTO DATA(key).
      APPEND VALUE #(
        %tky    = key-%tky
        %target = VALUE #( (
          %cid        = 'DEP1'
          transaction_id = |{ lv_next_id WIDTH = 10 ALIGN = RIGHT PAD = '0' }|
          txn_type    = 'DEPOSIT'
          amount      = key-%param-amount
          txn_date    = cl_abap_context_info=>get_system_date( )
          txn_time    = cl_abap_context_info=>get_system_time( )
        ) )
      ) TO txn_create.
      lv_next_id = lv_next_id + 1.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
        CREATE BY \_Transaction
        FIELDS ( transaction_id txn_type amount txn_date txn_time )
        WITH txn_create.

    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_accounts).

    result = VALUE #( FOR acc IN result_accounts ( %tky = acc-%tky %param = acc ) ).
  ENDMETHOD.

  METHOD withdraw.
    DATA txn_create TYPE TABLE FOR CREATE ZI_BANKACCOUNT\_Transaction.
    DATA(lv_next_id) = 1.

    SELECT SINGLE MAX( transaction_id ) FROM zbank_txn INTO @DATA(lv_max_id).
    IF lv_max_id IS NOT INITIAL.
      lv_next_id = lv_max_id + 1.
    ENDIF.

    LOOP AT keys INTO DATA(key).
      APPEND VALUE #(
        %tky    = key-%tky
        %target = VALUE #( (
          %cid        = 'WDR1'
          transaction_id = |{ lv_next_id WIDTH = 10 ALIGN = RIGHT PAD = '0' }|
          txn_type    = 'WITHDRAW'
          amount      = key-%param-amount
          txn_date    = cl_abap_context_info=>get_system_date( )
          txn_time    = cl_abap_context_info=>get_system_time( )
        ) )
      ) TO txn_create.
      lv_next_id = lv_next_id + 1.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
        CREATE BY \_Transaction
        FIELDS ( transaction_id txn_type amount txn_date txn_time )
        WITH txn_create.

    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_accounts).

    result = VALUE #( FOR acc IN result_accounts ( %tky = acc-%tky %param = acc ) ).
  ENDMETHOD.

  METHOD closeAccount.
    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      FIELDS ( balance )
      WITH CORRESPONDING #( keys )
      RESULT DATA(accounts).

    DATA update_tab TYPE TABLE FOR UPDATE ZI_BANKACCOUNT.

    LOOP AT keys INTO DATA(key).
      READ TABLE accounts INTO DATA(account) WITH KEY %tky = key-%tky.
      IF sy-subrc = 0 AND account-balance <> 0.
        APPEND VALUE #( %tky = key-%tky ) TO failed-account.
        APPEND VALUE #( %tky = key-%tky
                         %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Account balance must be zero before closing' )
        ) TO reported-account.
      ELSE.
        APPEND VALUE #( %tky = key-%tky status = 'C' ) TO update_tab.
      ENDIF.
    ENDLOOP.

    IF update_tab IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
        ENTITY Account
        UPDATE FIELDS ( status )
        WITH update_tab.
    ENDIF.

    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_accounts).

    result = VALUE #( FOR acc IN result_accounts ( %tky = acc-%tky %param = acc ) ).
  ENDMETHOD.

  METHOD setAccountDefaults.
    DATA update_tab TYPE TABLE FOR UPDATE ZI_BANKACCOUNT.

    LOOP AT keys INTO DATA(key).
      APPEND VALUE #(
        %tky      = key-%tky
        balance   = 0
        status    = 'A'
        open_date = cl_abap_context_info=>get_system_date( )
      ) TO update_tab.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      UPDATE FIELDS ( balance status open_date )
      WITH update_tab.
  ENDMETHOD.

  METHOD checkActiveBranch.
    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      FIELDS ( branch_id )
      WITH CORRESPONDING #( keys )
      RESULT DATA(accounts).

    LOOP AT accounts INTO DATA(account).
      IF account-branch_id IS NOT INITIAL.
        SELECT SINGLE is_active FROM zbank_branch
          WHERE branch_id = @account-branch_id
          INTO @DATA(lv_active).
        IF sy-subrc = 0 AND lv_active <> 'X'.
          APPEND VALUE #( %tky = account-%tky ) TO failed-account.
          APPEND VALUE #( %tky = account-%tky
                           %msg = new_message_with_text(
                                    severity = if_abap_behv_message=>severity-error
                                    text     = 'Account cannot be active at an inactive branch' )
          ) TO reported-account.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkMinBalance.
    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      FIELDS ( balance account_type )
      WITH CORRESPONDING #( keys )
      RESULT DATA(accounts).

    LOOP AT accounts INTO DATA(account).
      SELECT SINGLE min_balance FROM zbank_accttype
        WHERE account_type = @account-account_type
        INTO @DATA(lv_min_balance).
      IF sy-subrc = 0 AND account-balance < lv_min_balance.
        APPEND VALUE #( %tky = account-%tky ) TO failed-account.
        APPEND VALUE #( %tky = account-%tky
                         %msg = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Balance cannot go below the minimum balance for this account type' )
        ) TO reported-account.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

 METHOD transfer.
    DATA txn_create_source TYPE TABLE FOR CREATE ZI_BANKACCOUNT\_Transaction.
    DATA txn_create_target TYPE TABLE FOR CREATE ZI_BANKACCOUNT\_Transaction.
    DATA(lv_next_id) = 1.

    SELECT SINGLE MAX( transaction_id ) FROM zbank_txn INTO @DATA(lv_max_id).
    IF lv_max_id IS NOT INITIAL.
      lv_next_id = lv_max_id + 1.
    ENDIF.

    LOOP AT keys INTO DATA(key).
      " Withdraw from the source account (the one the action was called on)
      APPEND VALUE #(
        %tky    = key-%tky
        %target = VALUE #( (
          %cid        = 'TRW1'
          transaction_id = |{ lv_next_id WIDTH = 10 ALIGN = RIGHT PAD = '0' }|
          txn_type    = 'WITHDRAW'
          amount      = key-%param-amount
          txn_date    = cl_abap_context_info=>get_system_date( )
          txn_time    = cl_abap_context_info=>get_system_time( )
        ) )
      ) TO txn_create_source.
      lv_next_id = lv_next_id + 1.

      " Deposit into the target account
      APPEND VALUE #(
        %tky    = VALUE #( account_id = key-%param-target_account_id )
        %target = VALUE #( (
          %cid        = 'TRD1'
          transaction_id = |{ lv_next_id WIDTH = 10 ALIGN = RIGHT PAD = '0' }|
          txn_type    = 'DEPOSIT'
          amount      = key-%param-amount
          txn_date    = cl_abap_context_info=>get_system_date( )
          txn_time    = cl_abap_context_info=>get_system_time( )
        ) )
      ) TO txn_create_target.
      lv_next_id = lv_next_id + 1.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
        CREATE BY \_Transaction
        FIELDS ( transaction_id txn_type amount txn_date txn_time )
        WITH txn_create_source.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
        CREATE BY \_Transaction
        FIELDS ( transaction_id txn_type amount txn_date txn_time )
        WITH txn_create_target.

    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_accounts).

    result = VALUE #( FOR acc IN result_accounts ( %tky = acc-%tky %param = acc ) ).
  ENDMETHOD.

ENDCLASS.

