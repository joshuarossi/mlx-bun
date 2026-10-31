import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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

/-! The compaction after the merge at call site 43 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s429` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa43` into the merged state
`PRE_first_tail_x15_r0_body.s428`. -/

def PRE_first_tail_x15_r0_body.pl43 : List Nat := []
def PRE_first_tail_x15_r0_body.nr43 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd43 : RData :=
  ⟨2708715, 2708717, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19054, 19054, 16155, 16155, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa43 : Map :=
  Conv.Map.compact 2708715 2708717 1919 PRE_first_tail_x15_r0_body.pl43 (PRE_first_tail_x15_r0_body.nr43.map NumV.ref) PRE_first_tail_x15_r0_body.kd43.big
    PRE_first_tail_x15_r0_body.kd43.region PRE_first_tail_x15_r0_body.kd43.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws43 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs43 : List SymE := PRE_first_tail_x15_r0_body.nr43.map fun r => (nth? PRE_first_tail_x15_r0_body.S428.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta43 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws43 PRE_first_tail_x15_r0_body.crs43
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB43 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab43 : PRE_first_tail_x15_r0_body.S429.tab = PRE_first_tail_x15_r0_body.S427.tab ++ PRE_first_tail_x15_r0_body.cws43.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace43 : PRE_first_tail_x15_r0_body.s429.trace = PRE_first_tail_x15_r0_body.s427.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext43 : PRE_first_tail_x15_r0_body.s429.next = 2708715
kernel_rfl PRE_first_tail_x15_r0_body.ccounters43 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx.nnext) = (19054, 16155)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue43 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s428.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa43.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp43 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx.tokens.all (bSN 1919) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean43 : Conv.cleanListB 19054 131072 (fun r => Nat.ble 76216 r) PRE_first_tail_x15_r0_body.s429
    (PRE_first_tail_x15_r0_body.wrB43 ++ (List.range 0).map (2708715 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs43 : bigsOutB 19054 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s429.ffi).mlx = true

end Host.Load.Run.Tpl
