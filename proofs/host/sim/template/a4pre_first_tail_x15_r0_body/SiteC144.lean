import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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

/-! The compaction after the merge at call site 144 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1398` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa144` into the merged state
`PRE_first_tail_x15_r0_body.s1397`. -/

def PRE_first_tail_x15_r0_body.pl144 : List Nat := [2789571, 2788746, 2789577, 2789573, 2788748, 2789579]
def PRE_first_tail_x15_r0_body.nr144 : List Nat := [6269, 6268, 6244, 6252, 6257, 6262, 6267, 6241, 6242, 6243, 6250, 6251, 6239, 6246, 6247, 6248, 6249, 6245]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd144 : RData :=
  ⟨2788465, 2789614, Stage.setAll PTrie.nil [(2788459, 2789571), (2788460, 2788746), (2788461, 2789577), (2788462, 2789573), (2788463, 2788748), (2788464, 2789579)], Stage.setAll PTrie.nil [(21048, 21074), (21049, 21052), (21050, 21075)],
   21051, 21076, 18149, 18149, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6239, .ref 6269), (6240, .ref 6268), (6241, .ref 6244), (6242, .ref 6252), (6243, .ref 6257), (6244, .ref 6262), (6245, .ref 6267), (6246, .ref 6241), (6247, .ref 6242), (6248, .ref 6243), (6249, .ref 6250), (6250, .ref 6251), (6251, .ref 6239), (6252, .ref 6246), (6253, .ref 6247), (6254, .ref 6248), (6255, .ref 6249), (6256, .ref 6245)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa144 : Map :=
  Conv.Map.compact 2788459 2789614 6239 PRE_first_tail_x15_r0_body.pl144 (PRE_first_tail_x15_r0_body.nr144.map NumV.ref) PRE_first_tail_x15_r0_body.kd144.big
    PRE_first_tail_x15_r0_body.kd144.region PRE_first_tail_x15_r0_body.kd144.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws144 : List Nat := [3431, 3432, 3433, 3434, 3435, 3436, 3437, 3438, 3439, 3440, 3441, 3442, 3443, 3444, 3445, 3446, 3447, 3448]
noncomputable def PRE_first_tail_x15_r0_body.crs144 : List SymE := PRE_first_tail_x15_r0_body.nr144.map fun r => (nth? PRE_first_tail_x15_r0_body.S1397.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta144 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws144 PRE_first_tail_x15_r0_body.crs144
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB144 : List Nat := [2665, 2672672, 2673467, 2787633, 2788178, 2788434]

kernel_rfl PRE_first_tail_x15_r0_body.ctab144 : PRE_first_tail_x15_r0_body.S1398.tab = PRE_first_tail_x15_r0_body.S1396.tab ++ PRE_first_tail_x15_r0_body.cws144.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace144 : PRE_first_tail_x15_r0_body.s1398.trace = PRE_first_tail_x15_r0_body.s1396.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext144 : PRE_first_tail_x15_r0_body.s1398.next = 2788465
kernel_rfl PRE_first_tail_x15_r0_body.ccounters144 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.nnext) = (21051, 18149)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue144 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1397.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa144.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp144 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx.tokens.all (bSN 6257) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean144 : Conv.cleanListB 21051 131072 (fun r => Nat.ble 84204 r) PRE_first_tail_x15_r0_body.s1398
    (PRE_first_tail_x15_r0_body.wrB144 ++ (List.range 6).map (2788459 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs144 : bigsOutB 21051 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1398.ffi).mlx = true

end Host.Load.Run.Tpl
