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

/-! The compaction after the merge at call site 10 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s101` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa10` into the merged state
`PRE_first_tail_x15_r0_body.s100`. -/

def PRE_first_tail_x15_r0_body.pl10 : List Nat := []
def PRE_first_tail_x15_r0_body.nr10 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd10 : RData :=
  ⟨2683093, 2683095, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18410, 18410, 15492, 15492, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa10 : Map :=
  Conv.Map.compact 2683093 2683095 506 PRE_first_tail_x15_r0_body.pl10 (PRE_first_tail_x15_r0_body.nr10.map NumV.ref) PRE_first_tail_x15_r0_body.kd10.big
    PRE_first_tail_x15_r0_body.kd10.region PRE_first_tail_x15_r0_body.kd10.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws10 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs10 : List SymE := PRE_first_tail_x15_r0_body.nr10.map fun r => (nth? PRE_first_tail_x15_r0_body.S100.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta10 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws10 PRE_first_tail_x15_r0_body.crs10
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB10 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab10 : PRE_first_tail_x15_r0_body.S101.tab = PRE_first_tail_x15_r0_body.S99.tab ++ PRE_first_tail_x15_r0_body.cws10.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace10 : PRE_first_tail_x15_r0_body.s101.trace = PRE_first_tail_x15_r0_body.s99.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext10 : PRE_first_tail_x15_r0_body.s101.next = 2683093
kernel_rfl PRE_first_tail_x15_r0_body.ccounters10 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s101.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s101.ffi).mlx.nnext) = (18410, 15492)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue10 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s100.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s101.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa10.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp10 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s101.ffi).mlx.tokens.all (bSN 506) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean10 : Conv.cleanListB 18410 131072 (fun r => Nat.ble 73640 r) PRE_first_tail_x15_r0_body.s101
    (PRE_first_tail_x15_r0_body.wrB10 ++ (List.range 0).map (2683093 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs10 : bigsOutB 18410 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s101.ffi).mlx = true

end Host.Load.Run.Tpl
