import host.sim.template.a4dec_fill.H0
import host.sim.conv.NClean
import host.sim.conv.CompactShift
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Glue piece 1 of chain `DEC_fill` (boundaries 2 to 4): the native bookkeeping's step. -/

def DEC_fill.gh1 : List Nat := [25658, 29302]
def DEC_fill.gn1 : List Nat := [22539]
def DEC_fill.gi1 : List Nat := []
kernel_rfl DEC_fill.gkA1 : (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx.arrs (DEC_fill.gh1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl DEC_fill.gkO1 : (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx.objs (DEC_fill.gh1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl DEC_fill.gkN1 : (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx.nodes (DEC_fill.gn1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl DEC_fill.gkI1 : (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx.items (DEC_fill.gi1.filterMap fun i => ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.items.get i).map (i, ·))
kernel_rfl DEC_fill.gbd1 : (DEC_fill.gh1 ++ DEC_fill.gn1 ++ DEC_fill.gi1).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.gle1 : Conv.Cnt.leB (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) = true
kernel_rfl DEC_fill.gck1 : Conv.ncleanListB (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx DEC_fill.gh1 DEC_fill.gn1 DEC_fill.gi1 = true
theorem DEC_fill.gncl1 (h : Conv.NClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s2.ffi).mlx) : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx :=
  Conv.NClean.stepKeep h DEC_fill.gle1 DEC_fill.gkA1 DEC_fill.gkO1 DEC_fill.gkN1 DEC_fill.gkI1 DEC_fill.gbd1 DEC_fill.gck1

-- the JS bookkeeping's step
def DEC_fill.gjh1 : List Nat := [2591, 2592, 12504, 2673217, 2673244, 2673258, 2673317, 2673320, 2673321, 2673322, 2673323, 2673448, 2827780, 2827781, 2827785, 2827786, 2975629, 2975689, 3123568, 3123569, 3123570, 3123571, 3123572, 3123573, 3123574, 3123575, 3123576, 3123577, 3123578, 3123579, 3123580, 3123581, 3123582, 3123583, 3123584, 3123585, 3123586, 3123587, 3123588, 3123589, 3123590, 3123591, 3123592, 3123593, 3123594, 3123595, 3123596, 3123597, 3123598, 3123599, 3123600, 3123601, 3123602, 3123603, 3123604, 3123605, 3123606, 3123607, 3123608, 3123609, 3123610, 3123611, 3123612, 3123613, 3123614, 3123615, 3123616, 3123617, 3123618, 3123619, 3123620, 3123621, 3123622, 3123623, 3123624, 3123625, 3123626, 3123627, 3123628, 3123629, 3123630, 3123631, 3123632, 3123633, 3123634, 3123635, 3123636, 3123637, 3123638, 3123639, 3123640]
kernel_rfl DEC_fill.gjk1 : DEC_fill.s4.heap = Stage.setAll DEC_fill.s2.heap (DEC_fill.gjh1.filterMap fun a => (DEC_fill.s4.heap.get a).map (a, ·))
kernel_rfl DEC_fill.gjbd1 : DEC_fill.gjh1.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl DEC_fill.gjc1 : Conv.jcleanListB (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_fill.s4 DEC_fill.gjh1 = true
theorem DEC_fill.gjcl1 (h : Conv.JClean (⟨29302, 22539, 3123568, 123⟩ : Conv.Cnt) DEC_fill.s2) : Conv.JClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_fill.s4 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB DEC_fill.gle1)
    (Conv.heap_off_setAll DEC_fill.gjk1 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp DEC_fill.gjbd1 a ha)) DEC_fill.gjc1

end Host.Load.Run.Tpl
