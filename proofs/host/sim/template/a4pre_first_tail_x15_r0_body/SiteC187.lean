import host.sim.template.a4pre_first_tail_x15_r0_body.H56
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

/-! The compaction after the merge at call site 187 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1809` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa187` into the merged state
`PRE_first_tail_x15_r0_body.s1808`. -/

def PRE_first_tail_x15_r0_body.pl187 : List Nat := []
def PRE_first_tail_x15_r0_body.nr187 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd187 : RData :=
  ⟨2821743, 2821745, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21886, 21886, 18999, 18999, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa187 : Map :=
  Conv.Map.compact 2821743 2821745 8075 PRE_first_tail_x15_r0_body.pl187 (PRE_first_tail_x15_r0_body.nr187.map NumV.ref) PRE_first_tail_x15_r0_body.kd187.big
    PRE_first_tail_x15_r0_body.kd187.region PRE_first_tail_x15_r0_body.kd187.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws187 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs187 : List SymE := PRE_first_tail_x15_r0_body.nr187.map fun r => (nth? PRE_first_tail_x15_r0_body.S1808.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta187 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws187 PRE_first_tail_x15_r0_body.crs187
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB187 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab187 : PRE_first_tail_x15_r0_body.S1809.tab = PRE_first_tail_x15_r0_body.S1807.tab ++ PRE_first_tail_x15_r0_body.cws187.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace187 : PRE_first_tail_x15_r0_body.s1809.trace = PRE_first_tail_x15_r0_body.s1807.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext187 : PRE_first_tail_x15_r0_body.s1809.next = 2821743
kernel_rfl PRE_first_tail_x15_r0_body.ccounters187 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.nnext) = (21886, 18999)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1808.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa187.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp187 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx.tokens.all (bSN 8075) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean187 : Conv.cleanListB 21886 131072 (fun r => Nat.ble 87544 r) PRE_first_tail_x15_r0_body.s1809
    (PRE_first_tail_x15_r0_body.wrB187 ++ (List.range 0).map (2821743 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs187 : bigsOutB 21886 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1809.ffi).mlx = true

end Host.Load.Run.Tpl
