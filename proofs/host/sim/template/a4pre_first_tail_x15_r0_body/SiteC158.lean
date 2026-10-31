import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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

/-! The compaction after the merge at call site 158 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1392` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa158` into the merged state
`PRE_first_tail_x15_r0_body.s1391`. -/

def PRE_first_tail_x15_r0_body.pl158 : List Nat := [2798673]
def PRE_first_tail_x15_r0_body.nr158 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd158 : RData :=
  ⟨2798664, 2798674, Stage.setAll PTrie.nil [(2798663, 2798673)], Stage.setAll PTrie.nil [],
   21307, 21307, 18403, 18403, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa158 : Map :=
  Conv.Map.compact 2798663 2798674 6808 PRE_first_tail_x15_r0_body.pl158 (PRE_first_tail_x15_r0_body.nr158.map NumV.ref) PRE_first_tail_x15_r0_body.kd158.big
    PRE_first_tail_x15_r0_body.kd158.region PRE_first_tail_x15_r0_body.kd158.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws158 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs158 : List SymE := PRE_first_tail_x15_r0_body.nr158.map fun r => (nth? PRE_first_tail_x15_r0_body.S1391.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta158 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws158 PRE_first_tail_x15_r0_body.crs158
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB158 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab158 : PRE_first_tail_x15_r0_body.S1392.tab = PRE_first_tail_x15_r0_body.S1390.tab ++ PRE_first_tail_x15_r0_body.cws158.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace158 : PRE_first_tail_x15_r0_body.s1392.trace = PRE_first_tail_x15_r0_body.s1390.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext158 : PRE_first_tail_x15_r0_body.s1392.next = 2798664
kernel_rfl PRE_first_tail_x15_r0_body.ccounters158 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx.nnext) = (21307, 18403)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue158 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1391.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa158.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp158 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx.tokens.all (bSN 6808) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean158 : Conv.cleanListB 21307 131072 (fun r => Nat.ble 85228 r) PRE_first_tail_x15_r0_body.s1392
    (PRE_first_tail_x15_r0_body.wrB158 ++ (List.range 1).map (2798663 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs158 : bigsOutB 21307 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1392.ffi).mlx = true

end Host.Load.Run.Tpl
