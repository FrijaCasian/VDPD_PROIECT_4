include "Types.dfy"

method FindLRUVictim(store: map<string, Entry>) returns (victim: string)
  requires |store| > 0
  ensures victim in store
{
  victim :| victim in store.Keys;
}