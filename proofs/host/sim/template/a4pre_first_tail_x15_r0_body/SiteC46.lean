import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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

/-! The compaction after the merge at call site 46 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s457` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa46` into the merged state
`PRE_first_tail_x15_r0_body.s456`. -/

def PRE_first_tail_x15_r0_body.pl46 : List Nat := []
def PRE_first_tail_x15_r0_body.nr46 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd46 : RData :=
  ⟨2711337, 2711339, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19118, 19118, 16203, 16203, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa46 : Map :=
  Conv.Map.compact 2711337 2711339 2045 PRE_first_tail_x15_r0_body.pl46 (PRE_first_tail_x15_r0_body.nr46.map NumV.ref) PRE_first_tail_x15_r0_body.kd46.big
    PRE_first_tail_x15_r0_body.kd46.region PRE_first_tail_x15_r0_body.kd46.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws46 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs46 : List SymE := PRE_first_tail_x15_r0_body.nr46.map fun r => (nth? PRE_first_tail_x15_r0_body.S456.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta46 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws46 PRE_first_tail_x15_r0_body.crs46
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB46 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab46 : PRE_first_tail_x15_r0_body.S457.tab = PRE_first_tail_x15_r0_body.S455.tab ++ PRE_first_tail_x15_r0_body.cws46.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace46 : PRE_first_tail_x15_r0_body.s457.trace = PRE_first_tail_x15_r0_body.s455.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext46 : PRE_first_tail_x15_r0_body.s457.next = 2711337
kernel_rfl PRE_first_tail_x15_r0_body.ccounters46 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.nnext) = (19118, 16203)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s456.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa46.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp46 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx.tokens.all (bSN 2045) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean46 : Conv.cleanListB 19118 131072 (fun r => Nat.ble 76472 r) PRE_first_tail_x15_r0_body.s457
    (PRE_first_tail_x15_r0_body.wrB46 ++ (List.range 0).map (2711337 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs46 : bigsOutB 19118 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s457.ffi).mlx = true

end Host.Load.Run.Tpl
