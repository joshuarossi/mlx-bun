import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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

/-! The compaction after the merge at call site 179 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1575` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa179` into the merged state
`PRE_first_tail_x15_r0_body.s1574`. -/

def PRE_first_tail_x15_r0_body.pl179 : List Nat := [2815248]
def PRE_first_tail_x15_r0_body.nr179 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd179 : RData :=
  ⟨2815230, 2815249, Stage.setAll PTrie.nil [(2815229, 2815248)], Stage.setAll PTrie.nil [],
   21721, 21721, 18814, 18814, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa179 : Map :=
  Conv.Map.compact 2815229 2815249 7705 PRE_first_tail_x15_r0_body.pl179 (PRE_first_tail_x15_r0_body.nr179.map NumV.ref) PRE_first_tail_x15_r0_body.kd179.big
    PRE_first_tail_x15_r0_body.kd179.region PRE_first_tail_x15_r0_body.kd179.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws179 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs179 : List SymE := PRE_first_tail_x15_r0_body.nr179.map fun r => (nth? PRE_first_tail_x15_r0_body.S1574.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta179 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws179 PRE_first_tail_x15_r0_body.crs179
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB179 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab179 : PRE_first_tail_x15_r0_body.S1575.tab = PRE_first_tail_x15_r0_body.S1573.tab ++ PRE_first_tail_x15_r0_body.cws179.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace179 : PRE_first_tail_x15_r0_body.s1575.trace = PRE_first_tail_x15_r0_body.s1573.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext179 : PRE_first_tail_x15_r0_body.s1575.next = 2815230
kernel_rfl PRE_first_tail_x15_r0_body.ccounters179 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.nnext) = (21721, 18814)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue179 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1574.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa179.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp179 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx.tokens.all (bSN 7705) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean179 : Conv.cleanListB 21721 131072 (fun r => Nat.ble 86884 r) PRE_first_tail_x15_r0_body.s1575
    (PRE_first_tail_x15_r0_body.wrB179 ++ (List.range 1).map (2815229 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs179 : bigsOutB 21721 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1575.ffi).mlx = true

end Host.Load.Run.Tpl
