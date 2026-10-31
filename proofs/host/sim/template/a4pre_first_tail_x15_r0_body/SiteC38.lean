import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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

/-! The compaction after the merge at call site 38 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s375` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa38` into the merged state
`PRE_first_tail_x15_r0_body.s374`. -/

def PRE_first_tail_x15_r0_body.pl38 : List Nat := [2704497]
def PRE_first_tail_x15_r0_body.nr38 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd38 : RData :=
  ⟨2704488, 2704498, Stage.setAll PTrie.nil [(2704487, 2704497)], Stage.setAll PTrie.nil [],
   18947, 18947, 16033, 16033, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa38 : Map :=
  Conv.Map.compact 2704487 2704498 1678 PRE_first_tail_x15_r0_body.pl38 (PRE_first_tail_x15_r0_body.nr38.map NumV.ref) PRE_first_tail_x15_r0_body.kd38.big
    PRE_first_tail_x15_r0_body.kd38.region PRE_first_tail_x15_r0_body.kd38.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws38 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs38 : List SymE := PRE_first_tail_x15_r0_body.nr38.map fun r => (nth? PRE_first_tail_x15_r0_body.S374.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta38 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws38 PRE_first_tail_x15_r0_body.crs38
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB38 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab38 : PRE_first_tail_x15_r0_body.S375.tab = PRE_first_tail_x15_r0_body.S373.tab ++ PRE_first_tail_x15_r0_body.cws38.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace38 : PRE_first_tail_x15_r0_body.s375.trace = PRE_first_tail_x15_r0_body.s373.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext38 : PRE_first_tail_x15_r0_body.s375.next = 2704488
kernel_rfl PRE_first_tail_x15_r0_body.ccounters38 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx.nnext) = (18947, 16033)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue38 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s374.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa38.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp38 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx.tokens.all (bSN 1678) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean38 : Conv.cleanListB 18947 131072 (fun r => Nat.ble 75788 r) PRE_first_tail_x15_r0_body.s375
    (PRE_first_tail_x15_r0_body.wrB38 ++ (List.range 1).map (2704487 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs38 : bigsOutB 18947 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s375.ffi).mlx = true

end Host.Load.Run.Tpl
