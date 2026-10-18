import host.load.run.full.WeightsEqualityCore
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
theorem stage48_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage48 v = weights.stage48 v' := by
  unfold weights.stage48
  parameter_congr h

theorem stage49_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage49 v = weights.stage49 v' := by
  unfold weights.stage49
  parameter_congr h

theorem stage50_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage50 v = weights.stage50 v' := by
  unfold weights.stage50
  parameter_congr h

theorem stage51_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage51 v = weights.stage51 v' := by
  unfold weights.stage51
  parameter_congr h

theorem stage52_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage52 v = weights.stage52 v' := by
  unfold weights.stage52
  parameter_congr h

theorem stage53_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage53 v = weights.stage53 v' := by
  unfold weights.stage53
  parameter_congr h

theorem stage54_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage54 v = weights.stage54 v' := by
  unfold weights.stage54
  parameter_congr h

theorem stage55_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage55 v = weights.stage55 v' := by
  unfold weights.stage55
  parameter_congr h

end Host.Load.Run.Full
