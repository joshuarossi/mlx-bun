import host.sim.template.a4pre_first_tail_x15_r0_body.H35
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

/-! The compaction after the merge at call site 128 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1131` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa128` into the merged state
`PRE_first_tail_x15_r0_body.s1130`. -/

def PRE_first_tail_x15_r0_body.pl128 : List Nat := [2774929]
def PRE_first_tail_x15_r0_body.nr128 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd128 : RData :=
  ⟨2774920, 2774930, Stage.setAll PTrie.nil [(2774919, 2774929)], Stage.setAll PTrie.nil [],
   20713, 20713, 17818, 17818, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa128 : Map :=
  Conv.Map.compact 2774919 2774930 5527 PRE_first_tail_x15_r0_body.pl128 (PRE_first_tail_x15_r0_body.nr128.map NumV.ref) PRE_first_tail_x15_r0_body.kd128.big
    PRE_first_tail_x15_r0_body.kd128.region PRE_first_tail_x15_r0_body.kd128.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws128 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs128 : List SymE := PRE_first_tail_x15_r0_body.nr128.map fun r => (nth? PRE_first_tail_x15_r0_body.S1130.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta128 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws128 PRE_first_tail_x15_r0_body.crs128
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB128 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab128 : PRE_first_tail_x15_r0_body.S1131.tab = PRE_first_tail_x15_r0_body.S1129.tab ++ PRE_first_tail_x15_r0_body.cws128.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace128 : PRE_first_tail_x15_r0_body.s1131.trace = PRE_first_tail_x15_r0_body.s1129.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext128 : PRE_first_tail_x15_r0_body.s1131.next = 2774920
kernel_rfl PRE_first_tail_x15_r0_body.ccounters128 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.nnext) = (20713, 17818)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1130.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa128.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.tokens.all (bSN 5527) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean128 : Conv.cleanListB 20713 131072 (fun r => Nat.ble 82852 r) PRE_first_tail_x15_r0_body.s1131
    (PRE_first_tail_x15_r0_body.wrB128 ++ (List.range 1).map (2774919 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs128 : bigsOutB 20713 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx = true

end Host.Load.Run.Tpl
