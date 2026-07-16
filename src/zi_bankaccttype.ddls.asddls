@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bank Account Type'
define view entity ZI_BANKACCTTYPE as select from zbank_accttype
{
  key account_type,
      description,
      min_balance
}
