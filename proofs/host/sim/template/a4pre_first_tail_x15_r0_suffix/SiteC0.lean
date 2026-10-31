import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen
import host.sim.stage.Mlx
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 0 of chain `PRE_first_tail_x15_r0_suffix` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_suffix.s4` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_suffix.kappa0` into the merged state
`PRE_first_tail_x15_r0_suffix.s3`. -/

def PRE_first_tail_x15_r0_suffix.pl0 : List Nat := []
def PRE_first_tail_x15_r0_suffix.nr0 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_suffix.kd0 : RData :=
  ⟨2825030, 2828013, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21966, 21967, 19057, 19057, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_suffix.kappa0 : Map :=
  Conv.Map.compact 2825030 2828013 8226 PRE_first_tail_x15_r0_suffix.pl0 (PRE_first_tail_x15_r0_suffix.nr0.map NumV.ref) PRE_first_tail_x15_r0_suffix.kd0.big
    PRE_first_tail_x15_r0_suffix.kd0.region PRE_first_tail_x15_r0_suffix.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_suffix.cws0 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_suffix.crs0 : List SymE := PRE_first_tail_x15_r0_suffix.nr0.map fun r => (nth? PRE_first_tail_x15_r0_suffix.S3.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_suffix.ctheta0 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_suffix.cws0 PRE_first_tail_x15_r0_suffix.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_suffix.wrB0 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_suffix.ctab0 : PRE_first_tail_x15_r0_suffix.S4.tab = PRE_first_tail_x15_r0_suffix.S2.tab ++ PRE_first_tail_x15_r0_suffix.cws0.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_suffix.ctrace0 : PRE_first_tail_x15_r0_suffix.s4.trace = PRE_first_tail_x15_r0_suffix.s2.trace
kernel_rfl PRE_first_tail_x15_r0_suffix.cnext0 : PRE_first_tail_x15_r0_suffix.s4.next = 2825030
kernel_rfl PRE_first_tail_x15_r0_suffix.ccounters0 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.nnext) = (21966, 19057)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_suffix.cqueue0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s3.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.tokens.map PRE_first_tail_x15_r0_suffix.kappa0.nv
kernel_rfl PRE_first_tail_x15_r0_suffix.ctokSupp0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.tokens.all (bSN 8226) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_suffix.cclean0 : Conv.cleanListB 21966 131072 (fun r => Nat.ble 87864 r) PRE_first_tail_x15_r0_suffix.s4
    (PRE_first_tail_x15_r0_suffix.wrB0 ++ (List.range 0).map (2825030 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cbigs0 : bigsOutB 21966 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx = true

end Host.Load.Run.Tpl
