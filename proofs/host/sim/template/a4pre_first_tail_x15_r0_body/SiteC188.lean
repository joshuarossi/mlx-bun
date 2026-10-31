import host.sim.template.a4pre_first_tail_x15_r0_body.H56
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

/-! The compaction after the merge at call site 188 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1813` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa188` into the merged state
`PRE_first_tail_x15_r0_body.s1812`. -/

def PRE_first_tail_x15_r0_body.pl188 : List Nat := [2822041]
def PRE_first_tail_x15_r0_body.nr188 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd188 : RData :=
  ⟨2822032, 2822042, Stage.setAll PTrie.nil [(2822031, 2822041)], Stage.setAll PTrie.nil [],
   21893, 21893, 19003, 19003, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa188 : Map :=
  Conv.Map.compact 2822031 2822042 8092 PRE_first_tail_x15_r0_body.pl188 (PRE_first_tail_x15_r0_body.nr188.map NumV.ref) PRE_first_tail_x15_r0_body.kd188.big
    PRE_first_tail_x15_r0_body.kd188.region PRE_first_tail_x15_r0_body.kd188.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws188 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs188 : List SymE := PRE_first_tail_x15_r0_body.nr188.map fun r => (nth? PRE_first_tail_x15_r0_body.S1812.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta188 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws188 PRE_first_tail_x15_r0_body.crs188
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB188 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab188 : PRE_first_tail_x15_r0_body.S1813.tab = PRE_first_tail_x15_r0_body.S1811.tab ++ PRE_first_tail_x15_r0_body.cws188.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace188 : PRE_first_tail_x15_r0_body.s1813.trace = PRE_first_tail_x15_r0_body.s1811.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext188 : PRE_first_tail_x15_r0_body.s1813.next = 2822032
kernel_rfl PRE_first_tail_x15_r0_body.ccounters188 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.nnext) = (21893, 19003)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1812.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa188.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp188 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx.tokens.all (bSN 8092) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean188 : Conv.cleanListB 21893 131072 (fun r => Nat.ble 87572 r) PRE_first_tail_x15_r0_body.s1813
    (PRE_first_tail_x15_r0_body.wrB188 ++ (List.range 1).map (2822031 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs188 : bigsOutB 21893 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1813.ffi).mlx = true

end Host.Load.Run.Tpl
