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

/-! The compaction after the merge at call site 16 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s155` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa16` into the merged state
`PRE_first_tail_x15_r0_body.s154`. -/

def PRE_first_tail_x15_r0_body.pl16 : List Nat := []
def PRE_first_tail_x15_r0_body.nr16 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd16 : RData :=
  ⟨2687627, 2687629, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18525, 18525, 15618, 15618, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa16 : Map :=
  Conv.Map.compact 2687627 2687629 764 PRE_first_tail_x15_r0_body.pl16 (PRE_first_tail_x15_r0_body.nr16.map NumV.ref) PRE_first_tail_x15_r0_body.kd16.big
    PRE_first_tail_x15_r0_body.kd16.region PRE_first_tail_x15_r0_body.kd16.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws16 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs16 : List SymE := PRE_first_tail_x15_r0_body.nr16.map fun r => (nth? PRE_first_tail_x15_r0_body.S154.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta16 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws16 PRE_first_tail_x15_r0_body.crs16
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB16 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab16 : PRE_first_tail_x15_r0_body.S155.tab = PRE_first_tail_x15_r0_body.S153.tab ++ PRE_first_tail_x15_r0_body.cws16.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace16 : PRE_first_tail_x15_r0_body.s155.trace = PRE_first_tail_x15_r0_body.s153.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext16 : PRE_first_tail_x15_r0_body.s155.next = 2687627
kernel_rfl PRE_first_tail_x15_r0_body.ccounters16 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s155.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s155.ffi).mlx.nnext) = (18525, 15618)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue16 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s154.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s155.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa16.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp16 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s155.ffi).mlx.tokens.all (bSN 764) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean16 : Conv.cleanListB 18525 131072 (fun r => Nat.ble 74100 r) PRE_first_tail_x15_r0_body.s155
    (PRE_first_tail_x15_r0_body.wrB16 ++ (List.range 0).map (2687627 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs16 : bigsOutB 18525 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s155.ffi).mlx = true

end Host.Load.Run.Tpl
