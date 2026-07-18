@EndUserText.label: 'Accounts Below Minimum Balance'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_LOWBALANCEACCOUNTS
  as select from ZI_BANKACCOUNT as Account

  association [0..1] to ZI_BANKACCTTYPE as _AcctType on Account.account_type = _AcctType.account_type

{
  key Account.account_id,
      Account.customer_id,
      Account.account_type,
      Account.branch_id,
      Account.balance,
      Account.status,
      Account.open_date,
      _AcctType.min_balance,
      _AcctType

}
where
  Account.balance < _AcctType.min_balance
