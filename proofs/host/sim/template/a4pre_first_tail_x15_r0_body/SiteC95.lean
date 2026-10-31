import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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

/-! The compaction after the merge at call site 95 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s840` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa95` into the merged state
`PRE_first_tail_x15_r0_body.s839`. -/

def PRE_first_tail_x15_r0_body.pl95 : List Nat := [2749312]
def PRE_first_tail_x15_r0_body.nr95 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd95 : RData :=
  ⟨2749294, 2749313, Stage.setAll PTrie.nil [(2749293, 2749312)], Stage.setAll PTrie.nil [],
   20069, 20069, 17155, 17155, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa95 : Map :=
  Conv.Map.compact 2749293 2749313 4114 PRE_first_tail_x15_r0_body.pl95 (PRE_first_tail_x15_r0_body.nr95.map NumV.ref) PRE_first_tail_x15_r0_body.kd95.big
    PRE_first_tail_x15_r0_body.kd95.region PRE_first_tail_x15_r0_body.kd95.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws95 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs95 : List SymE := PRE_first_tail_x15_r0_body.nr95.map fun r => (nth? PRE_first_tail_x15_r0_body.S839.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta95 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws95 PRE_first_tail_x15_r0_body.crs95
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB95 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab95 : PRE_first_tail_x15_r0_body.S840.tab = PRE_first_tail_x15_r0_body.S838.tab ++ PRE_first_tail_x15_r0_body.cws95.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace95 : PRE_first_tail_x15_r0_body.s840.trace = PRE_first_tail_x15_r0_body.s838.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext95 : PRE_first_tail_x15_r0_body.s840.next = 2749294
kernel_rfl PRE_first_tail_x15_r0_body.ccounters95 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.nnext) = (20069, 17155)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue95 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s839.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa95.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp95 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx.tokens.all (bSN 4114) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean95 : Conv.cleanListB 20069 131072 (fun r => Nat.ble 80276 r) PRE_first_tail_x15_r0_body.s840
    (PRE_first_tail_x15_r0_body.wrB95 ++ (List.range 1).map (2749293 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs95 : bigsOutB 20069 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s840.ffi).mlx = true

end Host.Load.Run.Tpl
