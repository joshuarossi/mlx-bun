import host.load.run.full.WeightsEqualityCore
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
theorem stage16_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage16 v = weights.stage16 v' := by
  unfold weights.stage16
  parameter_congr h

theorem stage17_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage17 v = weights.stage17 v' := by
  unfold weights.stage17
  parameter_congr h

theorem stage18_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage18 v = weights.stage18 v' := by
  unfold weights.stage18
  parameter_congr h

theorem stage19_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage19 v = weights.stage19 v' := by
  unfold weights.stage19
  parameter_congr h

theorem stage20_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage20 v = weights.stage20 v' := by
  unfold weights.stage20
  parameter_congr h

theorem stage21_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage21 v = weights.stage21 v' := by
  unfold weights.stage21
  parameter_congr h

theorem stage22_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage22 v = weights.stage22 v' := by
  unfold weights.stage22
  parameter_congr h

theorem stage23_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage23 v = weights.stage23 v' := by
  unfold weights.stage23
  parameter_congr h

theorem stage24_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage24 v = weights.stage24 v' := by
  unfold weights.stage24
  parameter_congr h

theorem stage25_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage25 v = weights.stage25 v' := by
  unfold weights.stage25
  parameter_congr h

theorem stage26_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage26 v = weights.stage26 v' := by
  unfold weights.stage26
  parameter_congr h

theorem stage27_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage27 v = weights.stage27 v' := by
  unfold weights.stage27
  parameter_congr h

theorem stage28_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage28 v = weights.stage28 v' := by
  unfold weights.stage28
  parameter_congr h

theorem stage29_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage29 v = weights.stage29 v' := by
  unfold weights.stage29
  parameter_congr h

theorem stage30_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage30 v = weights.stage30 v' := by
  unfold weights.stage30
  parameter_congr h

theorem stage31_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage31 v = weights.stage31 v' := by
  unfold weights.stage31
  parameter_congr h

end Host.Load.Run.Full
