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

/-! The compaction after the merge at call site 69 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s679` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa69` into the merged state
`PRE_first_tail_x15_r0_body.s678`. -/

def PRE_first_tail_x15_r0_body.pl69 : List Nat := [2729942, 2729778, 2729830, 2729943, 2729944, 2729780, 2729832, 2729941, 2729940, 2729939, 2729938, 2729932, 2729883, 2729934, 2729885]
def PRE_first_tail_x15_r0_body.nr69 : List Nat := [3047, 3048, 3044, 3050, 3046, 3054, 3055, 3052, 3053]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd69 : RData :=
  ⟨2729595, 2729945, Stage.setAll PTrie.nil [(2729580, 2729942), (2729581, 2729778), (2729582, 2729830), (2729583, 2729943), (2729584, 2729944), (2729585, 2729780), (2729586, 2729832), (2729587, 2729941), (2729588, 2729940), (2729589, 2729939), (2729590, 2729938), (2729591, 2729932), (2729592, 2729883), (2729593, 2729934), (2729594, 2729885)], Stage.setAll PTrie.nil [(19573, 19575), (19574, 19576), (19575, 19578), (19576, 19577)],
   19577, 19579, 16667, 16667, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3039, .ref 3047), (3040, .ref 3048), (3041, .ref 3044), (3042, .ref 3050), (3043, .ref 3046), (3044, .ref 3054), (3045, .ref 3055), (3046, .ref 3052), (3047, .ref 3053)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa69 : Map :=
  Conv.Map.compact 2729580 2729945 3039 PRE_first_tail_x15_r0_body.pl69 (PRE_first_tail_x15_r0_body.nr69.map NumV.ref) PRE_first_tail_x15_r0_body.kd69.big
    PRE_first_tail_x15_r0_body.kd69.region PRE_first_tail_x15_r0_body.kd69.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws69 : List Nat := [2186, 2187, 2188, 2189, 2190, 2191, 2192, 2193, 2194]
noncomputable def PRE_first_tail_x15_r0_body.crs69 : List SymE := PRE_first_tail_x15_r0_body.nr69.map fun r => (nth? PRE_first_tail_x15_r0_body.S678.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta69 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws69 PRE_first_tail_x15_r0_body.crs69
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB69 : List Nat := [2665, 2672477, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab69 : PRE_first_tail_x15_r0_body.S679.tab = PRE_first_tail_x15_r0_body.S677.tab ++ PRE_first_tail_x15_r0_body.cws69.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace69 : PRE_first_tail_x15_r0_body.s679.trace = PRE_first_tail_x15_r0_body.s677.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext69 : PRE_first_tail_x15_r0_body.s679.next = 2729595
kernel_rfl PRE_first_tail_x15_r0_body.ccounters69 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.nnext) = (19577, 16667)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s678.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa69.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx.tokens.all (bSN 3048) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean69 : Conv.cleanListB 19577 131072 (fun r => Nat.ble 78308 r) PRE_first_tail_x15_r0_body.s679
    (PRE_first_tail_x15_r0_body.wrB69 ++ (List.range 15).map (2729580 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs69 : bigsOutB 19577 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s679.ffi).mlx = true

end Host.Load.Run.Tpl
