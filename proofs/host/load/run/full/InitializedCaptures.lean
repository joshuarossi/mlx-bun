import host.load.run.full.SourceInitialization
import host.ts.BuiltinCaptureInitialization
import host.ts.RenameKernelRfl
import host.ts.RenameLiteralCaptureSeed

set_option Elab.async false
namespace Host.Load.Run.Full
open Host.Ts Host.Load Host.Ts.Owned Host.Ts.Owned.Annotated

def initializedTypedCaptures : NativeCaptureNotes :=
  NativeCaptureNotes.empty.write 90 (NativeCaptureNote.typedConstructor 4 21)

theorem boot_int32_kind : (P.s0.obj? 90).map Obj.kind =
    some (.fn (.native (.buf .typedCtor) [natV 4,natV 21])) := by host_kernel_rfl

theorem loaded_int32_kind : (P.s2818.obj? 90).map Obj.kind =
    some (.fn (.native (.buf .typedCtor) [natV 4,natV 21])) := by host_kernel_rfl

theorem loaded_int32_capture (ν : Nat → F64) (C : CSrv) (R : Ren) (fixed : R.a 90 = 90) :
    (NativeCaptureNote.typedConstructor 4 21).Holds ν C R 90 P.s2818 := by
  apply NativeCaptureNote.typedConstructor_of_kind ν C R _ 90 4 21
  rw [fixed]
  exact loaded_int32_kind

theorem loaded_int32_inventory (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live : Nat → Prop)
    (alive : live 90) (fixed : R.a 90 = 90) :
    NativeCaptureInventory initializedTypedCaptures ν₀ ν C₀ C R live P.s2818 P.s2818 :=
  NativeCaptureInventory.empty.annotate 90 (NativeCaptureNote.typedConstructor 4 21) alive
    (loaded_int32_capture ν₀ C₀ identity rfl) (loaded_int32_capture ν C R fixed)

/-- Actual linking, openModel and cache initialization reach a heap carrying
the fixed Int32Array metadata. Loading consumes no comparison answers; neither
future token choices nor target postvalues are premises. -/
theorem source_initialization_captures (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 28172201 start C) =
      some (P.s2818,C') ∧ C'.tab = P.S2818.tab.map (SymE.eval ρ) ∧ InitializationAt P.s2818 ∧
      NativeCaptureInventory initializedTypedCaptures ρ ρ C' C' identity (fun _ => True) P.s2818 P.s2818 := by
  obtain ⟨C',run,tab,initialized⟩ := source_initialization ρ C table
  exact ⟨C',run,tab,initialized,loaded_int32_inventory ρ ρ C' C' identity _ True.intro rfl⟩

/-- Linking itself reaches the exact source heap that supplies all retained
literal native metadata, including the other typed constructors. -/
theorem boot_literal_captures (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live : Nat → Prop) :
    P.boot = some P.s0 ∧
      NativeCaptureInventory (literalCaptures live P.s0) ν₀ ν C₀ C identity live P.s0 P.s0 :=
  ⟨P.boot_eq,NativeCaptureInventory.literal_seed_same P.s0 ν₀ ν C₀ C identity live (fun _ _ _ => rfl)⟩

/-- The actual openModel/cache run establishes the initialized literal-capture
inventory on the reached heap. There is no arbitrary-target StateR premise. -/
theorem source_initialization_literal_captures (ρ : Nat → F64) (C : CSrv) (live : Nat → Prop)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 28172201 start C) =
      some (P.s2818,C') ∧ C'.tab = P.S2818.tab.map (SymE.eval ρ) ∧ InitializationAt P.s2818 ∧
      NativeCaptureInventory (literalCaptures live P.s2818) ρ ρ C' C' identity live P.s2818 P.s2818 := by
  obtain ⟨C',run,tab,initialized⟩ := source_initialization ρ C table
  exact ⟨C',run,tab,initialized,NativeCaptureInventory.literal_seed_same P.s2818 ρ ρ C' C' identity live (fun _ _ _ => rfl)⟩

end Host.Load.Run.Full
