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

/-! The compaction after the merge at call site 49 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s443` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa49` into the merged state
`PRE_first_tail_x15_r0_body.s442`. -/

def PRE_first_tail_x15_r0_body.pl49 : List Nat := []
def PRE_first_tail_x15_r0_body.nr49 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd49 : RData :=
  ⟨2713619, 2713621, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19176, 19176, 16266, 16266, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa49 : Map :=
  Conv.Map.compact 2713619 2713621 2174 PRE_first_tail_x15_r0_body.pl49 (PRE_first_tail_x15_r0_body.nr49.map NumV.ref) PRE_first_tail_x15_r0_body.kd49.big
    PRE_first_tail_x15_r0_body.kd49.region PRE_first_tail_x15_r0_body.kd49.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws49 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs49 : List SymE := PRE_first_tail_x15_r0_body.nr49.map fun r => (nth? PRE_first_tail_x15_r0_body.S442.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta49 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws49 PRE_first_tail_x15_r0_body.crs49
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB49 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab49 : PRE_first_tail_x15_r0_body.S443.tab = PRE_first_tail_x15_r0_body.S441.tab ++ PRE_first_tail_x15_r0_body.cws49.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace49 : PRE_first_tail_x15_r0_body.s443.trace = PRE_first_tail_x15_r0_body.s441.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext49 : PRE_first_tail_x15_r0_body.s443.next = 2713619
kernel_rfl PRE_first_tail_x15_r0_body.ccounters49 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx.nnext) = (19176, 16266)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s442.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa49.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx.tokens.all (bSN 2174) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean49 : Conv.cleanListB 19176 131072 (fun r => Nat.ble 76704 r) PRE_first_tail_x15_r0_body.s443
    (PRE_first_tail_x15_r0_body.wrB49 ++ (List.range 0).map (2713619 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs49 : bigsOutB 19176 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s443.ffi).mlx = true

end Host.Load.Run.Tpl
