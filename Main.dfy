include "Types.dfy"
include "Cache.dfy"

method Main()
{
  var cache := new Memcached(2, 0);
  assert cache.Valid();
  assert AbstractMap(cache.store, cache.currentTime) == map[];
  var st1 := cache.Set("session_1", "alice", 10);
  assert st1 == STORED;
  var res1 := cache.Get("session_1");
  assert res1 == Hit("alice", 1);
  cache.Tick(10);
  assert cache.currentTime == 10;
  var resExpired := cache.Get("session_1");
  assert resExpired == Miss;
  var st2 := cache.Set("counter", "100", 0);
  assert st2 == STORED;
  var res2 := cache.Get("counter");
  assert res2 == Hit("100", 2);
  var casOk := cache.Cas("counter", "101", 0, 2);
  assert casOk == STORED;
  var res3 := cache.Get("counter");
  assert res3 == Hit("101", 3);
  var casConflict := cache.Cas("counter", "999", 0, 2);
  assert casConflict == EXISTS;
  var st3 := cache.Set("config", "dark_mode", 0);
  assert st3 == STORED;
  var resConfig := cache.Get("config");
  assert resConfig == Hit("dark_mode", 4);
  var resEvicted := cache.Get("session_1");
  assert resEvicted == Miss;
}
