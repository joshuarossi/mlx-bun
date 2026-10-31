import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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

/-! The compaction after the merge at call site 53 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s474` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa53` into the merged state
`PRE_first_tail_x15_r0_body.s473`. -/

def PRE_first_tail_x15_r0_body.pl53 : List Nat := [2716186]
def PRE_first_tail_x15_r0_body.nr53 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd53 : RData :=
  ⟨2716168, 2716187, Stage.setAll PTrie.nil [(2716167, 2716186)], Stage.setAll PTrie.nil [],
   19240, 19240, 16333, 16333, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa53 : Map :=
  Conv.Map.compact 2716167 2716187 2320 PRE_first_tail_x15_r0_body.pl53 (PRE_first_tail_x15_r0_body.nr53.map NumV.ref) PRE_first_tail_x15_r0_body.kd53.big
    PRE_first_tail_x15_r0_body.kd53.region PRE_first_tail_x15_r0_body.kd53.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws53 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs53 : List SymE := PRE_first_tail_x15_r0_body.nr53.map fun r => (nth? PRE_first_tail_x15_r0_body.S473.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta53 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws53 PRE_first_tail_x15_r0_body.crs53
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB53 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab53 : PRE_first_tail_x15_r0_body.S474.tab = PRE_first_tail_x15_r0_body.S472.tab ++ PRE_first_tail_x15_r0_body.cws53.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace53 : PRE_first_tail_x15_r0_body.s474.trace = PRE_first_tail_x15_r0_body.s472.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext53 : PRE_first_tail_x15_r0_body.s474.next = 2716168
kernel_rfl PRE_first_tail_x15_r0_body.ccounters53 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.nnext) = (19240, 16333)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s473.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa53.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.tokens.all (bSN 2320) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean53 : Conv.cleanListB 19240 131072 (fun r => Nat.ble 76960 r) PRE_first_tail_x15_r0_body.s474
    (PRE_first_tail_x15_r0_body.wrB53 ++ (List.range 1).map (2716167 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs53 : bigsOutB 19240 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx = true

end Host.Load.Run.Tpl
