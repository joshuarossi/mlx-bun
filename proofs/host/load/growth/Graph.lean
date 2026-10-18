import host.load.growth.Result
import host.mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Growth256
open Host.Mlx Host.Mlx.FfiEval

/-- Four incoming tensor carriers, followed by the eight operations the
real source method emitted at positive-capacity growth. -/
def expected : List (RNode Int (Fin 4)) :=
  [⟨.input 0, []⟩, ⟨.input 1, []⟩, ⟨.input 2, []⟩, ⟨.input 3, []⟩,
   ⟨.zeros [1,4,256,256] 12, []⟩, ⟨.zeros [1,4,256,256] 12, []⟩,
   ⟨.concat 2, [0,4]⟩, ⟨.concat 2, [1,5]⟩,
   ⟨.sliceUpdate [0,0,256,0] [1,4,257,256] [1,1,1,1], [6,2]⟩,
   ⟨.sliceUpdate [0,0,256,0] [1,4,257,256] [1,1,1,1], [7,3]⟩,
   ⟨.slice [0,0,0,0] [1,4,257,256] [1,1,1,1], [8]⟩,
   ⟨.slice [0,0,0,0] [1,4,257,256] [1,1,1,1], [9]⟩]

noncomputable def carriers : List Nat :=
  [roots.oldKey.node, roots.oldValue.node, roots.newKey.node, roots.newValue.node,
   22672,22673,22674,22675,22676,22677,22678,22679]

noncomputable def actual (sources : KernelSources) (table : List Host.Ts.F64) : Nat → Option (RNode Int (Fin 4)) :=
  ffiGraph (concrete (Host.Ts.CSrv.val ⟨table⟩)) sources s5.ffi.mlx

/-- The certificate is checked against the actual post-fragment graph, for
every number table and kernel-source environment. No evaluation of derived
tensor values is assumed by this correspondence. -/
theorem graph_matches (sources : KernelSources) (table : List Host.Ts.F64) :
    Matches (actual sources table) expected carriers = true := by rfl

theorem output_carriers :
    certAt carriers 8 = outcome.bufferKey.node ∧ certAt carriers 9 = outcome.bufferValue.node ∧
    certAt carriers 10 = outcome.fetchedKey.node ∧ certAt carriers 11 = outcome.fetchedValue.node := by
  exact ⟨rfl,rfl,rfl,rfl⟩

end Host.Load.Run.Full.Growth256
