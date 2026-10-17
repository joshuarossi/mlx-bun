import models.qwen.Attention
import models.qwen.AttentionHeadsDevice
import kernels.attention.SdpaLoads
import state.KvSources

namespace Inference.Models.Qwen.AttentionReadStorage
open Contracts.Mlx Kernels.Attention
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000

def fromCache (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    {cache : State.Kv.Cache BF n} {storage : State.KvAllocation.Storage cache}
    (heads : AttentionHeadsDevice.Execution layer.projections layer.preparation input angle)
    (updated : State.KvDevice.Execution storage (layer.heads input angle).key (layer.heads input angle).value) :
    SdpaLoads.Storage (layer.heads input angle).query (State.KvBytes.cacheAfter updated.toKvBytes).keys
      (State.KvBytes.cacheAfter updated.toKvBytes).values where
  query := heads.queryBuffer
  keys :=
    { bytes := updated.after.keys
      capacity := State.KvAllocation.capacity (n+1)
      room := (State.KvAllocation.capacity_bounds (n+1)).1
      attached := by
        intro head time i
        rw [State.KvBytes.cacheAfter_eq]
        exact updated.after.keysAttached head time i }
  values :=
    { bytes := updated.after.values
      capacity := State.KvAllocation.capacity (n+1)
      room := (State.KvAllocation.capacity_bounds (n+1)).1
      attached := by
        intro head time i
        rw [State.KvBytes.cacheAfter_eq]
        exact updated.after.valuesAttached head time i }

theorem key_bytes (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    {cache : State.Kv.Cache BF n} {storage : State.KvAllocation.Storage cache}
    (heads : AttentionHeadsDevice.Execution layer.projections layer.preparation input angle)
    (updated : State.KvDevice.Execution storage (layer.heads input angle).key (layer.heads input angle).value) :
    (fromCache layer input angle heads updated).keys.bytes=updated.toKvBytes.keys.memory := rfl

theorem value_bytes (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    {cache : State.Kv.Cache BF n} {storage : State.KvAllocation.Storage cache}
    (heads : AttentionHeadsDevice.Execution layer.projections layer.preparation input angle)
    (updated : State.KvDevice.Execution storage (layer.heads input angle).key (layer.heads input angle).value) :
    (fromCache layer input angle heads updated).values.bytes=updated.toKvBytes.values.memory := rfl

theorem query_bytes (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    {cache : State.Kv.Cache BF n} {storage : State.KvAllocation.Storage cache}
    (heads : AttentionHeadsDevice.Execution layer.projections layer.preparation input angle)
    (updated : State.KvDevice.Execution storage (layer.heads input angle).key (layer.heads input angle).value) (head : Fin 24) :
    ((fromCache layer input angle heads updated).query head).bytes=(heads.query head).rotation.memory := rfl

end Inference.Models.Qwen.AttentionReadStorage
