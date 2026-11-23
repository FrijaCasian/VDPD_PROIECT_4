include "Types.dfy"

method FindLRUVictim(store: map<string, Entry>) returns (victim: string)
  requires |store| > 0
  ensures victim in store
{
  // Stub pentru Săptămâna 1; va fi înlocuit cu bucla LRU (minimul după lastUsed)
  victim :| victim in store.Keys;
}