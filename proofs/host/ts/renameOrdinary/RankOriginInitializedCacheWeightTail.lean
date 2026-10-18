import host.ts.renameOrdinary.RankOriginInitializedCacheWeightShape
import host.load.RuntimeOracleWeightShapeSpread

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheWeightTail
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorOracleBatch RetainedOracleConcatReturnBatch
open InitializedCacheWeightRank (identity_budget)
open InitializedCacheWeightShape (owned_weight)

def live7 := InitializedCacheWeightShape.live7
def live8 := shapeBufferLive live7
def live9 := shapeSpreadEntryLive live8
def live10 := shapeTailLive live9

theorem live7_grow (a : Nat) (alive : InitialRetained.live a) : live7 a := InitializedCacheWeightShape.live7_grow a alive
theorem live8_grow (a : Nat) (alive : InitialRetained.live a) : live8 a := by
  have base := live7_grow a alive
  unfold live8 shapeBufferLive
  repeat first | exact base | apply Or.inl
theorem live9_grow (a : Nat) (alive : InitialRetained.live a) : live9 a := by
  have base := live8_grow a alive
  unfold live9 shapeSpreadEntryLive
  repeat first | exact base | apply Or.inl
theorem live10_grow (a : Nat) (alive : InitialRetained.live a) : live10 a := by
  have base := live9_grow a alive
  unfold live10 shapeTailLive
  repeat first | exact base | apply Or.inl

theorem native_frame : P.RestStream.micro0.micro5.s70.ffi = P.RestStream.micro0.micro5.s30.ffi := by host_kernel_rfl

theorem constructor_selected (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller).captures.owners 90 =
      some InitialRetained.constructorMetadata := by
  change (InitializedCache.entryNotes ic is).captures.owners 90 = some InitialRetained.constructorMetadata
  simpa only [InitializedCache.constructorMetadata,InitialRetained.constructorMetadata,literalNativeNote_subst]
    using InitializedCache.entry_constructor ic is

theorem public_fields (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (shapeTailNotes notes caller).publicFields = notes.publicFields := rfl

theorem initialized_weight_tail (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742425 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' InitializedCacheConcat.roles NativeSeed.boundary
          InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation)
        identity live10 (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro5.s70 result ∧
      RetainedInventory (shapeTailNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller) (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity live10 P.RestStream.micro0.micro5.s70 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes
        InitializedCacheConcat.roles InitializedCacheConcat.objects ∧
      ProducerSupport ObjectSeed.roots InitializedCacheConcat.handles InitializedCacheConcat.nodes P.RestStream.micro0.micro5.s70.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit)) (numberServer (P.RestStream.micro0.micro5.S70.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s530,run530,h530,inventory530,policy,support,inst530⟩ :=
    InitializedCacheWeightShape.initialized_weight_shape ρ C limit table answers
  let notes := RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller
  have intrinsic {live : Nat → Prop} (grow : ∀ a, InitialRetained.live a → live a) (a : Nat) (small : a < 100) : live a :=
    grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  obtain ⟨s552,run22,h552,inventory552,inst552⟩ := weight_shape_to_buffer notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live7 (fun _ => False) [] [] input.trace input.trace s530 inst530 h530 inventory530
    (identity_budget h530 (by decide +kernel))
    (intrinsic live7_grow _ (by decide +kernel)) rfl (intrinsic live7_grow _ (by decide +kernel)) rfl
    (intrinsic live7_grow _ (by decide +kernel)) rfl (intrinsic live7_grow _ (by decide +kernel)) rfl
    (intrinsic live7_grow _ (by decide +kernel)) rfl (intrinsic live7_grow _ (by decide +kernel)) rfl
    owned_weight rfl (constructor_selected ic is control fnRole thisRole saved caller)
  obtain ⟨s555,run3,h555,inventory555,inst555⟩ := weight_buffer_to_spread notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live8 (fun _ => False) [] [] input.trace input.trace s552 inst552 h552 inventory552
    (identity_budget h552 (by decide +kernel))
    (intrinsic live8_grow _ (by decide +kernel)) rfl (intrinsic live8_grow _ (by decide +kernel)) rfl
    (intrinsic live8_grow _ (by decide +kernel)) rfl (intrinsic live8_grow _ (by decide +kernel)) rfl
    (intrinsic live8_grow _ (by decide +kernel)) rfl (intrinsic live8_grow _ (by decide +kernel)) rfl
    owned_weight rfl (constructor_selected ic is control fnRole thisRole saved caller)
  obtain ⟨result,run15,h570,inventory570,inst570⟩ := weight_spread_to_tail notes caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    NativeSeed.boundary InitializedCacheConcat.objects InitializedCacheConcat.handles InitializedCacheConcat.nodes [] InitializedCache.hostRelation
    live9 (fun _ => False) [] [] input.trace input.trace s555 inst555 h555 inventory555
    (identity_budget h555 (by decide +kernel))
    (intrinsic live9_grow _ (by decide +kernel)) rfl (intrinsic live9_grow _ (by decide +kernel)) rfl
    (intrinsic live9_grow _ (by decide +kernel)) rfl (intrinsic live9_grow _ (by decide +kernel)) rfl
    (intrinsic live9_grow _ (by decide +kernel)) rfl (intrinsic live9_grow _ (by decide +kernel)) rfl
    owned_weight rfl (constructor_selected ic is control fnRole thisRole saved caller)
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h570,inventory570,policy,?_,inst570⟩
  · have run40 := runC_join P.F (m:=25) (n:=15) (runC_join P.F (m:=22) (n:=3) run22 run3) run15
    cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run530; cases run530
    | some start =>
      simp only [boot,Option.bind_some] at run530 ⊢
      exact runC_join P.F (m:=32742385) (n:=40) run530 run40
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheWeightTail
