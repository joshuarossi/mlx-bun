import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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

/-! The compaction after the merge at call site 15 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s148` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa15` into the merged state
`PRE_first_tail_x15_r0_body.s147`. -/

def PRE_first_tail_x15_r0_body.pl15 : List Nat := [2688243, 2687418, 2688249, 2688245, 2687420, 2688251]
def PRE_first_tail_x15_r0_body.nr15 : List Nat := [755, 754, 730, 738, 743, 748, 753, 727, 728, 729, 736, 737, 725, 732, 733, 734, 735, 731]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd15 : RData :=
  ⟨2687137, 2688286, Stage.setAll PTrie.nil [(2687131, 2688243), (2687132, 2687418), (2687133, 2688249), (2687134, 2688245), (2687135, 2687420), (2687136, 2688251)], Stage.setAll PTrie.nil [(18509, 18535), (18510, 18513), (18511, 18536)],
   18512, 18537, 15605, 15605, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(725, .ref 755), (726, .ref 754), (727, .ref 730), (728, .ref 738), (729, .ref 743), (730, .ref 748), (731, .ref 753), (732, .ref 727), (733, .ref 728), (734, .ref 729), (735, .ref 736), (736, .ref 737), (737, .ref 725), (738, .ref 732), (739, .ref 733), (740, .ref 734), (741, .ref 735), (742, .ref 731)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa15 : Map :=
  Conv.Map.compact 2687131 2688286 725 PRE_first_tail_x15_r0_body.pl15 (PRE_first_tail_x15_r0_body.nr15.map NumV.ref) PRE_first_tail_x15_r0_body.kd15.big
    PRE_first_tail_x15_r0_body.kd15.region PRE_first_tail_x15_r0_body.kd15.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws15 : List Nat := [1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 1301]
noncomputable def PRE_first_tail_x15_r0_body.crs15 : List SymE := PRE_first_tail_x15_r0_body.nr15.map fun r => (nth? PRE_first_tail_x15_r0_body.S147.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta15 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws15 PRE_first_tail_x15_r0_body.crs15
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB15 : List Nat := [2665, 2672336, 2673467, 2686305, 2686850, 2687106]

kernel_rfl PRE_first_tail_x15_r0_body.ctab15 : PRE_first_tail_x15_r0_body.S148.tab = PRE_first_tail_x15_r0_body.S146.tab ++ PRE_first_tail_x15_r0_body.cws15.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace15 : PRE_first_tail_x15_r0_body.s148.trace = PRE_first_tail_x15_r0_body.s146.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext15 : PRE_first_tail_x15_r0_body.s148.next = 2687137
kernel_rfl PRE_first_tail_x15_r0_body.ccounters15 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.nnext) = (18512, 15605)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue15 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s147.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa15.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp15 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.tokens.all (bSN 743) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean15 : Conv.cleanListB 18512 131072 (fun r => Nat.ble 74048 r) PRE_first_tail_x15_r0_body.s148
    (PRE_first_tail_x15_r0_body.wrB15 ++ (List.range 6).map (2687131 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs15 : bigsOutB 18512 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx = true

end Host.Load.Run.Tpl
