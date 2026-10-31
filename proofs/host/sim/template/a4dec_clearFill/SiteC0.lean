import host.sim.template.a4dec_clearFill.H0
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

/-! The compaction after the merge at call site 0 of chain `DEC_clearFill` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `DEC_clearFill.s2` (the stage's results at canonical places, its trace the call's) under `DEC_clearFill.kappa0` into the merged state
`DEC_clearFill.s1`. -/

def DEC_clearFill.pl0 : List Nat := []
def DEC_clearFill.nr0 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def DEC_clearFill.kd0 : RData :=
  ⟨3123568, 3123580, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   29302, 29302, 22539, 22539, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def DEC_clearFill.kappa0 : Map :=
  Conv.Map.compact 3123568 3123580 123 DEC_clearFill.pl0 (DEC_clearFill.nr0.map NumV.ref) DEC_clearFill.kd0.big
    DEC_clearFill.kd0.region DEC_clearFill.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def DEC_clearFill.cws0 : List Nat := []
noncomputable def DEC_clearFill.crs0 : List SymE := DEC_clearFill.nr0.map fun r => (nth? DEC_clearFill.S1.tab r).getD (.var 0)
noncomputable def DEC_clearFill.ctheta0 : Nat → SymE := Conv.compactθ DEC_clearFill.cws0 DEC_clearFill.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def DEC_clearFill.wrB0 : List Nat := [2665, 12504, 2673448]

kernel_rfl DEC_clearFill.ctab0 : DEC_clearFill.S2.tab = DEC_clearFill.S0.tab ++ DEC_clearFill.cws0.map SymE.var
kernel_rfl DEC_clearFill.ctrace0 : DEC_clearFill.s2.trace = DEC_clearFill.s0.trace
kernel_rfl DEC_clearFill.cnext0 : DEC_clearFill.s2.next = 3123568
kernel_rfl DEC_clearFill.ccounters0 : ((Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.next, (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.nnext) = (29302, 22539)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl DEC_clearFill.cqueue0 : (Host.Load.Layers.toLoad DEC_clearFill.s1.ffi).mlx.tokens = (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.tokens.map DEC_clearFill.kappa0.nv
kernel_rfl DEC_clearFill.ctokSupp0 : (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx.tokens.all (bSN 123) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl DEC_clearFill.cclean0 : Conv.cleanListB 29302 131072 (fun r => Nat.ble 117208 r) DEC_clearFill.s2
    (DEC_clearFill.wrB0 ++ (List.range 0).map (3123568 + ·)) = true
kernel_rfl DEC_clearFill.cbigs0 : bigsOutB 29302 131072 (Host.Load.Layers.toLoad DEC_clearFill.s2.ffi).mlx = true

end Host.Load.Run.Tpl
