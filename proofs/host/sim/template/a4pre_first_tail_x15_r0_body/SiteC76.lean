import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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

/-! The compaction after the merge at call site 76 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s745` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa76` into the merged state
`PRE_first_tail_x15_r0_body.s744`. -/

def PRE_first_tail_x15_r0_body.pl76 : List Nat := []
def PRE_first_tail_x15_r0_body.nr76 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd76 : RData :=
  ⟨2734711, 2734713, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19705, 19705, 16803, 16803, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa76 : Map :=
  Conv.Map.compact 2734711 2734713 3329 PRE_first_tail_x15_r0_body.pl76 (PRE_first_tail_x15_r0_body.nr76.map NumV.ref) PRE_first_tail_x15_r0_body.kd76.big
    PRE_first_tail_x15_r0_body.kd76.region PRE_first_tail_x15_r0_body.kd76.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws76 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs76 : List SymE := PRE_first_tail_x15_r0_body.nr76.map fun r => (nth? PRE_first_tail_x15_r0_body.S744.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta76 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws76 PRE_first_tail_x15_r0_body.crs76
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB76 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab76 : PRE_first_tail_x15_r0_body.S745.tab = PRE_first_tail_x15_r0_body.S743.tab ++ PRE_first_tail_x15_r0_body.cws76.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace76 : PRE_first_tail_x15_r0_body.s745.trace = PRE_first_tail_x15_r0_body.s743.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext76 : PRE_first_tail_x15_r0_body.s745.next = 2734711
kernel_rfl PRE_first_tail_x15_r0_body.ccounters76 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.nnext) = (19705, 16803)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s744.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa76.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp76 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx.tokens.all (bSN 3329) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean76 : Conv.cleanListB 19705 131072 (fun r => Nat.ble 78820 r) PRE_first_tail_x15_r0_body.s745
    (PRE_first_tail_x15_r0_body.wrB76 ++ (List.range 0).map (2734711 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs76 : bigsOutB 19705 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s745.ffi).mlx = true

end Host.Load.Run.Tpl
