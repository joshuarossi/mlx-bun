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

/-! The compaction after the merge at call site 78 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s700` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa78` into the merged state
`PRE_first_tail_x15_r0_body.s699`. -/

def PRE_first_tail_x15_r0_body.pl78 : List Nat := [2737583, 2736758, 2737589, 2737585, 2736760, 2737591]
def PRE_first_tail_x15_r0_body.nr78 : List Nat := [3449, 3448, 3424, 3432, 3437, 3442, 3447, 3421, 3422, 3423, 3430, 3431, 3419, 3426, 3427, 3428, 3429, 3425]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd78 : RData :=
  ⟨2736477, 2737626, Stage.setAll PTrie.nil [(2736471, 2737583), (2736472, 2736758), (2736473, 2737589), (2736474, 2737585), (2736475, 2736760), (2736476, 2737591)], Stage.setAll PTrie.nil [(19746, 19772), (19747, 19750), (19748, 19773)],
   19749, 19774, 16853, 16853, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(3419, .ref 3449), (3420, .ref 3448), (3421, .ref 3424), (3422, .ref 3432), (3423, .ref 3437), (3424, .ref 3442), (3425, .ref 3447), (3426, .ref 3421), (3427, .ref 3422), (3428, .ref 3423), (3429, .ref 3430), (3430, .ref 3431), (3431, .ref 3419), (3432, .ref 3426), (3433, .ref 3427), (3434, .ref 3428), (3435, .ref 3429), (3436, .ref 3425)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa78 : Map :=
  Conv.Map.compact 2736471 2737626 3419 PRE_first_tail_x15_r0_body.pl78 (PRE_first_tail_x15_r0_body.nr78.map NumV.ref) PRE_first_tail_x15_r0_body.kd78.big
    PRE_first_tail_x15_r0_body.kd78.region PRE_first_tail_x15_r0_body.kd78.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws78 : List Nat := [2339, 2340, 2341, 2342, 2343, 2344, 2345, 2346, 2347, 2348, 2349, 2350, 2351, 2352, 2353, 2354, 2355, 2356]
noncomputable def PRE_first_tail_x15_r0_body.crs78 : List SymE := PRE_first_tail_x15_r0_body.nr78.map fun r => (nth? PRE_first_tail_x15_r0_body.S699.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta78 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws78 PRE_first_tail_x15_r0_body.crs78
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB78 : List Nat := [2665, 2672496, 2673467, 2735645, 2736190, 2736446]

kernel_rfl PRE_first_tail_x15_r0_body.ctab78 : PRE_first_tail_x15_r0_body.S700.tab = PRE_first_tail_x15_r0_body.S698.tab ++ PRE_first_tail_x15_r0_body.cws78.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace78 : PRE_first_tail_x15_r0_body.s700.trace = PRE_first_tail_x15_r0_body.s698.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext78 : PRE_first_tail_x15_r0_body.s700.next = 2736477
kernel_rfl PRE_first_tail_x15_r0_body.ccounters78 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.nnext) = (19749, 16853)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue78 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s699.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa78.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp78 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx.tokens.all (bSN 3437) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean78 : Conv.cleanListB 19749 131072 (fun r => Nat.ble 78996 r) PRE_first_tail_x15_r0_body.s700
    (PRE_first_tail_x15_r0_body.wrB78 ++ (List.range 6).map (2736471 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs78 : bigsOutB 19749 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s700.ffi).mlx = true

end Host.Load.Run.Tpl
