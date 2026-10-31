import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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

/-! The compaction after the merge at call site 59 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s525` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa59` into the merged state
`PRE_first_tail_x15_r0_body.s524`. -/

def PRE_first_tail_x15_r0_body.pl59 : List Nat := [2721063]
def PRE_first_tail_x15_r0_body.nr59 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd59 : RData :=
  ⟨2721054, 2721064, Stage.setAll PTrie.nil [(2721053, 2721063)], Stage.setAll PTrie.nil [],
   19361, 19361, 16444, 16444, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa59 : Map :=
  Conv.Map.compact 2721053 2721064 2575 PRE_first_tail_x15_r0_body.pl59 (PRE_first_tail_x15_r0_body.nr59.map NumV.ref) PRE_first_tail_x15_r0_body.kd59.big
    PRE_first_tail_x15_r0_body.kd59.region PRE_first_tail_x15_r0_body.kd59.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws59 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs59 : List SymE := PRE_first_tail_x15_r0_body.nr59.map fun r => (nth? PRE_first_tail_x15_r0_body.S524.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta59 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws59 PRE_first_tail_x15_r0_body.crs59
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB59 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab59 : PRE_first_tail_x15_r0_body.S525.tab = PRE_first_tail_x15_r0_body.S523.tab ++ PRE_first_tail_x15_r0_body.cws59.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace59 : PRE_first_tail_x15_r0_body.s525.trace = PRE_first_tail_x15_r0_body.s523.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext59 : PRE_first_tail_x15_r0_body.s525.next = 2721054
kernel_rfl PRE_first_tail_x15_r0_body.ccounters59 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx.nnext) = (19361, 16444)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s524.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa59.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp59 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx.tokens.all (bSN 2575) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean59 : Conv.cleanListB 19361 131072 (fun r => Nat.ble 77444 r) PRE_first_tail_x15_r0_body.s525
    (PRE_first_tail_x15_r0_body.wrB59 ++ (List.range 1).map (2721053 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs59 : bigsOutB 19361 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s525.ffi).mlx = true

end Host.Load.Run.Tpl
