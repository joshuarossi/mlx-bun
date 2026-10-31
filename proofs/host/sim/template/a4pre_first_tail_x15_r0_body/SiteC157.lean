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

/-! The compaction after the merge at call site 157 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1388` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa157` into the merged state
`PRE_first_tail_x15_r0_body.s1387`. -/

def PRE_first_tail_x15_r0_body.pl157 : List Nat := []
def PRE_first_tail_x15_r0_body.nr157 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd157 : RData :=
  ⟨2798375, 2798377, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21300, 21300, 18399, 18399, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa157 : Map :=
  Conv.Map.compact 2798375 2798377 6791 PRE_first_tail_x15_r0_body.pl157 (PRE_first_tail_x15_r0_body.nr157.map NumV.ref) PRE_first_tail_x15_r0_body.kd157.big
    PRE_first_tail_x15_r0_body.kd157.region PRE_first_tail_x15_r0_body.kd157.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws157 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs157 : List SymE := PRE_first_tail_x15_r0_body.nr157.map fun r => (nth? PRE_first_tail_x15_r0_body.S1387.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta157 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws157 PRE_first_tail_x15_r0_body.crs157
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB157 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab157 : PRE_first_tail_x15_r0_body.S1388.tab = PRE_first_tail_x15_r0_body.S1386.tab ++ PRE_first_tail_x15_r0_body.cws157.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace157 : PRE_first_tail_x15_r0_body.s1388.trace = PRE_first_tail_x15_r0_body.s1386.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext157 : PRE_first_tail_x15_r0_body.s1388.next = 2798375
kernel_rfl PRE_first_tail_x15_r0_body.ccounters157 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx.nnext) = (21300, 18399)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue157 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1387.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa157.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp157 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx.tokens.all (bSN 6791) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean157 : Conv.cleanListB 21300 131072 (fun r => Nat.ble 85200 r) PRE_first_tail_x15_r0_body.s1388
    (PRE_first_tail_x15_r0_body.wrB157 ++ (List.range 0).map (2798375 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs157 : bigsOutB 21300 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1388.ffi).mlx = true

end Host.Load.Run.Tpl
