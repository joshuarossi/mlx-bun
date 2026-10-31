import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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

/-! The compaction after the merge at call site 64 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s575` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa64` into the merged state
`PRE_first_tail_x15_r0_body.s574`. -/

def PRE_first_tail_x15_r0_body.pl64 : List Nat := []
def PRE_first_tail_x15_r0_body.nr64 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd64 : RData :=
  ⟨2725299, 2725301, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   19469, 19469, 16566, 16566, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa64 : Map :=
  Conv.Map.compact 2725299 2725301 2816 PRE_first_tail_x15_r0_body.pl64 (PRE_first_tail_x15_r0_body.nr64.map NumV.ref) PRE_first_tail_x15_r0_body.kd64.big
    PRE_first_tail_x15_r0_body.kd64.region PRE_first_tail_x15_r0_body.kd64.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws64 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs64 : List SymE := PRE_first_tail_x15_r0_body.nr64.map fun r => (nth? PRE_first_tail_x15_r0_body.S574.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta64 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws64 PRE_first_tail_x15_r0_body.crs64
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB64 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab64 : PRE_first_tail_x15_r0_body.S575.tab = PRE_first_tail_x15_r0_body.S573.tab ++ PRE_first_tail_x15_r0_body.cws64.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace64 : PRE_first_tail_x15_r0_body.s575.trace = PRE_first_tail_x15_r0_body.s573.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext64 : PRE_first_tail_x15_r0_body.s575.next = 2725299
kernel_rfl PRE_first_tail_x15_r0_body.ccounters64 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.nnext) = (19469, 16566)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s574.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa64.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp64 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx.tokens.all (bSN 2816) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean64 : Conv.cleanListB 19469 131072 (fun r => Nat.ble 77876 r) PRE_first_tail_x15_r0_body.s575
    (PRE_first_tail_x15_r0_body.wrB64 ++ (List.range 0).map (2725299 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs64 : bigsOutB 19469 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s575.ffi).mlx = true

end Host.Load.Run.Tpl
