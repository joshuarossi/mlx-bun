import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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

/-! The compaction after the merge at call site 31 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s287` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa31` into the merged state
`PRE_first_tail_x15_r0_body.s286`. -/

def PRE_first_tail_x15_r0_body.pl31 : List Nat := []
def PRE_first_tail_x15_r0_body.nr31 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd31 : RData :=
  ⟨2699295, 2699297, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18818, 18818, 15918, 15918, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa31 : Map :=
  Conv.Map.compact 2699295 2699297 1406 PRE_first_tail_x15_r0_body.pl31 (PRE_first_tail_x15_r0_body.nr31.map NumV.ref) PRE_first_tail_x15_r0_body.kd31.big
    PRE_first_tail_x15_r0_body.kd31.region PRE_first_tail_x15_r0_body.kd31.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws31 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs31 : List SymE := PRE_first_tail_x15_r0_body.nr31.map fun r => (nth? PRE_first_tail_x15_r0_body.S286.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta31 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws31 PRE_first_tail_x15_r0_body.crs31
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB31 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab31 : PRE_first_tail_x15_r0_body.S287.tab = PRE_first_tail_x15_r0_body.S285.tab ++ PRE_first_tail_x15_r0_body.cws31.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace31 : PRE_first_tail_x15_r0_body.s287.trace = PRE_first_tail_x15_r0_body.s285.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext31 : PRE_first_tail_x15_r0_body.s287.next = 2699295
kernel_rfl PRE_first_tail_x15_r0_body.ccounters31 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.nnext) = (18818, 15918)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue31 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s286.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa31.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp31 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx.tokens.all (bSN 1406) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean31 : Conv.cleanListB 18818 131072 (fun r => Nat.ble 75272 r) PRE_first_tail_x15_r0_body.s287
    (PRE_first_tail_x15_r0_body.wrB31 ++ (List.range 0).map (2699295 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs31 : bigsOutB 18818 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s287.ffi).mlx = true

end Host.Load.Run.Tpl
