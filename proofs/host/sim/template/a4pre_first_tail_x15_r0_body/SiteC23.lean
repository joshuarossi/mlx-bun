import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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

/-! The compaction after the merge at call site 23 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s210` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa23` into the merged state
`PRE_first_tail_x15_r0_body.s209`. -/

def PRE_first_tail_x15_r0_body.pl23 : List Nat := [2692803]
def PRE_first_tail_x15_r0_body.nr23 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd23 : RData :=
  ⟨2692794, 2692804, Stage.setAll PTrie.nil [(2692793, 2692803)], Stage.setAll PTrie.nil [],
   18653, 18653, 15733, 15733, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa23 : Map :=
  Conv.Map.compact 2692793 2692804 1036 PRE_first_tail_x15_r0_body.pl23 (PRE_first_tail_x15_r0_body.nr23.map NumV.ref) PRE_first_tail_x15_r0_body.kd23.big
    PRE_first_tail_x15_r0_body.kd23.region PRE_first_tail_x15_r0_body.kd23.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws23 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs23 : List SymE := PRE_first_tail_x15_r0_body.nr23.map fun r => (nth? PRE_first_tail_x15_r0_body.S209.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta23 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws23 PRE_first_tail_x15_r0_body.crs23
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB23 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab23 : PRE_first_tail_x15_r0_body.S210.tab = PRE_first_tail_x15_r0_body.S208.tab ++ PRE_first_tail_x15_r0_body.cws23.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace23 : PRE_first_tail_x15_r0_body.s210.trace = PRE_first_tail_x15_r0_body.s208.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext23 : PRE_first_tail_x15_r0_body.s210.next = 2692794
kernel_rfl PRE_first_tail_x15_r0_body.ccounters23 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.nnext) = (18653, 15733)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue23 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s209.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa23.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp23 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx.tokens.all (bSN 1036) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean23 : Conv.cleanListB 18653 131072 (fun r => Nat.ble 74612 r) PRE_first_tail_x15_r0_body.s210
    (PRE_first_tail_x15_r0_body.wrB23 ++ (List.range 1).map (2692793 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs23 : bigsOutB 18653 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s210.ffi).mlx = true

end Host.Load.Run.Tpl
