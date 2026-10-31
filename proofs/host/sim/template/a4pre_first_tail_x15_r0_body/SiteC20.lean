import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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

/-! The compaction after the merge at call site 20 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s186` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa20` into the merged state
`PRE_first_tail_x15_r0_body.s185`. -/

def PRE_first_tail_x15_r0_body.pl20 : List Nat := [2690181]
def PRE_first_tail_x15_r0_body.nr20 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd20 : RData :=
  ⟨2690172, 2690182, Stage.setAll PTrie.nil [(2690171, 2690181)], Stage.setAll PTrie.nil [],
   18589, 18589, 15685, 15685, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa20 : Map :=
  Conv.Map.compact 2690171 2690182 910 PRE_first_tail_x15_r0_body.pl20 (PRE_first_tail_x15_r0_body.nr20.map NumV.ref) PRE_first_tail_x15_r0_body.kd20.big
    PRE_first_tail_x15_r0_body.kd20.region PRE_first_tail_x15_r0_body.kd20.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws20 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs20 : List SymE := PRE_first_tail_x15_r0_body.nr20.map fun r => (nth? PRE_first_tail_x15_r0_body.S185.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta20 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws20 PRE_first_tail_x15_r0_body.crs20
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB20 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab20 : PRE_first_tail_x15_r0_body.S186.tab = PRE_first_tail_x15_r0_body.S184.tab ++ PRE_first_tail_x15_r0_body.cws20.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace20 : PRE_first_tail_x15_r0_body.s186.trace = PRE_first_tail_x15_r0_body.s184.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext20 : PRE_first_tail_x15_r0_body.s186.next = 2690172
kernel_rfl PRE_first_tail_x15_r0_body.ccounters20 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s186.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s186.ffi).mlx.nnext) = (18589, 15685)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue20 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s185.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s186.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa20.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp20 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s186.ffi).mlx.tokens.all (bSN 910) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean20 : Conv.cleanListB 18589 131072 (fun r => Nat.ble 74356 r) PRE_first_tail_x15_r0_body.s186
    (PRE_first_tail_x15_r0_body.wrB20 ++ (List.range 1).map (2690171 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs20 : bigsOutB 18589 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s186.ffi).mlx = true

end Host.Load.Run.Tpl
