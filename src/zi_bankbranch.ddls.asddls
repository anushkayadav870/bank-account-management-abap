@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bank Branch'
define view entity ZI_BANKBRANCH as select from zbank_branch
{
  key branch_id,
      branch_name,
      city,
      contact_phone,
      is_active
}
