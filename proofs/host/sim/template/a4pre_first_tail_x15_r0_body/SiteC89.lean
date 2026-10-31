import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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

/-! The compaction after the merge at call site 89 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s789` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa89` into the merged state
`PRE_first_tail_x15_r0_body.s788`. -/

def PRE_first_tail_x15_r0_body.pl89 : List Nat := [2744430]
def PRE_first_tail_x15_r0_body.nr89 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd89 : RData :=
  ⟨2744412, 2744431, Stage.setAll PTrie.nil [(2744411, 2744430)], Stage.setAll PTrie.nil [],
   19948, 19948, 17044, 17044, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa89 : Map :=
  Conv.Map.compact 2744411 2744431 3859 PRE_first_tail_x15_r0_body.pl89 (PRE_first_tail_x15_r0_body.nr89.map NumV.ref) PRE_first_tail_x15_r0_body.kd89.big
    PRE_first_tail_x15_r0_body.kd89.region PRE_first_tail_x15_r0_body.kd89.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws89 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs89 : List SymE := PRE_first_tail_x15_r0_body.nr89.map fun r => (nth? PRE_first_tail_x15_r0_body.S788.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta89 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws89 PRE_first_tail_x15_r0_body.crs89
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB89 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab89 : PRE_first_tail_x15_r0_body.S789.tab = PRE_first_tail_x15_r0_body.S787.tab ++ PRE_first_tail_x15_r0_body.cws89.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace89 : PRE_first_tail_x15_r0_body.s789.trace = PRE_first_tail_x15_r0_body.s787.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext89 : PRE_first_tail_x15_r0_body.s789.next = 2744412
kernel_rfl PRE_first_tail_x15_r0_body.ccounters89 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s789.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s789.ffi).mlx.nnext) = (19948, 17044)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue89 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s788.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s789.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa89.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp89 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s789.ffi).mlx.tokens.all (bSN 3859) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean89 : Conv.cleanListB 19948 131072 (fun r => Nat.ble 79792 r) PRE_first_tail_x15_r0_body.s789
    (PRE_first_tail_x15_r0_body.wrB89 ++ (List.range 1).map (2744411 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs89 : bigsOutB 19948 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s789.ffi).mlx = true

end Host.Load.Run.Tpl
