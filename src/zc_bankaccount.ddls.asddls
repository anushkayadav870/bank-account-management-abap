@EndUserText.label: 'Bank Account'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_BANKACCOUNT
  as projection on ZI_BANKACCOUNT as Account
{
  key account_id,
      customer_id,
      account_type,
      branch_id,
      balance,
      status,
      open_date,
      created_by,
      created_at,
      last_changed_by,
      last_changed_at,
      local_last_changed_at,

      _Transaction : redirected to composition child ZC_BANKTRANSACTION
}
