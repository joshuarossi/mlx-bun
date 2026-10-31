import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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

/-! The compaction after the merge at call site 37 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s338` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa37` into the merged state
`PRE_first_tail_x15_r0_body.s337`. -/

def PRE_first_tail_x15_r0_body.pl37 : List Nat := []
def PRE_first_tail_x15_r0_body.nr37 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd37 : RData :=
  ⟨2704199, 2704201, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18940, 18940, 16029, 16029, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa37 : Map :=
  Conv.Map.compact 2704199 2704201 1661 PRE_first_tail_x15_r0_body.pl37 (PRE_first_tail_x15_r0_body.nr37.map NumV.ref) PRE_first_tail_x15_r0_body.kd37.big
    PRE_first_tail_x15_r0_body.kd37.region PRE_first_tail_x15_r0_body.kd37.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws37 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs37 : List SymE := PRE_first_tail_x15_r0_body.nr37.map fun r => (nth? PRE_first_tail_x15_r0_body.S337.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta37 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws37 PRE_first_tail_x15_r0_body.crs37
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB37 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab37 : PRE_first_tail_x15_r0_body.S338.tab = PRE_first_tail_x15_r0_body.S336.tab ++ PRE_first_tail_x15_r0_body.cws37.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace37 : PRE_first_tail_x15_r0_body.s338.trace = PRE_first_tail_x15_r0_body.s336.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext37 : PRE_first_tail_x15_r0_body.s338.next = 2704199
kernel_rfl PRE_first_tail_x15_r0_body.ccounters37 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx.nnext) = (18940, 16029)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue37 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s337.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa37.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp37 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx.tokens.all (bSN 1661) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean37 : Conv.cleanListB 18940 131072 (fun r => Nat.ble 75760 r) PRE_first_tail_x15_r0_body.s338
    (PRE_first_tail_x15_r0_body.wrB37 ++ (List.range 0).map (2704199 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs37 : bigsOutB 18940 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s338.ffi).mlx = true

end Host.Load.Run.Tpl
