import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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

/-! The compaction after the merge at call site 1 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s26` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa1` into the merged state
`PRE_first_tail_x15_r0_body.s25`. -/

def PRE_first_tail_x15_r0_body.pl1 : List Nat := []
def PRE_first_tail_x15_r0_body.nr1 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd1 : RData :=
  ⟨2675765, 2675767, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18226, 18226, 15318, 15318, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa1 : Map :=
  Conv.Map.compact 2675765 2675767 122 PRE_first_tail_x15_r0_body.pl1 (PRE_first_tail_x15_r0_body.nr1.map NumV.ref) PRE_first_tail_x15_r0_body.kd1.big
    PRE_first_tail_x15_r0_body.kd1.region PRE_first_tail_x15_r0_body.kd1.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws1 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs1 : List SymE := PRE_first_tail_x15_r0_body.nr1.map fun r => (nth? PRE_first_tail_x15_r0_body.S25.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta1 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws1 PRE_first_tail_x15_r0_body.crs1
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB1 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab1 : PRE_first_tail_x15_r0_body.S26.tab = PRE_first_tail_x15_r0_body.S24.tab ++ PRE_first_tail_x15_r0_body.cws1.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace1 : PRE_first_tail_x15_r0_body.s26.trace = PRE_first_tail_x15_r0_body.s24.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext1 : PRE_first_tail_x15_r0_body.s26.next = 2675765
kernel_rfl PRE_first_tail_x15_r0_body.ccounters1 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx.nnext) = (18226, 15318)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa1.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx.tokens.all (bSN 122) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean1 : Conv.cleanListB 18226 131072 (fun r => Nat.ble 72904 r) PRE_first_tail_x15_r0_body.s26
    (PRE_first_tail_x15_r0_body.wrB1 ++ (List.range 0).map (2675765 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs1 : bigsOutB 18226 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s26.ffi).mlx = true

end Host.Load.Run.Tpl
