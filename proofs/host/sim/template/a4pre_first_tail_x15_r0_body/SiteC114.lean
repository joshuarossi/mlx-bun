import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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

/-! The compaction after the merge at call site 114 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1015` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa114` into the merged state
`PRE_first_tail_x15_r0_body.s1014`. -/

def PRE_first_tail_x15_r0_body.pl114 : List Nat := [2765835, 2765010, 2765841, 2765837, 2765012, 2765843]
def PRE_first_tail_x15_r0_body.nr114 : List Nat := [4988, 4987, 4963, 4971, 4976, 4981, 4986, 4960, 4961, 4962, 4969, 4970, 4958, 4965, 4966, 4967, 4968, 4964]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd114 : RData :=
  ⟨2764729, 2765878, Stage.setAll PTrie.nil [(2764723, 2765835), (2764724, 2765010), (2764725, 2765841), (2764726, 2765837), (2764727, 2765012), (2764728, 2765843)], Stage.setAll PTrie.nil [(20454, 20480), (20455, 20458), (20456, 20481)],
   20457, 20482, 17564, 17564, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4958, .ref 4988), (4959, .ref 4987), (4960, .ref 4963), (4961, .ref 4971), (4962, .ref 4976), (4963, .ref 4981), (4964, .ref 4986), (4965, .ref 4960), (4966, .ref 4961), (4967, .ref 4962), (4968, .ref 4969), (4969, .ref 4970), (4970, .ref 4958), (4971, .ref 4965), (4972, .ref 4966), (4973, .ref 4967), (4974, .ref 4968), (4975, .ref 4964)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa114 : Map :=
  Conv.Map.compact 2764723 2765878 4958 PRE_first_tail_x15_r0_body.pl114 (PRE_first_tail_x15_r0_body.nr114.map NumV.ref) PRE_first_tail_x15_r0_body.kd114.big
    PRE_first_tail_x15_r0_body.kd114.region PRE_first_tail_x15_r0_body.kd114.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws114 : List Nat := [2942, 2943, 2944, 2945, 2946, 2947, 2948, 2949, 2950, 2951, 2952, 2953, 2954, 2955, 2956, 2957, 2958, 2959]
noncomputable def PRE_first_tail_x15_r0_body.crs114 : List SymE := PRE_first_tail_x15_r0_body.nr114.map fun r => (nth? PRE_first_tail_x15_r0_body.S1014.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta114 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws114 PRE_first_tail_x15_r0_body.crs114
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB114 : List Nat := [2665, 2672589, 2673467, 2763897, 2764442, 2764698]

kernel_rfl PRE_first_tail_x15_r0_body.ctab114 : PRE_first_tail_x15_r0_body.S1015.tab = PRE_first_tail_x15_r0_body.S1013.tab ++ PRE_first_tail_x15_r0_body.cws114.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace114 : PRE_first_tail_x15_r0_body.s1015.trace = PRE_first_tail_x15_r0_body.s1013.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext114 : PRE_first_tail_x15_r0_body.s1015.next = 2764729
kernel_rfl PRE_first_tail_x15_r0_body.ccounters114 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.nnext) = (20457, 17564)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue114 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1014.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa114.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp114 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx.tokens.all (bSN 4976) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean114 : Conv.cleanListB 20457 131072 (fun r => Nat.ble 81828 r) PRE_first_tail_x15_r0_body.s1015
    (PRE_first_tail_x15_r0_body.wrB114 ++ (List.range 6).map (2764723 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs114 : bigsOutB 20457 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1015.ffi).mlx = true

end Host.Load.Run.Tpl
