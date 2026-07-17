@EndUserText.label: 'Bank Transaction'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_BANKTRANSACTION
  as projection on ZI_BANKTRANSACTION as Transaction
{
  key transaction_id,
      account_id,
      txn_type,
      amount,
      txn_date,
      txn_time,
      created_by,
      created_at,
      last_changed_by,
      last_changed_at,
      local_last_changed_at,

      _Account : redirected to parent ZC_BANKACCOUNT
}
