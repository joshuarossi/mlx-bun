import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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

/-! The compaction after the merge at call site 3 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s43` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa3` into the merged state
`PRE_first_tail_x15_r0_body.s42`. -/

def PRE_first_tail_x15_r0_body.pl3 : List Nat := [2678735, 2677910, 2678741, 2678737, 2677912, 2678743]
def PRE_first_tail_x15_r0_body.nr3 : List Nat := [242, 241, 217, 225, 230, 235, 240, 214, 215, 216, 223, 224, 212, 219, 220, 221, 222, 218]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd3 : RData :=
  ⟨2677629, 2678778, Stage.setAll PTrie.nil [(2677623, 2678735), (2677624, 2677910), (2677625, 2678741), (2677626, 2678737), (2677627, 2677912), (2677628, 2678743)], Stage.setAll PTrie.nil [(18270, 18296), (18271, 18274), (18272, 18297)],
   18273, 18298, 15368, 15368, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(212, .ref 242), (213, .ref 241), (214, .ref 217), (215, .ref 225), (216, .ref 230), (217, .ref 235), (218, .ref 240), (219, .ref 214), (220, .ref 215), (221, .ref 216), (222, .ref 223), (223, .ref 224), (224, .ref 212), (225, .ref 219), (226, .ref 220), (227, .ref 221), (228, .ref 222), (229, .ref 218)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa3 : Map :=
  Conv.Map.compact 2677623 2678778 212 PRE_first_tail_x15_r0_body.pl3 (PRE_first_tail_x15_r0_body.nr3.map NumV.ref) PRE_first_tail_x15_r0_body.kd3.big
    PRE_first_tail_x15_r0_body.kd3.region PRE_first_tail_x15_r0_body.kd3.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws3 : List Nat := [1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108]
noncomputable def PRE_first_tail_x15_r0_body.crs3 : List SymE := PRE_first_tail_x15_r0_body.nr3.map fun r => (nth? PRE_first_tail_x15_r0_body.S42.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta3 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws3 PRE_first_tail_x15_r0_body.crs3
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB3 : List Nat := [2665, 2672305, 2673467, 2676797, 2677342, 2677598]

kernel_rfl PRE_first_tail_x15_r0_body.ctab3 : PRE_first_tail_x15_r0_body.S43.tab = PRE_first_tail_x15_r0_body.S41.tab ++ PRE_first_tail_x15_r0_body.cws3.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace3 : PRE_first_tail_x15_r0_body.s43.trace = PRE_first_tail_x15_r0_body.s41.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext3 : PRE_first_tail_x15_r0_body.s43.next = 2677629
kernel_rfl PRE_first_tail_x15_r0_body.ccounters3 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.nnext) = (18273, 15368)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s42.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa3.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp3 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx.tokens.all (bSN 230) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean3 : Conv.cleanListB 18273 131072 (fun r => Nat.ble 73092 r) PRE_first_tail_x15_r0_body.s43
    (PRE_first_tail_x15_r0_body.wrB3 ++ (List.range 6).map (2677623 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs3 : bigsOutB 18273 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s43.ffi).mlx = true

end Host.Load.Run.Tpl
