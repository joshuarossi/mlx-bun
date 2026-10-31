import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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

/-! The compaction after the merge at call site 145 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1406` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa145` into the merged state
`PRE_first_tail_x15_r0_body.s1405`. -/

def PRE_first_tail_x15_r0_body.pl145 : List Nat := []
def PRE_first_tail_x15_r0_body.nr145 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd145 : RData :=
  ⟨2788955, 2788957, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21064, 21064, 18162, 18162, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa145 : Map :=
  Conv.Map.compact 2788955 2788957 6278 PRE_first_tail_x15_r0_body.pl145 (PRE_first_tail_x15_r0_body.nr145.map NumV.ref) PRE_first_tail_x15_r0_body.kd145.big
    PRE_first_tail_x15_r0_body.kd145.region PRE_first_tail_x15_r0_body.kd145.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws145 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs145 : List SymE := PRE_first_tail_x15_r0_body.nr145.map fun r => (nth? PRE_first_tail_x15_r0_body.S1405.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta145 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws145 PRE_first_tail_x15_r0_body.crs145
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB145 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab145 : PRE_first_tail_x15_r0_body.S1406.tab = PRE_first_tail_x15_r0_body.S1404.tab ++ PRE_first_tail_x15_r0_body.cws145.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace145 : PRE_first_tail_x15_r0_body.s1406.trace = PRE_first_tail_x15_r0_body.s1404.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext145 : PRE_first_tail_x15_r0_body.s1406.next = 2788955
kernel_rfl PRE_first_tail_x15_r0_body.ccounters145 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.nnext) = (21064, 18162)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue145 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1405.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa145.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp145 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.tokens.all (bSN 6278) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean145 : Conv.cleanListB 21064 131072 (fun r => Nat.ble 84256 r) PRE_first_tail_x15_r0_body.s1406
    (PRE_first_tail_x15_r0_body.wrB145 ++ (List.range 0).map (2788955 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs145 : bigsOutB 21064 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx = true

end Host.Load.Run.Tpl
