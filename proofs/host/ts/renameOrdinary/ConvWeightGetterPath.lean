import host.ts.renameOrdinary.ConvWeightGetterSteps
import host.ts.RenameParameterBodyFrame
import host.ts.RenameClosureEffects
import host.ts.RenameArgumentEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def WeightLive446 (live : Nat → Prop) : Nat → Prop := ClosureLive live WeightShapeGetter445.input.next WeightShapeGetter445.sourceArrow WeightShapeGetter445.sourceHome WeightShapeGetter445.sourceFunction

def WeightLive447 (live : Nat → Prop) : Nat → Prop := CellsLive (WeightLive446 live) WeightShapeBody446.input.next (blockNames WeightShapeBody446.sourceBody)

def WeightLive453 (live : Nat → Prop) : Nat → Prop := ClosureLive (WeightLive447 live) WeightEnterRank452.input.next WeightEnterRank452.sourceArrow WeightEnterRank452.sourceHome WeightEnterRank452.sourceFunction

def WeightLive454 (live : Nat → Prop) : Nat → Prop := CellsLive (WeightLive453 live) WeightRankBody453.input.next (blockNames WeightRankBody453.sourceBody)

def WeightLive467 (live : Nat → Prop) : Nat → Prop := ClosureLive (WeightLive454 live) WeightEnterHandle466.input.next WeightEnterHandle466.sourceArrow WeightEnterHandle466.sourceHome WeightEnterHandle466.sourceFunction

def WeightLive468 (live : Nat → Prop) : Nat → Prop := CellsLive (WeightLive467 live) WeightHandleBody467.input.next (blockNames WeightHandleBody467.sourceBody)

theorem WeightLive446.grow (live : Nat → Prop) (a : Nat) (ha : live a) : WeightLive446 live a := by
  exact ClosureLive.grow _ WeightShapeGetter445.input.next WeightShapeGetter445.sourceArrow WeightShapeGetter445.sourceHome WeightShapeGetter445.sourceFunction a (ha)

theorem WeightLive447.grow (live : Nat → Prop) (a : Nat) (ha : live a) : WeightLive447 live a := by
  exact CellsLive.grow _ WeightShapeBody446.input.next (blockNames WeightShapeBody446.sourceBody) a (WeightLive446.grow live a ha)

theorem WeightLive453.grow (live : Nat → Prop) (a : Nat) (ha : live a) : WeightLive453 live a := by
  exact ClosureLive.grow _ WeightEnterRank452.input.next WeightEnterRank452.sourceArrow WeightEnterRank452.sourceHome WeightEnterRank452.sourceFunction a (WeightLive447.grow live a ha)

theorem WeightLive454.grow (live : Nat → Prop) (a : Nat) (ha : live a) : WeightLive454 live a := by
  exact CellsLive.grow _ WeightRankBody453.input.next (blockNames WeightRankBody453.sourceBody) a (WeightLive453.grow live a ha)

theorem WeightLive467.grow (live : Nat → Prop) (a : Nat) (ha : live a) : WeightLive467 live a := by
  exact ClosureLive.grow _ WeightEnterHandle466.input.next WeightEnterHandle466.sourceArrow WeightEnterHandle466.sourceHome WeightEnterHandle466.sourceFunction a (WeightLive454.grow live a ha)

theorem WeightLive468.grow (live : Nat → Prop) (a : Nat) (ha : live a) : WeightLive468 live a := by
  exact CellsLive.grow _ WeightHandleBody467.input.next (blockNames WeightHandleBody467.sourceBody) a (WeightLive467.grow live a ha)

/-- The actual nested shape/ndim/handle getters supply the owned handle for
its real native rank call. The private-field occurrence comes from entry;
all intermediate reads and the call argument follow from execution. -/
theorem conv_weight_rank_argument (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' WeightShapeGetter445.input s)
    (field : PrivateData s (R.a WeightHandleValue478.sourceAddress) (R.a WeightHandleValue478.sourceBrand)
      WeightHandleValue478.sourceName (.big (Int.ofNat (R.handle 1365))))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+20 ≤ 2^64) :
    ∃ result, runC P.F 39 s C = some (result,C) ∧
      StateR NR FR R (WeightLive468 live) framed before after old old' WeightRankArgument483.output result ∧
      callArgument result.ctl 0 = .big (Int.ofNat (R.handle 1365)) ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  let s445 := s
  have h445 := h
  have next445 := h.heap.target_next_add h445.heap (WeightShapeGetter445.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget445 : WeightShapeGetter445.input.next-WeightShapeGetter445.input.next+(2+(paramNames WeightShapeGetter445.sourceFunction).length) ≤ 20 := by decide +kernel
  have need445 : 2+(paramNames WeightShapeGetter445.sourceFunction).length ≤ 20 := by decide +kernel
  have bound445 : s445.next+(2+(paramNames WeightShapeGetter445.sourceFunction).length) ≤ 2^64 := by
    change s.next+(2+(paramNames WeightShapeGetter445.sourceFunction).length) ≤ 2^64
    omega
  obtain ⟨s446,r445,h446⟩ := WeightShapeGetter445.transport NR FR R C₀ C live framed before after old old' s445 h445 bound445
  have next446 := h.heap.target_next_add h446.heap (WeightShapeBody446.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget446 : WeightShapeBody446.input.next-WeightShapeGetter445.input.next+((blockNames WeightShapeBody446.sourceBody).length) ≤ 20 := by decide +kernel
  have bound446 : s446.next+((blockNames WeightShapeBody446.sourceBody).length) ≤ 2^64 := by omega
  obtain ⟨s447,r446,h447⟩ := WeightShapeBody446.transport NR FR R C₀ C (WeightLive446 live) framed before after old old' s446 h446 bound446
  obtain ⟨s448,r447,h448⟩ := WeightShapeBlock447.transport NR FR R C₀ C (WeightLive447 live) framed before after old old' s447 h447
  obtain ⟨s449,r448,h449⟩ := WeightRankDeclaration448.transport NR FR R C₀ C (WeightLive447 live) framed before after old old' s448 h448
  obtain ⟨s450,r449,h450⟩ := WeightRankMember449.transport NR FR R C₀ C (WeightLive447 live) framed before after old old' s449 h449
  obtain ⟨s451,r450,h451⟩ := WeightRankThis450.transport NR FR R C₀ C (WeightLive447 live) framed before after old old' s450 h450
  obtain ⟨s452,r451,h452⟩ := WeightRankGetter451.transport NR FR R C₀ C (WeightLive447 live) framed before after old old' s451 h451
  have next452 := h.heap.target_next_add h452.heap (WeightEnterRank452.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget452 : WeightEnterRank452.input.next-WeightShapeGetter445.input.next+(2+(paramNames WeightEnterRank452.sourceFunction).length) ≤ 20 := by decide +kernel
  have bound452 : s452.next+(2+(paramNames WeightEnterRank452.sourceFunction).length) ≤ 2^64 := by omega
  obtain ⟨s453,r452,h453⟩ := WeightEnterRank452.transport NR FR R C₀ C (WeightLive447 live) framed before after old old' s452 h452 bound452
  have next453 := h.heap.target_next_add h453.heap (WeightRankBody453.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget453 : WeightRankBody453.input.next-WeightShapeGetter445.input.next+((blockNames WeightRankBody453.sourceBody).length) ≤ 20 := by decide +kernel
  have bound453 : s453.next+((blockNames WeightRankBody453.sourceBody).length) ≤ 2^64 := by omega
  obtain ⟨s454,r453,h454⟩ := WeightRankBody453.transport NR FR R C₀ C (WeightLive453 live) framed before after old old' s453 h453 bound453
  obtain ⟨s455,r454,h455⟩ := WeightRankBlock454.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s454 h454
  obtain ⟨s456,r455,h456⟩ := WeightRankReturn455.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s455 h455
  obtain ⟨s457,r456,h457⟩ := WeightNumberCall456.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s456 h456
  obtain ⟨v457,r457,h458,_⟩ := WeightNumberGlobal457.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s457 h457 (WeightLive454.grow live aGlobal globalLive) globalFixed
  let s458 := s457.ret v457
  obtain ⟨s459,r458,h459⟩ := WeightNumberArguments458.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s458 h458
  obtain ⟨s460,r459,h460⟩ := WeightRankNativeCall459.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s459 h459
  obtain ⟨v460,r460,h461,_⟩ := WeightRankNativeNamespace460.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s460 h460
  let s461 := s460.ret v460
  obtain ⟨s462,r461,h462⟩ := WeightRankNativeMethod461.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s461 h461
  obtain ⟨s463,r462,h463⟩ := WeightRankNativeArguments462.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s462 h462
  obtain ⟨s464,r463,h464⟩ := WeightRankHandleMember463.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s463 h463
  obtain ⟨s465,r464,h465⟩ := WeightRankHandleThis464.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s464 h464
  obtain ⟨s466,r465,h466⟩ := WeightRankHandleGetter465.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s465 h465
  have next466 := h.heap.target_next_add h466.heap (WeightEnterHandle466.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget466 : WeightEnterHandle466.input.next-WeightShapeGetter445.input.next+(2+(paramNames WeightEnterHandle466.sourceFunction).length) ≤ 20 := by decide +kernel
  have bound466 : s466.next+(2+(paramNames WeightEnterHandle466.sourceFunction).length) ≤ 2^64 := by omega
  obtain ⟨s467,r466,h467⟩ := WeightEnterHandle466.transport NR FR R C₀ C (WeightLive454 live) framed before after old old' s466 h466 bound466
  have next467 := h.heap.target_next_add h467.heap (WeightHandleBody467.input.next-WeightShapeGetter445.input.next) (by host_kernel_rfl)
  have budget467 : WeightHandleBody467.input.next-WeightShapeGetter445.input.next+((blockNames WeightHandleBody467.sourceBody).length) ≤ 20 := by decide +kernel
  have bound467 : s467.next+((blockNames WeightHandleBody467.sourceBody).length) ≤ 2^64 := by omega
  obtain ⟨s468,r467,h468⟩ := WeightHandleBody467.transport NR FR R C₀ C (WeightLive467 live) framed before after old old' s467 h467 bound467
  obtain ⟨s469,r468,h469⟩ := WeightHandleBlock468.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s468 h468
  obtain ⟨s470,r469,h470⟩ := WeightHandleDisposedTest469.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s469 h469
  obtain ⟨s471,r470,h471⟩ := WeightHandleDisposed470.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s470 h470
  obtain ⟨s472,r471,h472⟩ := WeightHandleDisposedThis471.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s471 h471
  obtain ⟨s473,r472,h473⟩ := WeightHandleDisposedValue472.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s472 h472
  obtain ⟨s474,r473,h474⟩ := WeightHandleDisposedBranch473.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s473 h473
  obtain ⟨s475,r474,h475⟩ := WeightHandleReturnBlock474.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s474 h474
  obtain ⟨s476,r475,h476⟩ := WeightHandleReturn475.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s475 h475
  obtain ⟨s477,r476,h477⟩ := WeightHandlePrivate476.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s476 h476
  obtain ⟨s478,r477,h478⟩ := WeightHandleThis477.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s477 h477
  obtain ⟨s479,r478,h479⟩ := WeightHandleValue478.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s478 h478
  obtain ⟨s480,r479,h480⟩ := WeightHandleReturn479.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s479 h479
  obtain ⟨s481,r480,h481⟩ := WeightHandleBlock480.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s480 h480
  obtain ⟨s482,r481,h482⟩ := WeightHandleScope481.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s481 h481
  obtain ⟨s483,r482,h483⟩ := WeightHandleCall482.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s482 h482
  obtain ⟨result,r483,h484⟩ := WeightRankArgument483.transport NR FR R C₀ C (WeightLive468 live) framed before after old old' s483 h483
  have heap446 := step_closure_heap_below P.F NR FR R live framed before after old old' WeightShapeGetter445.input s445 s446 C C h445
    WeightShapeGetter445.address WeightShapeGetter445.object WeightShapeGetter445.sourceFunction WeightShapeGetter445.sourceEnv WeightShapeGetter445.sourceArrow WeightShapeGetter445.sourceHome WeightShapeGetter445.sourceThis WeightShapeGetter445.sourceArgs WeightShapeGetter445.source_control WeightShapeGetter445.source_heap WeightShapeGetter445.source_kind bound445 r445
  have heap447 := step_parameter_body_heap_below P.F NR FR R (WeightLive446 live) framed before after old old' WeightShapeBody446.input s446 s447 C C h446
    WeightShapeBody446.sourceValue WeightShapeBody446.sourceName WeightShapeBody446.sourceParams WeightShapeBody446.sourceBody WeightShapeBody446.sourceArgs WeightShapeBody446.sourceEnv WeightShapeBody446.sourceTail WeightShapeBody446.source_control WeightShapeBody446.source_frame WeightShapeBody446.source_hoist bound446 r446
  have heap448 := step_block_next_heap P.F NR FR R (WeightLive447 live) framed before after old old' WeightShapeBlock447.input s447 s448 C C h447
    WeightShapeBlock447.sourceValue WeightShapeBlock447.sourceStatement WeightShapeBlock447.sourceRest WeightShapeBlock447.sourceEnv WeightShapeBlock447.sourceTail WeightShapeBlock447.source_control WeightShapeBlock447.source_frame r447
  have heap449 := step_statement_heap P.F NR FR R (WeightLive447 live) framed before after old old' WeightRankDeclaration448.input s448 s449 C C h448
    WeightRankDeclaration448.sourceAction WeightRankDeclaration448.sourceEnv WeightRankDeclaration448.source_control r448
  have heap450 := step_descent_heap_from_source P.F NR FR R (WeightLive447 live) framed before after old old' WeightRankMember449.input s449 s450 C C h449
    WeightRankMember449.descent WeightRankMember449.sourceEnv WeightRankMember449.source_control r449
  have heap451 := step_this_heap_from_source P.F NR FR R (WeightLive447 live) framed before after old old' WeightRankThis450.input s450 s451 C₀ C C h450
    WeightRankThis450.sourceEnv WeightRankThis450.sourceAddress WeightRankThis450.sourceValue WeightRankThis450.source_control WeightRankThis450.source_lookup WeightRankThis450.source_cell r450
  have heap452 := WeightRankGetter451.heap_frame NR FR R C₀ C C (WeightLive447 live) framed before after old old' s451 s452 h451 r451
  have heap453 := step_closure_heap_below P.F NR FR R (WeightLive447 live) framed before after old old' WeightEnterRank452.input s452 s453 C C h452
    WeightEnterRank452.address WeightEnterRank452.object WeightEnterRank452.sourceFunction WeightEnterRank452.sourceEnv WeightEnterRank452.sourceArrow WeightEnterRank452.sourceHome WeightEnterRank452.sourceThis WeightEnterRank452.sourceArgs WeightEnterRank452.source_control WeightEnterRank452.source_heap WeightEnterRank452.source_kind bound452 r452
  have heap454 := step_parameter_body_heap_below P.F NR FR R (WeightLive453 live) framed before after old old' WeightRankBody453.input s453 s454 C C h453
    WeightRankBody453.sourceValue WeightRankBody453.sourceName WeightRankBody453.sourceParams WeightRankBody453.sourceBody WeightRankBody453.sourceArgs WeightRankBody453.sourceEnv WeightRankBody453.sourceTail WeightRankBody453.source_control WeightRankBody453.source_frame WeightRankBody453.source_hoist bound453 r453
  have heap455 := step_block_next_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankBlock454.input s454 s455 C C h454
    WeightRankBlock454.sourceValue WeightRankBlock454.sourceStatement WeightRankBlock454.sourceRest WeightRankBlock454.sourceEnv WeightRankBlock454.sourceTail WeightRankBlock454.source_control WeightRankBlock454.source_frame r454
  have heap456 := step_statement_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankReturn455.input s455 s456 C C h455
    (.returnExpression WeightRankReturn455.sourceExpression) WeightRankReturn455.sourceEnv WeightRankReturn455.source_control r455
  have heap457 := step_identifier_call_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightNumberCall456.input s456 s457 C₀ C C h456
    WeightNumberCall456.sourceName WeightNumberCall456.sourceArgs WeightNumberCall456.sourceOptional WeightNumberCall456.sourceEnv WeightNumberCall456.source_control r456
  have heap458 : s458.heap = s457.heap := rfl
  have heap459 := step_callStart_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightNumberArguments458.input s458 s459 C C h458
    (.callee WeightNumberArguments458.sourceOptional) WeightNumberArguments458.sourceAddress .undef WeightNumberArguments458.sourceArgs WeightNumberArguments458.sourceEnv WeightNumberArguments458.sourceTail WeightNumberArguments458.source_control WeightNumberArguments458.source_frame r458
  have heap460 := step_method_descent_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankNativeCall459.input s459 s460 C₀ C C h459
    WeightRankNativeCall459.sourceExpression WeightRankNativeCall459.sourceName WeightRankNativeCall459.sourceArgs WeightRankNativeCall459.sourceEnv WeightRankNativeCall459.sourceOptObject WeightRankNativeCall459.sourceOptCall WeightRankNativeCall459.source_control r459
  have heap461 : s461.heap = s460.heap := rfl
  have heap462 := step_method_data_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankNativeMethod461.input s461 s462 C C h461
    WeightRankNativeMethod461.sourceAddress WeightRankNativeMethod461.sourceObject WeightRankNativeMethod461.sourceName WeightRankNativeMethod461.sourceArgs WeightRankNativeMethod461.sourceEnv WeightRankNativeMethod461.sourceOptObject WeightRankNativeMethod461.sourceOptCall WeightRankNativeMethod461.sourceMethod WeightRankNativeMethod461.sourceWritable WeightRankNativeMethod461.sourceEnumerable WeightRankNativeMethod461.sourceTail WeightRankNativeMethod461.source_control WeightRankNativeMethod461.source_frame WeightRankNativeMethod461.source_heap WeightRankNativeMethod461.source_kind WeightRankNativeMethod461.source_property r461
  have heap463 := step_callStart_heap P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankNativeArguments462.input s462 s463 C C h462
    WeightRankNativeArguments462.sourceMode WeightRankNativeArguments462.sourceAddress WeightRankNativeArguments462.sourceThis WeightRankNativeArguments462.sourceArgs WeightRankNativeArguments462.sourceEnv WeightRankNativeArguments462.sourceTail WeightRankNativeArguments462.source_control WeightRankNativeArguments462.source_frame r462
  have heap464 := step_descent_heap_from_source P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankHandleMember463.input s463 s464 C C h463
    WeightRankHandleMember463.descent WeightRankHandleMember463.sourceEnv WeightRankHandleMember463.source_control r463
  have heap465 := step_this_heap_from_source P.F NR FR R (WeightLive454 live) framed before after old old' WeightRankHandleThis464.input s464 s465 C₀ C C h464
    WeightRankHandleThis464.sourceEnv WeightRankHandleThis464.sourceAddress WeightRankHandleThis464.sourceValue WeightRankHandleThis464.source_control WeightRankHandleThis464.source_lookup WeightRankHandleThis464.source_cell r464
  have heap466 := WeightRankHandleGetter465.heap_frame NR FR R C₀ C C (WeightLive454 live) framed before after old old' s465 s466 h465 r465
  have heap467 := step_closure_heap_below P.F NR FR R (WeightLive454 live) framed before after old old' WeightEnterHandle466.input s466 s467 C C h466
    WeightEnterHandle466.address WeightEnterHandle466.object WeightEnterHandle466.sourceFunction WeightEnterHandle466.sourceEnv WeightEnterHandle466.sourceArrow WeightEnterHandle466.sourceHome WeightEnterHandle466.sourceThis WeightEnterHandle466.sourceArgs WeightEnterHandle466.source_control WeightEnterHandle466.source_heap WeightEnterHandle466.source_kind bound466 r466
  have heap468 := step_parameter_body_heap_below P.F NR FR R (WeightLive467 live) framed before after old old' WeightHandleBody467.input s467 s468 C C h467
    WeightHandleBody467.sourceValue WeightHandleBody467.sourceName WeightHandleBody467.sourceParams WeightHandleBody467.sourceBody WeightHandleBody467.sourceArgs WeightHandleBody467.sourceEnv WeightHandleBody467.sourceTail WeightHandleBody467.source_control WeightHandleBody467.source_frame WeightHandleBody467.source_hoist bound467 r467
  have heap469 := step_block_next_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleBlock468.input s468 s469 C C h468
    WeightHandleBlock468.sourceValue WeightHandleBlock468.sourceStatement WeightHandleBlock468.sourceRest WeightHandleBlock468.sourceEnv WeightHandleBlock468.sourceTail WeightHandleBlock468.source_control WeightHandleBlock468.source_frame r468
  have heap470 := step_statement_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleDisposedTest469.input s469 s470 C C h469
    WeightHandleDisposedTest469.sourceAction WeightHandleDisposedTest469.sourceEnv WeightHandleDisposedTest469.source_control r469
  have heap471 := step_private_descent_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleDisposed470.input s470 s471 C₀ C C h470
    WeightHandleDisposed470.sourceObject WeightHandleDisposed470.sourceName WeightHandleDisposed470.sourceOptional WeightHandleDisposed470.sourceEnv WeightHandleDisposed470.sourceBrand WeightHandleDisposed470.source_control WeightHandleDisposed470.source_brand r470
  have heap472 := step_this_heap_from_source P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleDisposedThis471.input s471 s472 C₀ C C h471
    WeightHandleDisposedThis471.sourceEnv WeightHandleDisposedThis471.sourceAddress WeightHandleDisposedThis471.sourceValue WeightHandleDisposedThis471.source_control WeightHandleDisposedThis471.source_lookup WeightHandleDisposedThis471.source_cell r471
  have heap473 := WeightHandleDisposedValue472.heap_frame NR FR R C₀ C C (WeightLive468 live) framed before after old old' s472 s473 h472 r472
  have heap474 := step_if_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleDisposedBranch473.input s473 s474 C C h473
    WeightHandleDisposedBranch473.sourceGuard WeightHandleDisposedBranch473.sourceYes WeightHandleDisposedBranch473.sourceNo WeightHandleDisposedBranch473.sourceEnv WeightHandleDisposedBranch473.sourceTail WeightHandleDisposedBranch473.source_control WeightHandleDisposedBranch473.source_frame r473
  have heap475 := step_block_next_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleReturnBlock474.input s474 s475 C C h474
    WeightHandleReturnBlock474.sourceValue WeightHandleReturnBlock474.sourceStatement WeightHandleReturnBlock474.sourceRest WeightHandleReturnBlock474.sourceEnv WeightHandleReturnBlock474.sourceTail WeightHandleReturnBlock474.source_control WeightHandleReturnBlock474.source_frame r474
  have heap476 := step_statement_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleReturn475.input s475 s476 C C h475
    (.returnExpression WeightHandleReturn475.sourceExpression) WeightHandleReturn475.sourceEnv WeightHandleReturn475.source_control r475
  have heap477 := step_private_descent_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandlePrivate476.input s476 s477 C₀ C C h476
    WeightHandlePrivate476.sourceObject WeightHandlePrivate476.sourceName WeightHandlePrivate476.sourceOptional WeightHandlePrivate476.sourceEnv WeightHandlePrivate476.sourceBrand WeightHandlePrivate476.source_control WeightHandlePrivate476.source_brand r476
  have heap478 := step_this_heap_from_source P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleThis477.input s477 s478 C₀ C C h477
    WeightHandleThis477.sourceEnv WeightHandleThis477.sourceAddress WeightHandleThis477.sourceValue WeightHandleThis477.source_control WeightHandleThis477.source_lookup WeightHandleThis477.source_cell r477
  have heap479 := WeightHandleValue478.heap_frame NR FR R C₀ C C (WeightLive468 live) framed before after old old' s478 s479 h478 r478
  have heap480 := step_return_exit_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleReturn479.input s479 s480 C C h479
    WeightHandleReturn479.sourceValue WeightHandleReturn479.sourceAction WeightHandleReturn479.sourceEnv WeightHandleReturn479.sourceTail WeightHandleReturn479.source_control WeightHandleReturn479.source_frame r479
  have heap481 := step_return_unwind_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleBlock480.input s480 s481 C C h480
    WeightHandleBlock480.sourceValue WeightHandleBlock480.sourceAction WeightHandleBlock480.sourceEnv WeightHandleBlock480.sourceTail WeightHandleBlock480.source_control WeightHandleBlock480.source_frame r480
  have heap482 := step_return_unwind_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleScope481.input s481 s482 C C h481
    WeightHandleScope481.sourceValue WeightHandleScope481.sourceAction WeightHandleScope481.sourceEnv WeightHandleScope481.sourceTail WeightHandleScope481.source_control WeightHandleScope481.source_frame r481
  have heap483 := step_return_unwind_heap P.F NR FR R (WeightLive468 live) framed before after old old' WeightHandleCall482.input s482 s483 C C h482
    WeightHandleCall482.sourceValue WeightHandleCall482.sourceAction WeightHandleCall482.sourceEnv WeightHandleCall482.sourceTail WeightHandleCall482.source_control WeightHandleCall482.source_frame r482
  have heap484 := step_argument_heap_from_source P.F NR FR R (WeightLive468 live) framed before after old old' WeightRankArgument483.input s483 result C C h483
    WeightRankArgument483.sourceValue WeightRankArgument483.sourceKind WeightRankArgument483.sourceFunction WeightRankArgument483.sourceThis WeightRankArgument483.sourceAcc WeightRankArgument483.sourceRest WeightRankArgument483.sourceEnv WeightRankArgument483.sourceTail WeightRankArgument483.source_control WeightRankArgument483.source_frame (by decide) r483
  have oldHeap478 (a : Nat) (below : a < s.next) : s478.heap.get a = s.heap.get a := by
    calc
      s478.heap.get a = s477.heap.get a := congrArg (fun hp => hp.get a) heap478
      _ = s476.heap.get a := congrArg (fun hp => hp.get a) heap477
      _ = s475.heap.get a := congrArg (fun hp => hp.get a) heap476
      _ = s474.heap.get a := congrArg (fun hp => hp.get a) heap475
      _ = s473.heap.get a := congrArg (fun hp => hp.get a) heap474
      _ = s472.heap.get a := congrArg (fun hp => hp.get a) heap473
      _ = s471.heap.get a := congrArg (fun hp => hp.get a) heap472
      _ = s470.heap.get a := congrArg (fun hp => hp.get a) heap471
      _ = s469.heap.get a := congrArg (fun hp => hp.get a) heap470
      _ = s468.heap.get a := congrArg (fun hp => hp.get a) heap469
      _ = s467.heap.get a := heap468 a (by omega)
      _ = s466.heap.get a := heap467 a (by omega)
      _ = s465.heap.get a := congrArg (fun hp => hp.get a) heap466
      _ = s464.heap.get a := congrArg (fun hp => hp.get a) heap465
      _ = s463.heap.get a := congrArg (fun hp => hp.get a) heap464
      _ = s462.heap.get a := congrArg (fun hp => hp.get a) heap463
      _ = s461.heap.get a := congrArg (fun hp => hp.get a) heap462
      _ = s460.heap.get a := congrArg (fun hp => hp.get a) heap461
      _ = s459.heap.get a := congrArg (fun hp => hp.get a) heap460
      _ = s458.heap.get a := congrArg (fun hp => hp.get a) heap459
      _ = s457.heap.get a := congrArg (fun hp => hp.get a) heap458
      _ = s456.heap.get a := congrArg (fun hp => hp.get a) heap457
      _ = s455.heap.get a := congrArg (fun hp => hp.get a) heap456
      _ = s454.heap.get a := congrArg (fun hp => hp.get a) heap455
      _ = s453.heap.get a := heap454 a (by omega)
      _ = s452.heap.get a := heap453 a (by omega)
      _ = s451.heap.get a := congrArg (fun hp => hp.get a) heap452
      _ = s450.heap.get a := congrArg (fun hp => hp.get a) heap451
      _ = s449.heap.get a := congrArg (fun hp => hp.get a) heap450
      _ = s448.heap.get a := congrArg (fun hp => hp.get a) heap449
      _ = s447.heap.get a := congrArg (fun hp => hp.get a) heap448
      _ = s446.heap.get a := heap447 a (by omega)
      _ = s445.heap.get a := heap446 a (by omega)
      _ = s.heap.get a := rfl
  have oldHeap484 (a : Nat) (below : a < s.next) : result.heap.get a = s.heap.get a := by
    calc
      result.heap.get a = s483.heap.get a := congrArg (fun hp => hp.get a) heap484
      _ = s482.heap.get a := congrArg (fun hp => hp.get a) heap483
      _ = s481.heap.get a := congrArg (fun hp => hp.get a) heap482
      _ = s480.heap.get a := congrArg (fun hp => hp.get a) heap481
      _ = s479.heap.get a := congrArg (fun hp => hp.get a) heap480
      _ = s478.heap.get a := congrArg (fun hp => hp.get a) heap479
      _ = s477.heap.get a := congrArg (fun hp => hp.get a) heap478
      _ = s476.heap.get a := congrArg (fun hp => hp.get a) heap477
      _ = s475.heap.get a := congrArg (fun hp => hp.get a) heap476
      _ = s474.heap.get a := congrArg (fun hp => hp.get a) heap475
      _ = s473.heap.get a := congrArg (fun hp => hp.get a) heap474
      _ = s472.heap.get a := congrArg (fun hp => hp.get a) heap473
      _ = s471.heap.get a := congrArg (fun hp => hp.get a) heap472
      _ = s470.heap.get a := congrArg (fun hp => hp.get a) heap471
      _ = s469.heap.get a := congrArg (fun hp => hp.get a) heap470
      _ = s468.heap.get a := congrArg (fun hp => hp.get a) heap469
      _ = s467.heap.get a := heap468 a (by omega)
      _ = s466.heap.get a := heap467 a (by omega)
      _ = s465.heap.get a := congrArg (fun hp => hp.get a) heap466
      _ = s464.heap.get a := congrArg (fun hp => hp.get a) heap465
      _ = s463.heap.get a := congrArg (fun hp => hp.get a) heap464
      _ = s462.heap.get a := congrArg (fun hp => hp.get a) heap463
      _ = s461.heap.get a := congrArg (fun hp => hp.get a) heap462
      _ = s460.heap.get a := congrArg (fun hp => hp.get a) heap461
      _ = s459.heap.get a := congrArg (fun hp => hp.get a) heap460
      _ = s458.heap.get a := congrArg (fun hp => hp.get a) heap459
      _ = s457.heap.get a := congrArg (fun hp => hp.get a) heap458
      _ = s456.heap.get a := congrArg (fun hp => hp.get a) heap457
      _ = s455.heap.get a := congrArg (fun hp => hp.get a) heap456
      _ = s454.heap.get a := congrArg (fun hp => hp.get a) heap455
      _ = s453.heap.get a := heap454 a (by omega)
      _ = s452.heap.get a := heap453 a (by omega)
      _ = s451.heap.get a := congrArg (fun hp => hp.get a) heap452
      _ = s450.heap.get a := congrArg (fun hp => hp.get a) heap451
      _ = s449.heap.get a := congrArg (fun hp => hp.get a) heap450
      _ = s448.heap.get a := congrArg (fun hp => hp.get a) heap449
      _ = s447.heap.get a := congrArg (fun hp => hp.get a) heap448
      _ = s446.heap.get a := heap447 a (by omega)
      _ = s445.heap.get a := heap446 a (by omega)
      _ = s.heap.get a := rfl
  have receiver : WeightShapeGetter445.sourceThis = .obj WeightHandleValue478.sourceAddress := by host_kernel_rfl
  have receiverLive : live WeightHandleValue478.sourceAddress := by
    have hl := h.controlLive
    change treeSupport live (Encode.ctl WeightShapeGetter445.input.ctl) at hl
    rw [WeightShapeGetter445.source_control,receiver] at hl
    exact hl.2.1
  have field478 := field.heap_at (oldHeap478 _ (h.heap.targetBound _ receiverLive))
  obtain ⟨ctl479,_⟩ := step_private_data_fields P.F NR FR R (WeightLive468 live) framed before after old old'
    WeightHandleValue478.input s478 s479 C C h478 WeightHandleValue478.sourceAddress WeightHandleValue478.sourceBrand
    WeightHandleValue478.sourceName (.big (Int.ofNat (R.handle 1365))) WeightHandleValue478.sourceTail
    WeightHandleValue478.source_control WeightHandleValue478.source_frame field478 r478
  have ctl480 := step_return_exit_control P.F NR FR R (WeightLive468 live) framed before after old old'
    WeightHandleReturn479.input s479 s480 C C h479 (.big (Int.ofNat (R.handle 1365))) WeightHandleReturn479.sourceAction
    WeightHandleReturn479.sourceEnv WeightHandleReturn479.sourceTail WeightHandleReturn479.source_frame ctl479 r479
  have ctl481 := step_return_unwind_control P.F NR FR R (WeightLive468 live) framed before after old old'
    WeightHandleBlock480.input s480 s481 C C h480 (.big (Int.ofNat (R.handle 1365))) WeightHandleBlock480.sourceAction
    WeightHandleBlock480.sourceEnv WeightHandleBlock480.sourceTail WeightHandleBlock480.source_frame ctl480 r480
  have ctl482 := step_return_unwind_control P.F NR FR R (WeightLive468 live) framed before after old old'
    WeightHandleScope481.input s481 s482 C C h481 (.big (Int.ofNat (R.handle 1365))) WeightHandleScope481.sourceAction
    WeightHandleScope481.sourceEnv WeightHandleScope481.sourceTail WeightHandleScope481.source_frame ctl481 r481
  have ctl483 := step_return_unwind_control P.F NR FR R (WeightLive468 live) framed before after old old'
    WeightHandleCall482.input s482 s483 C C h482 (.big (Int.ofNat (R.handle 1365))) WeightHandleCall482.sourceAction
    WeightHandleCall482.sourceEnv WeightHandleCall482.sourceTail WeightHandleCall482.source_frame ctl482 r482
  have frame483 : WeightRankArgument483.input.stack = .c (.args 0 WeightRankArgument483.sourceFunction
      WeightRankArgument483.sourceThis [] [] WeightRankArgument483.sourceEnv)::WeightRankArgument483.sourceTail := by host_kernel_rfl
  have argument := step_single_argument_fields P.F NR FR R C C (WeightLive468 live) framed before after old old'
    WeightRankArgument483.input s483 result h483 WeightRankArgument483.sourceFunction WeightRankArgument483.sourceThis
    (.big (Int.ofNat (R.handle 1365))) WeightRankArgument483.sourceEnv WeightRankArgument483.sourceTail frame483 ctl483 r483
  refine ⟨result,?_,h484,argument,oldHeap484⟩
  apply runC_cons P.F 38 s445 s446 result C C C (h445.control.isHalt_eq.trans (by host_kernel_rfl)) r445
  apply runC_cons P.F 37 s446 s447 result C C C (h446.control.isHalt_eq.trans (by host_kernel_rfl)) r446
  apply runC_cons P.F 36 s447 s448 result C C C (h447.control.isHalt_eq.trans (by host_kernel_rfl)) r447
  apply runC_cons P.F 35 s448 s449 result C C C (h448.control.isHalt_eq.trans (by host_kernel_rfl)) r448
  apply runC_cons P.F 34 s449 s450 result C C C (h449.control.isHalt_eq.trans (by host_kernel_rfl)) r449
  apply runC_cons P.F 33 s450 s451 result C C C (h450.control.isHalt_eq.trans (by host_kernel_rfl)) r450
  apply runC_cons P.F 32 s451 s452 result C C C (h451.control.isHalt_eq.trans (by host_kernel_rfl)) r451
  apply runC_cons P.F 31 s452 s453 result C C C (h452.control.isHalt_eq.trans (by host_kernel_rfl)) r452
  apply runC_cons P.F 30 s453 s454 result C C C (h453.control.isHalt_eq.trans (by host_kernel_rfl)) r453
  apply runC_cons P.F 29 s454 s455 result C C C (h454.control.isHalt_eq.trans (by host_kernel_rfl)) r454
  apply runC_cons P.F 28 s455 s456 result C C C (h455.control.isHalt_eq.trans (by host_kernel_rfl)) r455
  apply runC_cons P.F 27 s456 s457 result C C C (h456.control.isHalt_eq.trans (by host_kernel_rfl)) r456
  apply runC_cons P.F 26 s457 s458 result C C C (h457.control.isHalt_eq.trans (by host_kernel_rfl)) r457
  apply runC_cons P.F 25 s458 s459 result C C C (h458.control.isHalt_eq.trans (by host_kernel_rfl)) r458
  apply runC_cons P.F 24 s459 s460 result C C C (h459.control.isHalt_eq.trans (by host_kernel_rfl)) r459
  apply runC_cons P.F 23 s460 s461 result C C C (h460.control.isHalt_eq.trans (by host_kernel_rfl)) r460
  apply runC_cons P.F 22 s461 s462 result C C C (h461.control.isHalt_eq.trans (by host_kernel_rfl)) r461
  apply runC_cons P.F 21 s462 s463 result C C C (h462.control.isHalt_eq.trans (by host_kernel_rfl)) r462
  apply runC_cons P.F 20 s463 s464 result C C C (h463.control.isHalt_eq.trans (by host_kernel_rfl)) r463
  apply runC_cons P.F 19 s464 s465 result C C C (h464.control.isHalt_eq.trans (by host_kernel_rfl)) r464
  apply runC_cons P.F 18 s465 s466 result C C C (h465.control.isHalt_eq.trans (by host_kernel_rfl)) r465
  apply runC_cons P.F 17 s466 s467 result C C C (h466.control.isHalt_eq.trans (by host_kernel_rfl)) r466
  apply runC_cons P.F 16 s467 s468 result C C C (h467.control.isHalt_eq.trans (by host_kernel_rfl)) r467
  apply runC_cons P.F 15 s468 s469 result C C C (h468.control.isHalt_eq.trans (by host_kernel_rfl)) r468
  apply runC_cons P.F 14 s469 s470 result C C C (h469.control.isHalt_eq.trans (by host_kernel_rfl)) r469
  apply runC_cons P.F 13 s470 s471 result C C C (h470.control.isHalt_eq.trans (by host_kernel_rfl)) r470
  apply runC_cons P.F 12 s471 s472 result C C C (h471.control.isHalt_eq.trans (by host_kernel_rfl)) r471
  apply runC_cons P.F 11 s472 s473 result C C C (h472.control.isHalt_eq.trans (by host_kernel_rfl)) r472
  apply runC_cons P.F 10 s473 s474 result C C C (h473.control.isHalt_eq.trans (by host_kernel_rfl)) r473
  apply runC_cons P.F 9 s474 s475 result C C C (h474.control.isHalt_eq.trans (by host_kernel_rfl)) r474
  apply runC_cons P.F 8 s475 s476 result C C C (h475.control.isHalt_eq.trans (by host_kernel_rfl)) r475
  apply runC_cons P.F 7 s476 s477 result C C C (h476.control.isHalt_eq.trans (by host_kernel_rfl)) r476
  apply runC_cons P.F 6 s477 s478 result C C C (h477.control.isHalt_eq.trans (by host_kernel_rfl)) r477
  apply runC_cons P.F 5 s478 s479 result C C C (h478.control.isHalt_eq.trans (by host_kernel_rfl)) r478
  apply runC_cons P.F 4 s479 s480 result C C C (h479.control.isHalt_eq.trans (by host_kernel_rfl)) r479
  apply runC_cons P.F 3 s480 s481 result C C C (h480.control.isHalt_eq.trans (by host_kernel_rfl)) r480
  apply runC_cons P.F 2 s481 s482 result C C C (h481.control.isHalt_eq.trans (by host_kernel_rfl)) r481
  apply runC_cons P.F 1 s482 s483 result C C C (h482.control.isHalt_eq.trans (by host_kernel_rfl)) r482
  apply runC_cons P.F 0 s483 result result C C C (h483.control.isHalt_eq.trans (by host_kernel_rfl)) r483
  rfl

end Host.Load.Run.Full.Ordinary.VectorToConcat
