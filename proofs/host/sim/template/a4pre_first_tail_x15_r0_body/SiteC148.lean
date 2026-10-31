import host.sim.template.a4pre_first_tail_x15_r0_body.H40
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

/-! The compaction after the merge at call site 148 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1310` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa148` into the merged state
`PRE_first_tail_x15_r0_body.s1309`. -/

def PRE_first_tail_x15_r0_body.pl148 : List Nat := []
def PRE_first_tail_x15_r0_body.nr148 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd148 : RData :=
  ⟨2791215, 2791217, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21121, 21121, 18225, 18225, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa148 : Map :=
  Conv.Map.compact 2791215 2791217 6407 PRE_first_tail_x15_r0_body.pl148 (PRE_first_tail_x15_r0_body.nr148.map NumV.ref) PRE_first_tail_x15_r0_body.kd148.big
    PRE_first_tail_x15_r0_body.kd148.region PRE_first_tail_x15_r0_body.kd148.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws148 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs148 : List SymE := PRE_first_tail_x15_r0_body.nr148.map fun r => (nth? PRE_first_tail_x15_r0_body.S1309.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta148 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws148 PRE_first_tail_x15_r0_body.crs148
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB148 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab148 : PRE_first_tail_x15_r0_body.S1310.tab = PRE_first_tail_x15_r0_body.S1308.tab ++ PRE_first_tail_x15_r0_body.cws148.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace148 : PRE_first_tail_x15_r0_body.s1310.trace = PRE_first_tail_x15_r0_body.s1308.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext148 : PRE_first_tail_x15_r0_body.s1310.next = 2791215
kernel_rfl PRE_first_tail_x15_r0_body.ccounters148 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = (21121, 18225)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue148 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1309.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa148.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp148 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.tokens.all (bSN 6407) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean148 : Conv.cleanListB 21121 131072 (fun r => Nat.ble 84484 r) PRE_first_tail_x15_r0_body.s1310
    (PRE_first_tail_x15_r0_body.wrB148 ++ (List.range 0).map (2791215 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs148 : bigsOutB 21121 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx = true

end Host.Load.Run.Tpl
