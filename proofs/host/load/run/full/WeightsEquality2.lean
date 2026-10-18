import host.load.run.full.WeightsEqualityCore
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
theorem stage32_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage32 v = weights.stage32 v' := by
  unfold weights.stage32
  parameter_congr h

theorem stage33_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage33 v = weights.stage33 v' := by
  unfold weights.stage33
  parameter_congr h

theorem stage34_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage34 v = weights.stage34 v' := by
  unfold weights.stage34
  parameter_congr h

theorem stage35_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage35 v = weights.stage35 v' := by
  unfold weights.stage35
  parameter_congr h

theorem stage36_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage36 v = weights.stage36 v' := by
  unfold weights.stage36
  parameter_congr h

theorem stage37_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage37 v = weights.stage37 v' := by
  unfold weights.stage37
  parameter_congr h

theorem stage38_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage38 v = weights.stage38 v' := by
  unfold weights.stage38
  parameter_congr h

theorem stage39_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage39 v = weights.stage39 v' := by
  unfold weights.stage39
  parameter_congr h

theorem stage40_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage40 v = weights.stage40 v' := by
  unfold weights.stage40
  parameter_congr h

theorem stage41_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage41 v = weights.stage41 v' := by
  unfold weights.stage41
  parameter_congr h

theorem stage42_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage42 v = weights.stage42 v' := by
  unfold weights.stage42
  parameter_congr h

theorem stage43_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage43 v = weights.stage43 v' := by
  unfold weights.stage43
  parameter_congr h

theorem stage44_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage44 v = weights.stage44 v' := by
  unfold weights.stage44
  parameter_congr h

theorem stage45_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage45 v = weights.stage45 v' := by
  unfold weights.stage45
  parameter_congr h

theorem stage46_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage46 v = weights.stage46 v' := by
  unfold weights.stage46
  parameter_congr h

theorem stage47_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage47 v = weights.stage47 v' := by
  unfold weights.stage47
  parameter_congr h

end Host.Load.Run.Full
