import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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

/-! The compaction after the merge at call site 94 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s917` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa94` into the merged state
`PRE_first_tail_x15_r0_body.s916`. -/

def PRE_first_tail_x15_r0_body.pl94 : List Nat := []
def PRE_first_tail_x15_r0_body.nr94 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd94 : RData :=
  ⟨2749005, 2749007, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20062, 20062, 17151, 17151, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa94 : Map :=
  Conv.Map.compact 2749005 2749007 4097 PRE_first_tail_x15_r0_body.pl94 (PRE_first_tail_x15_r0_body.nr94.map NumV.ref) PRE_first_tail_x15_r0_body.kd94.big
    PRE_first_tail_x15_r0_body.kd94.region PRE_first_tail_x15_r0_body.kd94.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws94 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs94 : List SymE := PRE_first_tail_x15_r0_body.nr94.map fun r => (nth? PRE_first_tail_x15_r0_body.S916.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta94 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws94 PRE_first_tail_x15_r0_body.crs94
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB94 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab94 : PRE_first_tail_x15_r0_body.S917.tab = PRE_first_tail_x15_r0_body.S915.tab ++ PRE_first_tail_x15_r0_body.cws94.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace94 : PRE_first_tail_x15_r0_body.s917.trace = PRE_first_tail_x15_r0_body.s915.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext94 : PRE_first_tail_x15_r0_body.s917.next = 2749005
kernel_rfl PRE_first_tail_x15_r0_body.ccounters94 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.nnext) = (20062, 17151)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue94 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s916.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa94.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp94 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.tokens.all (bSN 4097) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean94 : Conv.cleanListB 20062 131072 (fun r => Nat.ble 80248 r) PRE_first_tail_x15_r0_body.s917
    (PRE_first_tail_x15_r0_body.wrB94 ++ (List.range 0).map (2749005 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs94 : bigsOutB 20062 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx = true

end Host.Load.Run.Tpl
