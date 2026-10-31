import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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

/-! The compaction after the merge at call site 21 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s199` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa21` into the merged state
`PRE_first_tail_x15_r0_body.s198`. -/

def PRE_first_tail_x15_r0_body.pl21 : List Nat := [2692270, 2692106, 2692158, 2692271, 2692272, 2692108, 2692160, 2692269, 2692268, 2692267, 2692266, 2692260, 2692211, 2692262, 2692213]
def PRE_first_tail_x15_r0_body.nr21 : List Nat := [995, 996, 992, 998, 994, 1002, 1003, 1000, 1001]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd21 : RData :=
  ⟨2691923, 2692273, Stage.setAll PTrie.nil [(2691908, 2692270), (2691909, 2692106), (2691910, 2692158), (2691911, 2692271), (2691912, 2692272), (2691913, 2692108), (2691914, 2692160), (2691915, 2692269), (2691916, 2692268), (2691917, 2692267), (2691918, 2692266), (2691919, 2692260), (2691920, 2692211), (2691921, 2692262), (2691922, 2692213)], Stage.setAll PTrie.nil [(18629, 18631), (18630, 18632), (18631, 18634), (18632, 18633)],
   18633, 18635, 15719, 15719, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(987, .ref 995), (988, .ref 996), (989, .ref 992), (990, .ref 998), (991, .ref 994), (992, .ref 1002), (993, .ref 1003), (994, .ref 1000), (995, .ref 1001)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa21 : Map :=
  Conv.Map.compact 2691908 2692273 987 PRE_first_tail_x15_r0_body.pl21 (PRE_first_tail_x15_r0_body.nr21.map NumV.ref) PRE_first_tail_x15_r0_body.kd21.big
    PRE_first_tail_x15_r0_body.kd21.region PRE_first_tail_x15_r0_body.kd21.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws21 : List Nat := [1378, 1379, 1380, 1381, 1382, 1383, 1384, 1385, 1386]
noncomputable def PRE_first_tail_x15_r0_body.crs21 : List SymE := PRE_first_tail_x15_r0_body.nr21.map fun r => (nth? PRE_first_tail_x15_r0_body.S198.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta21 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws21 PRE_first_tail_x15_r0_body.crs21
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB21 : List Nat := [2665, 2672353, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab21 : PRE_first_tail_x15_r0_body.S199.tab = PRE_first_tail_x15_r0_body.S197.tab ++ PRE_first_tail_x15_r0_body.cws21.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace21 : PRE_first_tail_x15_r0_body.s199.trace = PRE_first_tail_x15_r0_body.s197.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext21 : PRE_first_tail_x15_r0_body.s199.next = 2691923
kernel_rfl PRE_first_tail_x15_r0_body.ccounters21 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.nnext) = (18633, 15719)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue21 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s198.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa21.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp21 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx.tokens.all (bSN 996) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean21 : Conv.cleanListB 18633 131072 (fun r => Nat.ble 74532 r) PRE_first_tail_x15_r0_body.s199
    (PRE_first_tail_x15_r0_body.wrB21 ++ (List.range 15).map (2691908 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs21 : bigsOutB 18633 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s199.ffi).mlx = true

end Host.Load.Run.Tpl
