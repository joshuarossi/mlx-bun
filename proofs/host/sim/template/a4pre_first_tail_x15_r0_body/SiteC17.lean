import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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

/-! The compaction after the merge at call site 17 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s174` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa17` into the merged state
`PRE_first_tail_x15_r0_body.s173`. -/

def PRE_first_tail_x15_r0_body.pl17 : List Nat := [2687925]
def PRE_first_tail_x15_r0_body.nr17 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd17 : RData :=
  ⟨2687916, 2687926, Stage.setAll PTrie.nil [(2687915, 2687925)], Stage.setAll PTrie.nil [],
   18532, 18532, 15622, 15622, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa17 : Map :=
  Conv.Map.compact 2687915 2687926 781 PRE_first_tail_x15_r0_body.pl17 (PRE_first_tail_x15_r0_body.nr17.map NumV.ref) PRE_first_tail_x15_r0_body.kd17.big
    PRE_first_tail_x15_r0_body.kd17.region PRE_first_tail_x15_r0_body.kd17.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws17 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs17 : List SymE := PRE_first_tail_x15_r0_body.nr17.map fun r => (nth? PRE_first_tail_x15_r0_body.S173.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta17 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws17 PRE_first_tail_x15_r0_body.crs17
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB17 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab17 : PRE_first_tail_x15_r0_body.S174.tab = PRE_first_tail_x15_r0_body.S172.tab ++ PRE_first_tail_x15_r0_body.cws17.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace17 : PRE_first_tail_x15_r0_body.s174.trace = PRE_first_tail_x15_r0_body.s172.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext17 : PRE_first_tail_x15_r0_body.s174.next = 2687916
kernel_rfl PRE_first_tail_x15_r0_body.ccounters17 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.nnext) = (18532, 15622)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue17 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s173.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa17.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp17 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx.tokens.all (bSN 781) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean17 : Conv.cleanListB 18532 131072 (fun r => Nat.ble 74128 r) PRE_first_tail_x15_r0_body.s174
    (PRE_first_tail_x15_r0_body.wrB17 ++ (List.range 1).map (2687915 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs17 : bigsOutB 18532 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s174.ffi).mlx = true

end Host.Load.Run.Tpl
