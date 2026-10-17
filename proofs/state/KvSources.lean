import state.KvDevice

namespace Inference.State.KvSources
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000

-- Construct the same allocation/append execution from the producer's byte
-- source, retaining its base and strides instead of encoding logical values.
def append (old : History n) (before : HalfMemory.Bytes) (next : Row) (source : KvCopy.Source next) :
    KvDevice.AppendExecution old before next :=
  let growth := fun (_ : KvAllocation.capacity n<n+1) => KvDevice.GrowthTrace.canonical (KvAllocation.capacity n) before
  let preserve : KvDevice.Preserve (KvDevice.prepared n before growth) (KvAllocation.capacity (n+1)*256) := .donated
  ⟨source, growth, preserve,
    KvCopy.canonicalCopy source 0 (KvAllocation.capacity (n+1)) n preserve.memory (by decide)
      (Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1), rfl⟩

def fromSources {cache : Kv.Cache BF n} (storage : KvAllocation.Storage cache) (key value : Row)
    (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) : KvDevice.Execution storage key value :=
  ⟨append cache.keys storage.keys key keySource, append cache.values storage.values value valueSource⟩

theorem key_source {cache : Kv.Cache BF n} (storage : KvAllocation.Storage cache) (key value : Row)
    (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) :
    (fromSources storage key value keySource valueSource).keys.source=keySource := rfl

theorem value_source {cache : Kv.Cache BF n} (storage : KvAllocation.Storage cache) (key value : Row)
    (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) :
    (fromSources storage key value keySource valueSource).values.source=valueSource := rfl

theorem cache_eq {cache : Kv.Cache BF n} (storage : KvAllocation.Storage cache) (key value : Row)
    (keySource : KvCopy.Source key) (valueSource : KvCopy.Source value) :
    KvBytes.cacheAfter (fromSources storage key value keySource valueSource).toKvBytes=Kv.append cache key value :=
  KvDevice.Execution.cache_eq _

end Inference.State.KvSources
