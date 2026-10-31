import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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

/-! The compaction after the merge at call site 14 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s145` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa14` into the merged state
`PRE_first_tail_x15_r0_body.s144`. -/

def PRE_first_tail_x15_r0_body.pl14 : List Nat := [2685669]
def PRE_first_tail_x15_r0_body.nr14 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd14 : RData :=
  ⟨2685660, 2685670, Stage.setAll PTrie.nil [(2685659, 2685669)], Stage.setAll PTrie.nil [],
   18475, 18475, 15559, 15559, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa14 : Map :=
  Conv.Map.compact 2685659 2685670 652 PRE_first_tail_x15_r0_body.pl14 (PRE_first_tail_x15_r0_body.nr14.map NumV.ref) PRE_first_tail_x15_r0_body.kd14.big
    PRE_first_tail_x15_r0_body.kd14.region PRE_first_tail_x15_r0_body.kd14.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws14 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs14 : List SymE := PRE_first_tail_x15_r0_body.nr14.map fun r => (nth? PRE_first_tail_x15_r0_body.S144.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta14 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws14 PRE_first_tail_x15_r0_body.crs14
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB14 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab14 : PRE_first_tail_x15_r0_body.S145.tab = PRE_first_tail_x15_r0_body.S143.tab ++ PRE_first_tail_x15_r0_body.cws14.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace14 : PRE_first_tail_x15_r0_body.s145.trace = PRE_first_tail_x15_r0_body.s143.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext14 : PRE_first_tail_x15_r0_body.s145.next = 2685660
kernel_rfl PRE_first_tail_x15_r0_body.ccounters14 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.nnext) = (18475, 15559)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue14 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s144.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa14.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp14 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx.tokens.all (bSN 652) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean14 : Conv.cleanListB 18475 131072 (fun r => Nat.ble 73900 r) PRE_first_tail_x15_r0_body.s145
    (PRE_first_tail_x15_r0_body.wrB14 ++ (List.range 1).map (2685659 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs14 : bigsOutB 18475 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s145.ffi).mlx = true

end Host.Load.Run.Tpl
