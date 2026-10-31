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

/-! The compaction after the merge at call site 25 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s256` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa25` into the merged state
`PRE_first_tail_x15_r0_body.s255`. -/

def PRE_first_tail_x15_r0_body.pl25 : List Nat := []
def PRE_first_tail_x15_r0_body.nr25 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd25 : RData :=
  ⟨2694783, 2694785, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18704, 18704, 15792, 15792, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa25 : Map :=
  Conv.Map.compact 2694783 2694785 1148 PRE_first_tail_x15_r0_body.pl25 (PRE_first_tail_x15_r0_body.nr25.map NumV.ref) PRE_first_tail_x15_r0_body.kd25.big
    PRE_first_tail_x15_r0_body.kd25.region PRE_first_tail_x15_r0_body.kd25.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws25 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs25 : List SymE := PRE_first_tail_x15_r0_body.nr25.map fun r => (nth? PRE_first_tail_x15_r0_body.S255.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta25 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws25 PRE_first_tail_x15_r0_body.crs25
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB25 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab25 : PRE_first_tail_x15_r0_body.S256.tab = PRE_first_tail_x15_r0_body.S254.tab ++ PRE_first_tail_x15_r0_body.cws25.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace25 : PRE_first_tail_x15_r0_body.s256.trace = PRE_first_tail_x15_r0_body.s254.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext25 : PRE_first_tail_x15_r0_body.s256.next = 2694783
kernel_rfl PRE_first_tail_x15_r0_body.ccounters25 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx.nnext) = (18704, 15792)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue25 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s255.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa25.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp25 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx.tokens.all (bSN 1148) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean25 : Conv.cleanListB 18704 131072 (fun r => Nat.ble 74816 r) PRE_first_tail_x15_r0_body.s256
    (PRE_first_tail_x15_r0_body.wrB25 ++ (List.range 0).map (2694783 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs25 : bigsOutB 18704 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s256.ffi).mlx = true

end Host.Load.Run.Tpl
