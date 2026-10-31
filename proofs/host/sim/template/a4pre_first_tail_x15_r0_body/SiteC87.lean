import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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

/-! The compaction after the merge at call site 87 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s852` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa87` into the merged state
`PRE_first_tail_x15_r0_body.s851`. -/

def PRE_first_tail_x15_r0_body.pl87 : List Nat := [2744739, 2743914, 2744745, 2744741, 2743916, 2744747]
def PRE_first_tail_x15_r0_body.nr87 : List Nat := [3833, 3832, 3808, 3816, 3821, 3826, 3831, 3805, 3806, 3807, 3814, 3815, 3803, 3810, 3811, 3812, 3813, 3809]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd87 : RData :=
  ⟨2743633, 2744782, Stage.setAll PTrie.nil [(2743627, 2744739), (2743628, 2743914), (2743629, 2744745), (2743630, 2744741), (2743631, 2743916), (2743632, 2744747)], Stage.setAll PTrie.nil [(19925, 19951), (19926, 19929), (19927, 19952)],
   19928, 19953, 17027, 17027, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3803, .ref 3833), (3804, .ref 3832), (3805, .ref 3808), (3806, .ref 3816), (3807, .ref 3821), (3808, .ref 3826), (3809, .ref 3831), (3810, .ref 3805), (3811, .ref 3806), (3812, .ref 3807), (3813, .ref 3814), (3814, .ref 3815), (3815, .ref 3803), (3816, .ref 3810), (3817, .ref 3811), (3818, .ref 3812), (3819, .ref 3813), (3820, .ref 3809)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa87 : Map :=
  Conv.Map.compact 2743627 2744782 3803 PRE_first_tail_x15_r0_body.pl87 (PRE_first_tail_x15_r0_body.nr87.map NumV.ref) PRE_first_tail_x15_r0_body.kd87.big
    PRE_first_tail_x15_r0_body.kd87.region PRE_first_tail_x15_r0_body.kd87.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws87 : List Nat := [2478, 2479, 2480, 2481, 2482, 2483, 2484, 2485, 2486, 2487, 2488, 2489, 2490, 2491, 2492, 2493, 2494, 2495]
noncomputable def PRE_first_tail_x15_r0_body.crs87 : List SymE := PRE_first_tail_x15_r0_body.nr87.map fun r => (nth? PRE_first_tail_x15_r0_body.S851.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta87 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws87 PRE_first_tail_x15_r0_body.crs87
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB87 : List Nat := [2665, 2672522, 2673467, 2742801, 2743346, 2743602]

kernel_rfl PRE_first_tail_x15_r0_body.ctab87 : PRE_first_tail_x15_r0_body.S852.tab = PRE_first_tail_x15_r0_body.S850.tab ++ PRE_first_tail_x15_r0_body.cws87.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace87 : PRE_first_tail_x15_r0_body.s852.trace = PRE_first_tail_x15_r0_body.s850.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext87 : PRE_first_tail_x15_r0_body.s852.next = 2743633
kernel_rfl PRE_first_tail_x15_r0_body.ccounters87 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.nnext) = (19928, 17027)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue87 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s851.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa87.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp87 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx.tokens.all (bSN 3821) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean87 : Conv.cleanListB 19928 131072 (fun r => Nat.ble 79712 r) PRE_first_tail_x15_r0_body.s852
    (PRE_first_tail_x15_r0_body.wrB87 ++ (List.range 6).map (2743627 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs87 : bigsOutB 19928 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s852.ffi).mlx = true

end Host.Load.Run.Tpl
