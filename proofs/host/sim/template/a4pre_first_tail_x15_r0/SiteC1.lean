import host.sim.template.a4pre_first_tail_x15_r0.H0
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

/-! The compaction after the merge at call site 1 of chain `PRE_first_tail_x15_r0` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0.s19` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0.kappa1` into the merged state
`PRE_first_tail_x15_r0.s18`. -/

def PRE_first_tail_x15_r0.pl1 : List Nat := [2673467]
def PRE_first_tail_x15_r0.nr1 : List Nat := [18]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0.kd1 : RData :=
  ⟨2673458, 2673472, Stage.setAll PTrie.nil [(2673457, 2673467)], Stage.setAll PTrie.nil [],
   18155, 18155, 15235, 15235, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(14, .ref 18)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0.kappa1 : Map :=
  Conv.Map.compact 2673457 2673472 14 PRE_first_tail_x15_r0.pl1 (PRE_first_tail_x15_r0.nr1.map NumV.ref) PRE_first_tail_x15_r0.kd1.big
    PRE_first_tail_x15_r0.kd1.region PRE_first_tail_x15_r0.kd1.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0.cws1 : List Nat := [1087]
noncomputable def PRE_first_tail_x15_r0.crs1 : List SymE := PRE_first_tail_x15_r0.nr1.map fun r => (nth? PRE_first_tail_x15_r0.S18.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0.ctheta1 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0.cws1 PRE_first_tail_x15_r0.crs1
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0.wrB1 : List Nat := [2665]

kernel_rfl PRE_first_tail_x15_r0.ctab1 : PRE_first_tail_x15_r0.S19.tab = PRE_first_tail_x15_r0.S17.tab ++ PRE_first_tail_x15_r0.cws1.map SymE.var
kernel_rfl PRE_first_tail_x15_r0.ctrace1 : PRE_first_tail_x15_r0.s19.trace = PRE_first_tail_x15_r0.s17.trace
kernel_rfl PRE_first_tail_x15_r0.cnext1 : PRE_first_tail_x15_r0.s19.next = 2673458
kernel_rfl PRE_first_tail_x15_r0.ccounters1 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.nnext) = (18155, 15235)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0.cqueue1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s18.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.tokens.map PRE_first_tail_x15_r0.kappa1.nv
kernel_rfl PRE_first_tail_x15_r0.ctokSupp1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.tokens.all (bSN 15) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0.cclean1 : Conv.cleanListB 18155 131072 (fun r => Nat.ble 72620 r) PRE_first_tail_x15_r0.s19
    (PRE_first_tail_x15_r0.wrB1 ++ (List.range 1).map (2673457 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0.cbigs1 : bigsOutB 18155 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx = true

end Host.Load.Run.Tpl
