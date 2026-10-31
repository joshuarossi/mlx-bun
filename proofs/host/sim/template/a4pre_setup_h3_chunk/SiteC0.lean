import host.sim.template.a4pre_setup_h3_chunk.H0
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

/-! The compaction after the merge at call site 0 of chain `PRE_setup_h3_chunk` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_setup_h3_chunk.s2` (the stage's results at canonical places, its trace the call's) under `PRE_setup_h3_chunk.kappa0` into the merged state
`PRE_setup_h3_chunk.s1`. -/

def PRE_setup_h3_chunk.pl0 : List Nat := []
def PRE_setup_h3_chunk.nr0 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_setup_h3_chunk.kd0 : RData :=
  ⟨2673336, 2675688, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   18155, 18155, 15235, 15235, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_setup_h3_chunk.kappa0 : Map :=
  Conv.Map.compact 2673336 2675688 10 PRE_setup_h3_chunk.pl0 (PRE_setup_h3_chunk.nr0.map NumV.ref) PRE_setup_h3_chunk.kd0.big
    PRE_setup_h3_chunk.kd0.region PRE_setup_h3_chunk.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_setup_h3_chunk.cws0 : List Nat := []
noncomputable def PRE_setup_h3_chunk.crs0 : List SymE := PRE_setup_h3_chunk.nr0.map fun r => (nth? PRE_setup_h3_chunk.S1.tab r).getD (.var 0)
noncomputable def PRE_setup_h3_chunk.ctheta0 : Nat → SymE := Conv.compactθ PRE_setup_h3_chunk.cws0 PRE_setup_h3_chunk.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_setup_h3_chunk.wrB0 : List Nat := [2665]

kernel_rfl PRE_setup_h3_chunk.ctab0 : PRE_setup_h3_chunk.S2.tab = PRE_setup_h3_chunk.S0.tab ++ PRE_setup_h3_chunk.cws0.map SymE.var
kernel_rfl PRE_setup_h3_chunk.ctrace0 : PRE_setup_h3_chunk.s2.trace = PRE_setup_h3_chunk.s0.trace
kernel_rfl PRE_setup_h3_chunk.cnext0 : PRE_setup_h3_chunk.s2.next = 2673336
kernel_rfl PRE_setup_h3_chunk.ccounters0 : ((Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx.nnext) = (18155, 15235)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_setup_h3_chunk.cqueue0 : (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s1.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx.tokens.map PRE_setup_h3_chunk.kappa0.nv
kernel_rfl PRE_setup_h3_chunk.ctokSupp0 : (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx.tokens.all (bSN 10) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_setup_h3_chunk.cclean0 : Conv.cleanListB 18155 131072 (fun r => Nat.ble 72620 r) PRE_setup_h3_chunk.s2
    (PRE_setup_h3_chunk.wrB0 ++ (List.range 0).map (2673336 + ·)) = true
kernel_rfl PRE_setup_h3_chunk.cbigs0 : bigsOutB 18155 131072 (Host.Load.Layers.toLoad PRE_setup_h3_chunk.s2.ffi).mlx = true

end Host.Load.Run.Tpl
