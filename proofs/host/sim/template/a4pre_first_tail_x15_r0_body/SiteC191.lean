import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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

/-! The compaction after the merge at call site 191 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1680` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa191` into the merged state
`PRE_first_tail_x15_r0_body.s1679`. -/

def PRE_first_tail_x15_r0_body.pl191 : List Nat := [2824663]
def PRE_first_tail_x15_r0_body.nr191 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd191 : RData :=
  ⟨2824654, 2824664, Stage.setAll PTrie.nil [(2824653, 2824663)], Stage.setAll PTrie.nil [],
   21957, 21957, 19051, 19051, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa191 : Map :=
  Conv.Map.compact 2824653 2824664 8218 PRE_first_tail_x15_r0_body.pl191 (PRE_first_tail_x15_r0_body.nr191.map NumV.ref) PRE_first_tail_x15_r0_body.kd191.big
    PRE_first_tail_x15_r0_body.kd191.region PRE_first_tail_x15_r0_body.kd191.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws191 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs191 : List SymE := PRE_first_tail_x15_r0_body.nr191.map fun r => (nth? PRE_first_tail_x15_r0_body.S1679.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta191 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws191 PRE_first_tail_x15_r0_body.crs191
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB191 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab191 : PRE_first_tail_x15_r0_body.S1680.tab = PRE_first_tail_x15_r0_body.S1678.tab ++ PRE_first_tail_x15_r0_body.cws191.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace191 : PRE_first_tail_x15_r0_body.s1680.trace = PRE_first_tail_x15_r0_body.s1678.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext191 : PRE_first_tail_x15_r0_body.s1680.next = 2824654
kernel_rfl PRE_first_tail_x15_r0_body.ccounters191 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx.nnext) = (21957, 19051)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1679.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa191.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp191 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx.tokens.all (bSN 8218) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean191 : Conv.cleanListB 21957 131072 (fun r => Nat.ble 87828 r) PRE_first_tail_x15_r0_body.s1680
    (PRE_first_tail_x15_r0_body.wrB191 ++ (List.range 1).map (2824653 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs191 : bigsOutB 21957 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1680.ffi).mlx = true

end Host.Load.Run.Tpl
