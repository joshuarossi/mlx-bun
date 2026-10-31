import host.sim.template.a4pre_first_tail_x15_r0_body.H50
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

/-! The compaction after the merge at call site 185 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1629` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa185` into the merged state
`PRE_first_tail_x15_r0_body.s1628`. -/

def PRE_first_tail_x15_r0_body.pl185 : List Nat := [2819790]
def PRE_first_tail_x15_r0_body.nr185 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd185 : RData :=
  ⟨2819772, 2819791, Stage.setAll PTrie.nil [(2819771, 2819790)], Stage.setAll PTrie.nil [],
   21836, 21836, 18940, 18940, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa185 : Map :=
  Conv.Map.compact 2819771 2819791 7963 PRE_first_tail_x15_r0_body.pl185 (PRE_first_tail_x15_r0_body.nr185.map NumV.ref) PRE_first_tail_x15_r0_body.kd185.big
    PRE_first_tail_x15_r0_body.kd185.region PRE_first_tail_x15_r0_body.kd185.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws185 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs185 : List SymE := PRE_first_tail_x15_r0_body.nr185.map fun r => (nth? PRE_first_tail_x15_r0_body.S1628.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta185 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws185 PRE_first_tail_x15_r0_body.crs185
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB185 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab185 : PRE_first_tail_x15_r0_body.S1629.tab = PRE_first_tail_x15_r0_body.S1627.tab ++ PRE_first_tail_x15_r0_body.cws185.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace185 : PRE_first_tail_x15_r0_body.s1629.trace = PRE_first_tail_x15_r0_body.s1627.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext185 : PRE_first_tail_x15_r0_body.s1629.next = 2819772
kernel_rfl PRE_first_tail_x15_r0_body.ccounters185 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx.nnext) = (21836, 18940)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue185 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1628.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa185.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp185 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx.tokens.all (bSN 7963) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean185 : Conv.cleanListB 21836 131072 (fun r => Nat.ble 87344 r) PRE_first_tail_x15_r0_body.s1629
    (PRE_first_tail_x15_r0_body.wrB185 ++ (List.range 1).map (2819771 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs185 : bigsOutB 21836 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1629.ffi).mlx = true

end Host.Load.Run.Tpl
