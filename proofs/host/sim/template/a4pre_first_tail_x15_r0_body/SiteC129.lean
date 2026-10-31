import host.sim.template.a4pre_first_tail_x15_r0_body.H35
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

/-! The compaction after the merge at call site 129 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1144` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa129` into the merged state
`PRE_first_tail_x15_r0_body.s1143`. -/

def PRE_first_tail_x15_r0_body.pl129 : List Nat := [2777018, 2776854, 2776906, 2777019, 2777020, 2776856, 2776908, 2777017, 2777016, 2777015, 2777014, 2777008, 2776959, 2777010, 2776961]
def PRE_first_tail_x15_r0_body.nr129 : List Nat := [5612, 5613, 5609, 5615, 5611, 5619, 5620, 5617, 5618]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd129 : RData :=
  ⟨2776671, 2777021, Stage.setAll PTrie.nil [(2776656, 2777018), (2776657, 2776854), (2776658, 2776906), (2776659, 2777019), (2776660, 2777020), (2776661, 2776856), (2776662, 2776908), (2776663, 2777017), (2776664, 2777016), (2776665, 2777015), (2776666, 2777014), (2776667, 2777008), (2776668, 2776959), (2776669, 2777010), (2776670, 2776961)], Stage.setAll PTrie.nil [(20753, 20755), (20754, 20756), (20755, 20758), (20756, 20757)],
   20757, 20759, 17852, 17852, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5604, .ref 5612), (5605, .ref 5613), (5606, .ref 5609), (5607, .ref 5615), (5608, .ref 5611), (5609, .ref 5619), (5610, .ref 5620), (5611, .ref 5617), (5612, .ref 5618)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa129 : Map :=
  Conv.Map.compact 2776656 2777021 5604 PRE_first_tail_x15_r0_body.pl129 (PRE_first_tail_x15_r0_body.nr129.map NumV.ref) PRE_first_tail_x15_r0_body.kd129.big
    PRE_first_tail_x15_r0_body.kd129.region PRE_first_tail_x15_r0_body.kd129.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws129 : List Nat := [3175, 3176, 3177, 3178, 3179, 3180, 3181, 3182, 3183]
noncomputable def PRE_first_tail_x15_r0_body.crs129 : List SymE := PRE_first_tail_x15_r0_body.nr129.map fun r => (nth? PRE_first_tail_x15_r0_body.S1143.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta129 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws129 PRE_first_tail_x15_r0_body.crs129
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB129 : List Nat := [2665, 2672632, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab129 : PRE_first_tail_x15_r0_body.S1144.tab = PRE_first_tail_x15_r0_body.S1142.tab ++ PRE_first_tail_x15_r0_body.cws129.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace129 : PRE_first_tail_x15_r0_body.s1144.trace = PRE_first_tail_x15_r0_body.s1142.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext129 : PRE_first_tail_x15_r0_body.s1144.next = 2776671
kernel_rfl PRE_first_tail_x15_r0_body.ccounters129 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1144.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1144.ffi).mlx.nnext) = (20757, 17852)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1143.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1144.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa129.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1144.ffi).mlx.tokens.all (bSN 5613) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean129 : Conv.cleanListB 20757 131072 (fun r => Nat.ble 83028 r) PRE_first_tail_x15_r0_body.s1144
    (PRE_first_tail_x15_r0_body.wrB129 ++ (List.range 15).map (2776656 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs129 : bigsOutB 20757 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1144.ffi).mlx = true

end Host.Load.Run.Tpl
