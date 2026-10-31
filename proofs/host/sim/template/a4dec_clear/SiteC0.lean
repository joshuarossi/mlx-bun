import host.sim.template.a4dec_clear.H0
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

/-! The compaction after the merge at call site 0 of chain `DEC_clear` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `DEC_clear.s2` (the stage's results at canonical places, its trace the call's) under `DEC_clear.kappa0` into the merged state
`DEC_clear.s1`. -/

def DEC_clear.pl0 : List Nat := []
def DEC_clear.nr0 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def DEC_clear.kd0 : RData :=
  ⟨3123568, 3123580, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   29302, 29302, 22539, 22539, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def DEC_clear.kappa0 : Map :=
  Conv.Map.compact 3123568 3123580 123 DEC_clear.pl0 (DEC_clear.nr0.map NumV.ref) DEC_clear.kd0.big
    DEC_clear.kd0.region DEC_clear.kd0.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def DEC_clear.cws0 : List Nat := []
noncomputable def DEC_clear.crs0 : List SymE := DEC_clear.nr0.map fun r => (nth? DEC_clear.S1.tab r).getD (.var 0)
noncomputable def DEC_clear.ctheta0 : Nat → SymE := Conv.compactθ DEC_clear.cws0 DEC_clear.crs0
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def DEC_clear.wrB0 : List Nat := [2665, 12504, 2673448]

kernel_rfl DEC_clear.ctab0 : DEC_clear.S2.tab = DEC_clear.S0.tab ++ DEC_clear.cws0.map SymE.var
kernel_rfl DEC_clear.ctrace0 : DEC_clear.s2.trace = DEC_clear.s0.trace
kernel_rfl DEC_clear.cnext0 : DEC_clear.s2.next = 3123568
kernel_rfl DEC_clear.ccounters0 : ((Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.next, (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.nnext) = (29302, 22539)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl DEC_clear.cqueue0 : (Host.Load.Layers.toLoad DEC_clear.s1.ffi).mlx.tokens = (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.tokens.map DEC_clear.kappa0.nv
kernel_rfl DEC_clear.ctokSupp0 : (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx.tokens.all (bSN 123) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl DEC_clear.cclean0 : Conv.cleanListB 29302 131072 (fun r => Nat.ble 117208 r) DEC_clear.s2
    (DEC_clear.wrB0 ++ (List.range 0).map (3123568 + ·)) = true
kernel_rfl DEC_clear.cbigs0 : bigsOutB 29302 131072 (Host.Load.Layers.toLoad DEC_clear.s2.ffi).mlx = true

end Host.Load.Run.Tpl
