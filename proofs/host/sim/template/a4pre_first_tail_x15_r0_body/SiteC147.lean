import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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

/-! The compaction after the merge at call site 147 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1427` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa147` into the merged state
`PRE_first_tail_x15_r0_body.s1426`. -/

def PRE_first_tail_x15_r0_body.pl147 : List Nat := [2791831, 2791006, 2791837, 2791833, 2791008, 2791839]
def PRE_first_tail_x15_r0_body.nr147 : List Nat := [6398, 6397, 6373, 6381, 6386, 6391, 6396, 6370, 6371, 6372, 6379, 6380, 6368, 6375, 6376, 6377, 6378, 6374]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd147 : RData :=
  ⟨2790725, 2791874, Stage.setAll PTrie.nil [(2790719, 2791831), (2790720, 2791006), (2790721, 2791837), (2790722, 2791833), (2790723, 2791008), (2790724, 2791839)], Stage.setAll PTrie.nil [(21105, 21131), (21106, 21109), (21107, 21132)],
   21108, 21133, 18212, 18212, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6368, .ref 6398), (6369, .ref 6397), (6370, .ref 6373), (6371, .ref 6381), (6372, .ref 6386), (6373, .ref 6391), (6374, .ref 6396), (6375, .ref 6370), (6376, .ref 6371), (6377, .ref 6372), (6378, .ref 6379), (6379, .ref 6380), (6380, .ref 6368), (6381, .ref 6375), (6382, .ref 6376), (6383, .ref 6377), (6384, .ref 6378), (6385, .ref 6374)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa147 : Map :=
  Conv.Map.compact 2790719 2791874 6368 PRE_first_tail_x15_r0_body.pl147 (PRE_first_tail_x15_r0_body.nr147.map NumV.ref) PRE_first_tail_x15_r0_body.kd147.big
    PRE_first_tail_x15_r0_body.kd147.region PRE_first_tail_x15_r0_body.kd147.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws147 : List Nat := [3491, 3492, 3493, 3494, 3495, 3496, 3497, 3498, 3499, 3500, 3501, 3502, 3503, 3504, 3505, 3506, 3507, 3508]
noncomputable def PRE_first_tail_x15_r0_body.crs147 : List SymE := PRE_first_tail_x15_r0_body.nr147.map fun r => (nth? PRE_first_tail_x15_r0_body.S1426.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta147 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws147 PRE_first_tail_x15_r0_body.crs147
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB147 : List Nat := [2665, 2672677, 2673467, 2789893, 2790438, 2790694]

kernel_rfl PRE_first_tail_x15_r0_body.ctab147 : PRE_first_tail_x15_r0_body.S1427.tab = PRE_first_tail_x15_r0_body.S1425.tab ++ PRE_first_tail_x15_r0_body.cws147.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace147 : PRE_first_tail_x15_r0_body.s1427.trace = PRE_first_tail_x15_r0_body.s1425.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext147 : PRE_first_tail_x15_r0_body.s1427.next = 2790725
kernel_rfl PRE_first_tail_x15_r0_body.ccounters147 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.nnext) = (21108, 18212)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue147 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1426.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa147.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp147 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx.tokens.all (bSN 6386) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean147 : Conv.cleanListB 21108 131072 (fun r => Nat.ble 84432 r) PRE_first_tail_x15_r0_body.s1427
    (PRE_first_tail_x15_r0_body.wrB147 ++ (List.range 6).map (2790719 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs147 : bigsOutB 21108 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1427.ffi).mlx = true

end Host.Load.Run.Tpl
