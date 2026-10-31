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

/-! The compaction after the merge at call site 63 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s568` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa63` into the merged state
`PRE_first_tail_x15_r0_body.s567`. -/

def PRE_first_tail_x15_r0_body.pl63 : List Nat := [2725915, 2725090, 2725921, 2725917, 2725092, 2725923]
def PRE_first_tail_x15_r0_body.nr63 : List Nat := [2807, 2806, 2782, 2790, 2795, 2800, 2805, 2779, 2780, 2781, 2788, 2789, 2777, 2784, 2785, 2786, 2787, 2783]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd63 : RData :=
  ⟨2724809, 2725958, Stage.setAll PTrie.nil [(2724803, 2725915), (2724804, 2725090), (2724805, 2725921), (2724806, 2725917), (2724807, 2725092), (2724808, 2725923)], Stage.setAll PTrie.nil [(19453, 19479), (19454, 19457), (19455, 19480)],
   19456, 19481, 16553, 16553, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2777, .ref 2807), (2778, .ref 2806), (2779, .ref 2782), (2780, .ref 2790), (2781, .ref 2795), (2782, .ref 2800), (2783, .ref 2805), (2784, .ref 2779), (2785, .ref 2780), (2786, .ref 2781), (2787, .ref 2788), (2788, .ref 2789), (2789, .ref 2777), (2790, .ref 2784), (2791, .ref 2785), (2792, .ref 2786), (2793, .ref 2787), (2794, .ref 2783)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa63 : Map :=
  Conv.Map.compact 2724803 2725958 2777 PRE_first_tail_x15_r0_body.pl63 (PRE_first_tail_x15_r0_body.nr63.map NumV.ref) PRE_first_tail_x15_r0_body.kd63.big
    PRE_first_tail_x15_r0_body.kd63.region PRE_first_tail_x15_r0_body.kd63.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws63 : List Nat := [2092, 2093, 2094, 2095, 2096, 2097, 2098, 2099, 2100, 2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109]
noncomputable def PRE_first_tail_x15_r0_body.crs63 : List SymE := PRE_first_tail_x15_r0_body.nr63.map fun r => (nth? PRE_first_tail_x15_r0_body.S567.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta63 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws63 PRE_first_tail_x15_r0_body.crs63
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB63 : List Nat := [2665, 2672460, 2673467, 2723977, 2724522, 2724778]

kernel_rfl PRE_first_tail_x15_r0_body.ctab63 : PRE_first_tail_x15_r0_body.S568.tab = PRE_first_tail_x15_r0_body.S566.tab ++ PRE_first_tail_x15_r0_body.cws63.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace63 : PRE_first_tail_x15_r0_body.s568.trace = PRE_first_tail_x15_r0_body.s566.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext63 : PRE_first_tail_x15_r0_body.s568.next = 2724809
kernel_rfl PRE_first_tail_x15_r0_body.ccounters63 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.nnext) = (19456, 16553)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s567.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa63.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp63 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx.tokens.all (bSN 2795) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean63 : Conv.cleanListB 19456 131072 (fun r => Nat.ble 77824 r) PRE_first_tail_x15_r0_body.s568
    (PRE_first_tail_x15_r0_body.wrB63 ++ (List.range 6).map (2724803 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs63 : bigsOutB 19456 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s568.ffi).mlx = true

end Host.Load.Run.Tpl
