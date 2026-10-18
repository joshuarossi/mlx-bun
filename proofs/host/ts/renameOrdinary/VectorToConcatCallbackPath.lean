import host.ts.renameOrdinary.VectorToConcatCallbackPrefix
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteHeapFields
import host.ts.RenameRouteFields
import host.ts.RenameClosureEffects
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def callbackLive (live : Nat → Prop) : Nat → Prop := ClosureLive live CallbackEnter320.input.next
  CallbackEnter320.sourceArrow CallbackEnter320.sourceHome CallbackEnter320.sourceFunction

theorem callback_live_eq (live : Nat → Prop) : callbackLive live = LiveAfter live CallbackEnter320.input.next := by host_kernel_rfl
theorem callback_parameter_fresh : CallbackBinding322.sourceAddress = PointerReturn310.input.next := by host_kernel_rfl

/-- The actual callback-entry path reaches the real concat call. The only
old heap cell changed is slotPtr; all other live occurrence annotations,
including the output buffer, vector, axis and stream, remain available. -/
theorem concat_callback_arguments_cuts (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' PointerReturn310.input s)
    (bound : s.next+3 ≤ 2^64) :
    ∃ entry result, runC P.F 18 s C = some (entry,C) ∧
      StateR NR FR R (callbackLive live) framed before after old old' OutputVariable328.input entry ∧
      (∀ a, live a → a ≠ PointerBinding311.sourceAddress → entry.heap.get (R.a a) = s.heap.get (R.a a)) ∧
      runC P.F 8 entry C = some (result,C) ∧
      StateR NR FR R (callbackLive live) framed before after old old' StreamArgument335.output result ∧
      (∀ a, live a → a ≠ PointerBinding311.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  let s310 := s
  have h310 := h
  obtain ⟨s311,hr310,h311⟩ := PointerReturn310.transport NR FR R C₀ C live framed before after old old' s310 h310
  have bound311 : s311.next ≤ 2^64 := by
    have hn := h.target_next_add h311 0 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s312,hr311,h312⟩ := PointerBinding311.transport NR FR R C₀ C live framed before after old old' s311 h311 bound311
  obtain ⟨s313,hr312,h313⟩ := PointerDone312.transport NR FR R C₀ C live framed before after old old' s312 h312
  obtain ⟨s314,hr313,h314⟩ := CallbackBlock313.transport NR FR R C₀ C live framed before after old old' s313 h313
  obtain ⟨s315,hr314,h315⟩ := CallbackDeclaration314.transport NR FR R C₀ C live framed before after old old' s314 h314
  obtain ⟨s316,hr315,h316⟩ := CallbackCall315.transport NR FR R C₀ C live framed before after old old' s315 h315
  obtain ⟨v316,hr316,h317,_⟩ := CallbackVariable316.transport NR FR R C₀ C live framed before after old old' s316 h316
  let s317 := s316.ret v316
  obtain ⟨s318,hr317,h318⟩ := CallbackCallee317.transport NR FR R C₀ C live framed before after old old' s317 h317
  obtain ⟨v318,hr318,h319,_⟩ := PointerVariable318.transport NR FR R C₀ C live framed before after old old' s318 h318
  let s319 := s318.ret v318
  obtain ⟨s320,hr319,h320⟩ := PointerArgument319.transport NR FR R C₀ C live framed before after old old' s319 h319
  have bound320 : s320.next+2+(paramNames CallbackEnter320.sourceFunction).length ≤ 2^64 := by
    have hn := h.target_next_eq h320 (by host_kernel_rfl)
    have hp : (paramNames CallbackEnter320.sourceFunction).length = 1 := by host_kernel_rfl
    rw [hn,hp]; exact bound
  obtain ⟨s321,hr320,h321⟩ := CallbackEnter320.transport NR FR R C₀ C live framed before after old old' s320 h320 bound320
  obtain ⟨s322,hr321,h322⟩ := CallbackParameter321.transport NR FR R C₀ C (callbackLive live) framed before after old old' s321 h321
  have bound322 : s322.next ≤ 2^64 := by
    have hn := h.target_next_add h322 1 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s323,hr322,h323⟩ := CallbackBinding322.transport NR FR R C₀ C (callbackLive live) framed before after old old' s322 h322 bound322
  obtain ⟨s324,hr323,h324,hh324⟩ := CallbackBody323.transport NR FR R C₀ C (callbackLive live) framed before after old old' s323 h323
  obtain ⟨s325,hr324,h325⟩ := ConcatMethod324.transport NR FR R C₀ C (callbackLive live) framed before after old old' s324 h324
  obtain ⟨v325,hr325,h326,_⟩ := ConcatNamespace325.transport NR FR R C₀ C (callbackLive live) framed before after old old' s325 h325
  let s326 := s325.ret v325
  obtain ⟨s327,hr326,h327⟩ := ConcatLookup326.transport NR FR R C₀ C (callbackLive live) framed before after old old' s326 h326
  obtain ⟨s328,hr327,h328⟩ := ConcatCallee327.transport NR FR R C₀ C (callbackLive live) framed before after old old' s327 h327
  obtain ⟨v328,hr328,h329,_⟩ := OutputVariable328.transport NR FR R C₀ C (callbackLive live) framed before after old old' s328 h328
  let s329 := s328.ret v328
  obtain ⟨s330,hr329,h330⟩ := OutputArgument329.transport NR FR R C₀ C (callbackLive live) framed before after old old' s329 h329
  obtain ⟨v330,hr330,h331,_⟩ := VectorVariable330.transport NR FR R C₀ C (callbackLive live) framed before after old old' s330 h330
  let s331 := s330.ret v330
  obtain ⟨s332,hr331,h332⟩ := VectorArgument331.transport NR FR R C₀ C (callbackLive live) framed before after old old' s331 h331
  obtain ⟨v332,hr332,h333,_⟩ := AxisVariable332.transport NR FR R C₀ C (callbackLive live) framed before after old old' s332 h332
  let s333 := s332.ret v332
  obtain ⟨s334,hr333,h334⟩ := AxisArgument333.transport NR FR R C₀ C (callbackLive live) framed before after old old' s333 h333
  obtain ⟨v334,hr334,h335,_⟩ := StreamVariable334.transport NR FR R C₀ C (callbackLive live) framed before after old old' s334 h334
  let s335 := s334.ret v334
  obtain ⟨s336,hr335,h336⟩ := StreamArgument335.transport NR FR R C₀ C (callbackLive live) framed before after old old' s335 h335
  have frames : ∀ a, live a → a ≠ PointerBinding311.sourceAddress →
      s328.heap.get (R.a a) = s.heap.get (R.a a) ∧ s336.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a ha hptr
    have hh311 := step_declaration_value_heap P.F NR FR R live framed before after old old' PointerReturn310.input s310 s311 C C h310
      PointerReturn310.sourceValue PointerReturn310.sourceKind PointerReturn310.sourcePattern PointerReturn310.sourceRest PointerReturn310.sourceEnv PointerReturn310.sourceTail PointerReturn310.source_control PointerReturn310.source_frame PointerReturn310.source_kind hr310
    have cellLive311 : live PointerBinding311.sourceAddress := by
      have hl := h311.controlLive
      change treeSupport live (Encode.ctl PointerBinding311.input.ctl) at hl
      rw [PointerBinding311.source_control] at hl
      exact env_lookup_live PointerBinding311.sourceName PointerBinding311.sourceEnv PointerBinding311.sourceAddress hl.2.2.1 PointerBinding311.source_lookup
    have oldLive311 : live a := by exact ha
    have other311 : a ≠ PointerBinding311.sourceAddress := by
      exact hptr
    have mappedOther311 : R.a a ≠ R.a PointerBinding311.sourceAddress := by
      intro he
      exact other311 (h311.heap.inj a PointerBinding311.sourceAddress oldLive311 cellLive311 he)
    have hh312a := step_bind_init_heap_other P.F NR FR R live framed before after old old' PointerBinding311.input s311 s312 C C h311
      PointerBinding311.sourceName PointerBinding311.sourceValue PointerBinding311.sourceEnv PointerBinding311.sourceKind PointerBinding311.sourceAddress PointerBinding311.source_control PointerBinding311.source_lookup
      bound311 hr311 (R.a a) mappedOther311
    have hh313 := step_declaration_next_heap P.F NR FR R live framed before after old old' PointerDone312.input s312 s313 C C h312
      PointerDone312.sourceValue PointerDone312.sourceKind PointerDone312.sourceRest PointerDone312.sourceEnv PointerDone312.sourceTail PointerDone312.source_control PointerDone312.source_frame hr312
    have hh314 := step_block_next_heap P.F NR FR R live framed before after old old' CallbackBlock313.input s313 s314 C C h313
      CallbackBlock313.sourceValue CallbackBlock313.sourceStatement CallbackBlock313.sourceRest CallbackBlock313.sourceEnv CallbackBlock313.sourceTail CallbackBlock313.source_control CallbackBlock313.source_frame hr313
    have hh315 := step_statement_heap P.F NR FR R live framed before after old old' CallbackDeclaration314.input s314 s315 C C h314
      CallbackDeclaration314.sourceAction CallbackDeclaration314.sourceEnv CallbackDeclaration314.source_control hr314
    have hh316 := step_identifier_call_heap P.F NR FR R live framed before after old old' CallbackCall315.input s315 s316 C₀ C C h315
      CallbackCall315.sourceName CallbackCall315.sourceArgs CallbackCall315.sourceOptional CallbackCall315.sourceEnv CallbackCall315.source_control hr315
    have hh317 : s317.heap = s316.heap := rfl
    have hh318 := step_callStart_heap P.F NR FR R live framed before after old old' CallbackCallee317.input s317 s318 C C h317
      (.callee CallbackCallee317.sourceOptional) CallbackCallee317.sourceAddress .undef CallbackCallee317.sourceArgs CallbackCallee317.sourceEnv CallbackCallee317.sourceTail CallbackCallee317.source_control CallbackCallee317.source_frame hr317
    have hh319 : s319.heap = s318.heap := rfl
    have hh320 := step_argument_heap_from_source P.F NR FR R live framed before after old old' PointerArgument319.input s319 s320 C C h319
      PointerArgument319.sourceValue PointerArgument319.sourceKind PointerArgument319.sourceFunction PointerArgument319.sourceThis PointerArgument319.sourceAcc PointerArgument319.sourceRest PointerArgument319.sourceEnv PointerArgument319.sourceTail PointerArgument319.source_control PointerArgument319.source_frame (by decide) hr319
    have hh321 := step_closure_heap_below P.F NR FR R live framed before after old old' CallbackEnter320.input s320 s321 C C h320
      CallbackEnter320.address CallbackEnter320.object CallbackEnter320.sourceFunction CallbackEnter320.sourceEnv CallbackEnter320.sourceArrow CallbackEnter320.sourceHome CallbackEnter320.sourceThis CallbackEnter320.sourceArgs CallbackEnter320.source_control CallbackEnter320.source_heap CallbackEnter320.source_kind bound320 hr320
    have hh321a := hh321 (R.a a) (h320.heap.targetBound a ha)
    have hh322 : s322.heap = s321.heap := by
      obtain ⟨v,hc,_⟩ := (h321.control_view CallbackParameter321.source_control).ret_view
      obtain ⟨f,fs,hf,hfr,_⟩ := h321.stack_view CallbackParameter321.source_frame
      obtain ⟨args,hft,_⟩ := hfr.params_view
      rw [hft] at hf
      have hr := hr321
      change interpC (step P.F s321).run C = some (s322,C) at hr
      rw [step_parameter_id_eq P.F s321 v CallbackParameter321.sourceFunction CallbackParameter321.sourceName CallbackParameter321.sourceParams args (R.env CallbackParameter321.sourceEnv) fs hc hf] at hr
      exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj hr))).symm
    have cellLive322 : (callbackLive live) CallbackBinding322.sourceAddress := by
      have hl := h322.controlLive
      change treeSupport (callbackLive live) (Encode.ctl CallbackBinding322.input.ctl) at hl
      rw [CallbackBinding322.source_control] at hl
      exact env_lookup_live CallbackBinding322.sourceName CallbackBinding322.sourceEnv CallbackBinding322.sourceAddress hl.2.2.1 CallbackBinding322.source_lookup
    have oldLive322 : (callbackLive live) a := by rw [callback_live_eq]; exact Or.inl ha
    have other322 : a ≠ CallbackBinding322.sourceAddress := by
      intro he
      have hb := h.heap.sourceBound a ha
      rw [he,callback_parameter_fresh] at hb
      exact Nat.lt_irrefl _ hb
    have mappedOther322 : R.a a ≠ R.a CallbackBinding322.sourceAddress := by
      intro he
      exact other322 (h322.heap.inj a CallbackBinding322.sourceAddress oldLive322 cellLive322 he)
    have hh323a := step_bind_init_heap_other P.F NR FR R (callbackLive live) framed before after old old' CallbackBinding322.input s322 s323 C C h322
      CallbackBinding322.sourceName CallbackBinding322.sourceValue CallbackBinding322.sourceEnv CallbackBinding322.sourceKind CallbackBinding322.sourceAddress CallbackBinding322.source_control CallbackBinding322.source_lookup
      bound322 hr322 (R.a a) mappedOther322
    have hh325 := step_method_descent_heap P.F NR FR R (callbackLive live) framed before after old old' ConcatMethod324.input s324 s325 C₀ C C h324
      ConcatMethod324.sourceExpression ConcatMethod324.sourceName ConcatMethod324.sourceArgs ConcatMethod324.sourceEnv ConcatMethod324.sourceOptObject ConcatMethod324.sourceOptCall ConcatMethod324.source_control hr324
    have hh326 : s326.heap = s325.heap := rfl
    have hh327 := step_method_data_heap P.F NR FR R (callbackLive live) framed before after old old' ConcatLookup326.input s326 s327 C C h326
      ConcatLookup326.sourceAddress ConcatLookup326.sourceObject ConcatLookup326.sourceName ConcatLookup326.sourceArgs ConcatLookup326.sourceEnv ConcatLookup326.sourceOptObject ConcatLookup326.sourceOptCall ConcatLookup326.sourceMethod ConcatLookup326.sourceWritable ConcatLookup326.sourceEnumerable ConcatLookup326.sourceTail ConcatLookup326.source_control ConcatLookup326.source_frame ConcatLookup326.source_heap ConcatLookup326.source_kind ConcatLookup326.source_property hr326
    have hh328 := step_callStart_heap P.F NR FR R (callbackLive live) framed before after old old' ConcatCallee327.input s327 s328 C C h327
      ConcatCallee327.sourceMode ConcatCallee327.sourceAddress ConcatCallee327.sourceThis ConcatCallee327.sourceArgs ConcatCallee327.sourceEnv ConcatCallee327.sourceTail ConcatCallee327.source_control ConcatCallee327.source_frame hr327
    have hh329 : s329.heap = s328.heap := rfl
    have hh330 := step_argument_heap_from_source P.F NR FR R (callbackLive live) framed before after old old' OutputArgument329.input s329 s330 C C h329
      OutputArgument329.sourceValue OutputArgument329.sourceKind OutputArgument329.sourceFunction OutputArgument329.sourceThis OutputArgument329.sourceAcc OutputArgument329.sourceRest OutputArgument329.sourceEnv OutputArgument329.sourceTail OutputArgument329.source_control OutputArgument329.source_frame (by decide) hr329
    have hh331 : s331.heap = s330.heap := rfl
    have hh332 := step_argument_heap_from_source P.F NR FR R (callbackLive live) framed before after old old' VectorArgument331.input s331 s332 C C h331
      VectorArgument331.sourceValue VectorArgument331.sourceKind VectorArgument331.sourceFunction VectorArgument331.sourceThis VectorArgument331.sourceAcc VectorArgument331.sourceRest VectorArgument331.sourceEnv VectorArgument331.sourceTail VectorArgument331.source_control VectorArgument331.source_frame (by decide) hr331
    have hh333 : s333.heap = s332.heap := rfl
    have hh334 := step_argument_heap_from_source P.F NR FR R (callbackLive live) framed before after old old' AxisArgument333.input s333 s334 C C h333
      AxisArgument333.sourceValue AxisArgument333.sourceKind AxisArgument333.sourceFunction AxisArgument333.sourceThis AxisArgument333.sourceAcc AxisArgument333.sourceRest AxisArgument333.sourceEnv AxisArgument333.sourceTail AxisArgument333.source_control AxisArgument333.source_frame (by decide) hr333
    have hh335 : s335.heap = s334.heap := rfl
    have hh336 := step_argument_heap_from_source P.F NR FR R (callbackLive live) framed before after old old' StreamArgument335.input s335 s336 C C h335
      StreamArgument335.sourceValue StreamArgument335.sourceKind StreamArgument335.sourceFunction StreamArgument335.sourceThis StreamArgument335.sourceAcc StreamArgument335.sourceRest StreamArgument335.sourceEnv StreamArgument335.sourceTail StreamArgument335.source_control StreamArgument335.source_frame (by decide) hr335
    have firstPart : s328.heap.get (R.a a) = s.heap.get (R.a a) := by
      calc
        s328.heap.get (R.a a) = s327.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh328
        _ = s326.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh327
        _ = s325.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh326
        _ = s324.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh325
        _ = s323.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh324
        _ = s322.heap.get (R.a a) := hh323a
        _ = s321.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh322
        _ = s320.heap.get (R.a a) := hh321a
        _ = s319.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh320
        _ = s318.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh319
        _ = s317.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh318
        _ = s316.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh317
        _ = s315.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh316
        _ = s314.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh315
        _ = s313.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh314
        _ = s312.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh313
        _ = s311.heap.get (R.a a) := hh312a
        _ = s310.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh311
    have lastPart : s336.heap.get (R.a a) = s328.heap.get (R.a a) := by
      calc
        s336.heap.get (R.a a) = s335.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh336
        _ = s334.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh335
        _ = s333.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh334
        _ = s332.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh333
        _ = s331.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh332
        _ = s330.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh331
        _ = s329.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh330
        _ = s328.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh329
    exact ⟨firstPart,lastPart.trans firstPart⟩
  refine ⟨s328,s336,?_,h328,(fun a ha hn => (frames a ha hn).1),?_,h336,(fun a ha hn => (frames a ha hn).2)⟩
  · apply runC_cons P.F 17 s310 s311 s328 C C C (h310.control.isHalt_eq.trans (by host_kernel_rfl)) hr310
    apply runC_cons P.F 16 s311 s312 s328 C C C (h311.control.isHalt_eq.trans (by host_kernel_rfl)) hr311
    apply runC_cons P.F 15 s312 s313 s328 C C C (h312.control.isHalt_eq.trans (by host_kernel_rfl)) hr312
    apply runC_cons P.F 14 s313 s314 s328 C C C (h313.control.isHalt_eq.trans (by host_kernel_rfl)) hr313
    apply runC_cons P.F 13 s314 s315 s328 C C C (h314.control.isHalt_eq.trans (by host_kernel_rfl)) hr314
    apply runC_cons P.F 12 s315 s316 s328 C C C (h315.control.isHalt_eq.trans (by host_kernel_rfl)) hr315
    apply runC_cons P.F 11 s316 s317 s328 C C C (h316.control.isHalt_eq.trans (by host_kernel_rfl)) hr316
    apply runC_cons P.F 10 s317 s318 s328 C C C (h317.control.isHalt_eq.trans (by host_kernel_rfl)) hr317
    apply runC_cons P.F 9 s318 s319 s328 C C C (h318.control.isHalt_eq.trans (by host_kernel_rfl)) hr318
    apply runC_cons P.F 8 s319 s320 s328 C C C (h319.control.isHalt_eq.trans (by host_kernel_rfl)) hr319
    apply runC_cons P.F 7 s320 s321 s328 C C C (h320.control.isHalt_eq.trans (by host_kernel_rfl)) hr320
    apply runC_cons P.F 6 s321 s322 s328 C C C (h321.control.isHalt_eq.trans (by host_kernel_rfl)) hr321
    apply runC_cons P.F 5 s322 s323 s328 C C C (h322.control.isHalt_eq.trans (by host_kernel_rfl)) hr322
    apply runC_cons P.F 4 s323 s324 s328 C C C (h323.control.isHalt_eq.trans (by host_kernel_rfl)) hr323
    apply runC_cons P.F 3 s324 s325 s328 C C C (h324.control.isHalt_eq.trans (by host_kernel_rfl)) hr324
    apply runC_cons P.F 2 s325 s326 s328 C C C (h325.control.isHalt_eq.trans (by host_kernel_rfl)) hr325
    apply runC_cons P.F 1 s326 s327 s328 C C C (h326.control.isHalt_eq.trans (by host_kernel_rfl)) hr326
    apply runC_cons P.F 0 s327 s328 s328 C C C (h327.control.isHalt_eq.trans (by host_kernel_rfl)) hr327
    rfl
  · apply runC_cons P.F 7 s328 s329 s336 C C C (h328.control.isHalt_eq.trans (by host_kernel_rfl)) hr328
    apply runC_cons P.F 6 s329 s330 s336 C C C (h329.control.isHalt_eq.trans (by host_kernel_rfl)) hr329
    apply runC_cons P.F 5 s330 s331 s336 C C C (h330.control.isHalt_eq.trans (by host_kernel_rfl)) hr330
    apply runC_cons P.F 4 s331 s332 s336 C C C (h331.control.isHalt_eq.trans (by host_kernel_rfl)) hr331
    apply runC_cons P.F 3 s332 s333 s336 C C C (h332.control.isHalt_eq.trans (by host_kernel_rfl)) hr332
    apply runC_cons P.F 2 s333 s334 s336 C C C (h333.control.isHalt_eq.trans (by host_kernel_rfl)) hr333
    apply runC_cons P.F 1 s334 s335 s336 C C C (h334.control.isHalt_eq.trans (by host_kernel_rfl)) hr334
    apply runC_cons P.F 0 s335 s336 s336 C C C (h335.control.isHalt_eq.trans (by host_kernel_rfl)) hr335
    rfl

theorem concat_callback_arguments_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' PointerReturn310.input s)
    (bound : s.next+3 ≤ 2^64) :
    ∃ result, runC P.F 26 s C = some (result,C) ∧
      StateR NR FR R (callbackLive live) framed before after old old' StreamArgument335.output result ∧
      ∀ a, live a → a ≠ PointerBinding311.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a) := by
  obtain ⟨entry,result,firstPart,_,_,lastPart,hs,frame⟩ := concat_callback_arguments_cuts NR FR R C₀ C live framed before after old old' s h bound
  exact ⟨result,runC_join P.F (m := 18) (n := 8) firstPart lastPart,hs,frame⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
