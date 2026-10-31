import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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

/-! The compaction after the merge at call site 118 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1046` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa118` into the merged state
`PRE_first_tail_x15_r0_body.s1045`. -/

def PRE_first_tail_x15_r0_body.pl118 : List Nat := []
def PRE_first_tail_x15_r0_body.nr118 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd118 : RData :=
  ⟨2767841, 2767843, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20534, 20534, 17625, 17625, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa118 : Map :=
  Conv.Map.compact 2767841 2767843 5123 PRE_first_tail_x15_r0_body.pl118 (PRE_first_tail_x15_r0_body.nr118.map NumV.ref) PRE_first_tail_x15_r0_body.kd118.big
    PRE_first_tail_x15_r0_body.kd118.region PRE_first_tail_x15_r0_body.kd118.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws118 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs118 : List SymE := PRE_first_tail_x15_r0_body.nr118.map fun r => (nth? PRE_first_tail_x15_r0_body.S1045.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta118 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws118 PRE_first_tail_x15_r0_body.crs118
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB118 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab118 : PRE_first_tail_x15_r0_body.S1046.tab = PRE_first_tail_x15_r0_body.S1044.tab ++ PRE_first_tail_x15_r0_body.cws118.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace118 : PRE_first_tail_x15_r0_body.s1046.trace = PRE_first_tail_x15_r0_body.s1044.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext118 : PRE_first_tail_x15_r0_body.s1046.next = 2767841
kernel_rfl PRE_first_tail_x15_r0_body.ccounters118 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.nnext) = (20534, 17625)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue118 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1045.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa118.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp118 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.tokens.all (bSN 5123) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean118 : Conv.cleanListB 20534 131072 (fun r => Nat.ble 82136 r) PRE_first_tail_x15_r0_body.s1046
    (PRE_first_tail_x15_r0_body.wrB118 ++ (List.range 0).map (2767841 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs118 : bigsOutB 20534 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx = true

end Host.Load.Run.Tpl
