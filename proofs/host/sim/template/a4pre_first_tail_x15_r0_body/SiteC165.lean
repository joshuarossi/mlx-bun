import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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

/-! The compaction after the merge at call site 165 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1459` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa165` into the merged state
`PRE_first_tail_x15_r0_body.s1458`. -/

def PRE_first_tail_x15_r0_body.pl165 : List Nat := [2805278, 2805114, 2805166, 2805279, 2805280, 2805116, 2805168, 2805277, 2805276, 2805275, 2805274, 2805268, 2805219, 2805270, 2805221]
def PRE_first_tail_x15_r0_body.nr165 : List Nat := [7151, 7152, 7148, 7154, 7150, 7158, 7159, 7156, 7157]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd165 : RData :=
  ⟨2804931, 2805281, Stage.setAll PTrie.nil [(2804916, 2805278), (2804917, 2805114), (2804918, 2805166), (2804919, 2805279), (2804920, 2805280), (2804921, 2805116), (2804922, 2805168), (2804923, 2805277), (2804924, 2805276), (2804925, 2805275), (2804926, 2805274), (2804927, 2805268), (2804928, 2805219), (2804929, 2805270), (2804930, 2805221)], Stage.setAll PTrie.nil [(21461, 21463), (21462, 21464), (21463, 21466), (21464, 21465)],
   21465, 21467, 18563, 18563, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7143, .ref 7151), (7144, .ref 7152), (7145, .ref 7148), (7146, .ref 7154), (7147, .ref 7150), (7148, .ref 7158), (7149, .ref 7159), (7150, .ref 7156), (7151, .ref 7157)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa165 : Map :=
  Conv.Map.compact 2804916 2805281 7143 PRE_first_tail_x15_r0_body.pl165 (PRE_first_tail_x15_r0_body.nr165.map NumV.ref) PRE_first_tail_x15_r0_body.kd165.big
    PRE_first_tail_x15_r0_body.kd165.region PRE_first_tail_x15_r0_body.kd165.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws165 : List Nat := [3790, 3791, 3792, 3793, 3794, 3795, 3796, 3797, 3798]
noncomputable def PRE_first_tail_x15_r0_body.crs165 : List SymE := PRE_first_tail_x15_r0_body.nr165.map fun r => (nth? PRE_first_tail_x15_r0_body.S1458.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta165 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws165 PRE_first_tail_x15_r0_body.crs165
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB165 : List Nat := [2665, 2672725, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab165 : PRE_first_tail_x15_r0_body.S1459.tab = PRE_first_tail_x15_r0_body.S1457.tab ++ PRE_first_tail_x15_r0_body.cws165.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace165 : PRE_first_tail_x15_r0_body.s1459.trace = PRE_first_tail_x15_r0_body.s1457.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext165 : PRE_first_tail_x15_r0_body.s1459.next = 2804931
kernel_rfl PRE_first_tail_x15_r0_body.ccounters165 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx.nnext) = (21465, 18563)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue165 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1458.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa165.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp165 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx.tokens.all (bSN 7152) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean165 : Conv.cleanListB 21465 131072 (fun r => Nat.ble 85860 r) PRE_first_tail_x15_r0_body.s1459
    (PRE_first_tail_x15_r0_body.wrB165 ++ (List.range 15).map (2804916 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs165 : bigsOutB 21465 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1459.ffi).mlx = true

end Host.Load.Run.Tpl
