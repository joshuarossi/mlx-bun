import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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

/-! The compaction after the merge at call site 50 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s490` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa50` into the merged state
`PRE_first_tail_x15_r0_body.s489`. -/

def PRE_first_tail_x15_r0_body.pl50 : List Nat := [2713926]
def PRE_first_tail_x15_r0_body.nr50 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd50 : RData :=
  ⟨2713908, 2713927, Stage.setAll PTrie.nil [(2713907, 2713926)], Stage.setAll PTrie.nil [],
   19183, 19183, 16270, 16270, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa50 : Map :=
  Conv.Map.compact 2713907 2713927 2191 PRE_first_tail_x15_r0_body.pl50 (PRE_first_tail_x15_r0_body.nr50.map NumV.ref) PRE_first_tail_x15_r0_body.kd50.big
    PRE_first_tail_x15_r0_body.kd50.region PRE_first_tail_x15_r0_body.kd50.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws50 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs50 : List SymE := PRE_first_tail_x15_r0_body.nr50.map fun r => (nth? PRE_first_tail_x15_r0_body.S489.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta50 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws50 PRE_first_tail_x15_r0_body.crs50
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB50 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab50 : PRE_first_tail_x15_r0_body.S490.tab = PRE_first_tail_x15_r0_body.S488.tab ++ PRE_first_tail_x15_r0_body.cws50.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace50 : PRE_first_tail_x15_r0_body.s490.trace = PRE_first_tail_x15_r0_body.s488.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext50 : PRE_first_tail_x15_r0_body.s490.next = 2713908
kernel_rfl PRE_first_tail_x15_r0_body.ccounters50 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.nnext) = (19183, 16270)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s489.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa50.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp50 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx.tokens.all (bSN 2191) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean50 : Conv.cleanListB 19183 131072 (fun r => Nat.ble 76732 r) PRE_first_tail_x15_r0_body.s490
    (PRE_first_tail_x15_r0_body.wrB50 ++ (List.range 1).map (2713907 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs50 : bigsOutB 19183 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s490.ffi).mlx = true

end Host.Load.Run.Tpl
