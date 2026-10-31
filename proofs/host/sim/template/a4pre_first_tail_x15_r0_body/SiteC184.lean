import host.sim.template.a4pre_first_tail_x15_r0_body.H50
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

/-! The compaction after the merge at call site 184 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1625` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa184` into the merged state
`PRE_first_tail_x15_r0_body.s1624`. -/

def PRE_first_tail_x15_r0_body.pl184 : List Nat := []
def PRE_first_tail_x15_r0_body.nr184 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd184 : RData :=
  ⟨2819483, 2819485, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21829, 21829, 18936, 18936, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa184 : Map :=
  Conv.Map.compact 2819483 2819485 7946 PRE_first_tail_x15_r0_body.pl184 (PRE_first_tail_x15_r0_body.nr184.map NumV.ref) PRE_first_tail_x15_r0_body.kd184.big
    PRE_first_tail_x15_r0_body.kd184.region PRE_first_tail_x15_r0_body.kd184.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws184 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs184 : List SymE := PRE_first_tail_x15_r0_body.nr184.map fun r => (nth? PRE_first_tail_x15_r0_body.S1624.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta184 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws184 PRE_first_tail_x15_r0_body.crs184
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB184 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab184 : PRE_first_tail_x15_r0_body.S1625.tab = PRE_first_tail_x15_r0_body.S1623.tab ++ PRE_first_tail_x15_r0_body.cws184.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace184 : PRE_first_tail_x15_r0_body.s1625.trace = PRE_first_tail_x15_r0_body.s1623.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext184 : PRE_first_tail_x15_r0_body.s1625.next = 2819483
kernel_rfl PRE_first_tail_x15_r0_body.ccounters184 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.nnext) = (21829, 18936)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue184 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1624.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa184.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp184 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.tokens.all (bSN 7946) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean184 : Conv.cleanListB 21829 131072 (fun r => Nat.ble 87316 r) PRE_first_tail_x15_r0_body.s1625
    (PRE_first_tail_x15_r0_body.wrB184 ++ (List.range 0).map (2819483 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs184 : bigsOutB 21829 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx = true

end Host.Load.Run.Tpl
