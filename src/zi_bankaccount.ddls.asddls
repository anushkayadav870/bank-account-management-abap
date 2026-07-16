@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bank Account'
define root view entity ZI_BANKACCOUNT as select from zbank_acct

  composition [0..*] of ZI_BANKTRANSACTION as _Transaction

  association [0..1] to ZI_BANKCUST     as _Customer   on $projection.customer_id = _Customer.customer_id
  association [0..1] to ZI_BANKACCTTYPE as _AcctType   on $projection.account_type = _AcctType.account_type
  association [0..1] to ZI_BANKBRANCH   as _Branch     on $projection.branch_id = _Branch.branch_id

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

      // associations exposed for navigation/value help
      _Transaction,
      _Customer,
      _AcctType,
      _Branch
}
