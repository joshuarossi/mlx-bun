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

/-! The compaction after the merge at call site 60 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s593` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa60` into the merged state
`PRE_first_tail_x15_r0_body.s592`. -/

def PRE_first_tail_x15_r0_body.pl60 : List Nat := [2723659, 2722834, 2723665, 2723661, 2722836, 2723667]
def PRE_first_tail_x15_r0_body.nr60 : List Nat := [2678, 2677, 2653, 2661, 2666, 2671, 2676, 2650, 2651, 2652, 2659, 2660, 2648, 2655, 2656, 2657, 2658, 2654]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd60 : RData :=
  ⟨2722553, 2723702, Stage.setAll PTrie.nil [(2722547, 2723659), (2722548, 2722834), (2722549, 2723665), (2722550, 2723661), (2722551, 2722836), (2722552, 2723667)], Stage.setAll PTrie.nil [(19396, 19422), (19397, 19400), (19398, 19423)],
   19399, 19424, 16490, 16490, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(2648, .ref 2678), (2649, .ref 2677), (2650, .ref 2653), (2651, .ref 2661), (2652, .ref 2666), (2653, .ref 2671), (2654, .ref 2676), (2655, .ref 2650), (2656, .ref 2651), (2657, .ref 2652), (2658, .ref 2659), (2659, .ref 2660), (2660, .ref 2648), (2661, .ref 2655), (2662, .ref 2656), (2663, .ref 2657), (2664, .ref 2658), (2665, .ref 2654)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa60 : Map :=
  Conv.Map.compact 2722547 2723702 2648 PRE_first_tail_x15_r0_body.pl60 (PRE_first_tail_x15_r0_body.nr60.map NumV.ref) PRE_first_tail_x15_r0_body.kd60.big
    PRE_first_tail_x15_r0_body.kd60.region PRE_first_tail_x15_r0_body.kd60.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws60 : List Nat := [2038, 2039, 2040, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 2048, 2049, 2050, 2051, 2052, 2053, 2054, 2055]
noncomputable def PRE_first_tail_x15_r0_body.crs60 : List SymE := PRE_first_tail_x15_r0_body.nr60.map fun r => (nth? PRE_first_tail_x15_r0_body.S592.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta60 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws60 PRE_first_tail_x15_r0_body.crs60
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB60 : List Nat := [2665, 2672455, 2673467, 2721721, 2722266, 2722522]

kernel_rfl PRE_first_tail_x15_r0_body.ctab60 : PRE_first_tail_x15_r0_body.S593.tab = PRE_first_tail_x15_r0_body.S591.tab ++ PRE_first_tail_x15_r0_body.cws60.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace60 : PRE_first_tail_x15_r0_body.s593.trace = PRE_first_tail_x15_r0_body.s591.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext60 : PRE_first_tail_x15_r0_body.s593.next = 2722553
kernel_rfl PRE_first_tail_x15_r0_body.ccounters60 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.nnext) = (19399, 16490)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s592.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa60.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp60 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx.tokens.all (bSN 2666) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean60 : Conv.cleanListB 19399 131072 (fun r => Nat.ble 77596 r) PRE_first_tail_x15_r0_body.s593
    (PRE_first_tail_x15_r0_body.wrB60 ++ (List.range 6).map (2722547 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs60 : bigsOutB 19399 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s593.ffi).mlx = true

end Host.Load.Run.Tpl
