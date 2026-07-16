@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bank Transaction'
define  view entity ZI_BANKTRANSACTION as select from zbank_txn

  association to parent ZI_BANKACCOUNT as _Account on $projection.account_id = _Account.account_id

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

      _Account
}
