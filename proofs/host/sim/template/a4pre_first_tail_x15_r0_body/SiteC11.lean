import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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

/-! The compaction after the merge at call site 11 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s116` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa11` into the merged state
`PRE_first_tail_x15_r0_body.s115`. -/

def PRE_first_tail_x15_r0_body.pl11 : List Nat := [2683391]
def PRE_first_tail_x15_r0_body.nr11 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd11 : RData :=
  ⟨2683382, 2683392, Stage.setAll PTrie.nil [(2683381, 2683391)], Stage.setAll PTrie.nil [],
   18417, 18417, 15496, 15496, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa11 : Map :=
  Conv.Map.compact 2683381 2683392 523 PRE_first_tail_x15_r0_body.pl11 (PRE_first_tail_x15_r0_body.nr11.map NumV.ref) PRE_first_tail_x15_r0_body.kd11.big
    PRE_first_tail_x15_r0_body.kd11.region PRE_first_tail_x15_r0_body.kd11.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws11 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs11 : List SymE := PRE_first_tail_x15_r0_body.nr11.map fun r => (nth? PRE_first_tail_x15_r0_body.S115.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta11 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws11 PRE_first_tail_x15_r0_body.crs11
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB11 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab11 : PRE_first_tail_x15_r0_body.S116.tab = PRE_first_tail_x15_r0_body.S114.tab ++ PRE_first_tail_x15_r0_body.cws11.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace11 : PRE_first_tail_x15_r0_body.s116.trace = PRE_first_tail_x15_r0_body.s114.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext11 : PRE_first_tail_x15_r0_body.s116.next = 2683382
kernel_rfl PRE_first_tail_x15_r0_body.ccounters11 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.nnext) = (18417, 15496)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue11 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s115.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa11.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp11 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx.tokens.all (bSN 523) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean11 : Conv.cleanListB 18417 131072 (fun r => Nat.ble 73668 r) PRE_first_tail_x15_r0_body.s116
    (PRE_first_tail_x15_r0_body.wrB11 ++ (List.range 1).map (2683381 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs11 : bigsOutB 18417 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s116.ffi).mlx = true

end Host.Load.Run.Tpl
