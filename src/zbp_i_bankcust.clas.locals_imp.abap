CLASS lhc_Customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Customer RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Customer.

ENDCLASS.

CLASS lhc_Customer IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lv_next_id) = 1.

    SELECT SINGLE MAX( customer_id ) FROM zbank_cust INTO @DATA(lv_max_id).
    IF lv_max_id IS NOT INITIAL.
      lv_next_id = lv_max_id+4(4) + 1.
    ENDIF.

    LOOP AT entities INTO DATA(entity).
      APPEND VALUE #(
        %cid        = entity-%cid
        %is_draft   = entity-%is_draft
        customer_id = |CUST{ lv_next_id WIDTH = 4 ALIGN = RIGHT PAD = '0' }|
      ) TO mapped-customer.
      lv_next_id = lv_next_id + 1.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
