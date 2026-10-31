import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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

/-! The compaction after the merge at call site 75 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s673` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa75` into the merged state
`PRE_first_tail_x15_r0_body.s672`. -/

def PRE_first_tail_x15_r0_body.pl75 : List Nat := [2735327, 2734502, 2735333, 2735329, 2734504, 2735335]
def PRE_first_tail_x15_r0_body.nr75 : List Nat := [3320, 3319, 3295, 3303, 3308, 3313, 3318, 3292, 3293, 3294, 3301, 3302, 3290, 3297, 3298, 3299, 3300, 3296]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd75 : RData :=
  ⟨2734221, 2735370, Stage.setAll PTrie.nil [(2734215, 2735327), (2734216, 2734502), (2734217, 2735333), (2734218, 2735329), (2734219, 2734504), (2734220, 2735335)], Stage.setAll PTrie.nil [(19689, 19715), (19690, 19693), (19691, 19716)],
   19692, 19717, 16790, 16790, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3290, .ref 3320), (3291, .ref 3319), (3292, .ref 3295), (3293, .ref 3303), (3294, .ref 3308), (3295, .ref 3313), (3296, .ref 3318), (3297, .ref 3292), (3298, .ref 3293), (3299, .ref 3294), (3300, .ref 3301), (3301, .ref 3302), (3302, .ref 3290), (3303, .ref 3297), (3304, .ref 3298), (3305, .ref 3299), (3306, .ref 3300), (3307, .ref 3296)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa75 : Map :=
  Conv.Map.compact 2734215 2735370 3290 PRE_first_tail_x15_r0_body.pl75 (PRE_first_tail_x15_r0_body.nr75.map NumV.ref) PRE_first_tail_x15_r0_body.kd75.big
    PRE_first_tail_x15_r0_body.kd75.region PRE_first_tail_x15_r0_body.kd75.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws75 : List Nat := [2285, 2286, 2287, 2288, 2289, 2290, 2291, 2292, 2293, 2294, 2295, 2296, 2297, 2298, 2299, 2300, 2301, 2302]
noncomputable def PRE_first_tail_x15_r0_body.crs75 : List SymE := PRE_first_tail_x15_r0_body.nr75.map fun r => (nth? PRE_first_tail_x15_r0_body.S672.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta75 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws75 PRE_first_tail_x15_r0_body.crs75
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB75 : List Nat := [2665, 2672491, 2673467, 2733389, 2733934, 2734190]

kernel_rfl PRE_first_tail_x15_r0_body.ctab75 : PRE_first_tail_x15_r0_body.S673.tab = PRE_first_tail_x15_r0_body.S671.tab ++ PRE_first_tail_x15_r0_body.cws75.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace75 : PRE_first_tail_x15_r0_body.s673.trace = PRE_first_tail_x15_r0_body.s671.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext75 : PRE_first_tail_x15_r0_body.s673.next = 2734221
kernel_rfl PRE_first_tail_x15_r0_body.ccounters75 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.nnext) = (19692, 16790)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s672.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa75.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.tokens.all (bSN 3308) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean75 : Conv.cleanListB 19692 131072 (fun r => Nat.ble 78768 r) PRE_first_tail_x15_r0_body.s673
    (PRE_first_tail_x15_r0_body.wrB75 ++ (List.range 6).map (2734215 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs75 : bigsOutB 19692 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx = true

end Host.Load.Run.Tpl
