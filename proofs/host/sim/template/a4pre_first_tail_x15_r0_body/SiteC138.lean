import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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

/-! The compaction after the merge at call site 138 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1225` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa138` into the merged state
`PRE_first_tail_x15_r0_body.s1224`. -/

def PRE_first_tail_x15_r0_body.pl138 : List Nat := [2784663, 2783838, 2784669, 2784665, 2783840, 2784671]
def PRE_first_tail_x15_r0_body.nr138 : List Nat := [6014, 6013, 5989, 5997, 6002, 6007, 6012, 5986, 5987, 5988, 5995, 5996, 5984, 5991, 5992, 5993, 5994, 5990]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd138 : RData :=
  ⟨2783557, 2784706, Stage.setAll PTrie.nil [(2783551, 2784663), (2783552, 2783838), (2783553, 2784669), (2783554, 2784665), (2783555, 2783840), (2783556, 2784671)], Stage.setAll PTrie.nil [(20926, 20952), (20927, 20930), (20928, 20953)],
   20929, 20954, 18038, 18038, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5984, .ref 6014), (5985, .ref 6013), (5986, .ref 5989), (5987, .ref 5997), (5988, .ref 6002), (5989, .ref 6007), (5990, .ref 6012), (5991, .ref 5986), (5992, .ref 5987), (5993, .ref 5988), (5994, .ref 5995), (5995, .ref 5996), (5996, .ref 5984), (5997, .ref 5991), (5998, .ref 5992), (5999, .ref 5993), (6000, .ref 5994), (6001, .ref 5990)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa138 : Map :=
  Conv.Map.compact 2783551 2784706 5984 PRE_first_tail_x15_r0_body.pl138 (PRE_first_tail_x15_r0_body.nr138.map NumV.ref) PRE_first_tail_x15_r0_body.kd138.big
    PRE_first_tail_x15_r0_body.kd138.region PRE_first_tail_x15_r0_body.kd138.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws138 : List Nat := [3334, 3335, 3336, 3337, 3338, 3339, 3340, 3341, 3342, 3343, 3344, 3345, 3346, 3347, 3348, 3349, 3350, 3351]
noncomputable def PRE_first_tail_x15_r0_body.crs138 : List SymE := PRE_first_tail_x15_r0_body.nr138.map fun r => (nth? PRE_first_tail_x15_r0_body.S1224.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta138 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws138 PRE_first_tail_x15_r0_body.crs138
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB138 : List Nat := [2665, 2672651, 2673467, 2782725, 2783270, 2783526]

kernel_rfl PRE_first_tail_x15_r0_body.ctab138 : PRE_first_tail_x15_r0_body.S1225.tab = PRE_first_tail_x15_r0_body.S1223.tab ++ PRE_first_tail_x15_r0_body.cws138.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace138 : PRE_first_tail_x15_r0_body.s1225.trace = PRE_first_tail_x15_r0_body.s1223.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext138 : PRE_first_tail_x15_r0_body.s1225.next = 2783557
kernel_rfl PRE_first_tail_x15_r0_body.ccounters138 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.nnext) = (20929, 18038)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa138.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx.tokens.all (bSN 6002) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean138 : Conv.cleanListB 20929 131072 (fun r => Nat.ble 83716 r) PRE_first_tail_x15_r0_body.s1225
    (PRE_first_tail_x15_r0_body.wrB138 ++ (List.range 6).map (2783551 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs138 : bigsOutB 20929 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1225.ffi).mlx = true

end Host.Load.Run.Tpl
