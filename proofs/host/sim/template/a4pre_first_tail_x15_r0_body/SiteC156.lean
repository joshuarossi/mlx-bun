import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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

/-! The compaction after the merge at call site 156 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1513` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa156` into the merged state
`PRE_first_tail_x15_r0_body.s1512`. -/

def PRE_first_tail_x15_r0_body.pl156 : List Nat := [2798991, 2798166, 2798997, 2798993, 2798168, 2798999]
def PRE_first_tail_x15_r0_body.nr156 : List Nat := [6782, 6781, 6757, 6765, 6770, 6775, 6780, 6754, 6755, 6756, 6763, 6764, 6752, 6759, 6760, 6761, 6762, 6758]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd156 : RData :=
  ⟨2797885, 2799034, Stage.setAll PTrie.nil [(2797879, 2798991), (2797880, 2798166), (2797881, 2798997), (2797882, 2798993), (2797883, 2798168), (2797884, 2798999)], Stage.setAll PTrie.nil [(21284, 21310), (21285, 21288), (21286, 21311)],
   21287, 21312, 18386, 18386, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6752, .ref 6782), (6753, .ref 6781), (6754, .ref 6757), (6755, .ref 6765), (6756, .ref 6770), (6757, .ref 6775), (6758, .ref 6780), (6759, .ref 6754), (6760, .ref 6755), (6761, .ref 6756), (6762, .ref 6763), (6763, .ref 6764), (6764, .ref 6752), (6765, .ref 6759), (6766, .ref 6760), (6767, .ref 6761), (6768, .ref 6762), (6769, .ref 6758)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa156 : Map :=
  Conv.Map.compact 2797879 2799034 6752 PRE_first_tail_x15_r0_body.pl156 (PRE_first_tail_x15_r0_body.nr156.map NumV.ref) PRE_first_tail_x15_r0_body.kd156.big
    PRE_first_tail_x15_r0_body.kd156.region PRE_first_tail_x15_r0_body.kd156.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws156 : List Nat := [3636, 3637, 3638, 3639, 3640, 3641, 3642, 3643, 3644, 3645, 3646, 3647, 3648, 3649, 3650, 3651, 3652, 3653]
noncomputable def PRE_first_tail_x15_r0_body.crs156 : List SymE := PRE_first_tail_x15_r0_body.nr156.map fun r => (nth? PRE_first_tail_x15_r0_body.S1512.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta156 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws156 PRE_first_tail_x15_r0_body.crs156
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB156 : List Nat := [2665, 2672703, 2673467, 2797053, 2797598, 2797854]

kernel_rfl PRE_first_tail_x15_r0_body.ctab156 : PRE_first_tail_x15_r0_body.S1513.tab = PRE_first_tail_x15_r0_body.S1511.tab ++ PRE_first_tail_x15_r0_body.cws156.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace156 : PRE_first_tail_x15_r0_body.s1513.trace = PRE_first_tail_x15_r0_body.s1511.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext156 : PRE_first_tail_x15_r0_body.s1513.next = 2797885
kernel_rfl PRE_first_tail_x15_r0_body.ccounters156 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx.nnext) = (21287, 18386)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue156 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1512.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa156.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp156 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx.tokens.all (bSN 6770) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean156 : Conv.cleanListB 21287 131072 (fun r => Nat.ble 85148 r) PRE_first_tail_x15_r0_body.s1513
    (PRE_first_tail_x15_r0_body.wrB156 ++ (List.range 6).map (2797879 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs156 : bigsOutB 21287 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1513.ffi).mlx = true

end Host.Load.Run.Tpl
