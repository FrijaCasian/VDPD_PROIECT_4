include "Eviction.dfy"

class Memcached
{
  var capacity: nat
  var currentTime: nat
  var nextCas: nat
  var store: map<string, Entry>

  ghost function Model(): map<string, string>
    reads this
  {
    AbstractMap(store, currentTime)
  }

  ghost predicate Valid()
    reads this
  {
    capacity > 0 &&
    |store| <= capacity &&
    forall k :: k in store ==> store[k].cas < nextCas
  }

  constructor(cap: nat)
    requires cap > 0
    ensures Valid()
    ensures capacity == cap
    ensures currentTime == 0
    ensures Model() == map[]
  {
    capacity := cap;
    currentTime := 0;
    nextCas := 1;
    store := map[];
  }

  method Set(key: string, val: string, ttl: nat := 0) returns (status: Status)
    requires Valid()
    modifies this
    ensures Valid()
    ensures status == STORED
    ensures key in Model() && Model()[key] == val
    ensures (key in old(store) || |old(store)| < capacity) ==> Model() == old(Model())[key := val]
  {
    if key !in store && |store| == capacity {
      var victim := FindLRUVictim(store);
      store := store - {victim};
    }
    var exp: nat := if ttl == 0 then 0 else currentTime + ttl;
    store := store[key := Entry(val, exp, nextCas, currentTime)];
    nextCas := nextCas + 1;
    return STORED;
  }

  method Get(key: string) returns (res: GetResult)
    requires Valid()
    modifies this
    ensures Valid()
    ensures key in old(Model()) ==> res.Hit? && res.val == old(Model())[key]
    ensures key !in old(Model()) ==> res == Miss
    ensures Model() == old(Model())
  {
    if key !in store {
      return Miss;
    }
    var entry := store[key];
    if !IsAlive(entry, currentTime) {
      store := store - {key};
      return Miss;
    }
    store := store[key := entry.(lastUsed := currentTime)];
    return Hit(entry.val, entry.cas);
  }

  
}

method Main()
{
  var cache := new Memcached(2);

  var s1 := cache.Set("k1", "v1");
  assert s1 == STORED;

  var g1 := cache.Get("k1");
  assert g1.Hit? && g1.val == "v1";

  var d1 := cache.Delete("k1");
  assert d1 == DELETED;

  var g2 := cache.Get("k1");
  assert g2 == Miss;
}