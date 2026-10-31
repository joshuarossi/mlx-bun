import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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

/-! The compaction after the merge at call site 172 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1665` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa172` into the merged state
`PRE_first_tail_x15_r0_body.s1664`. -/

def PRE_first_tail_x15_r0_body.pl172 : List Nat := []
def PRE_first_tail_x15_r0_body.nr172 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd172 : RData :=
  ⟨2810055, 2810057, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21593, 21593, 18699, 18699, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa172 : Map :=
  Conv.Map.compact 2810055 2810057 7433 PRE_first_tail_x15_r0_body.pl172 (PRE_first_tail_x15_r0_body.nr172.map NumV.ref) PRE_first_tail_x15_r0_body.kd172.big
    PRE_first_tail_x15_r0_body.kd172.region PRE_first_tail_x15_r0_body.kd172.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws172 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs172 : List SymE := PRE_first_tail_x15_r0_body.nr172.map fun r => (nth? PRE_first_tail_x15_r0_body.S1664.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta172 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws172 PRE_first_tail_x15_r0_body.crs172
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB172 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab172 : PRE_first_tail_x15_r0_body.S1665.tab = PRE_first_tail_x15_r0_body.S1663.tab ++ PRE_first_tail_x15_r0_body.cws172.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace172 : PRE_first_tail_x15_r0_body.s1665.trace = PRE_first_tail_x15_r0_body.s1663.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext172 : PRE_first_tail_x15_r0_body.s1665.next = 2810055
kernel_rfl PRE_first_tail_x15_r0_body.ccounters172 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx.nnext) = (21593, 18699)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue172 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1664.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa172.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp172 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx.tokens.all (bSN 7433) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean172 : Conv.cleanListB 21593 131072 (fun r => Nat.ble 86372 r) PRE_first_tail_x15_r0_body.s1665
    (PRE_first_tail_x15_r0_body.wrB172 ++ (List.range 0).map (2810055 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs172 : bigsOutB 21593 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1665.ffi).mlx = true

end Host.Load.Run.Tpl
