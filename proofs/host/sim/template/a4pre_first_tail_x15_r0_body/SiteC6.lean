import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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

/-! The compaction after the merge at call site 6 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s70` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa6` into the merged state
`PRE_first_tail_x15_r0_body.s69`. -/

def PRE_first_tail_x15_r0_body.pl6 : List Nat := [2681085, 2680260, 2681091, 2681087, 2680262, 2681093]
def PRE_first_tail_x15_r0_body.nr6 : List Nat := [371, 370, 346, 354, 359, 364, 369, 343, 344, 345, 352, 353, 341, 348, 349, 350, 351, 347]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd6 : RData :=
  ⟨2679979, 2681128, Stage.setAll PTrie.nil [(2679973, 2681085), (2679974, 2680260), (2679975, 2681091), (2679976, 2681087), (2679977, 2680262), (2679978, 2681093)], Stage.setAll PTrie.nil [(18330, 18356), (18331, 18334), (18332, 18357)],
   18333, 18358, 15431, 15431, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(341, .ref 371), (342, .ref 370), (343, .ref 346), (344, .ref 354), (345, .ref 359), (346, .ref 364), (347, .ref 369), (348, .ref 343), (349, .ref 344), (350, .ref 345), (351, .ref 352), (352, .ref 353), (353, .ref 341), (354, .ref 348), (355, .ref 349), (356, .ref 350), (357, .ref 351), (358, .ref 347)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa6 : Map :=
  Conv.Map.compact 2679973 2681128 341 PRE_first_tail_x15_r0_body.pl6 (PRE_first_tail_x15_r0_body.nr6.map NumV.ref) PRE_first_tail_x15_r0_body.kd6.big
    PRE_first_tail_x15_r0_body.kd6.region PRE_first_tail_x15_r0_body.kd6.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws6 : List Nat := [1145, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162]
noncomputable def PRE_first_tail_x15_r0_body.crs6 : List SymE := PRE_first_tail_x15_r0_body.nr6.map fun r => (nth? PRE_first_tail_x15_r0_body.S69.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta6 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws6 PRE_first_tail_x15_r0_body.crs6
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB6 : List Nat := [2665, 2672310, 2673467, 2679147, 2679692, 2679948]

kernel_rfl PRE_first_tail_x15_r0_body.ctab6 : PRE_first_tail_x15_r0_body.S70.tab = PRE_first_tail_x15_r0_body.S68.tab ++ PRE_first_tail_x15_r0_body.cws6.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace6 : PRE_first_tail_x15_r0_body.s70.trace = PRE_first_tail_x15_r0_body.s68.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext6 : PRE_first_tail_x15_r0_body.s70.next = 2679979
kernel_rfl PRE_first_tail_x15_r0_body.ccounters6 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s70.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s70.ffi).mlx.nnext) = (18333, 15431)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue6 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s69.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s70.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa6.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp6 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s70.ffi).mlx.tokens.all (bSN 359) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean6 : Conv.cleanListB 18333 131072 (fun r => Nat.ble 73332 r) PRE_first_tail_x15_r0_body.s70
    (PRE_first_tail_x15_r0_body.wrB6 ++ (List.range 6).map (2679973 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs6 : bigsOutB 18333 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s70.ffi).mlx = true

end Host.Load.Run.Tpl
