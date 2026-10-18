import host.ts.renameOrdinary.VectorToConcatVectorPrefix
import host.mlx.OrdinaryArrayCut
import host.ts.RenameRouteComposition
import host.ts.RenameParametricMapControl
import host.ts.RenameRouteCellFields
import host.ts.RenameClosureEffects
import host.ts.RenameRouteFields
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def vectorCallbackLive (live : Nat → Prop) := LiveAfter live ConcatenateCallback265.input.next

def outParameterLive (live : Nat → Prop) := ClosureLive (vectorCallbackLive live) OutEnter267.input.next
  OutEnter267.sourceArrow OutEnter267.sourceHome OutEnter267.sourceFunction

def outBodyLive (live : Nat → Prop) := CellsLive (outParameterLive live) OutBody272.input.next (blockNames OutBody272.sourceBody)

theorem vector_callback_grow (live : Nat → Prop) : ∀ a, live a → vectorCallbackLive live a := fun _ ha => Or.inl ha
theorem out_parameter_grow (live : Nat → Prop) : ∀ a, live a → outParameterLive live a :=
  fun a ha => ClosureLive.grow _ _ _ _ _ a (Or.inl ha)
theorem out_body_grow (live : Nat → Prop) : ∀ a, live a → outBodyLive live a :=
  fun a ha => CellsLive.grow _ _ _ a (out_parameter_grow live a ha)
theorem try_body_no_cells : blockNames Try254.sourceBody = [] := by host_kernel_rfl

/-- The original 45-step source path binds the returned vector, creates its
callback, enters outArray and reaches its native null-slot initializer. -/
theorem vector_to_null_initializer_fields (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' VectorDeclaration250.input s)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+32 ≤ 2^64) :
    ∃ result, runC P.F 45 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (outBodyLive live) framed before after old old' ArrayCall.input result ∧
      (∀ v, s.ctl = .ret v → result.heap.get (R.a VectorBinding251.sourceAddress) = some (.cell (some v))) ∧
      (∀ a, live a → a ≠ VectorBinding251.sourceAddress → result.heap.get (R.a a) = s.heap.get (R.a a)) := by
  let NR := NumberRoles ν₀ ν C₀ C
  let s250 := s
  have h250 := h
  obtain ⟨s251,hr250,h251⟩ := VectorDeclaration250.transport NR FR R C₀ C live framed before after old old' s250 h250
  have bound251 : s251.next ≤ 2^64 := by
    have hn := h.target_next_add h251 0 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s252,hr251,h252⟩ := VectorBinding251.transport NR FR R C₀ C live framed before after old old' s251 h251 bound251
  obtain ⟨s253,hr252,h253⟩ := VectorDone252.transport NR FR R C₀ C live framed before after old old' s252 h252
  obtain ⟨s254,hr253,h254⟩ := VectorBlock253.transport NR FR R C₀ C live framed before after old old' s253 h253
  have bound254 : s254.next+(blockNames Try254.sourceBody).length ≤ 2^64 := by
    have hn := h.target_next_add h254 0 (by host_kernel_rfl)
    have hp : (blockNames Try254.sourceBody).length ≤ 10 := by decide +kernel
    rw [hn]; omega
  obtain ⟨s255,hr254,h255⟩ := Try254.transport NR FR R C₀ C live framed before after old old' s254 h254 bound254
  have h255' : StateR NR FR R live framed before after old old' Try254.output s255 := by
    simp only [try_body_no_cells,CellsLive] at h255
    exact h255
  clear h255
  have h255 := h255'
  obtain ⟨s256,hr255,h256⟩ := VectorBlock255.transport NR FR R C₀ C live framed before after old old' s255 h255
  obtain ⟨s257,hr256,h257⟩ := ArrayReturn256.transport NR FR R C₀ C live framed before after old old' s256 h256
  obtain ⟨s258,hr257,h258⟩ := MlxConstruct257.transport NR FR R C₀ C live framed before after old old' s257 h257
  obtain ⟨v258,hr258,h259,_⟩ := MlxVariable258.transport NR FR R C₀ C live framed before after old old' s258 h258
  let s259 := s258.ret v258
  obtain ⟨s260,hr259,h260⟩ := MlxCallee259.transport NR FR R C₀ C live framed before after old old' s259 h259
  obtain ⟨s261,hr260,h261⟩ := OutCall260.transport NR FR R C₀ C live framed before after old old' s260 h260
  obtain ⟨v261,hr261,h262,_⟩ := OutVariable261.transport NR FR R C₀ C live framed before after old old' s261 h261
  let s262 := s261.ret v261
  obtain ⟨s263,hr262,h263⟩ := OutCallee262.transport NR FR R C₀ C live framed before after old old' s262 h262
  obtain ⟨hr263,h264,_,_⟩ := Operation263.transport FR R ν₀ ν C₀ C live framed before after old old' s263 h263
  let s264 := s263.ret Operation263.sourceValue
  obtain ⟨s265,hr264,h265⟩ := OperationArgument264.transport NR FR R C₀ C live framed before after old old' s264 h264
  have bound265 : s265.next < 2^64 := by
    have hn := h.target_next_add h265 0 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s266,hr265,h266⟩ := ConcatenateCallback265.transport NR FR R C₀ C live framed before after old old' s265 h265 functionProtoLive functionProtoFixed bound265
  obtain ⟨s267,hr266,h267⟩ := CallbackArgument266.transport NR FR R C₀ C (vectorCallbackLive live) framed before after old old' s266 h266
  have bound267 : s267.next+2+(paramNames OutEnter267.sourceFunction).length ≤ 2^64 := by
    have hn := h.target_next_add h267 1 (by host_kernel_rfl)
    have hp : (paramNames OutEnter267.sourceFunction).length ≤ 10 := by decide +kernel
    rw [hn]; omega
  obtain ⟨s268,hr267,h268⟩ := OutEnter267.transport NR FR R C₀ C (vectorCallbackLive live) framed before after old old' s267 h267 bound267
  obtain ⟨s269,hr268,h269⟩ := OutParameter268.transport NR FR R C₀ C (outParameterLive live) framed before after old old' s268 h268
  have bound269 : s269.next ≤ 2^64 := by
    have hn := h.target_next_add h269 4 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s270,hr269,h270⟩ := OutBinding269.transport NR FR R C₀ C (outParameterLive live) framed before after old old' s269 h269 bound269
  obtain ⟨s271,hr270,h271⟩ := OutParameter270.transport NR FR R C₀ C (outParameterLive live) framed before after old old' s270 h270
  have bound271 : s271.next ≤ 2^64 := by
    have hn := h.target_next_add h271 4 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s272,hr271,h272⟩ := OutBinding271.transport NR FR R C₀ C (outParameterLive live) framed before after old old' s271 h271 bound271
  have bound272 : s272.next+(blockNames OutBody272.sourceBody).length ≤ 2^64 := by
    have hn := h.target_next_add h272 4 (by host_kernel_rfl)
    have hp : (blockNames OutBody272.sourceBody).length ≤ 10 := by decide +kernel
    rw [hn]; omega
  obtain ⟨s273,hr272,h273⟩ := OutBody272.transport NR FR R C₀ C (outParameterLive live) framed before after old old' s272 h272 bound272
  obtain ⟨s274,hr273,h274⟩ := OutBlock273.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s273 h273
  obtain ⟨s275,hr274,h275⟩ := InventoryDeclaration274.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s274 h274
  obtain ⟨s276,hr275,h276⟩ := InventoryMember275.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s275 h275
  obtain ⟨v276,hr276,h277,_⟩ := GlobalThis276.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s276 h276 (out_body_grow live aGlobal globalLive) globalFixed
  let s277 := s276.ret v276
  obtain ⟨s278,hr277,h278⟩ := MissingInventory277.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s277 h277
  obtain ⟨s279,hr278,h279⟩ := InventoryReturn278.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s278 h278
  have bound279 : s279.next ≤ 2^64 := by
    have hn := h.target_next_add h279 9 (by host_kernel_rfl)
    rw [hn]; omega
  obtain ⟨s280,hr279,h280⟩ := InventoryBinding279.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s279 h279 bound279
  obtain ⟨s281,hr280,h281⟩ := InventoryDone280.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s280 h280
  obtain ⟨s282,hr281,h282⟩ := InventoryBlock281.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s281 h281
  obtain ⟨s283,hr282,h283⟩ := InventoryIf282.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s282 h282
  obtain ⟨v283,hr283,h284,_⟩ := InventoryVariable283.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s283 h283
  let s284 := s283.ret v283
  obtain ⟨s285,hr284,h285,heap285⟩ := InventoryBranch284.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s284 h284
  obtain ⟨s286,hr285,h286⟩ := SlotBlock285.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s285 h285
  obtain ⟨s287,hr286,h287⟩ := SlotDeclaration286.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s286 h286
  obtain ⟨s288,hr287,h288⟩ := SlotConstructor287.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s287 h287
  obtain ⟨v288,hr288,h289,_⟩ := SlotGlobal288.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s288 h288 (out_body_grow live aGlobal globalLive) globalFixed
  let s289 := s288.ret v288
  obtain ⟨s290,hr289,h290⟩ := SlotCallee289.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s289 h289
  obtain ⟨s291,hr290,h291⟩ := SlotArray290.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s290 h290
  obtain ⟨s292,hr291,h292⟩ := SlotMethod291.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s291 h291
  obtain ⟨v292,hr292,h293,_⟩ := SlotNamespace292.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s292 h292
  let s293 := s292.ret v292
  obtain ⟨s294,hr293,h294⟩ := SlotLookup293.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s293 h293
  obtain ⟨s295,hr294,h295⟩ := SlotNativeCallee294.transport NR FR R C₀ C (outBodyLive live) framed before after old old' s294 h294
  have vecLive : live VectorBinding251.sourceAddress := by
    have hl := h251.controlLive
    change treeSupport live (Encode.ctl VectorBinding251.input.ctl) at hl
    rw [VectorBinding251.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.2.1 VectorBinding251.source_lookup
  have afterFrame : ∀ a, live a → s295.heap.get (R.a a) = s252.heap.get (R.a a) := by
    intro a ha
    have hh253 := step_declaration_next_heap P.F NR FR R live framed before after old old' VectorDone252.input s252 s253 C C h252
      VectorDone252.sourceValue VectorDone252.sourceKind VectorDone252.sourceRest VectorDone252.sourceEnv VectorDone252.sourceTail VectorDone252.source_control VectorDone252.source_frame hr252
    have hh254 := step_block_next_heap P.F NR FR R live framed before after old old' VectorBlock253.input s253 s254 C C h253
      VectorBlock253.sourceValue VectorBlock253.sourceStatement VectorBlock253.sourceRest VectorBlock253.sourceEnv VectorBlock253.sourceTail VectorBlock253.source_control VectorBlock253.source_frame hr253
    have hh255a : s255.heap.get (R.a a) = s254.heap.get (R.a a) := by
      have hc := (h254.control_view Try254.source_control).ex_view
      have hr := hr254
      change interpC (step P.F s254).run C = some (s255,C) at hr
      rw [step_try_entry_eq P.F s254 Try254.sourceBody Try254.sourceHandler Try254.sourceFinalizer (R.env Try254.sourceEnv) hc] at hr
      have he := congrArg Prod.fst (Option.some.inj hr)
      dsimp only at he
      have hh := congrArg (fun t : St LSt => t.heap.get (R.a a)) he
      exact hh.symm.trans (enterBlock_heap_below (s254.push (.s (.try_ Try254.sourceHandler Try254.sourceFinalizer (R.env Try254.sourceEnv))))
        Try254.sourceBody (R.env Try254.sourceEnv) (R.a a) (h254.heap.targetBound a ha) bound254 Try254.source_hoist)
    have hh256 := step_block_next_heap P.F NR FR R live framed before after old old' VectorBlock255.input s255 s256 C C h255
      VectorBlock255.sourceValue VectorBlock255.sourceStatement VectorBlock255.sourceRest VectorBlock255.sourceEnv VectorBlock255.sourceTail VectorBlock255.source_control VectorBlock255.source_frame hr255
    have hh257 := step_statement_heap P.F NR FR R live framed before after old old' ArrayReturn256.input s256 s257 C C h256
      ArrayReturn256.sourceAction ArrayReturn256.sourceEnv ArrayReturn256.source_control hr256
    have hh258 := step_descent_heap_from_source P.F NR FR R live framed before after old old' MlxConstruct257.input s257 s258 C C h257
      MlxConstruct257.sourceDescent MlxConstruct257.sourceEnv MlxConstruct257.source_control hr257
    have hh259 : s259.heap = s258.heap := rfl
    have hh260 := step_callStart_heap P.F NR FR R live framed before after old old' MlxCallee259.input s259 s260 C C h259
      MlxCallee259.sourceMode MlxCallee259.sourceAddress MlxCallee259.sourceThis MlxCallee259.sourceArgs MlxCallee259.sourceEnv MlxCallee259.sourceTail MlxCallee259.source_control MlxCallee259.source_frame hr259
    have hh261 := step_identifier_call_heap P.F NR FR R live framed before after old old' OutCall260.input s260 s261 C₀ C C h260
      OutCall260.sourceName OutCall260.sourceArgs OutCall260.sourceOptional OutCall260.sourceEnv OutCall260.source_control hr260
    have hh262 : s262.heap = s261.heap := rfl
    have hh263 := step_callStart_heap P.F NR FR R live framed before after old old' OutCallee262.input s262 s263 C C h262
      (.callee OutCallee262.sourceOptional) OutCallee262.sourceAddress .undef OutCallee262.sourceArgs OutCallee262.sourceEnv OutCallee262.sourceTail OutCallee262.source_control OutCallee262.source_frame hr262
    have hh264 : s264.heap = s263.heap := rfl
    have hh265 := step_argument_heap_from_source P.F NR FR R live framed before after old old' OperationArgument264.input s264 s265 C C h264
      OperationArgument264.sourceValue OperationArgument264.sourceKind OperationArgument264.sourceFunction OperationArgument264.sourceThis OperationArgument264.sourceAcc OperationArgument264.sourceRest OperationArgument264.sourceEnv OperationArgument264.sourceTail OperationArgument264.source_control OperationArgument264.source_frame (by decide) hr264
    have hh266a : s266.heap.get (R.a a) = s265.heap.get (R.a a) := by
      have hc := (h265.control_view ConcatenateCallback265.source_control).ev_view
      have hr := hr265
      change interpC (step P.F s265).run C = some (s266,C) at hr
      rw [step_callback_eq P.F s265 ConcatenateCallback265.sourceFunction (R.env ConcatenateCallback265.sourceEnv) hc] at hr
      have he := congrArg Prod.fst (Option.some.inj hr)
      dsimp only at he
      have hh := congrArg (fun t : St LSt => t.heap.get (R.a a)) he
      exact hh.symm.trans (alloc_heap_below s265 _ (R.a a) (h265.heap.targetBound a ha) bound265)
    have hh267 := step_argument_heap_from_source P.F NR FR R (vectorCallbackLive live) framed before after old old' CallbackArgument266.input s266 s267 C C h266
      CallbackArgument266.sourceValue CallbackArgument266.sourceKind CallbackArgument266.sourceFunction CallbackArgument266.sourceThis CallbackArgument266.sourceAcc CallbackArgument266.sourceRest CallbackArgument266.sourceEnv CallbackArgument266.sourceTail CallbackArgument266.source_control CallbackArgument266.source_frame (by decide) hr266
    have hh268 := step_closure_heap_below P.F NR FR R (vectorCallbackLive live) framed before after old old' OutEnter267.input s267 s268 C C h267
      OutEnter267.address OutEnter267.object OutEnter267.sourceFunction OutEnter267.sourceEnv OutEnter267.sourceArrow OutEnter267.sourceHome OutEnter267.sourceThis OutEnter267.sourceArgs OutEnter267.source_control OutEnter267.source_heap OutEnter267.source_kind bound267 hr267
    have hh268a := hh268 (R.a a) (h267.heap.targetBound a (vector_callback_grow live a ha))
    have hh269 : s269.heap = s268.heap := by
      obtain ⟨v,hc,_⟩ := (h268.control_view OutParameter268.source_control).ret_view
      obtain ⟨f,fs,hf,hfr,_⟩ := h268.stack_view OutParameter268.source_frame
      obtain ⟨args,hft,_⟩ := hfr.params_view
      rw [hft] at hf
      have hr := hr268
      change interpC (step P.F s268).run C = some (s269,C) at hr
      rw [step_parameter_id_eq P.F s268 v OutParameter268.sourceFunction OutParameter268.sourceName OutParameter268.sourceParams args (R.env OutParameter268.sourceEnv) fs hc hf] at hr
      have he := congrArg Prod.fst (Option.some.inj hr)
      dsimp only at he
      exact (congrArg St.heap he).symm
    have cellLive269 : (outParameterLive live) OutBinding269.sourceAddress := by
      have hl := h269.controlLive
      change treeSupport (outParameterLive live) (Encode.ctl OutBinding269.input.ctl) at hl
      rw [OutBinding269.source_control] at hl
      exact env_lookup_live _ _ _ hl.2.2.1 OutBinding269.source_lookup
    have other269 : a ≠ OutBinding269.sourceAddress := by
      have hb := h.heap.sourceBound a ha
      have fresh : VectorDeclaration250.input.next ≤ OutBinding269.sourceAddress := by decide +kernel
      omega
    have mappedOther269 : R.a a ≠ R.a OutBinding269.sourceAddress := by
      intro he
      exact other269 (h269.heap.inj a OutBinding269.sourceAddress (out_parameter_grow live a ha) cellLive269 he)
    have hh270a := step_bind_init_heap_other P.F NR FR R (outParameterLive live) framed before after old old' OutBinding269.input s269 s270 C C h269
      OutBinding269.sourceName OutBinding269.sourceValue OutBinding269.sourceEnv OutBinding269.sourceKind OutBinding269.sourceAddress OutBinding269.source_control OutBinding269.source_lookup
      bound269 hr269 (R.a a) mappedOther269
    have hh271 : s271.heap = s270.heap := by
      obtain ⟨v,hc,_⟩ := (h270.control_view OutParameter270.source_control).ret_view
      obtain ⟨f,fs,hf,hfr,_⟩ := h270.stack_view OutParameter270.source_frame
      obtain ⟨args,hft,_⟩ := hfr.params_view
      rw [hft] at hf
      have hr := hr270
      change interpC (step P.F s270).run C = some (s271,C) at hr
      rw [step_parameter_id_eq P.F s270 v OutParameter270.sourceFunction OutParameter270.sourceName OutParameter270.sourceParams args (R.env OutParameter270.sourceEnv) fs hc hf] at hr
      have he := congrArg Prod.fst (Option.some.inj hr)
      dsimp only at he
      exact (congrArg St.heap he).symm
    have cellLive271 : (outParameterLive live) OutBinding271.sourceAddress := by
      have hl := h271.controlLive
      change treeSupport (outParameterLive live) (Encode.ctl OutBinding271.input.ctl) at hl
      rw [OutBinding271.source_control] at hl
      exact env_lookup_live _ _ _ hl.2.2.1 OutBinding271.source_lookup
    have other271 : a ≠ OutBinding271.sourceAddress := by
      have hb := h.heap.sourceBound a ha
      have fresh : VectorDeclaration250.input.next ≤ OutBinding271.sourceAddress := by decide +kernel
      omega
    have mappedOther271 : R.a a ≠ R.a OutBinding271.sourceAddress := by
      intro he
      exact other271 (h271.heap.inj a OutBinding271.sourceAddress (out_parameter_grow live a ha) cellLive271 he)
    have hh272a := step_bind_init_heap_other P.F NR FR R (outParameterLive live) framed before after old old' OutBinding271.input s271 s272 C C h271
      OutBinding271.sourceName OutBinding271.sourceValue OutBinding271.sourceEnv OutBinding271.sourceKind OutBinding271.sourceAddress OutBinding271.source_control OutBinding271.source_lookup
      bound271 hr271 (R.a a) mappedOther271
    have hh273a : s273.heap.get (R.a a) = s272.heap.get (R.a a) := by
      obtain ⟨v,hc,_⟩ := (h272.control_view OutBody272.source_control).ret_view
      obtain ⟨f,fs,hf,hfr,_⟩ := h272.stack_view OutBody272.source_frame
      obtain ⟨args,hft,_⟩ := hfr.params_view
      rw [hft] at hf
      have hr := hr272
      change interpC (step P.F s272).run C = some (s273,C) at hr
      rw [step_parameter_body_eq P.F s272 v OutBody272.sourceName OutBody272.sourceParams OutBody272.sourceBody args (R.env OutBody272.sourceEnv) fs hc hf] at hr
      have he := congrArg Prod.fst (Option.some.inj hr)
      dsimp only at he
      have hh := congrArg (fun t : St LSt => t.heap.get (R.a a)) he
      exact hh.symm.trans (enterBlock_heap_below {s272 with stack := fs} OutBody272.sourceBody (R.env OutBody272.sourceEnv)
        (R.a a) (h272.heap.targetBound a (out_parameter_grow live a ha)) bound272 OutBody272.source_hoist)
    have hh274 := step_block_next_heap P.F NR FR R (outBodyLive live) framed before after old old' OutBlock273.input s273 s274 C C h273
      OutBlock273.sourceValue OutBlock273.sourceStatement OutBlock273.sourceRest OutBlock273.sourceEnv OutBlock273.sourceTail OutBlock273.source_control OutBlock273.source_frame hr273
    have hh275 := step_statement_heap P.F NR FR R (outBodyLive live) framed before after old old' InventoryDeclaration274.input s274 s275 C C h274
      InventoryDeclaration274.sourceAction InventoryDeclaration274.sourceEnv InventoryDeclaration274.source_control hr274
    have hh276 := step_descent_heap_from_source P.F NR FR R (outBodyLive live) framed before after old old' InventoryMember275.input s275 s276 C C h275
      InventoryMember275.descent InventoryMember275.sourceEnv InventoryMember275.source_control hr275
    have hh277 : s277.heap = s276.heap := rfl
    have hh278 := MissingInventory277.heap_frame NR FR R C₀ C C (outBodyLive live) framed before after old old' s277 s278 h277 hr277
    have hh279 := step_declaration_value_heap P.F NR FR R (outBodyLive live) framed before after old old' InventoryReturn278.input s278 s279 C C h278
      InventoryReturn278.sourceValue InventoryReturn278.sourceKind InventoryReturn278.sourcePattern InventoryReturn278.sourceRest InventoryReturn278.sourceEnv InventoryReturn278.sourceTail InventoryReturn278.source_control InventoryReturn278.source_frame InventoryReturn278.source_kind hr278
    have cellLive279 : (outBodyLive live) InventoryBinding279.sourceAddress := by
      have hl := h279.controlLive
      change treeSupport (outBodyLive live) (Encode.ctl InventoryBinding279.input.ctl) at hl
      rw [InventoryBinding279.source_control] at hl
      exact env_lookup_live _ _ _ hl.2.2.1 InventoryBinding279.source_lookup
    have other279 : a ≠ InventoryBinding279.sourceAddress := by
      have hb := h.heap.sourceBound a ha
      have fresh : VectorDeclaration250.input.next ≤ InventoryBinding279.sourceAddress := by decide +kernel
      omega
    have mappedOther279 : R.a a ≠ R.a InventoryBinding279.sourceAddress := by
      intro he
      exact other279 (h279.heap.inj a InventoryBinding279.sourceAddress (out_body_grow live a ha) cellLive279 he)
    have hh280a := step_bind_init_heap_other P.F NR FR R (outBodyLive live) framed before after old old' InventoryBinding279.input s279 s280 C C h279
      InventoryBinding279.sourceName InventoryBinding279.sourceValue InventoryBinding279.sourceEnv InventoryBinding279.sourceKind InventoryBinding279.sourceAddress InventoryBinding279.source_control InventoryBinding279.source_lookup
      bound279 hr279 (R.a a) mappedOther279
    have hh281 := step_declaration_next_heap P.F NR FR R (outBodyLive live) framed before after old old' InventoryDone280.input s280 s281 C C h280
      InventoryDone280.sourceValue InventoryDone280.sourceKind InventoryDone280.sourceRest InventoryDone280.sourceEnv InventoryDone280.sourceTail InventoryDone280.source_control InventoryDone280.source_frame hr280
    have hh282 := step_block_next_heap P.F NR FR R (outBodyLive live) framed before after old old' InventoryBlock281.input s281 s282 C C h281
      InventoryBlock281.sourceValue InventoryBlock281.sourceStatement InventoryBlock281.sourceRest InventoryBlock281.sourceEnv InventoryBlock281.sourceTail InventoryBlock281.source_control InventoryBlock281.source_frame hr281
    have hh283 := step_statement_heap P.F NR FR R (outBodyLive live) framed before after old old' InventoryIf282.input s282 s283 C C h282
      InventoryIf282.sourceAction InventoryIf282.sourceEnv InventoryIf282.source_control hr282
    have hh284 : s284.heap = s283.heap := rfl
    have hh285 := heap285
    have hh286 := step_block_next_heap P.F NR FR R (outBodyLive live) framed before after old old' SlotBlock285.input s285 s286 C C h285
      SlotBlock285.sourceValue SlotBlock285.sourceStatement SlotBlock285.sourceRest SlotBlock285.sourceEnv SlotBlock285.sourceTail SlotBlock285.source_control SlotBlock285.source_frame hr285
    have hh287 := step_statement_heap P.F NR FR R (outBodyLive live) framed before after old old' SlotDeclaration286.input s286 s287 C C h286
      SlotDeclaration286.sourceAction SlotDeclaration286.sourceEnv SlotDeclaration286.source_control hr286
    have hh288 := step_descent_heap_from_source P.F NR FR R (outBodyLive live) framed before after old old' SlotConstructor287.input s287 s288 C C h287
      SlotConstructor287.sourceDescent SlotConstructor287.sourceEnv SlotConstructor287.source_control hr287
    have hh289 : s289.heap = s288.heap := rfl
    have hh290 := step_callStart_heap P.F NR FR R (outBodyLive live) framed before after old old' SlotCallee289.input s289 s290 C C h289
      SlotCallee289.sourceMode SlotCallee289.sourceAddress SlotCallee289.sourceThis SlotCallee289.sourceArgs SlotCallee289.sourceEnv SlotCallee289.sourceTail SlotCallee289.source_control SlotCallee289.source_frame hr289
    have hh291 : s291.heap = s290.heap := by
      have hc := (h290.control_view SlotArray290.source_control).ev_view
      have hr := hr290
      change interpC (step P.F s290).run C = some (s291,C) at hr
      rw [step_array_entry_eq P.F s290 SlotArray290.sourceExpression SlotArray290.sourceRest (R.env SlotArray290.sourceEnv) hc] at hr
      exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj hr))).symm
    have hh292 := step_method_descent_heap P.F NR FR R (outBodyLive live) framed before after old old' SlotMethod291.input s291 s292 C₀ C C h291
      SlotMethod291.sourceExpression SlotMethod291.sourceName SlotMethod291.sourceArgs SlotMethod291.sourceEnv SlotMethod291.sourceOptObject SlotMethod291.sourceOptCall SlotMethod291.source_control hr291
    have hh293 : s293.heap = s292.heap := rfl
    have hh294 := step_method_data_heap P.F NR FR R (outBodyLive live) framed before after old old' SlotLookup293.input s293 s294 C C h293
      SlotLookup293.sourceAddress SlotLookup293.sourceObject SlotLookup293.sourceName SlotLookup293.sourceArgs SlotLookup293.sourceEnv SlotLookup293.sourceOptObject SlotLookup293.sourceOptCall SlotLookup293.sourceMethod SlotLookup293.sourceWritable SlotLookup293.sourceEnumerable SlotLookup293.sourceTail SlotLookup293.source_control SlotLookup293.source_frame SlotLookup293.source_heap SlotLookup293.source_kind SlotLookup293.source_property hr293
    have hh295 := step_callStart_heap P.F NR FR R (outBodyLive live) framed before after old old' SlotNativeCallee294.input s294 s295 C C h294
      SlotNativeCallee294.sourceMode SlotNativeCallee294.sourceAddress SlotNativeCallee294.sourceThis SlotNativeCallee294.sourceArgs SlotNativeCallee294.sourceEnv SlotNativeCallee294.sourceTail SlotNativeCallee294.source_control SlotNativeCallee294.source_frame hr294
    calc
      s295.heap.get (R.a a) = s294.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh295
      _ = s293.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh294
      _ = s292.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh293
      _ = s291.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh292
      _ = s290.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh291
      _ = s289.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh290
      _ = s288.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh289
      _ = s287.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh288
      _ = s286.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh287
      _ = s285.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh286
      _ = s284.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh285
      _ = s283.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh284
      _ = s282.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh283
      _ = s281.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh282
      _ = s280.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh281
      _ = s279.heap.get (R.a a) := hh280a
      _ = s278.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh279
      _ = s277.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh278
      _ = s276.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh277
      _ = s275.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh276
      _ = s274.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh275
      _ = s273.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh274
      _ = s272.heap.get (R.a a) := hh273a
      _ = s271.heap.get (R.a a) := hh272a
      _ = s270.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh271
      _ = s269.heap.get (R.a a) := hh270a
      _ = s268.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh269
      _ = s267.heap.get (R.a a) := hh268a
      _ = s266.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh267
      _ = s265.heap.get (R.a a) := hh266a
      _ = s264.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh265
      _ = s263.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh264
      _ = s262.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh263
      _ = s261.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh262
      _ = s260.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh261
      _ = s259.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh260
      _ = s258.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh259
      _ = s257.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh258
      _ = s256.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh257
      _ = s255.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh256
      _ = s254.heap.get (R.a a) := hh255a
      _ = s253.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh254
      _ = s252.heap.get (R.a a) := congrArg (fun heap => heap.get (R.a a)) hh253
  have stored : ∀ v, s.ctl = .ret v → s295.heap.get (R.a VectorBinding251.sourceAddress) = some (.cell (some v)) := by
    intro v hc
    have hc251 := step_declaration_control P.F NR FR R live framed before after old old' VectorDeclaration250.input s s251 C C h
      v VectorDeclaration250.sourceKind VectorDeclaration250.sourcePattern VectorDeclaration250.sourceRest VectorDeclaration250.sourceEnv
      VectorDeclaration250.sourceTail VectorDeclaration250.source_frame hc VectorDeclaration250.source_kind hr250
    change s251.ctl = .bind (.id VectorBinding251.sourceName) v (R.env VectorBinding251.sourceEnv) .init VectorBinding251.sourceKind at hc251
    have cell := step_bind_init_cell_fields P.F NR FR R live framed before after old old' VectorBinding251.input s251 s252 C C h251
      VectorBinding251.sourceName VectorBinding251.sourceValue v VectorBinding251.sourceEnv VectorBinding251.sourceKind VectorBinding251.sourceAddress
      VectorBinding251.source_control hc251 VectorBinding251.source_lookup bound251 hr251
    exact (afterFrame _ vecLive).trans cell
  have framedOld : ∀ a, live a → a ≠ VectorBinding251.sourceAddress → s295.heap.get (R.a a) = s.heap.get (R.a a) := by
    intro a ha hn
    have mapped : R.a a ≠ R.a VectorBinding251.sourceAddress := by intro he; exact hn (h.heap.inj a _ ha vecLive he)
    have hh252 := step_bind_init_heap_other P.F NR FR R live framed before after old old' VectorBinding251.input s251 s252 C C h251
      VectorBinding251.sourceName VectorBinding251.sourceValue VectorBinding251.sourceEnv VectorBinding251.sourceKind VectorBinding251.sourceAddress
      VectorBinding251.source_control VectorBinding251.source_lookup bound251 hr251 (R.a a) mapped
    have hh251 := step_declaration_value_heap P.F NR FR R live framed before after old old' VectorDeclaration250.input s s251 C C h
      VectorDeclaration250.sourceValue VectorDeclaration250.sourceKind VectorDeclaration250.sourcePattern VectorDeclaration250.sourceRest
      VectorDeclaration250.sourceEnv VectorDeclaration250.sourceTail VectorDeclaration250.source_control VectorDeclaration250.source_frame VectorDeclaration250.source_kind hr250
    exact (afterFrame a ha).trans (hh252.trans (congrArg (fun heap => heap.get (R.a a)) hh251))
  refine ⟨s295,?_,h295,stored,framedOld⟩
  apply runC_cons P.F 44 s250 s251 s295 C C C (h250.control.isHalt_eq.trans (by host_kernel_rfl)) hr250
  apply runC_cons P.F 43 s251 s252 s295 C C C (h251.control.isHalt_eq.trans (by host_kernel_rfl)) hr251
  apply runC_cons P.F 42 s252 s253 s295 C C C (h252.control.isHalt_eq.trans (by host_kernel_rfl)) hr252
  apply runC_cons P.F 41 s253 s254 s295 C C C (h253.control.isHalt_eq.trans (by host_kernel_rfl)) hr253
  apply runC_cons P.F 40 s254 s255 s295 C C C (h254.control.isHalt_eq.trans (by host_kernel_rfl)) hr254
  apply runC_cons P.F 39 s255 s256 s295 C C C (h255.control.isHalt_eq.trans (by host_kernel_rfl)) hr255
  apply runC_cons P.F 38 s256 s257 s295 C C C (h256.control.isHalt_eq.trans (by host_kernel_rfl)) hr256
  apply runC_cons P.F 37 s257 s258 s295 C C C (h257.control.isHalt_eq.trans (by host_kernel_rfl)) hr257
  apply runC_cons P.F 36 s258 s259 s295 C C C (h258.control.isHalt_eq.trans (by host_kernel_rfl)) hr258
  apply runC_cons P.F 35 s259 s260 s295 C C C (h259.control.isHalt_eq.trans (by host_kernel_rfl)) hr259
  apply runC_cons P.F 34 s260 s261 s295 C C C (h260.control.isHalt_eq.trans (by host_kernel_rfl)) hr260
  apply runC_cons P.F 33 s261 s262 s295 C C C (h261.control.isHalt_eq.trans (by host_kernel_rfl)) hr261
  apply runC_cons P.F 32 s262 s263 s295 C C C (h262.control.isHalt_eq.trans (by host_kernel_rfl)) hr262
  apply runC_cons P.F 31 s263 s264 s295 C C C (h263.control.isHalt_eq.trans (by host_kernel_rfl)) hr263
  apply runC_cons P.F 30 s264 s265 s295 C C C (h264.control.isHalt_eq.trans (by host_kernel_rfl)) hr264
  apply runC_cons P.F 29 s265 s266 s295 C C C (h265.control.isHalt_eq.trans (by host_kernel_rfl)) hr265
  apply runC_cons P.F 28 s266 s267 s295 C C C (h266.control.isHalt_eq.trans (by host_kernel_rfl)) hr266
  apply runC_cons P.F 27 s267 s268 s295 C C C (h267.control.isHalt_eq.trans (by host_kernel_rfl)) hr267
  apply runC_cons P.F 26 s268 s269 s295 C C C (h268.control.isHalt_eq.trans (by host_kernel_rfl)) hr268
  apply runC_cons P.F 25 s269 s270 s295 C C C (h269.control.isHalt_eq.trans (by host_kernel_rfl)) hr269
  apply runC_cons P.F 24 s270 s271 s295 C C C (h270.control.isHalt_eq.trans (by host_kernel_rfl)) hr270
  apply runC_cons P.F 23 s271 s272 s295 C C C (h271.control.isHalt_eq.trans (by host_kernel_rfl)) hr271
  apply runC_cons P.F 22 s272 s273 s295 C C C (h272.control.isHalt_eq.trans (by host_kernel_rfl)) hr272
  apply runC_cons P.F 21 s273 s274 s295 C C C (h273.control.isHalt_eq.trans (by host_kernel_rfl)) hr273
  apply runC_cons P.F 20 s274 s275 s295 C C C (h274.control.isHalt_eq.trans (by host_kernel_rfl)) hr274
  apply runC_cons P.F 19 s275 s276 s295 C C C (h275.control.isHalt_eq.trans (by host_kernel_rfl)) hr275
  apply runC_cons P.F 18 s276 s277 s295 C C C (h276.control.isHalt_eq.trans (by host_kernel_rfl)) hr276
  apply runC_cons P.F 17 s277 s278 s295 C C C (h277.control.isHalt_eq.trans (by host_kernel_rfl)) hr277
  apply runC_cons P.F 16 s278 s279 s295 C C C (h278.control.isHalt_eq.trans (by host_kernel_rfl)) hr278
  apply runC_cons P.F 15 s279 s280 s295 C C C (h279.control.isHalt_eq.trans (by host_kernel_rfl)) hr279
  apply runC_cons P.F 14 s280 s281 s295 C C C (h280.control.isHalt_eq.trans (by host_kernel_rfl)) hr280
  apply runC_cons P.F 13 s281 s282 s295 C C C (h281.control.isHalt_eq.trans (by host_kernel_rfl)) hr281
  apply runC_cons P.F 12 s282 s283 s295 C C C (h282.control.isHalt_eq.trans (by host_kernel_rfl)) hr282
  apply runC_cons P.F 11 s283 s284 s295 C C C (h283.control.isHalt_eq.trans (by host_kernel_rfl)) hr283
  apply runC_cons P.F 10 s284 s285 s295 C C C (h284.control.isHalt_eq.trans (by host_kernel_rfl)) hr284
  apply runC_cons P.F 9 s285 s286 s295 C C C (h285.control.isHalt_eq.trans (by host_kernel_rfl)) hr285
  apply runC_cons P.F 8 s286 s287 s295 C C C (h286.control.isHalt_eq.trans (by host_kernel_rfl)) hr286
  apply runC_cons P.F 7 s287 s288 s295 C C C (h287.control.isHalt_eq.trans (by host_kernel_rfl)) hr287
  apply runC_cons P.F 6 s288 s289 s295 C C C (h288.control.isHalt_eq.trans (by host_kernel_rfl)) hr288
  apply runC_cons P.F 5 s289 s290 s295 C C C (h289.control.isHalt_eq.trans (by host_kernel_rfl)) hr289
  apply runC_cons P.F 4 s290 s291 s295 C C C (h290.control.isHalt_eq.trans (by host_kernel_rfl)) hr290
  apply runC_cons P.F 3 s291 s292 s295 C C C (h291.control.isHalt_eq.trans (by host_kernel_rfl)) hr291
  apply runC_cons P.F 2 s292 s293 s295 C C C (h292.control.isHalt_eq.trans (by host_kernel_rfl)) hr292
  apply runC_cons P.F 1 s293 s294 s295 C C C (h293.control.isHalt_eq.trans (by host_kernel_rfl)) hr293
  apply runC_cons P.F 0 s294 s295 s295 C C C (h294.control.isHalt_eq.trans (by host_kernel_rfl)) hr294
  rfl


theorem vector_to_null_initializer (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' VectorDeclaration250.input s)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next+32 ≤ 2^64) :
    ∃ result, runC P.F 45 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (outBodyLive live) framed before after old old' ArrayCall.input result := by
  obtain ⟨result,run,hr,_,_⟩ := vector_to_null_initializer_fields ν₀ ν C₀ C FR R live framed before after old old'
    s h functionProtoLive functionProtoFixed globalLive globalFixed bound
  exact ⟨result,run,hr⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat
