import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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

/-! The compaction after the merge at call site 40 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s365` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa40` into the merged state
`PRE_first_tail_x15_r0_body.s364`. -/

def PRE_first_tail_x15_r0_body.pl40 : List Nat := []
def PRE_first_tail_x15_r0_body.nr40 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd40 : RData :=
  ⟨2706455, 2706457, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18997, 18997, 16092, 16092, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa40 : Map :=
  Conv.Map.compact 2706455 2706457 1790 PRE_first_tail_x15_r0_body.pl40 (PRE_first_tail_x15_r0_body.nr40.map NumV.ref) PRE_first_tail_x15_r0_body.kd40.big
    PRE_first_tail_x15_r0_body.kd40.region PRE_first_tail_x15_r0_body.kd40.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws40 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs40 : List SymE := PRE_first_tail_x15_r0_body.nr40.map fun r => (nth? PRE_first_tail_x15_r0_body.S364.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta40 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws40 PRE_first_tail_x15_r0_body.crs40
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB40 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab40 : PRE_first_tail_x15_r0_body.S365.tab = PRE_first_tail_x15_r0_body.S363.tab ++ PRE_first_tail_x15_r0_body.cws40.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace40 : PRE_first_tail_x15_r0_body.s365.trace = PRE_first_tail_x15_r0_body.s363.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext40 : PRE_first_tail_x15_r0_body.s365.next = 2706455
kernel_rfl PRE_first_tail_x15_r0_body.ccounters40 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.nnext) = (18997, 16092)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue40 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s364.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa40.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp40 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx.tokens.all (bSN 1790) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean40 : Conv.cleanListB 18997 131072 (fun r => Nat.ble 75988 r) PRE_first_tail_x15_r0_body.s365
    (PRE_first_tail_x15_r0_body.wrB40 ++ (List.range 0).map (2706455 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs40 : bigsOutB 18997 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s365.ffi).mlx = true

end Host.Load.Run.Tpl
