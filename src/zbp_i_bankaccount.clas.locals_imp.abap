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
    DATA update_tab TYPE TABLE FOR UPDATE ZI_BANKACCOUNT.

    LOOP AT keys INTO DATA(key).
      APPEND VALUE #( %tky = key-%tky status = 'C' ) TO update_tab.
    ENDLOOP.

    MODIFY ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      UPDATE FIELDS ( status )
      WITH update_tab.

    READ ENTITIES OF ZI_BANKACCOUNT IN LOCAL MODE
      ENTITY Account
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(result_accounts).

    result = VALUE #( FOR acc IN result_accounts ( %tky = acc-%tky %param = acc ) ).
  ENDMETHOD.

ENDCLASS.
