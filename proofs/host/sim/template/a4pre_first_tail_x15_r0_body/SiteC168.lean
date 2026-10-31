import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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

/-! The compaction after the merge at call site 168 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1486` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa168` into the merged state
`PRE_first_tail_x15_r0_body.s1485`. -/

def PRE_first_tail_x15_r0_body.pl168 : List Nat := [2808411, 2807586, 2808417, 2808413, 2807588, 2808419]
def PRE_first_tail_x15_r0_body.nr168 : List Nat := [7295, 7294, 7270, 7278, 7283, 7288, 7293, 7267, 7268, 7269, 7276, 7277, 7265, 7272, 7273, 7274, 7275, 7271]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd168 : RData :=
  ⟨2807305, 2808454, Stage.setAll PTrie.nil [(2807299, 2808411), (2807300, 2807586), (2807301, 2808417), (2807302, 2808413), (2807303, 2807588), (2807304, 2808419)], Stage.setAll PTrie.nil [(21520, 21546), (21521, 21524), (21522, 21547)],
   21523, 21548, 18623, 18623, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(7265, .ref 7295), (7266, .ref 7294), (7267, .ref 7270), (7268, .ref 7278), (7269, .ref 7283), (7270, .ref 7288), (7271, .ref 7293), (7272, .ref 7267), (7273, .ref 7268), (7274, .ref 7269), (7275, .ref 7276), (7276, .ref 7277), (7277, .ref 7265), (7278, .ref 7272), (7279, .ref 7273), (7280, .ref 7274), (7281, .ref 7275), (7282, .ref 7271)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa168 : Map :=
  Conv.Map.compact 2807299 2808454 7265 PRE_first_tail_x15_r0_body.pl168 (PRE_first_tail_x15_r0_body.nr168.map NumV.ref) PRE_first_tail_x15_r0_body.kd168.big
    PRE_first_tail_x15_r0_body.kd168.region PRE_first_tail_x15_r0_body.kd168.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws168 : List Nat := [3841, 3842, 3843, 3844, 3845, 3846, 3847, 3848, 3849, 3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857, 3858]
noncomputable def PRE_first_tail_x15_r0_body.crs168 : List SymE := PRE_first_tail_x15_r0_body.nr168.map fun r => (nth? PRE_first_tail_x15_r0_body.S1485.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta168 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws168 PRE_first_tail_x15_r0_body.crs168
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB168 : List Nat := [2665, 2672734, 2673467, 2806473, 2807018, 2807274]

kernel_rfl PRE_first_tail_x15_r0_body.ctab168 : PRE_first_tail_x15_r0_body.S1486.tab = PRE_first_tail_x15_r0_body.S1484.tab ++ PRE_first_tail_x15_r0_body.cws168.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace168 : PRE_first_tail_x15_r0_body.s1486.trace = PRE_first_tail_x15_r0_body.s1484.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext168 : PRE_first_tail_x15_r0_body.s1486.next = 2807305
kernel_rfl PRE_first_tail_x15_r0_body.ccounters168 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx.nnext) = (21523, 18623)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue168 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1485.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa168.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp168 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx.tokens.all (bSN 7283) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean168 : Conv.cleanListB 21523 131072 (fun r => Nat.ble 86092 r) PRE_first_tail_x15_r0_body.s1486
    (PRE_first_tail_x15_r0_body.wrB168 ++ (List.range 6).map (2807299 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs168 : bigsOutB 21523 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1486.ffi).mlx = true

end Host.Load.Run.Tpl
