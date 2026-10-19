import host.ts.renameOrdinary.RankOriginInitializedCacheSliceOutput
import host.load.RuntimeOracleSliceOutputC

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceArguments
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedOracleConvolutionBatch
open InitializedCacheWeightRank (identity_budget)

def live25 := InitializedCacheSliceOutput.live25
def live26 := outputBLive live25
def live27 := outputCLive live26

theorem live25_grow (a : Nat) (alive : InitialRetained.live a) : live25 a := InitializedCacheSliceOutput.live25_grow a alive
theorem live26_grow (a : Nat) (alive : InitialRetained.live a) : live26 a := by
  have base := live25_grow a alive
  unfold live26 outputBLive
  repeat first | exact base | apply Or.inl
theorem live27_grow (a : Nat) (alive : InitialRetained.live a) : live27 a := by
  have base := live26_grow a alive
  unfold live27 outputCLive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro10.s48.ffi = P.RestStream.micro0.micro9.s80.ffi := by host_kernel_rfl

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (outputCNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_slice_arguments (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742903 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live27 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro10.s48 result ∧
      RetainedInventory (outputCNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live27 P.RestStream.micro0.micro10.s48 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro10.s48.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro10.S48.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s980,run980,h980,inventory980,policy,support,inst980⟩ :=
    InitializedCacheSliceOutput.initialized_slice_output ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s1005,run25,h1005,inventory1005,inst1005⟩ := slice_output_b notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live25 (fun _ => False) [] [] input.trace input.trace s980 inst980 h980 inventory980
    (identity_budget h980 (by decide +kernel))
    (intrinsic live25_grow _ (by decide +kernel)) rfl (intrinsic live25_grow _ (by decide +kernel)) rfl
    (intrinsic live25_grow _ (by decide +kernel)) rfl (intrinsic live25_grow _ (by decide +kernel)) rfl
    (intrinsic live25_grow _ (by decide +kernel)) rfl (intrinsic live25_grow _ (by decide +kernel)) rfl (intrinsic live25_grow _ (by decide +kernel)) rfl
    (InitializedCacheConcatEntry.constructor_selected ic is control fnRole thisRole saved caller) (by trivial)
  obtain ⟨s1048,run43,h1048,inventory1048,inst1048⟩ := slice_output_c notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
      InitializedCacheConcat.roles NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
    live26 (fun _ => False) [] [] input.trace input.trace s1005 inst1005 h1005 inventory1005
    (identity_budget h1005 (by decide +kernel))
    (intrinsic live26_grow _ (by decide +kernel)) rfl (intrinsic live26_grow _ (by decide +kernel)) rfl
    (intrinsic live26_grow _ (by decide +kernel)) rfl (intrinsic live26_grow _ (by decide +kernel)) rfl
    (intrinsic live26_grow _ (by decide +kernel)) rfl (intrinsic live26_grow _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s1048,?_,h1048,inventory1048,policy,?_,inst1048⟩
  · have run68 := runC_join P.F (m:=25) (n:=43) run25 run43
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run980; cases run980
    | some start =>
      simp only [boot,Option.bind_some] at run980 ⊢
      exact runC_join P.F (m:=32742835) (n:=68) run980 run68
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheSliceArguments
