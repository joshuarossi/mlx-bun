import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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

/-! The compaction after the merge at call site 103 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1004` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa103` into the merged state
`PRE_first_tail_x15_r0_body.s1003`. -/

def PRE_first_tail_x15_r0_body.pl103 : List Nat := []
def PRE_first_tail_x15_r0_body.nr103 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd103 : RData :=
  ⟨2755807, 2755809, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20234, 20234, 17340, 17340, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa103 : Map :=
  Conv.Map.compact 2755807 2755809 4484 PRE_first_tail_x15_r0_body.pl103 (PRE_first_tail_x15_r0_body.nr103.map NumV.ref) PRE_first_tail_x15_r0_body.kd103.big
    PRE_first_tail_x15_r0_body.kd103.region PRE_first_tail_x15_r0_body.kd103.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws103 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs103 : List SymE := PRE_first_tail_x15_r0_body.nr103.map fun r => (nth? PRE_first_tail_x15_r0_body.S1003.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta103 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws103 PRE_first_tail_x15_r0_body.crs103
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB103 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab103 : PRE_first_tail_x15_r0_body.S1004.tab = PRE_first_tail_x15_r0_body.S1002.tab ++ PRE_first_tail_x15_r0_body.cws103.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace103 : PRE_first_tail_x15_r0_body.s1004.trace = PRE_first_tail_x15_r0_body.s1002.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext103 : PRE_first_tail_x15_r0_body.s1004.next = 2755807
kernel_rfl PRE_first_tail_x15_r0_body.ccounters103 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.nnext) = (20234, 17340)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1003.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa103.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.tokens.all (bSN 4484) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean103 : Conv.cleanListB 20234 131072 (fun r => Nat.ble 80936 r) PRE_first_tail_x15_r0_body.s1004
    (PRE_first_tail_x15_r0_body.wrB103 ++ (List.range 0).map (2755807 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs103 : bigsOutB 20234 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx = true

end Host.Load.Run.Tpl
