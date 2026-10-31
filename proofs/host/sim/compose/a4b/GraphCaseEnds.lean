import host.sim.compose.a4b.GraphStart
import host.sim.compose.ChainFill
import host.sim.template.a4dec_ord.EEnd
import host.sim.template.a4dec_clear.EEnd
import host.sim.template.a4dec_grow.EEnd
import host.sim.template.a4dec_fill.EEnd
import host.sim.template.a4dec_clearFill.EEnd
import host.sim.template.a4dec_clearGrow.EEnd
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.DECGraph.CaseEnds
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full

/-- Every mapped cache carrier is present in the actual end state. -/
private def PresentB (x : Host.Mlx.Ffi.St) (ps : List (Option Nat × Option Nat)) : Bool :=
  ps.all fun p => (p.1.all fun j => (x.nodes.get j).isSome) &&
    (p.2.all fun j => (x.nodes.get j).isSome)

private theorem present_of_B (x : Host.Mlx.Ffi.St) (ps : List (Option Nat × Option Nat))
    (h : PresentB x ps = true) :
    ∀ p ∈ ps, ∀ j, (p.1 = some j ∨ p.2 = some j) → (x.nodes.get j).isSome = true := by
  intro p hp j hj
  have hc := List.all_eq_true.mp h p hp
  simp only [Bool.and_eq_true] at hc
  rcases hj with hj | hj
  · rw [hj] at hc; simpa using hc.1
  · rw [hj] at hc; simpa using hc.2

namespace Ord

noncomputable def outT : Nat := Host.Load.Run.Tpl.DEC_ord.σ.node 22538

noncomputable def outs : List (Option Nat × Option Nat) :=
  DEC.cacheNodes.map fun p => (p.1.map Host.Load.Run.Tpl.DEC_ord.σ.node, p.2.map Host.Load.Run.Tpl.DEC_ord.σ.node)

kernel_rfl read_eq : Host.Load.Run.Tpl.DEC_ord.σ.node 20157 = 22538
kernel_rfl readback : (mlxOf Host.Load.Run.Tpl.DEC_ord.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl read_present : ((mlxOf Host.Load.Run.Tpl.DEC_ord.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl tokens_empty : (mlxOf Host.Load.Run.Tpl.DEC_ord.s11.ffi).tokens = []
kernel_rfl output_present : ((mlxOf Host.Load.Run.Tpl.DEC_ord.s11.ffi).nodes.get outT).isSome = true
kernel_rfl caches_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC_ord.s11.ffi) outs = true

/-- The exact end carriers and readback of the generated `ord` case. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs ((Host.Load.Run.Tpl.DEC_ord.iterEnd NB).toFb b0) where
  outT := outT
  outs := outs
  read := read_eq
  fed := rfl
  caches := rfl
  h1read := readback
  h1pread := read_present
  s1tok := tokens_empty
  pout := output_present
  pouts := present_of_B _ _ caches_present

end Ord

namespace Clear

noncomputable def outT : Nat := Host.Load.Run.Tpl.DEC_clear.σ.node 22538

noncomputable def outs : List (Option Nat × Option Nat) :=
  DEC.cacheNodes.map fun p => (p.1.map Host.Load.Run.Tpl.DEC_clear.σ.node, p.2.map Host.Load.Run.Tpl.DEC_clear.σ.node)

kernel_rfl read_eq : Host.Load.Run.Tpl.DEC_clear.σ.node 20157 = 22538
kernel_rfl readback : (mlxOf Host.Load.Run.Tpl.DEC_clear.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl read_present : ((mlxOf Host.Load.Run.Tpl.DEC_clear.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl tokens_empty : (mlxOf Host.Load.Run.Tpl.DEC_clear.s11.ffi).tokens = []
kernel_rfl output_present : ((mlxOf Host.Load.Run.Tpl.DEC_clear.s11.ffi).nodes.get outT).isSome = true
kernel_rfl caches_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC_clear.s11.ffi) outs = true

/-- The exact end carriers and readback of the generated `clear` case. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs ((Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0) where
  outT := outT
  outs := outs
  read := read_eq
  fed := rfl
  caches := rfl
  h1read := readback
  h1pread := read_present
  s1tok := tokens_empty
  pout := output_present
  pouts := present_of_B _ _ caches_present

end Clear

namespace Grow

noncomputable def outT : Nat := Host.Load.Run.Tpl.DEC_grow.σ.node 22538

noncomputable def outs : List (Option Nat × Option Nat) :=
  DEC.cacheNodes.map fun p => (p.1.map Host.Load.Run.Tpl.DEC_grow.σ.node, p.2.map Host.Load.Run.Tpl.DEC_grow.σ.node)

kernel_rfl read_eq : Host.Load.Run.Tpl.DEC_grow.σ.node 20157 = 22538
kernel_rfl readback : (mlxOf Host.Load.Run.Tpl.DEC_grow.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl read_present : ((mlxOf Host.Load.Run.Tpl.DEC_grow.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl tokens_empty : (mlxOf Host.Load.Run.Tpl.DEC_grow.s11.ffi).tokens = []
kernel_rfl output_present : ((mlxOf Host.Load.Run.Tpl.DEC_grow.s11.ffi).nodes.get outT).isSome = true
kernel_rfl caches_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC_grow.s11.ffi) outs = true

/-- The exact end carriers and readback of the generated `grow` case. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs ((Host.Load.Run.Tpl.DEC_grow.iterEnd NB).toFb b0) where
  outT := outT
  outs := outs
  read := read_eq
  fed := rfl
  caches := rfl
  h1read := readback
  h1pread := read_present
  s1tok := tokens_empty
  pout := output_present
  pouts := present_of_B _ _ caches_present

end Grow

namespace Fill

noncomputable def outT : Nat := Host.Load.Run.Tpl.DEC_fill.σ.node 22538

noncomputable def outs : List (Option Nat × Option Nat) :=
  DEC.cacheNodes.map fun p => (p.1.map Host.Load.Run.Tpl.DEC_fill.σ.node, p.2.map Host.Load.Run.Tpl.DEC_fill.σ.node)

kernel_rfl read_eq : Host.Load.Run.Tpl.DEC_fill.σ.node 20157 = 22538
kernel_rfl readback : (mlxOf Host.Load.Run.Tpl.DEC_fill.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl read_present : ((mlxOf Host.Load.Run.Tpl.DEC_fill.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl tokens_empty : (mlxOf Host.Load.Run.Tpl.DEC_fill.s11.ffi).tokens = []
kernel_rfl output_present : ((mlxOf Host.Load.Run.Tpl.DEC_fill.s11.ffi).nodes.get outT).isSome = true
kernel_rfl caches_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC_fill.s11.ffi) outs = true

/-- The exact end carriers and readback of the generated `fill` case. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs ((Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0) where
  outT := outT
  outs := outs
  read := read_eq
  fed := rfl
  caches := rfl
  h1read := readback
  h1pread := read_present
  s1tok := tokens_empty
  pout := output_present
  pouts := present_of_B _ _ caches_present

end Fill

namespace ClearFill

noncomputable def outT : Nat := Host.Load.Run.Tpl.DEC_clearFill.σ.node 22538

noncomputable def outs : List (Option Nat × Option Nat) :=
  DEC.cacheNodes.map fun p => (p.1.map Host.Load.Run.Tpl.DEC_clearFill.σ.node, p.2.map Host.Load.Run.Tpl.DEC_clearFill.σ.node)

kernel_rfl read_eq : Host.Load.Run.Tpl.DEC_clearFill.σ.node 20157 = 22538
kernel_rfl readback : (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl read_present : ((mlxOf Host.Load.Run.Tpl.DEC_clearFill.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl tokens_empty : (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s11.ffi).tokens = []
kernel_rfl output_present : ((mlxOf Host.Load.Run.Tpl.DEC_clearFill.s11.ffi).nodes.get outT).isSome = true
kernel_rfl caches_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC_clearFill.s11.ffi) outs = true

/-- The exact end carriers and readback of the generated `clearFill` case. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs ((Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0) where
  outT := outT
  outs := outs
  read := read_eq
  fed := rfl
  caches := rfl
  h1read := readback
  h1pread := read_present
  s1tok := tokens_empty
  pout := output_present
  pouts := present_of_B _ _ caches_present

end ClearFill

namespace ClearGrow

noncomputable def outT : Nat := Host.Load.Run.Tpl.DEC_clearGrow.σ.node 22538

noncomputable def outs : List (Option Nat × Option Nat) :=
  DEC.cacheNodes.map fun p => (p.1.map Host.Load.Run.Tpl.DEC_clearGrow.σ.node, p.2.map Host.Load.Run.Tpl.DEC_clearGrow.σ.node)

kernel_rfl read_eq : Host.Load.Run.Tpl.DEC_clearGrow.σ.node 20157 = 22538
kernel_rfl readback : (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl read_present : ((mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl tokens_empty : (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s11.ffi).tokens = []
kernel_rfl output_present : ((mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s11.ffi).nodes.get outT).isSome = true
kernel_rfl caches_present : PresentB (mlxOf Host.Load.Run.Tpl.DEC_clearGrow.s11.ffi) outs = true

/-- The exact end carriers and readback of the generated `clearGrow` case. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs ((Host.Load.Run.Tpl.DEC_clearGrow.iterEnd NB).toFb b0) where
  outT := outT
  outs := outs
  read := read_eq
  fed := rfl
  caches := rfl
  h1read := readback
  h1pread := read_present
  s1tok := tokens_empty
  pout := output_present
  pouts := present_of_B _ _ caches_present

end ClearGrow

end Host.Ts.Sim.Compose.DECGraph.CaseEnds

