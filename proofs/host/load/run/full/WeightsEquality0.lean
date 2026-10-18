import host.load.run.full.WeightsEqualityCore
set_option Elab.async false
set_option maxRecDepth 100000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.GlueLayers
theorem stage0_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage0 v = weights.stage0 v' := by
  unfold weights.stage0
  parameter_congr h

theorem stage1_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage1 v = weights.stage1 v' := by
  unfold weights.stage1
  parameter_congr h

theorem stage2_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage2 v = weights.stage2 v' := by
  unfold weights.stage2
  parameter_congr h

theorem stage3_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage3 v = weights.stage3 v' := by
  unfold weights.stage3
  parameter_congr h

theorem stage4_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage4 v = weights.stage4 v' := by
  unfold weights.stage4
  parameter_congr h

theorem stage5_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage5 v = weights.stage5 v' := by
  unfold weights.stage5
  parameter_congr h

theorem stage6_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage6 v = weights.stage6 v' := by
  unfold weights.stage6
  parameter_congr h

theorem stage7_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage7 v = weights.stage7 v' := by
  unfold weights.stage7
  parameter_congr h

theorem stage8_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage8 v = weights.stage8 v' := by
  unfold weights.stage8
  parameter_congr h

theorem stage9_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage9 v = weights.stage9 v' := by
  unfold weights.stage9
  parameter_congr h

theorem stage10_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage10 v = weights.stage10 v' := by
  unfold weights.stage10
  parameter_congr h

theorem stage11_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage11 v = weights.stage11 v' := by
  unfold weights.stage11
  parameter_congr h

theorem stage12_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage12 v = weights.stage12 v' := by
  unfold weights.stage12
  parameter_congr h

theorem stage13_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage13 v = weights.stage13 v' := by
  unfold weights.stage13
  parameter_congr h

theorem stage14_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage14 v = weights.stage14 v' := by
  unfold weights.stage14
  parameter_congr h

theorem stage15_values_eq (v v' : TensorValues)
    (h : ∀ t, covered code code.cert t = true → v t = v' t) :
    weights.stage15 v = weights.stage15 v' := by
  unfold weights.stage15
  parameter_congr h

end Host.Load.Run.Full
