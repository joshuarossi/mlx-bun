import host.sim.template.a4pre_first_tail_x15_r0_body.H54
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

/-! The compaction after the merge at call site 181 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1751` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa181` into the merged state
`PRE_first_tail_x15_r0_body.s1750`. -/

def PRE_first_tail_x15_r0_body.pl181 : List Nat := []
def PRE_first_tail_x15_r0_body.nr181 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd181 : RData :=
  ⟨2817223, 2817225, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21772, 21772, 18873, 18873, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa181 : Map :=
  Conv.Map.compact 2817223 2817225 7817 PRE_first_tail_x15_r0_body.pl181 (PRE_first_tail_x15_r0_body.nr181.map NumV.ref) PRE_first_tail_x15_r0_body.kd181.big
    PRE_first_tail_x15_r0_body.kd181.region PRE_first_tail_x15_r0_body.kd181.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws181 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs181 : List SymE := PRE_first_tail_x15_r0_body.nr181.map fun r => (nth? PRE_first_tail_x15_r0_body.S1750.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta181 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws181 PRE_first_tail_x15_r0_body.crs181
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB181 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab181 : PRE_first_tail_x15_r0_body.S1751.tab = PRE_first_tail_x15_r0_body.S1749.tab ++ PRE_first_tail_x15_r0_body.cws181.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace181 : PRE_first_tail_x15_r0_body.s1751.trace = PRE_first_tail_x15_r0_body.s1749.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext181 : PRE_first_tail_x15_r0_body.s1751.next = 2817223
kernel_rfl PRE_first_tail_x15_r0_body.ccounters181 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.nnext) = (21772, 18873)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue181 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1750.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa181.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp181 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx.tokens.all (bSN 7817) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean181 : Conv.cleanListB 21772 131072 (fun r => Nat.ble 87088 r) PRE_first_tail_x15_r0_body.s1751
    (PRE_first_tail_x15_r0_body.wrB181 ++ (List.range 0).map (2817223 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs181 : bigsOutB 21772 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1751.ffi).mlx = true

end Host.Load.Run.Tpl
