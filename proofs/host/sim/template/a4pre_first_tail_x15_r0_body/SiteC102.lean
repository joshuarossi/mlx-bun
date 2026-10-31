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

/-! The compaction after the merge at call site 102 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s996` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa102` into the merged state
`PRE_first_tail_x15_r0_body.s995`. -/

def PRE_first_tail_x15_r0_body.pl102 : List Nat := [2756423, 2755598, 2756429, 2756425, 2755600, 2756431]
def PRE_first_tail_x15_r0_body.nr102 : List Nat := [4475, 4474, 4450, 4458, 4463, 4468, 4473, 4447, 4448, 4449, 4456, 4457, 4445, 4452, 4453, 4454, 4455, 4451]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd102 : RData :=
  ⟨2755317, 2756466, Stage.setAll PTrie.nil [(2755311, 2756423), (2755312, 2755598), (2755313, 2756429), (2755314, 2756425), (2755315, 2755600), (2755316, 2756431)], Stage.setAll PTrie.nil [(20218, 20244), (20219, 20222), (20220, 20245)],
   20221, 20246, 17327, 17327, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(4445, .ref 4475), (4446, .ref 4474), (4447, .ref 4450), (4448, .ref 4458), (4449, .ref 4463), (4450, .ref 4468), (4451, .ref 4473), (4452, .ref 4447), (4453, .ref 4448), (4454, .ref 4449), (4455, .ref 4456), (4456, .ref 4457), (4457, .ref 4445), (4458, .ref 4452), (4459, .ref 4453), (4460, .ref 4454), (4461, .ref 4455), (4462, .ref 4451)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa102 : Map :=
  Conv.Map.compact 2755311 2756466 4445 PRE_first_tail_x15_r0_body.pl102 (PRE_first_tail_x15_r0_body.nr102.map NumV.ref) PRE_first_tail_x15_r0_body.kd102.big
    PRE_first_tail_x15_r0_body.kd102.region PRE_first_tail_x15_r0_body.kd102.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws102 : List Nat := [2749, 2750, 2751, 2752, 2753, 2754, 2755, 2756, 2757, 2758, 2759, 2760, 2761, 2762, 2763, 2764, 2765, 2766]
noncomputable def PRE_first_tail_x15_r0_body.crs102 : List SymE := PRE_first_tail_x15_r0_body.nr102.map fun r => (nth? PRE_first_tail_x15_r0_body.S995.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta102 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws102 PRE_first_tail_x15_r0_body.crs102
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB102 : List Nat := [2665, 2672558, 2673467, 2754485, 2755030, 2755286]

kernel_rfl PRE_first_tail_x15_r0_body.ctab102 : PRE_first_tail_x15_r0_body.S996.tab = PRE_first_tail_x15_r0_body.S994.tab ++ PRE_first_tail_x15_r0_body.cws102.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace102 : PRE_first_tail_x15_r0_body.s996.trace = PRE_first_tail_x15_r0_body.s994.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext102 : PRE_first_tail_x15_r0_body.s996.next = 2755317
kernel_rfl PRE_first_tail_x15_r0_body.ccounters102 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.nnext) = (20221, 17327)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa102.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp102 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx.tokens.all (bSN 4463) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean102 : Conv.cleanListB 20221 131072 (fun r => Nat.ble 80884 r) PRE_first_tail_x15_r0_body.s996
    (PRE_first_tail_x15_r0_body.wrB102 ++ (List.range 6).map (2755311 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs102 : bigsOutB 20221 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s996.ffi).mlx = true

end Host.Load.Run.Tpl
