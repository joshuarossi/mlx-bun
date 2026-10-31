import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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

/-! The compaction after the merge at call site 77 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s749` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa77` into the merged state
`PRE_first_tail_x15_r0_body.s748`. -/

def PRE_first_tail_x15_r0_body.pl77 : List Nat := [2735009]
def PRE_first_tail_x15_r0_body.nr77 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd77 : RData :=
  ⟨2735000, 2735010, Stage.setAll PTrie.nil [(2734999, 2735009)], Stage.setAll PTrie.nil [],
   19712, 19712, 16807, 16807, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa77 : Map :=
  Conv.Map.compact 2734999 2735010 3346 PRE_first_tail_x15_r0_body.pl77 (PRE_first_tail_x15_r0_body.nr77.map NumV.ref) PRE_first_tail_x15_r0_body.kd77.big
    PRE_first_tail_x15_r0_body.kd77.region PRE_first_tail_x15_r0_body.kd77.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws77 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs77 : List SymE := PRE_first_tail_x15_r0_body.nr77.map fun r => (nth? PRE_first_tail_x15_r0_body.S748.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta77 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws77 PRE_first_tail_x15_r0_body.crs77
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB77 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab77 : PRE_first_tail_x15_r0_body.S749.tab = PRE_first_tail_x15_r0_body.S747.tab ++ PRE_first_tail_x15_r0_body.cws77.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace77 : PRE_first_tail_x15_r0_body.s749.trace = PRE_first_tail_x15_r0_body.s747.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext77 : PRE_first_tail_x15_r0_body.s749.next = 2735000
kernel_rfl PRE_first_tail_x15_r0_body.ccounters77 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.nnext) = (19712, 16807)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue77 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s748.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa77.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp77 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx.tokens.all (bSN 3346) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean77 : Conv.cleanListB 19712 131072 (fun r => Nat.ble 78848 r) PRE_first_tail_x15_r0_body.s749
    (PRE_first_tail_x15_r0_body.wrB77 ++ (List.range 1).map (2734999 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs77 : bigsOutB 19712 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s749.ffi).mlx = true

end Host.Load.Run.Tpl
