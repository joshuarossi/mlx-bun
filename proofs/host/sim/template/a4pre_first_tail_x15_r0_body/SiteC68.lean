import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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

/-! The compaction after the merge at call site 68 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s606` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa68` into the merged state
`PRE_first_tail_x15_r0_body.s605`. -/

def PRE_first_tail_x15_r0_body.pl68 : List Nat := [2727853]
def PRE_first_tail_x15_r0_body.nr68 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd68 : RData :=
  ⟨2727844, 2727854, Stage.setAll PTrie.nil [(2727843, 2727853)], Stage.setAll PTrie.nil [],
   19533, 19533, 16633, 16633, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa68 : Map :=
  Conv.Map.compact 2727843 2727854 2962 PRE_first_tail_x15_r0_body.pl68 (PRE_first_tail_x15_r0_body.nr68.map NumV.ref) PRE_first_tail_x15_r0_body.kd68.big
    PRE_first_tail_x15_r0_body.kd68.region PRE_first_tail_x15_r0_body.kd68.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws68 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs68 : List SymE := PRE_first_tail_x15_r0_body.nr68.map fun r => (nth? PRE_first_tail_x15_r0_body.S605.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta68 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws68 PRE_first_tail_x15_r0_body.crs68
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB68 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab68 : PRE_first_tail_x15_r0_body.S606.tab = PRE_first_tail_x15_r0_body.S604.tab ++ PRE_first_tail_x15_r0_body.cws68.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace68 : PRE_first_tail_x15_r0_body.s606.trace = PRE_first_tail_x15_r0_body.s604.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext68 : PRE_first_tail_x15_r0_body.s606.next = 2727844
kernel_rfl PRE_first_tail_x15_r0_body.ccounters68 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.nnext) = (19533, 16633)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s605.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa68.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp68 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx.tokens.all (bSN 2962) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean68 : Conv.cleanListB 19533 131072 (fun r => Nat.ble 78132 r) PRE_first_tail_x15_r0_body.s606
    (PRE_first_tail_x15_r0_body.wrB68 ++ (List.range 1).map (2727843 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs68 : bigsOutB 19533 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s606.ffi).mlx = true

end Host.Load.Run.Tpl
