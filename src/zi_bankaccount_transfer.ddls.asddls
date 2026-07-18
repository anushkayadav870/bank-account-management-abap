@EndUserText.label: 'Transfer Parameters'
define abstract entity ZI_BANKACCOUNT_TRANSFER
{
  target_account_id : abap.char(10);
  amount             : abap.dec(15,2);
}
