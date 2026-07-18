@EndUserText.label: 'Account Statement Report'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_ACCOUNTSTATEMENT
  as select from ZI_BANKTRANSACTION as Transaction

  association [0..1] to ZI_BANKACCOUNT as _Account on Transaction.account_id = _Account.account_id

{
  key Transaction.transaction_id,
      Transaction.account_id,
      _Account.customer_id,
      _Account.account_type,
      _Account.branch_id,
      Transaction.txn_type,
      Transaction.amount,
      Transaction.txn_date,
      Transaction.txn_time,
      _Account

}
