datatype Entry = Entry(val: string, expiresAt: nat, cas: nat, lastUsed: nat)
datatype Status = STORED | NOT_STORED | DELETED | NOT_FOUND | EXISTS
datatype GetResult = Hit(val: string, cas: nat) | Miss

predicate IsAlive(e: Entry, now: nat)
{
  e.expiresAt == 0 || now < e.expiresAt
}

ghost function AbstractMap(store: map<string, Entry>, now: nat): map<string, string>
{
  map k | k in store && IsAlive(store[k], now) :: store[k].val
}