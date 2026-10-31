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

/-! The compaction after the merge at call site 66 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s595` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa66` into the merged state
`PRE_first_tail_x15_r0_body.s594`. -/

def PRE_first_tail_x15_r0_body.pl66 : List Nat := [2728171, 2727346, 2728177, 2728173, 2727348, 2728179]
def PRE_first_tail_x15_r0_body.nr66 : List Nat := [2936, 2935, 2911, 2919, 2924, 2929, 2934, 2908, 2909, 2910, 2917, 2918, 2906, 2913, 2914, 2915, 2916, 2912]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd66 : RData :=
  ⟨2727065, 2728214, Stage.setAll PTrie.nil [(2727059, 2728171), (2727060, 2727346), (2727061, 2728177), (2727062, 2728173), (2727063, 2727348), (2727064, 2728179)], Stage.setAll PTrie.nil [(19510, 19536), (19511, 19514), (19512, 19537)],
   19513, 19538, 16616, 16616, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2906, .ref 2936), (2907, .ref 2935), (2908, .ref 2911), (2909, .ref 2919), (2910, .ref 2924), (2911, .ref 2929), (2912, .ref 2934), (2913, .ref 2908), (2914, .ref 2909), (2915, .ref 2910), (2916, .ref 2917), (2917, .ref 2918), (2918, .ref 2906), (2919, .ref 2913), (2920, .ref 2914), (2921, .ref 2915), (2922, .ref 2916), (2923, .ref 2912)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa66 : Map :=
  Conv.Map.compact 2727059 2728214 2906 PRE_first_tail_x15_r0_body.pl66 (PRE_first_tail_x15_r0_body.nr66.map NumV.ref) PRE_first_tail_x15_r0_body.kd66.big
    PRE_first_tail_x15_r0_body.kd66.region PRE_first_tail_x15_r0_body.kd66.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws66 : List Nat := [2146, 2147, 2148, 2149, 2150, 2151, 2152, 2153, 2154, 2155, 2156, 2157, 2158, 2159, 2160, 2161, 2162, 2163]
noncomputable def PRE_first_tail_x15_r0_body.crs66 : List SymE := PRE_first_tail_x15_r0_body.nr66.map fun r => (nth? PRE_first_tail_x15_r0_body.S594.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta66 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws66 PRE_first_tail_x15_r0_body.crs66
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB66 : List Nat := [2665, 2672465, 2673467, 2726233, 2726778, 2727034]

kernel_rfl PRE_first_tail_x15_r0_body.ctab66 : PRE_first_tail_x15_r0_body.S595.tab = PRE_first_tail_x15_r0_body.S593.tab ++ PRE_first_tail_x15_r0_body.cws66.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace66 : PRE_first_tail_x15_r0_body.s595.trace = PRE_first_tail_x15_r0_body.s593.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext66 : PRE_first_tail_x15_r0_body.s595.next = 2727065
kernel_rfl PRE_first_tail_x15_r0_body.ccounters66 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.nnext) = (19513, 16616)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s594.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa66.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp66 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx.tokens.all (bSN 2924) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean66 : Conv.cleanListB 19513 131072 (fun r => Nat.ble 78052 r) PRE_first_tail_x15_r0_body.s595
    (PRE_first_tail_x15_r0_body.wrB66 ++ (List.range 6).map (2727059 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs66 : bigsOutB 19513 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s595.ffi).mlx = true

end Host.Load.Run.Tpl
