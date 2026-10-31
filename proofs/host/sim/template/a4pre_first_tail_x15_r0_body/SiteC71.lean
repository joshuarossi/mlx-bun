import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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

/-! The compaction after the merge at call site 71 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s691` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa71` into the merged state
`PRE_first_tail_x15_r0_body.s690`. -/

def PRE_first_tail_x15_r0_body.pl71 : List Nat := [2730475]
def PRE_first_tail_x15_r0_body.nr71 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd71 : RData :=
  ⟨2730466, 2730476, Stage.setAll PTrie.nil [(2730465, 2730475)], Stage.setAll PTrie.nil [],
   19597, 19597, 16681, 16681, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa71 : Map :=
  Conv.Map.compact 2730465 2730476 3088 PRE_first_tail_x15_r0_body.pl71 (PRE_first_tail_x15_r0_body.nr71.map NumV.ref) PRE_first_tail_x15_r0_body.kd71.big
    PRE_first_tail_x15_r0_body.kd71.region PRE_first_tail_x15_r0_body.kd71.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws71 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs71 : List SymE := PRE_first_tail_x15_r0_body.nr71.map fun r => (nth? PRE_first_tail_x15_r0_body.S690.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta71 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws71 PRE_first_tail_x15_r0_body.crs71
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB71 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab71 : PRE_first_tail_x15_r0_body.S691.tab = PRE_first_tail_x15_r0_body.S689.tab ++ PRE_first_tail_x15_r0_body.cws71.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace71 : PRE_first_tail_x15_r0_body.s691.trace = PRE_first_tail_x15_r0_body.s689.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext71 : PRE_first_tail_x15_r0_body.s691.next = 2730466
kernel_rfl PRE_first_tail_x15_r0_body.ccounters71 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.nnext) = (19597, 16681)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s690.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa71.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.tokens.all (bSN 3088) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean71 : Conv.cleanListB 19597 131072 (fun r => Nat.ble 78388 r) PRE_first_tail_x15_r0_body.s691
    (PRE_first_tail_x15_r0_body.wrB71 ++ (List.range 1).map (2730465 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs71 : bigsOutB 19597 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx = true

end Host.Load.Run.Tpl
