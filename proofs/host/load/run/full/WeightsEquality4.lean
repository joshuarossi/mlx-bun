import host.load.run.full.WeightsEqualityCore
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
theorem stage56_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage56 v = weights.stage56 v' := by
  unfold weights.stage56
  parameter_congr h

theorem stage57_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage57 v = weights.stage57 v' := by
  unfold weights.stage57
  parameter_congr h

theorem stage58_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage58 v = weights.stage58 v' := by
  unfold weights.stage58
  parameter_congr h

theorem stage59_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage59 v = weights.stage59 v' := by
  unfold weights.stage59
  parameter_congr h

theorem stage60_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage60 v = weights.stage60 v' := by
  unfold weights.stage60
  parameter_congr h

theorem stage61_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage61 v = weights.stage61 v' := by
  unfold weights.stage61
  parameter_congr h

theorem stage62_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage62 v = weights.stage62 v' := by
  unfold weights.stage62
  parameter_congr h

theorem stage63_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage63 v = weights.stage63 v' := by
  unfold weights.stage63
  parameter_congr h


end Host.Load.Run.Full
