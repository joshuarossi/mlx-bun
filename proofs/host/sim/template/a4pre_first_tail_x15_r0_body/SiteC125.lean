import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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

/-! The compaction after the merge at call site 125 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1209` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa125` into the merged state
`PRE_first_tail_x15_r0_body.s1208`. -/

def PRE_first_tail_x15_r0_body.pl125 : List Nat := [2772673]
def PRE_first_tail_x15_r0_body.nr125 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd125 : RData :=
  ⟨2772664, 2772674, Stage.setAll PTrie.nil [(2772663, 2772673)], Stage.setAll PTrie.nil [],
   20656, 20656, 17755, 17755, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa125 : Map :=
  Conv.Map.compact 2772663 2772674 5398 PRE_first_tail_x15_r0_body.pl125 (PRE_first_tail_x15_r0_body.nr125.map NumV.ref) PRE_first_tail_x15_r0_body.kd125.big
    PRE_first_tail_x15_r0_body.kd125.region PRE_first_tail_x15_r0_body.kd125.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws125 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs125 : List SymE := PRE_first_tail_x15_r0_body.nr125.map fun r => (nth? PRE_first_tail_x15_r0_body.S1208.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta125 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws125 PRE_first_tail_x15_r0_body.crs125
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB125 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab125 : PRE_first_tail_x15_r0_body.S1209.tab = PRE_first_tail_x15_r0_body.S1207.tab ++ PRE_first_tail_x15_r0_body.cws125.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace125 : PRE_first_tail_x15_r0_body.s1209.trace = PRE_first_tail_x15_r0_body.s1207.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext125 : PRE_first_tail_x15_r0_body.s1209.next = 2772664
kernel_rfl PRE_first_tail_x15_r0_body.ccounters125 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.nnext) = (20656, 17755)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1208.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa125.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp125 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx.tokens.all (bSN 5398) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean125 : Conv.cleanListB 20656 131072 (fun r => Nat.ble 82624 r) PRE_first_tail_x15_r0_body.s1209
    (PRE_first_tail_x15_r0_body.wrB125 ++ (List.range 1).map (2772663 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs125 : bigsOutB 20656 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1209.ffi).mlx = true

end Host.Load.Run.Tpl
