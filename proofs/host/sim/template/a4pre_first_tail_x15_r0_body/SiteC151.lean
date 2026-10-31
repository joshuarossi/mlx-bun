import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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

/-! The compaction after the merge at call site 151 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1464` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa151` into the merged state
`PRE_first_tail_x15_r0_body.s1463`. -/

def PRE_first_tail_x15_r0_body.pl151 : List Nat := []
def PRE_first_tail_x15_r0_body.nr151 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd151 : RData :=
  ⟨2793475, 2793477, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21178, 21178, 18288, 18288, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa151 : Map :=
  Conv.Map.compact 2793475 2793477 6536 PRE_first_tail_x15_r0_body.pl151 (PRE_first_tail_x15_r0_body.nr151.map NumV.ref) PRE_first_tail_x15_r0_body.kd151.big
    PRE_first_tail_x15_r0_body.kd151.region PRE_first_tail_x15_r0_body.kd151.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws151 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs151 : List SymE := PRE_first_tail_x15_r0_body.nr151.map fun r => (nth? PRE_first_tail_x15_r0_body.S1463.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta151 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws151 PRE_first_tail_x15_r0_body.crs151
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB151 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab151 : PRE_first_tail_x15_r0_body.S1464.tab = PRE_first_tail_x15_r0_body.S1462.tab ++ PRE_first_tail_x15_r0_body.cws151.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace151 : PRE_first_tail_x15_r0_body.s1464.trace = PRE_first_tail_x15_r0_body.s1462.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext151 : PRE_first_tail_x15_r0_body.s1464.next = 2793475
kernel_rfl PRE_first_tail_x15_r0_body.ccounters151 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nnext) = (21178, 18288)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue151 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1463.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa151.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp151 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.tokens.all (bSN 6536) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean151 : Conv.cleanListB 21178 131072 (fun r => Nat.ble 84712 r) PRE_first_tail_x15_r0_body.s1464
    (PRE_first_tail_x15_r0_body.wrB151 ++ (List.range 0).map (2793475 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs151 : bigsOutB 21178 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx = true

end Host.Load.Run.Tpl
