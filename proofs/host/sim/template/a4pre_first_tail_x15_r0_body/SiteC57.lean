import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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

/-! The compaction after the merge at call site 57 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s564` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa57` into the merged state
`PRE_first_tail_x15_r0_body.s563`. -/

def PRE_first_tail_x15_r0_body.pl57 : List Nat := [2720530, 2720366, 2720418, 2720531, 2720532, 2720368, 2720420, 2720529, 2720528, 2720527, 2720526, 2720520, 2720471, 2720522, 2720473]
def PRE_first_tail_x15_r0_body.nr57 : List Nat := [2534, 2535, 2531, 2537, 2533, 2541, 2542, 2539, 2540]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd57 : RData :=
  ⟨2720183, 2720533, Stage.setAll PTrie.nil [(2720168, 2720530), (2720169, 2720366), (2720170, 2720418), (2720171, 2720531), (2720172, 2720532), (2720173, 2720368), (2720174, 2720420), (2720175, 2720529), (2720176, 2720528), (2720177, 2720527), (2720178, 2720526), (2720179, 2720520), (2720180, 2720471), (2720181, 2720522), (2720182, 2720473)], Stage.setAll PTrie.nil [(19337, 19339), (19338, 19340), (19339, 19342), (19340, 19341)],
   19341, 19343, 16430, 16430, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2526, .ref 2534), (2527, .ref 2535), (2528, .ref 2531), (2529, .ref 2537), (2530, .ref 2533), (2531, .ref 2541), (2532, .ref 2542), (2533, .ref 2539), (2534, .ref 2540)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa57 : Map :=
  Conv.Map.compact 2720168 2720533 2526 PRE_first_tail_x15_r0_body.pl57 (PRE_first_tail_x15_r0_body.nr57.map NumV.ref) PRE_first_tail_x15_r0_body.kd57.big
    PRE_first_tail_x15_r0_body.kd57.region PRE_first_tail_x15_r0_body.kd57.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws57 : List Nat := [1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001]
noncomputable def PRE_first_tail_x15_r0_body.crs57 : List SymE := PRE_first_tail_x15_r0_body.nr57.map fun r => (nth? PRE_first_tail_x15_r0_body.S563.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta57 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws57 PRE_first_tail_x15_r0_body.crs57
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB57 : List Nat := [2665, 2672446, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab57 : PRE_first_tail_x15_r0_body.S564.tab = PRE_first_tail_x15_r0_body.S562.tab ++ PRE_first_tail_x15_r0_body.cws57.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace57 : PRE_first_tail_x15_r0_body.s564.trace = PRE_first_tail_x15_r0_body.s562.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext57 : PRE_first_tail_x15_r0_body.s564.next = 2720183
kernel_rfl PRE_first_tail_x15_r0_body.ccounters57 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.nnext) = (19341, 16430)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s563.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa57.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx.tokens.all (bSN 2535) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean57 : Conv.cleanListB 19341 131072 (fun r => Nat.ble 77364 r) PRE_first_tail_x15_r0_body.s564
    (PRE_first_tail_x15_r0_body.wrB57 ++ (List.range 15).map (2720168 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs57 : bigsOutB 19341 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s564.ffi).mlx = true

end Host.Load.Run.Tpl
