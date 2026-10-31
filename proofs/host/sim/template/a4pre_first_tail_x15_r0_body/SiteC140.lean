import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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

/-! The compaction after the merge at call site 140 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1353` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa140` into the merged state
`PRE_first_tail_x15_r0_body.s1352`. -/

def PRE_first_tail_x15_r0_body.pl140 : List Nat := [2784354]
def PRE_first_tail_x15_r0_body.nr140 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd140 : RData :=
  ⟨2784336, 2784355, Stage.setAll PTrie.nil [(2784335, 2784354)], Stage.setAll PTrie.nil [],
   20949, 20949, 18055, 18055, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa140 : Map :=
  Conv.Map.compact 2784335 2784355 6040 PRE_first_tail_x15_r0_body.pl140 (PRE_first_tail_x15_r0_body.nr140.map NumV.ref) PRE_first_tail_x15_r0_body.kd140.big
    PRE_first_tail_x15_r0_body.kd140.region PRE_first_tail_x15_r0_body.kd140.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws140 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs140 : List SymE := PRE_first_tail_x15_r0_body.nr140.map fun r => (nth? PRE_first_tail_x15_r0_body.S1352.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta140 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws140 PRE_first_tail_x15_r0_body.crs140
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB140 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab140 : PRE_first_tail_x15_r0_body.S1353.tab = PRE_first_tail_x15_r0_body.S1351.tab ++ PRE_first_tail_x15_r0_body.cws140.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace140 : PRE_first_tail_x15_r0_body.s1353.trace = PRE_first_tail_x15_r0_body.s1351.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext140 : PRE_first_tail_x15_r0_body.s1353.next = 2784336
kernel_rfl PRE_first_tail_x15_r0_body.ccounters140 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.nnext) = (20949, 18055)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1352.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa140.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.tokens.all (bSN 6040) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean140 : Conv.cleanListB 20949 131072 (fun r => Nat.ble 83796 r) PRE_first_tail_x15_r0_body.s1353
    (PRE_first_tail_x15_r0_body.wrB140 ++ (List.range 1).map (2784335 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs140 : bigsOutB 20949 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx = true

end Host.Load.Run.Tpl
