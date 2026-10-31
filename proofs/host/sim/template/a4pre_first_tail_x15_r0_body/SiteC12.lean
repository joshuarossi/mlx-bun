import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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

/-! The compaction after the merge at call site 12 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s121` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa12` into the merged state
`PRE_first_tail_x15_r0_body.s120`. -/

def PRE_first_tail_x15_r0_body.pl12 : List Nat := [2685987, 2685162, 2685993, 2685989, 2685164, 2685995]
def PRE_first_tail_x15_r0_body.nr12 : List Nat := [626, 625, 601, 609, 614, 619, 624, 598, 599, 600, 607, 608, 596, 603, 604, 605, 606, 602]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd12 : RData :=
  ⟨2684881, 2686030, Stage.setAll PTrie.nil [(2684875, 2685987), (2684876, 2685162), (2684877, 2685993), (2684878, 2685989), (2684879, 2685164), (2684880, 2685995)], Stage.setAll PTrie.nil [(18452, 18478), (18453, 18456), (18454, 18479)],
   18455, 18480, 15542, 15542, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(596, .ref 626), (597, .ref 625), (598, .ref 601), (599, .ref 609), (600, .ref 614), (601, .ref 619), (602, .ref 624), (603, .ref 598), (604, .ref 599), (605, .ref 600), (606, .ref 607), (607, .ref 608), (608, .ref 596), (609, .ref 603), (610, .ref 604), (611, .ref 605), (612, .ref 606), (613, .ref 602)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa12 : Map :=
  Conv.Map.compact 2684875 2686030 596 PRE_first_tail_x15_r0_body.pl12 (PRE_first_tail_x15_r0_body.nr12.map NumV.ref) PRE_first_tail_x15_r0_body.kd12.big
    PRE_first_tail_x15_r0_body.kd12.region PRE_first_tail_x15_r0_body.kd12.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws12 : List Nat := [1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247]
noncomputable def PRE_first_tail_x15_r0_body.crs12 : List SymE := PRE_first_tail_x15_r0_body.nr12.map fun r => (nth? PRE_first_tail_x15_r0_body.S120.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta12 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws12 PRE_first_tail_x15_r0_body.crs12
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB12 : List Nat := [2665, 2672331, 2673467, 2684049, 2684594, 2684850]

kernel_rfl PRE_first_tail_x15_r0_body.ctab12 : PRE_first_tail_x15_r0_body.S121.tab = PRE_first_tail_x15_r0_body.S119.tab ++ PRE_first_tail_x15_r0_body.cws12.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace12 : PRE_first_tail_x15_r0_body.s121.trace = PRE_first_tail_x15_r0_body.s119.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext12 : PRE_first_tail_x15_r0_body.s121.next = 2684881
kernel_rfl PRE_first_tail_x15_r0_body.ccounters12 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.nnext) = (18455, 15542)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue12 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s120.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa12.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp12 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx.tokens.all (bSN 614) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean12 : Conv.cleanListB 18455 131072 (fun r => Nat.ble 73820 r) PRE_first_tail_x15_r0_body.s121
    (PRE_first_tail_x15_r0_body.wrB12 ++ (List.range 6).map (2684875 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs12 : bigsOutB 18455 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s121.ffi).mlx = true

end Host.Load.Run.Tpl
