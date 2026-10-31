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

/-! The compaction after the merge at call site 127 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1127` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa127` into the merged state
`PRE_first_tail_x15_r0_body.s1126`. -/

def PRE_first_tail_x15_r0_body.pl127 : List Nat := []
def PRE_first_tail_x15_r0_body.nr127 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd127 : RData :=
  ⟨2774631, 2774633, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20706, 20706, 17814, 17814, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa127 : Map :=
  Conv.Map.compact 2774631 2774633 5510 PRE_first_tail_x15_r0_body.pl127 (PRE_first_tail_x15_r0_body.nr127.map NumV.ref) PRE_first_tail_x15_r0_body.kd127.big
    PRE_first_tail_x15_r0_body.kd127.region PRE_first_tail_x15_r0_body.kd127.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws127 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs127 : List SymE := PRE_first_tail_x15_r0_body.nr127.map fun r => (nth? PRE_first_tail_x15_r0_body.S1126.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta127 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws127 PRE_first_tail_x15_r0_body.crs127
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB127 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab127 : PRE_first_tail_x15_r0_body.S1127.tab = PRE_first_tail_x15_r0_body.S1125.tab ++ PRE_first_tail_x15_r0_body.cws127.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace127 : PRE_first_tail_x15_r0_body.s1127.trace = PRE_first_tail_x15_r0_body.s1125.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext127 : PRE_first_tail_x15_r0_body.s1127.next = 2774631
kernel_rfl PRE_first_tail_x15_r0_body.ccounters127 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1127.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1127.ffi).mlx.nnext) = (20706, 17814)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1126.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1127.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa127.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp127 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1127.ffi).mlx.tokens.all (bSN 5510) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean127 : Conv.cleanListB 20706 131072 (fun r => Nat.ble 82824 r) PRE_first_tail_x15_r0_body.s1127
    (PRE_first_tail_x15_r0_body.wrB127 ++ (List.range 0).map (2774631 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs127 : bigsOutB 20706 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1127.ffi).mlx = true

end Host.Load.Run.Tpl
