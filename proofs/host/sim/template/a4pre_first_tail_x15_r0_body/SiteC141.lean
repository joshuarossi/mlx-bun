import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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

/-! The compaction after the merge at call site 141 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1249` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa141` into the merged state
`PRE_first_tail_x15_r0_body.s1248`. -/

def PRE_first_tail_x15_r0_body.pl141 : List Nat := [2786438, 2786274, 2786326, 2786439, 2786440, 2786276, 2786328, 2786437, 2786436, 2786435, 2786434, 2786428, 2786379, 2786430, 2786381]
def PRE_first_tail_x15_r0_body.nr141 : List Nat := [6125, 6126, 6122, 6128, 6124, 6132, 6133, 6130, 6131]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd141 : RData :=
  ⟨2786091, 2786441, Stage.setAll PTrie.nil [(2786076, 2786438), (2786077, 2786274), (2786078, 2786326), (2786079, 2786439), (2786080, 2786440), (2786081, 2786276), (2786082, 2786328), (2786083, 2786437), (2786084, 2786436), (2786085, 2786435), (2786086, 2786434), (2786087, 2786428), (2786088, 2786379), (2786089, 2786430), (2786090, 2786381)], Stage.setAll PTrie.nil [(20989, 20991), (20990, 20992), (20991, 20994), (20992, 20993)],
   20993, 20995, 18089, 18089, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6117, .ref 6125), (6118, .ref 6126), (6119, .ref 6122), (6120, .ref 6128), (6121, .ref 6124), (6122, .ref 6132), (6123, .ref 6133), (6124, .ref 6130), (6125, .ref 6131)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa141 : Map :=
  Conv.Map.compact 2786076 2786441 6117 PRE_first_tail_x15_r0_body.pl141 (PRE_first_tail_x15_r0_body.nr141.map NumV.ref) PRE_first_tail_x15_r0_body.kd141.big
    PRE_first_tail_x15_r0_body.kd141.region PRE_first_tail_x15_r0_body.kd141.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws141 : List Nat := [3380, 3381, 3382, 3383, 3384, 3385, 3386, 3387, 3388]
noncomputable def PRE_first_tail_x15_r0_body.crs141 : List SymE := PRE_first_tail_x15_r0_body.nr141.map fun r => (nth? PRE_first_tail_x15_r0_body.S1248.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta141 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws141 PRE_first_tail_x15_r0_body.crs141
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB141 : List Nat := [2665, 2672663, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab141 : PRE_first_tail_x15_r0_body.S1249.tab = PRE_first_tail_x15_r0_body.S1247.tab ++ PRE_first_tail_x15_r0_body.cws141.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace141 : PRE_first_tail_x15_r0_body.s1249.trace = PRE_first_tail_x15_r0_body.s1247.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext141 : PRE_first_tail_x15_r0_body.s1249.next = 2786091
kernel_rfl PRE_first_tail_x15_r0_body.ccounters141 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.nnext) = (20993, 18089)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1248.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa141.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx.tokens.all (bSN 6126) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean141 : Conv.cleanListB 20993 131072 (fun r => Nat.ble 83972 r) PRE_first_tail_x15_r0_body.s1249
    (PRE_first_tail_x15_r0_body.wrB141 ++ (List.range 15).map (2786076 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs141 : bigsOutB 20993 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1249.ffi).mlx = true

end Host.Load.Run.Tpl
