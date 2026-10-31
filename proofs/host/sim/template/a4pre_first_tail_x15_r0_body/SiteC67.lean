import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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

/-! The compaction after the merge at call site 67 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s659` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa67` into the merged state
`PRE_first_tail_x15_r0_body.s658`. -/

def PRE_first_tail_x15_r0_body.pl67 : List Nat := []
def PRE_first_tail_x15_r0_body.nr67 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd67 : RData :=
  ⟨2727555, 2727557, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19526, 19526, 16629, 16629, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa67 : Map :=
  Conv.Map.compact 2727555 2727557 2945 PRE_first_tail_x15_r0_body.pl67 (PRE_first_tail_x15_r0_body.nr67.map NumV.ref) PRE_first_tail_x15_r0_body.kd67.big
    PRE_first_tail_x15_r0_body.kd67.region PRE_first_tail_x15_r0_body.kd67.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws67 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs67 : List SymE := PRE_first_tail_x15_r0_body.nr67.map fun r => (nth? PRE_first_tail_x15_r0_body.S658.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta67 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws67 PRE_first_tail_x15_r0_body.crs67
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB67 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab67 : PRE_first_tail_x15_r0_body.S659.tab = PRE_first_tail_x15_r0_body.S657.tab ++ PRE_first_tail_x15_r0_body.cws67.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace67 : PRE_first_tail_x15_r0_body.s659.trace = PRE_first_tail_x15_r0_body.s657.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext67 : PRE_first_tail_x15_r0_body.s659.next = 2727555
kernel_rfl PRE_first_tail_x15_r0_body.ccounters67 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.nnext) = (19526, 16629)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s658.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa67.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx.tokens.all (bSN 2945) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean67 : Conv.cleanListB 19526 131072 (fun r => Nat.ble 78104 r) PRE_first_tail_x15_r0_body.s659
    (PRE_first_tail_x15_r0_body.wrB67 ++ (List.range 0).map (2727555 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs67 : bigsOutB 19526 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s659.ffi).mlx = true

end Host.Load.Run.Tpl
