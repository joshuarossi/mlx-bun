import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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

/-! The compaction after the merge at call site 130 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1262` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa130` into the merged state
`PRE_first_tail_x15_r0_body.s1261`. -/

def PRE_first_tail_x15_r0_body.pl130 : List Nat := []
def PRE_first_tail_x15_r0_body.nr130 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd130 : RData :=
  ⟨2777253, 2777255, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20770, 20770, 17862, 17862, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa130 : Map :=
  Conv.Map.compact 2777253 2777255 5636 PRE_first_tail_x15_r0_body.pl130 (PRE_first_tail_x15_r0_body.nr130.map NumV.ref) PRE_first_tail_x15_r0_body.kd130.big
    PRE_first_tail_x15_r0_body.kd130.region PRE_first_tail_x15_r0_body.kd130.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws130 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs130 : List SymE := PRE_first_tail_x15_r0_body.nr130.map fun r => (nth? PRE_first_tail_x15_r0_body.S1261.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta130 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws130 PRE_first_tail_x15_r0_body.crs130
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB130 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab130 : PRE_first_tail_x15_r0_body.S1262.tab = PRE_first_tail_x15_r0_body.S1260.tab ++ PRE_first_tail_x15_r0_body.cws130.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace130 : PRE_first_tail_x15_r0_body.s1262.trace = PRE_first_tail_x15_r0_body.s1260.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext130 : PRE_first_tail_x15_r0_body.s1262.next = 2777253
kernel_rfl PRE_first_tail_x15_r0_body.ccounters130 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.nnext) = (20770, 17862)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1261.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa130.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp130 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx.tokens.all (bSN 5636) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean130 : Conv.cleanListB 20770 131072 (fun r => Nat.ble 83080 r) PRE_first_tail_x15_r0_body.s1262
    (PRE_first_tail_x15_r0_body.wrB130 ++ (List.range 0).map (2777253 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs130 : bigsOutB 20770 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1262.ffi).mlx = true

end Host.Load.Run.Tpl
