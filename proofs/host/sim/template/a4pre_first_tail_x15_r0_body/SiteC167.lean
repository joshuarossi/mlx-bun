import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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

/-! The compaction after the merge at call site 167 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1470` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa167` into the merged state
`PRE_first_tail_x15_r0_body.s1469`. -/

def PRE_first_tail_x15_r0_body.pl167 : List Nat := [2805820]
def PRE_first_tail_x15_r0_body.nr167 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd167 : RData :=
  ⟨2805802, 2805821, Stage.setAll PTrie.nil [(2805801, 2805820)], Stage.setAll PTrie.nil [],
   21485, 21485, 18577, 18577, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa167 : Map :=
  Conv.Map.compact 2805801 2805821 7192 PRE_first_tail_x15_r0_body.pl167 (PRE_first_tail_x15_r0_body.nr167.map NumV.ref) PRE_first_tail_x15_r0_body.kd167.big
    PRE_first_tail_x15_r0_body.kd167.region PRE_first_tail_x15_r0_body.kd167.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws167 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs167 : List SymE := PRE_first_tail_x15_r0_body.nr167.map fun r => (nth? PRE_first_tail_x15_r0_body.S1469.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta167 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws167 PRE_first_tail_x15_r0_body.crs167
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB167 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab167 : PRE_first_tail_x15_r0_body.S1470.tab = PRE_first_tail_x15_r0_body.S1468.tab ++ PRE_first_tail_x15_r0_body.cws167.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace167 : PRE_first_tail_x15_r0_body.s1470.trace = PRE_first_tail_x15_r0_body.s1468.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext167 : PRE_first_tail_x15_r0_body.s1470.next = 2805802
kernel_rfl PRE_first_tail_x15_r0_body.ccounters167 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1470.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1470.ffi).mlx.nnext) = (21485, 18577)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue167 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1469.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1470.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa167.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp167 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1470.ffi).mlx.tokens.all (bSN 7192) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean167 : Conv.cleanListB 21485 131072 (fun r => Nat.ble 85940 r) PRE_first_tail_x15_r0_body.s1470
    (PRE_first_tail_x15_r0_body.wrB167 ++ (List.range 1).map (2805801 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs167 : bigsOutB 21485 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1470.ffi).mlx = true

end Host.Load.Run.Tpl
