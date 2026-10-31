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

/-! The compaction after the merge at call site 136 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1320` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa136` into the merged state
`PRE_first_tail_x15_r0_body.s1319`. -/

def PRE_first_tail_x15_r0_body.pl136 : List Nat := []
def PRE_first_tail_x15_r0_body.nr136 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd136 : RData :=
  ⟨2781787, 2781789, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20885, 20885, 17988, 17988, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa136 : Map :=
  Conv.Map.compact 2781787 2781789 5894 PRE_first_tail_x15_r0_body.pl136 (PRE_first_tail_x15_r0_body.nr136.map NumV.ref) PRE_first_tail_x15_r0_body.kd136.big
    PRE_first_tail_x15_r0_body.kd136.region PRE_first_tail_x15_r0_body.kd136.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws136 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs136 : List SymE := PRE_first_tail_x15_r0_body.nr136.map fun r => (nth? PRE_first_tail_x15_r0_body.S1319.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta136 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws136 PRE_first_tail_x15_r0_body.crs136
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB136 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab136 : PRE_first_tail_x15_r0_body.S1320.tab = PRE_first_tail_x15_r0_body.S1318.tab ++ PRE_first_tail_x15_r0_body.cws136.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace136 : PRE_first_tail_x15_r0_body.s1320.trace = PRE_first_tail_x15_r0_body.s1318.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext136 : PRE_first_tail_x15_r0_body.s1320.next = 2781787
kernel_rfl PRE_first_tail_x15_r0_body.ccounters136 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.nnext) = (20885, 17988)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1319.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa136.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.tokens.all (bSN 5894) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean136 : Conv.cleanListB 20885 131072 (fun r => Nat.ble 83540 r) PRE_first_tail_x15_r0_body.s1320
    (PRE_first_tail_x15_r0_body.wrB136 ++ (List.range 0).map (2781787 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs136 : bigsOutB 20885 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx = true

end Host.Load.Run.Tpl
