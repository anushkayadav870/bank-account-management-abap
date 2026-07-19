@EndUserText.label: 'Bank Customer'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_BANKCUST
  as projection on ZI_BANKCUST as Customer
{
  key customer_id,
      first_name,
      last_name,
      date_of_birth,
      phone,
      email,
      address,
      created_by,
      created_at,
      last_changed_by,
      last_changed_at,
      local_last_changed_at
}
