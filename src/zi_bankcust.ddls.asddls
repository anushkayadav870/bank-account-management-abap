@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bank Customer'
define view entity ZI_BANKCUST as select from zbank_cust
{
  key customer_id,
      first_name,
      last_name,
      date_of_birth,
      phone,
      email,
      address
}
