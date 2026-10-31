import host.sim.template.a4pre_first_tail_x15_r0_body.H35
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

/-! The compaction after the merge at call site 119 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1151` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa119` into the merged state
`PRE_first_tail_x15_r0_body.s1150`. -/

def PRE_first_tail_x15_r0_body.pl119 : List Nat := [2768139]
def PRE_first_tail_x15_r0_body.nr119 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd119 : RData :=
  ⟨2768130, 2768140, Stage.setAll PTrie.nil [(2768129, 2768139)], Stage.setAll PTrie.nil [],
   20541, 20541, 17629, 17629, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa119 : Map :=
  Conv.Map.compact 2768129 2768140 5140 PRE_first_tail_x15_r0_body.pl119 (PRE_first_tail_x15_r0_body.nr119.map NumV.ref) PRE_first_tail_x15_r0_body.kd119.big
    PRE_first_tail_x15_r0_body.kd119.region PRE_first_tail_x15_r0_body.kd119.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws119 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs119 : List SymE := PRE_first_tail_x15_r0_body.nr119.map fun r => (nth? PRE_first_tail_x15_r0_body.S1150.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta119 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws119 PRE_first_tail_x15_r0_body.crs119
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB119 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab119 : PRE_first_tail_x15_r0_body.S1151.tab = PRE_first_tail_x15_r0_body.S1149.tab ++ PRE_first_tail_x15_r0_body.cws119.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace119 : PRE_first_tail_x15_r0_body.s1151.trace = PRE_first_tail_x15_r0_body.s1149.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext119 : PRE_first_tail_x15_r0_body.s1151.next = 2768130
kernel_rfl PRE_first_tail_x15_r0_body.ccounters119 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.nnext) = (20541, 17629)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue119 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1150.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa119.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp119 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx.tokens.all (bSN 5140) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean119 : Conv.cleanListB 20541 131072 (fun r => Nat.ble 82164 r) PRE_first_tail_x15_r0_body.s1151
    (PRE_first_tail_x15_r0_body.wrB119 ++ (List.range 1).map (2768129 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs119 : bigsOutB 20541 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1151.ffi).mlx = true

end Host.Load.Run.Tpl
