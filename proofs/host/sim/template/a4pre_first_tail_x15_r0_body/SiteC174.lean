import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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

/-! The compaction after the merge at call site 174 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1686` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa174` into the merged state
`PRE_first_tail_x15_r0_body.s1685`. -/

def PRE_first_tail_x15_r0_body.pl174 : List Nat := [2812931, 2812106, 2812937, 2812933, 2812108, 2812939]
def PRE_first_tail_x15_r0_body.nr174 : List Nat := [7553, 7552, 7528, 7536, 7541, 7546, 7551, 7525, 7526, 7527, 7534, 7535, 7523, 7530, 7531, 7532, 7533, 7529]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd174 : RData :=
  ⟨2811825, 2812974, Stage.setAll PTrie.nil [(2811819, 2812931), (2811820, 2812106), (2811821, 2812937), (2811822, 2812933), (2811823, 2812108), (2811824, 2812939)], Stage.setAll PTrie.nil [(21634, 21660), (21635, 21638), (21636, 21661)],
   21637, 21662, 18749, 18749, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7523, .ref 7553), (7524, .ref 7552), (7525, .ref 7528), (7526, .ref 7536), (7527, .ref 7541), (7528, .ref 7546), (7529, .ref 7551), (7530, .ref 7525), (7531, .ref 7526), (7532, .ref 7527), (7533, .ref 7534), (7534, .ref 7535), (7535, .ref 7523), (7536, .ref 7530), (7537, .ref 7531), (7538, .ref 7532), (7539, .ref 7533), (7540, .ref 7529)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa174 : Map :=
  Conv.Map.compact 2811819 2812974 7523 PRE_first_tail_x15_r0_body.pl174 (PRE_first_tail_x15_r0_body.nr174.map NumV.ref) PRE_first_tail_x15_r0_body.kd174.big
    PRE_first_tail_x15_r0_body.kd174.region PRE_first_tail_x15_r0_body.kd174.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws174 : List Nat := [3961, 3962, 3963, 3964, 3965, 3966, 3967, 3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977, 3978]
noncomputable def PRE_first_tail_x15_r0_body.crs174 : List SymE := PRE_first_tail_x15_r0_body.nr174.map fun r => (nth? PRE_first_tail_x15_r0_body.S1685.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta174 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws174 PRE_first_tail_x15_r0_body.crs174
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB174 : List Nat := [2665, 2672744, 2673467, 2810993, 2811538, 2811794]

kernel_rfl PRE_first_tail_x15_r0_body.ctab174 : PRE_first_tail_x15_r0_body.S1686.tab = PRE_first_tail_x15_r0_body.S1684.tab ++ PRE_first_tail_x15_r0_body.cws174.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace174 : PRE_first_tail_x15_r0_body.s1686.trace = PRE_first_tail_x15_r0_body.s1684.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext174 : PRE_first_tail_x15_r0_body.s1686.next = 2811825
kernel_rfl PRE_first_tail_x15_r0_body.ccounters174 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.nnext) = (21637, 18749)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue174 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1685.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa174.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp174 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx.tokens.all (bSN 7541) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean174 : Conv.cleanListB 21637 131072 (fun r => Nat.ble 86548 r) PRE_first_tail_x15_r0_body.s1686
    (PRE_first_tail_x15_r0_body.wrB174 ++ (List.range 6).map (2811819 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs174 : bigsOutB 21637 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1686.ffi).mlx = true

end Host.Load.Run.Tpl
