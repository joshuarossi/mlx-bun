import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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

/-! The compaction after the merge at call site 149 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1314` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa149` into the merged state
`PRE_first_tail_x15_r0_body.s1313`. -/

def PRE_first_tail_x15_r0_body.pl149 : List Nat := [2791522]
def PRE_first_tail_x15_r0_body.nr149 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd149 : RData :=
  ⟨2791504, 2791523, Stage.setAll PTrie.nil [(2791503, 2791522)], Stage.setAll PTrie.nil [],
   21128, 21128, 18229, 18229, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa149 : Map :=
  Conv.Map.compact 2791503 2791523 6424 PRE_first_tail_x15_r0_body.pl149 (PRE_first_tail_x15_r0_body.nr149.map NumV.ref) PRE_first_tail_x15_r0_body.kd149.big
    PRE_first_tail_x15_r0_body.kd149.region PRE_first_tail_x15_r0_body.kd149.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws149 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs149 : List SymE := PRE_first_tail_x15_r0_body.nr149.map fun r => (nth? PRE_first_tail_x15_r0_body.S1313.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta149 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws149 PRE_first_tail_x15_r0_body.crs149
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB149 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab149 : PRE_first_tail_x15_r0_body.S1314.tab = PRE_first_tail_x15_r0_body.S1312.tab ++ PRE_first_tail_x15_r0_body.cws149.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace149 : PRE_first_tail_x15_r0_body.s1314.trace = PRE_first_tail_x15_r0_body.s1312.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext149 : PRE_first_tail_x15_r0_body.s1314.next = 2791504
kernel_rfl PRE_first_tail_x15_r0_body.ccounters149 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.nnext) = (21128, 18229)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue149 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1313.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa149.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp149 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx.tokens.all (bSN 6424) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean149 : Conv.cleanListB 21128 131072 (fun r => Nat.ble 84512 r) PRE_first_tail_x15_r0_body.s1314
    (PRE_first_tail_x15_r0_body.wrB149 ++ (List.range 1).map (2791503 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs149 : bigsOutB 21128 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1314.ffi).mlx = true

end Host.Load.Run.Tpl
