import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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

/-! The compaction after the merge at call site 120 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1168` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa120` into the merged state
`PRE_first_tail_x15_r0_body.s1167`. -/

def PRE_first_tail_x15_r0_body.pl120 : List Nat := [2770735, 2769910, 2770741, 2770737, 2769912, 2770743]
def PRE_first_tail_x15_r0_body.nr120 : List Nat := [5243, 5242, 5218, 5226, 5231, 5236, 5241, 5215, 5216, 5217, 5224, 5225, 5213, 5220, 5221, 5222, 5223, 5219]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd120 : RData :=
  ⟨2769629, 2770778, Stage.setAll PTrie.nil [(2769623, 2770735), (2769624, 2769910), (2769625, 2770741), (2769626, 2770737), (2769627, 2769912), (2769628, 2770743)], Stage.setAll PTrie.nil [(20576, 20602), (20577, 20580), (20578, 20603)],
   20579, 20604, 17675, 17675, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5213, .ref 5243), (5214, .ref 5242), (5215, .ref 5218), (5216, .ref 5226), (5217, .ref 5231), (5218, .ref 5236), (5219, .ref 5241), (5220, .ref 5215), (5221, .ref 5216), (5222, .ref 5217), (5223, .ref 5224), (5224, .ref 5225), (5225, .ref 5213), (5226, .ref 5220), (5227, .ref 5221), (5228, .ref 5222), (5229, .ref 5223), (5230, .ref 5219)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa120 : Map :=
  Conv.Map.compact 2769623 2770778 5213 PRE_first_tail_x15_r0_body.pl120 (PRE_first_tail_x15_r0_body.nr120.map NumV.ref) PRE_first_tail_x15_r0_body.kd120.big
    PRE_first_tail_x15_r0_body.kd120.region PRE_first_tail_x15_r0_body.kd120.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws120 : List Nat := [3027, 3028, 3029, 3030, 3031, 3032, 3033, 3034, 3035, 3036, 3037, 3038, 3039, 3040, 3041, 3042, 3043, 3044]
noncomputable def PRE_first_tail_x15_r0_body.crs120 : List SymE := PRE_first_tail_x15_r0_body.nr120.map fun r => (nth? PRE_first_tail_x15_r0_body.S1167.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta120 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws120 PRE_first_tail_x15_r0_body.crs120
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB120 : List Nat := [2665, 2672610, 2673467, 2768797, 2769342, 2769598]

kernel_rfl PRE_first_tail_x15_r0_body.ctab120 : PRE_first_tail_x15_r0_body.S1168.tab = PRE_first_tail_x15_r0_body.S1166.tab ++ PRE_first_tail_x15_r0_body.cws120.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace120 : PRE_first_tail_x15_r0_body.s1168.trace = PRE_first_tail_x15_r0_body.s1166.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext120 : PRE_first_tail_x15_r0_body.s1168.next = 2769629
kernel_rfl PRE_first_tail_x15_r0_body.ccounters120 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.nnext) = (20579, 17675)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue120 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1167.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa120.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp120 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.tokens.all (bSN 5231) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean120 : Conv.cleanListB 20579 131072 (fun r => Nat.ble 82316 r) PRE_first_tail_x15_r0_body.s1168
    (PRE_first_tail_x15_r0_body.wrB120 ++ (List.range 6).map (2769623 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs120 : bigsOutB 20579 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx = true

end Host.Load.Run.Tpl
