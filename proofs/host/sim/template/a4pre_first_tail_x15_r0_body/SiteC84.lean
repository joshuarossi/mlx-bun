import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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

/-! The compaction after the merge at call site 84 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s751` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa84` into the merged state
`PRE_first_tail_x15_r0_body.s750`. -/

def PRE_first_tail_x15_r0_body.pl84 : List Nat := [2742483, 2741658, 2742489, 2742485, 2741660, 2742491]
def PRE_first_tail_x15_r0_body.nr84 : List Nat := [3704, 3703, 3679, 3687, 3692, 3697, 3702, 3676, 3677, 3678, 3685, 3686, 3674, 3681, 3682, 3683, 3684, 3680]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd84 : RData :=
  ⟨2741377, 2742526, Stage.setAll PTrie.nil [(2741371, 2742483), (2741372, 2741658), (2741373, 2742489), (2741374, 2742485), (2741375, 2741660), (2741376, 2742491)], Stage.setAll PTrie.nil [(19868, 19894), (19869, 19872), (19870, 19895)],
   19871, 19896, 16964, 16964, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3674, .ref 3704), (3675, .ref 3703), (3676, .ref 3679), (3677, .ref 3687), (3678, .ref 3692), (3679, .ref 3697), (3680, .ref 3702), (3681, .ref 3676), (3682, .ref 3677), (3683, .ref 3678), (3684, .ref 3685), (3685, .ref 3686), (3686, .ref 3674), (3687, .ref 3681), (3688, .ref 3682), (3689, .ref 3683), (3690, .ref 3684), (3691, .ref 3680)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa84 : Map :=
  Conv.Map.compact 2741371 2742526 3674 PRE_first_tail_x15_r0_body.pl84 (PRE_first_tail_x15_r0_body.nr84.map NumV.ref) PRE_first_tail_x15_r0_body.kd84.big
    PRE_first_tail_x15_r0_body.kd84.region PRE_first_tail_x15_r0_body.kd84.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws84 : List Nat := [2424, 2425, 2426, 2427, 2428, 2429, 2430, 2431, 2432, 2433, 2434, 2435, 2436, 2437, 2438, 2439, 2440, 2441]
noncomputable def PRE_first_tail_x15_r0_body.crs84 : List SymE := PRE_first_tail_x15_r0_body.nr84.map fun r => (nth? PRE_first_tail_x15_r0_body.S750.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta84 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws84 PRE_first_tail_x15_r0_body.crs84
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB84 : List Nat := [2665, 2672517, 2673467, 2740545, 2741090, 2741346]

kernel_rfl PRE_first_tail_x15_r0_body.ctab84 : PRE_first_tail_x15_r0_body.S751.tab = PRE_first_tail_x15_r0_body.S749.tab ++ PRE_first_tail_x15_r0_body.cws84.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace84 : PRE_first_tail_x15_r0_body.s751.trace = PRE_first_tail_x15_r0_body.s749.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext84 : PRE_first_tail_x15_r0_body.s751.next = 2741377
kernel_rfl PRE_first_tail_x15_r0_body.ccounters84 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.nnext) = (19871, 16964)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue84 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s750.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa84.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp84 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx.tokens.all (bSN 3692) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean84 : Conv.cleanListB 19871 131072 (fun r => Nat.ble 79484 r) PRE_first_tail_x15_r0_body.s751
    (PRE_first_tail_x15_r0_body.wrB84 ++ (List.range 6).map (2741371 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs84 : bigsOutB 19871 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s751.ffi).mlx = true

end Host.Load.Run.Tpl
