import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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

/-! The compaction after the merge at call site 155 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1365` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa155` into the merged state
`PRE_first_tail_x15_r0_body.s1364`. -/

def PRE_first_tail_x15_r0_body.pl155 : List Nat := [2796395]
def PRE_first_tail_x15_r0_body.nr155 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd155 : RData :=
  ⟨2796386, 2796396, Stage.setAll PTrie.nil [(2796385, 2796395)], Stage.setAll PTrie.nil [],
   21249, 21249, 18340, 18340, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa155 : Map :=
  Conv.Map.compact 2796385 2796396 6679 PRE_first_tail_x15_r0_body.pl155 (PRE_first_tail_x15_r0_body.nr155.map NumV.ref) PRE_first_tail_x15_r0_body.kd155.big
    PRE_first_tail_x15_r0_body.kd155.region PRE_first_tail_x15_r0_body.kd155.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws155 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs155 : List SymE := PRE_first_tail_x15_r0_body.nr155.map fun r => (nth? PRE_first_tail_x15_r0_body.S1364.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta155 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws155 PRE_first_tail_x15_r0_body.crs155
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB155 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab155 : PRE_first_tail_x15_r0_body.S1365.tab = PRE_first_tail_x15_r0_body.S1363.tab ++ PRE_first_tail_x15_r0_body.cws155.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace155 : PRE_first_tail_x15_r0_body.s1365.trace = PRE_first_tail_x15_r0_body.s1363.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext155 : PRE_first_tail_x15_r0_body.s1365.next = 2796386
kernel_rfl PRE_first_tail_x15_r0_body.ccounters155 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx.nnext) = (21249, 18340)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue155 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1364.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa155.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp155 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx.tokens.all (bSN 6679) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean155 : Conv.cleanListB 21249 131072 (fun r => Nat.ble 84996 r) PRE_first_tail_x15_r0_body.s1365
    (PRE_first_tail_x15_r0_body.wrB155 ++ (List.range 1).map (2796385 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs155 : bigsOutB 21249 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1365.ffi).mlx = true

end Host.Load.Run.Tpl
