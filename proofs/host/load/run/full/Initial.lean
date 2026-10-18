import host.load.run.full.Parameters
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Mlx Host.Mlx.GlueStep
set_option maxRecDepth 1000000
set_option Elab.async false

/-- The request policy left the source's 48 SSM and 16 ordinary KV caches
unallocated at offset zero. Paged/quantized cache classes are not assumed. -/
def initialCache : List Cache := (List.range 64).map fun i =>
  ⟨if i % 4 = 3 then chars!"KVCache" else chars!"SSMCache", 0, none, none⟩

theorem cache_initial : parameterChoice.cache = initialCache := by rfl

theorem cache_at_zero (i : Fin 64) :
    parameterChoice.cache[i.val]? = some
      ⟨if i.val % 4 = 3 then chars!"KVCache" else chars!"SSMCache", 0, none, none⟩ := by
  fin_cases i <;> rfl

def cacheHandle (value : TensorValues) (c : Cache) : Option Handles :=
  if c.operation = chars!"SSMCache" then some (.delta (c.first.map value) (c.second.map value))
  else if c.operation = chars!"KVCache" then some (.attention (c.first.map value) (c.second.map value))
  else none

def initialHandles : List Handles := (List.range 64).map fun i =>
  if i % 4 = 3 then .attention none none else .delta none none

theorem handles_initial (value : TensorValues) :
    parameterChoice.cache.mapM (cacheHandle value) = some initialHandles := by rfl

theorem cache_offsets_zero : parameterChoice.cache.map Cache.offset = List.replicate 64 0 := by rfl

end Host.Load.Run.Full
