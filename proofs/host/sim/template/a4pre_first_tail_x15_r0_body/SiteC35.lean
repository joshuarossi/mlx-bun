import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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

/-! The compaction after the merge at call site 35 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s346` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa35` into the merged state
`PRE_first_tail_x15_r0_body.s345`. -/

def PRE_first_tail_x15_r0_body.pl35 : List Nat := [2702224]
def PRE_first_tail_x15_r0_body.nr35 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd35 : RData :=
  ⟨2702206, 2702225, Stage.setAll PTrie.nil [(2702205, 2702224)], Stage.setAll PTrie.nil [],
   18889, 18889, 15970, 15970, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa35 : Map :=
  Conv.Map.compact 2702205 2702225 1549 PRE_first_tail_x15_r0_body.pl35 (PRE_first_tail_x15_r0_body.nr35.map NumV.ref) PRE_first_tail_x15_r0_body.kd35.big
    PRE_first_tail_x15_r0_body.kd35.region PRE_first_tail_x15_r0_body.kd35.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws35 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs35 : List SymE := PRE_first_tail_x15_r0_body.nr35.map fun r => (nth? PRE_first_tail_x15_r0_body.S345.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta35 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws35 PRE_first_tail_x15_r0_body.crs35
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB35 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab35 : PRE_first_tail_x15_r0_body.S346.tab = PRE_first_tail_x15_r0_body.S344.tab ++ PRE_first_tail_x15_r0_body.cws35.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace35 : PRE_first_tail_x15_r0_body.s346.trace = PRE_first_tail_x15_r0_body.s344.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext35 : PRE_first_tail_x15_r0_body.s346.next = 2702206
kernel_rfl PRE_first_tail_x15_r0_body.ccounters35 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.nnext) = (18889, 15970)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue35 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s345.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa35.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp35 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx.tokens.all (bSN 1549) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean35 : Conv.cleanListB 18889 131072 (fun r => Nat.ble 75556 r) PRE_first_tail_x15_r0_body.s346
    (PRE_first_tail_x15_r0_body.wrB35 ++ (List.range 1).map (2702205 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs35 : bigsOutB 18889 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s346.ffi).mlx = true

end Host.Load.Run.Tpl
