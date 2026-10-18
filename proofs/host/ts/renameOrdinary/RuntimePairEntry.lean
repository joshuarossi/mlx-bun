import host.ts.renameOrdinary.RuntimeRetainedSeed
import host.load.RuntimeDriverTest
import host.ts.RenameRuntimePairSeed
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedPrefix SourceDriver

noncomputable def savedFrame : Frame := (input.stack[2]?).getD (.e (.binR .add .undef))
noncomputable def callerFrames : List Frame := input.stack.drop 3
theorem paired_stack : input.stack = .c (.args Source1.sourceKind Source1.sourceFunction Source1.sourceThis []
    Source1.sourceRest Source1.sourceEnv)::
    .c (.args Source11.sourceKind (.obj 90) .undef [] Source11.sourceRest Source11.sourceEnv)::savedFrame::callerFrames := by
  host_kernel_rfl

/-- The actual nested constructor/caller frames are seeded from this reached
entry. No annotation for an intermediate buffer or later operand is required. -/
theorem pair_entry (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (notes : RetainedNotes) (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s) :
    ∃ (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (savedNote : Annotated.Tree) (caller : List Annotated.Tree),
      RetainedInventory (notes.withRuntime ⟨control,
        argumentFrameNote false Source1.sourceKind fnRole thisRole [] Source1.sourceRest Source1.sourceEnv::
          argumentFrameNote false Source11.sourceKind (.obj 90) .undef [] Source11.sourceRest Source11.sourceEnv::savedNote::caller,
        notes.runtime.cells⟩)
        ν₀ ν C₀ C R live input s := by
  obtain ⟨control,fnRole,thisRole,savedNote,caller,runtime⟩ := RuntimeInventory.argument_pair_entry h inventory.runtime.cellInventory
    Source1.sourceKind Source1.sourceFunction Source1.sourceThis Source1.sourceRest Source1.sourceEnv
    Source11.sourceKind 90 Source11.sourceRest Source11.sourceEnv savedFrame callerFrames paired_stack
  exact ⟨control,fnRole,thisRole,savedNote,caller,runtime,inventory.privates,inventory.captures,
    inventory.arrays,inventory.publicFields,inventory.buffers⟩
end Host.Load.Run.Full.Ordinary.RetainedSeed
