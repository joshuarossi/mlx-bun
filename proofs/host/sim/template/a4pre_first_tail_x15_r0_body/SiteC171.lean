import host.sim.template.a4pre_first_tail_x15_r0_body.H51
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

/-! The compaction after the merge at call site 171 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1657` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa171` into the merged state
`PRE_first_tail_x15_r0_body.s1656`. -/

def PRE_first_tail_x15_r0_body.pl171 : List Nat := [2810671, 2809846, 2810677, 2810673, 2809848, 2810679]
def PRE_first_tail_x15_r0_body.nr171 : List Nat := [7424, 7423, 7399, 7407, 7412, 7417, 7422, 7396, 7397, 7398, 7405, 7406, 7394, 7401, 7402, 7403, 7404, 7400]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd171 : RData :=
  ⟨2809565, 2810714, Stage.setAll PTrie.nil [(2809559, 2810671), (2809560, 2809846), (2809561, 2810677), (2809562, 2810673), (2809563, 2809848), (2809564, 2810679)], Stage.setAll PTrie.nil [(21577, 21603), (21578, 21581), (21579, 21604)],
   21580, 21605, 18686, 18686, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7394, .ref 7424), (7395, .ref 7423), (7396, .ref 7399), (7397, .ref 7407), (7398, .ref 7412), (7399, .ref 7417), (7400, .ref 7422), (7401, .ref 7396), (7402, .ref 7397), (7403, .ref 7398), (7404, .ref 7405), (7405, .ref 7406), (7406, .ref 7394), (7407, .ref 7401), (7408, .ref 7402), (7409, .ref 7403), (7410, .ref 7404), (7411, .ref 7400)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa171 : Map :=
  Conv.Map.compact 2809559 2810714 7394 PRE_first_tail_x15_r0_body.pl171 (PRE_first_tail_x15_r0_body.nr171.map NumV.ref) PRE_first_tail_x15_r0_body.kd171.big
    PRE_first_tail_x15_r0_body.kd171.region PRE_first_tail_x15_r0_body.kd171.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws171 : List Nat := [3901, 3902, 3903, 3904, 3905, 3906, 3907, 3908, 3909, 3910, 3911, 3912, 3913, 3914, 3915, 3916, 3917, 3918]
noncomputable def PRE_first_tail_x15_r0_body.crs171 : List SymE := PRE_first_tail_x15_r0_body.nr171.map fun r => (nth? PRE_first_tail_x15_r0_body.S1656.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta171 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws171 PRE_first_tail_x15_r0_body.crs171
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB171 : List Nat := [2665, 2672739, 2673467, 2808733, 2809278, 2809534]

kernel_rfl PRE_first_tail_x15_r0_body.ctab171 : PRE_first_tail_x15_r0_body.S1657.tab = PRE_first_tail_x15_r0_body.S1655.tab ++ PRE_first_tail_x15_r0_body.cws171.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace171 : PRE_first_tail_x15_r0_body.s1657.trace = PRE_first_tail_x15_r0_body.s1655.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext171 : PRE_first_tail_x15_r0_body.s1657.next = 2809565
kernel_rfl PRE_first_tail_x15_r0_body.ccounters171 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.nnext) = (21580, 18686)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue171 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1656.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa171.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp171 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.tokens.all (bSN 7412) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean171 : Conv.cleanListB 21580 131072 (fun r => Nat.ble 86320 r) PRE_first_tail_x15_r0_body.s1657
    (PRE_first_tail_x15_r0_body.wrB171 ++ (List.range 6).map (2809559 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs171 : bigsOutB 21580 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx = true

end Host.Load.Run.Tpl
