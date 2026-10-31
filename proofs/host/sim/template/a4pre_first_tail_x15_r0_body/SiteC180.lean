import host.sim.template.a4pre_first_tail_x15_r0_body.H54
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

/-! The compaction after the merge at call site 180 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1743` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa180` into the merged state
`PRE_first_tail_x15_r0_body.s1742`. -/

def PRE_first_tail_x15_r0_body.pl180 : List Nat := [2817839, 2817014, 2817845, 2817841, 2817016, 2817847]
def PRE_first_tail_x15_r0_body.nr180 : List Nat := [7808, 7807, 7783, 7791, 7796, 7801, 7806, 7780, 7781, 7782, 7789, 7790, 7778, 7785, 7786, 7787, 7788, 7784]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd180 : RData :=
  ⟨2816733, 2817882, Stage.setAll PTrie.nil [(2816727, 2817839), (2816728, 2817014), (2816729, 2817845), (2816730, 2817841), (2816731, 2817016), (2816732, 2817847)], Stage.setAll PTrie.nil [(21756, 21782), (21757, 21760), (21758, 21783)],
   21759, 21784, 18860, 18860, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7778, .ref 7808), (7779, .ref 7807), (7780, .ref 7783), (7781, .ref 7791), (7782, .ref 7796), (7783, .ref 7801), (7784, .ref 7806), (7785, .ref 7780), (7786, .ref 7781), (7787, .ref 7782), (7788, .ref 7789), (7789, .ref 7790), (7790, .ref 7778), (7791, .ref 7785), (7792, .ref 7786), (7793, .ref 7787), (7794, .ref 7788), (7795, .ref 7784)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa180 : Map :=
  Conv.Map.compact 2816727 2817882 7778 PRE_first_tail_x15_r0_body.pl180 (PRE_first_tail_x15_r0_body.nr180.map NumV.ref) PRE_first_tail_x15_r0_body.kd180.big
    PRE_first_tail_x15_r0_body.kd180.region PRE_first_tail_x15_r0_body.kd180.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws180 : List Nat := [4058, 4059, 4060, 4061, 4062, 4063, 4064, 4065, 4066, 4067, 4068, 4069, 4070, 4071, 4072, 4073, 4074, 4075]
noncomputable def PRE_first_tail_x15_r0_body.crs180 : List SymE := PRE_first_tail_x15_r0_body.nr180.map fun r => (nth? PRE_first_tail_x15_r0_body.S1742.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta180 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws180 PRE_first_tail_x15_r0_body.crs180
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB180 : List Nat := [2665, 2672765, 2673467, 2815901, 2816446, 2816702]

kernel_rfl PRE_first_tail_x15_r0_body.ctab180 : PRE_first_tail_x15_r0_body.S1743.tab = PRE_first_tail_x15_r0_body.S1741.tab ++ PRE_first_tail_x15_r0_body.cws180.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace180 : PRE_first_tail_x15_r0_body.s1743.trace = PRE_first_tail_x15_r0_body.s1741.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext180 : PRE_first_tail_x15_r0_body.s1743.next = 2816733
kernel_rfl PRE_first_tail_x15_r0_body.ccounters180 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx.nnext) = (21759, 18860)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue180 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1742.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa180.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp180 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx.tokens.all (bSN 7796) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean180 : Conv.cleanListB 21759 131072 (fun r => Nat.ble 87036 r) PRE_first_tail_x15_r0_body.s1743
    (PRE_first_tail_x15_r0_body.wrB180 ++ (List.range 6).map (2816727 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs180 : bigsOutB 21759 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1743.ffi).mlx = true

end Host.Load.Run.Tpl
