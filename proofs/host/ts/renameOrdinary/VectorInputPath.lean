import host.ts.renameOrdinary.DriverVectorInputBuiltins
import host.ts.RenameRouteHeapFields
import host.ts.RenameRoutePrivateFields
import host.ts.RenamePreparationHeap
import host.ts.RenameArgumentEffects
import host.ts.RenameArrayLengthEffects
import host.ts.RenameRouteArgumentFields

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

/-- The actual typed-array declaration, ptr lookup, length getter and BigInt
conversion build the vector-call arguments. Only the handles local is written. -/
theorem vector_input_path (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' VectorInput224.input s)
    (inputNotFramed : ¬ framed VectorInput245.sourceAddress)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 25 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' VectorInput248.output result ∧
      callArgument result.ctl 1 = .big 2 ∧
      (∀ a, a ≠ R.a VectorInput225.sourceAddress → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s225,r224,h225⟩ := VectorInput224.transport NR FR R C₀ C live framed before after old old' s h
  have heap225 := step_declaration_value_heap P.F NR FR R live framed before after old old' VectorInput224.input s s225 C C h VectorInput224.sourceValue VectorInput224.sourceKind VectorInput224.sourcePattern VectorInput224.sourceRest VectorInput224.sourceEnv VectorInput224.sourceTail VectorInput224.source_control VectorInput224.source_frame VectorInput224.source_kind r224
  obtain ⟨s226,r225,h226⟩ := VectorInput225.transport NR FR R C₀ C live framed before after old old' s225 h225 (by rw [h.target_next_eq h225 (by host_kernel_rfl)]; exact bound)
  have heap226 := step_bind_init_heap_other P.F NR FR R live framed before after old old' VectorInput225.input s225 s226 C C h225 VectorInput225.sourceName VectorInput225.sourceValue VectorInput225.sourceEnv VectorInput225.sourceKind VectorInput225.sourceAddress VectorInput225.source_control VectorInput225.source_lookup (by rw [h.target_next_eq h225 (by host_kernel_rfl)]; exact bound) r225
  obtain ⟨s227,r226,h227⟩ := VectorInput226.transport NR FR R C₀ C live framed before after old old' s226 h226
  have heap227 := step_declaration_next_heap P.F NR FR R live framed before after old old' VectorInput226.input s226 s227 C C h226 VectorInput226.sourceValue VectorInput226.sourceKind VectorInput226.sourceRest VectorInput226.sourceEnv VectorInput226.sourceTail VectorInput226.source_control VectorInput226.source_frame r226
  obtain ⟨s228,r227,h228⟩ := VectorInput227.transport NR FR R C₀ C live framed before after old old' s227 h227
  have heap228 := step_block_next_heap P.F NR FR R live framed before after old old' VectorInput227.input s227 s228 C C h227 VectorInput227.sourceValue VectorInput227.sourceStatement VectorInput227.sourceRest VectorInput227.sourceEnv VectorInput227.sourceTail VectorInput227.source_control VectorInput227.source_frame r227
  obtain ⟨s229,r228,h229⟩ := VectorInput228.transport NR FR R C₀ C live framed before after old old' s228 h228
  have heap229 := step_statement_heap P.F NR FR R live framed before after old old' VectorInput228.input s228 s229 C C h228 VectorInput228.sourceAction VectorInput228.sourceEnv VectorInput228.source_control r228
  obtain ⟨s230,r229,h230⟩ := VectorInput229.transport NR FR R C₀ C live framed before after old old' s229 h229
  have heap230 := step_method_descent_heap P.F NR FR R live framed before after old old' VectorInput229.input s229 s230 C₀ C C h229 VectorInput229.sourceExpression VectorInput229.sourceName VectorInput229.sourceArgs VectorInput229.sourceEnv VectorInput229.sourceOptObject VectorInput229.sourceOptCall VectorInput229.source_control r229
  obtain ⟨v230,r230,h231,_⟩ := VectorInput230.transport NR FR R C₀ C live framed before after old old' s230 h230
  let s231 := s230.ret v230
  have heap231 : s231.heap = s230.heap := rfl
  obtain ⟨s232,r231,h232⟩ := VectorInput231.transport NR FR R C₀ C live framed before after old old' s231 h231
  have heap232 := step_method_data_heap P.F NR FR R live framed before after old old' VectorInput231.input s231 s232 C C h231
    VectorInput231.sourceAddress VectorInput231.sourceObject VectorInput231.sourceName VectorInput231.sourceArgs VectorInput231.sourceEnv
    VectorInput231.sourceOptObject VectorInput231.sourceOptCall VectorInput231.sourceMethod VectorInput231.sourceWritable VectorInput231.sourceEnumerable
    VectorInput231.sourceTail VectorInput231.source_control VectorInput231.source_frame VectorInput231.source_heap VectorInput231.source_kind VectorInput231.source_property r231
  obtain ⟨s233,r232,h233⟩ := VectorInput232.transport NR FR R C₀ C live framed before after old old' s232 h232
  have heap233 := step_callStart_heap P.F NR FR R live framed before after old old' VectorInput232.input s232 s233 C C h232 VectorInput232.sourceMode VectorInput232.sourceAddress VectorInput232.sourceThis VectorInput232.sourceArgs VectorInput232.sourceEnv VectorInput232.sourceTail VectorInput232.source_control VectorInput232.source_frame r232
  obtain ⟨s234,r233,h234⟩ := VectorInput233.transport NR FR R C₀ C live framed before after old old' s233 h233
  have heap234 := step_identifier_call_heap P.F NR FR R live framed before after old old' VectorInput233.input s233 s234 C₀ C C h233 VectorInput233.sourceName VectorInput233.sourceArgs VectorInput233.sourceOptional VectorInput233.sourceEnv VectorInput233.source_control r233
  obtain ⟨v234,r234,h235,_⟩ := VectorInput234.transport NR FR R C₀ C live framed before after old old' s234 h234
  let s235 := s234.ret v234
  have heap235 : s235.heap = s234.heap := rfl
  obtain ⟨s236,r235,h236⟩ := VectorInput235.transport NR FR R C₀ C live framed before after old old' s235 h235
  have heap236 := step_callStart_heap P.F NR FR R live framed before after old old' VectorInput235.input s235 s236 C C h235
    (.callee VectorInput235.sourceOptional) VectorInput235.sourceAddress .undef VectorInput235.sourceArgs VectorInput235.sourceEnv VectorInput235.sourceTail
    VectorInput235.source_control VectorInput235.source_frame r235
  obtain ⟨v236,r236,h237,_⟩ := VectorInput236.transport NR FR R C₀ C live framed before after old old' s236 h236
  let s237 := s236.ret v236
  have heap237 : s237.heap = s236.heap := rfl
  obtain ⟨s238,r237,h238⟩ := VectorInput237.transport NR FR R C₀ C live framed before after old old' s237 h237
  have heap238 := step_argument_heap_from_source P.F NR FR R live framed before after old old' VectorInput237.input s237 s238 C C h237 VectorInput237.sourceValue VectorInput237.sourceKind VectorInput237.sourceFunction VectorInput237.sourceThis VectorInput237.sourceAcc VectorInput237.sourceRest VectorInput237.sourceEnv VectorInput237.sourceTail VectorInput237.source_control VectorInput237.source_frame (by decide +kernel) r237
  obtain ⟨s239,r238,h239,control239,heap239⟩ := VectorInput238.transport NR FR R C₀ C live framed before after old old' s238 h238
  obtain ⟨s240,r239,h240⟩ := VectorInput239.transport NR FR R C₀ C live framed before after old old' s239 h239
  have heap240 := step_argument_heap_from_source P.F NR FR R live framed before after old old' VectorInput239.input s239 s240 C C h239 VectorInput239.sourceValue VectorInput239.sourceKind VectorInput239.sourceFunction VectorInput239.sourceThis VectorInput239.sourceAcc VectorInput239.sourceRest VectorInput239.sourceEnv VectorInput239.sourceTail VectorInput239.source_control VectorInput239.source_frame (by decide +kernel) r239
  obtain ⟨s241,r240,h241⟩ := VectorInput240.transport NR FR R C₀ C live framed before after old old' s240 h240
  have heap241 := step_identifier_call_heap P.F NR FR R live framed before after old old' VectorInput240.input s240 s241 C₀ C C h240 VectorInput240.sourceName VectorInput240.sourceArgs VectorInput240.sourceOptional VectorInput240.sourceEnv VectorInput240.source_control r240
  obtain ⟨v241,r241,h242,_⟩ := VectorInput241.transport NR FR R C₀ C live framed before after old old' s241 h241 globalLive globalFixed
  let s242 := s241.ret v241
  have heap242 : s242.heap = s241.heap := rfl
  obtain ⟨s243,r242,h243⟩ := VectorInput242.transport NR FR R C₀ C live framed before after old old' s242 h242
  have heap243 := step_callStart_heap P.F NR FR R live framed before after old old' VectorInput242.input s242 s243 C C h242
    (.callee VectorInput242.sourceOptional) VectorInput242.sourceAddress .undef VectorInput242.sourceArgs VectorInput242.sourceEnv VectorInput242.sourceTail
    VectorInput242.source_control VectorInput242.source_frame r242
  obtain ⟨s244,r243,h244⟩ := VectorInput243.transport NR FR R C₀ C live framed before after old old' s243 h243
  have heap244 := step_descent_heap_from_source P.F NR FR R live framed before after old old' VectorInput243.input s243 s244 C C h243 VectorInput243.descent VectorInput243.sourceEnv VectorInput243.source_control r243
  obtain ⟨v244,r244,h245,_⟩ := VectorInput244.transport NR FR R C₀ C live framed before after old old' s244 h244
  let s245 := s244.ret v244
  have heap245 : s245.heap = s244.heap := rfl
  obtain ⟨s246,r245,h246,control246⟩ := VectorInput245.transport NR FR R C₀ C live framed before after old old' s245 h245 inputNotFramed ⟨_,NumRole.literal ν₀ ν C₀ C _⟩
  have heap246 := step_array_length_heap P.F NR FR R live framed before after old old' VectorInput245.input s245 s246 C C h245
    VectorInput245.sourceAddress VectorInput245.sourceObject VectorInput245.sourceElements VectorInput245.sourceOptional VectorInput245.sourceTail
    VectorInput245.source_control VectorInput245.source_frame VectorInput245.source_heap VectorInput245.source_kind inputNotFramed r245
  obtain ⟨s247,r246,h247⟩ := VectorInput246.transport NR FR R C₀ C live framed before after old old' s246 h246
  have heap247 := step_argument_heap_from_source P.F NR FR R live framed before after old old' VectorInput246.input s246 s247 C C h246 VectorInput246.sourceValue VectorInput246.sourceKind VectorInput246.sourceFunction VectorInput246.sourceThis VectorInput246.sourceAcc VectorInput246.sourceRest VectorInput246.sourceEnv VectorInput246.sourceTail VectorInput246.source_control VectorInput246.source_frame (by decide +kernel) r246
  have argument247 := step_single_argument_fields P.F NR FR R C C live framed before after old old' VectorInput246.input s246 s247 h246 VectorInput246.sourceFunction VectorInput246.sourceThis (natV VectorInput245.sourceLength) VectorInput246.sourceEnv VectorInput246.sourceTail VectorInput246.source_frame control246 r246
  obtain ⟨s248,r247,h248,control248,heap248⟩ := VectorInput247.transport NR FR R C₀ C ν live framed before after old old' s247 h247 (by rw [argument247]; exact .literal _ _ rfl)
  obtain ⟨s249,r248,h249⟩ := VectorInput248.transport NR FR R C₀ C live framed before after old old' s248 h248
  have heap249 := step_argument_heap_from_source P.F NR FR R live framed before after old old' VectorInput248.input s248 s249 C C h248 VectorInput248.sourceValue VectorInput248.sourceKind VectorInput248.sourceFunction VectorInput248.sourceThis VectorInput248.sourceAcc VectorInput248.sourceRest VectorInput248.sourceEnv VectorInput248.sourceTail VectorInput248.source_control VectorInput248.source_frame (by decide +kernel) r248
  have lastArgument := step_argument_last P.F NR FR R live framed before after old old' VectorInput248.input s248 s249 C C h248
    VectorInput248.sourceValue (.big VectorInput247.sourceInteger) VectorInput248.sourceFunction VectorInput248.sourceThis
    VectorInput248.sourceAcc VectorInput248.sourceEnv VectorInput248.sourceTail VectorInput248.source_control control248
    VectorInput248.source_frame r248
  refine ⟨s249,?_,h249,lastArgument,?_⟩
  · apply runC_cons P.F 24 s s225 s249 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r224
    apply runC_cons P.F 23 s225 s226 s249 C C C (h225.control.isHalt_eq.trans (by host_kernel_rfl)) r225
    apply runC_cons P.F 22 s226 s227 s249 C C C (h226.control.isHalt_eq.trans (by host_kernel_rfl)) r226
    apply runC_cons P.F 21 s227 s228 s249 C C C (h227.control.isHalt_eq.trans (by host_kernel_rfl)) r227
    apply runC_cons P.F 20 s228 s229 s249 C C C (h228.control.isHalt_eq.trans (by host_kernel_rfl)) r228
    apply runC_cons P.F 19 s229 s230 s249 C C C (h229.control.isHalt_eq.trans (by host_kernel_rfl)) r229
    apply runC_cons P.F 18 s230 s231 s249 C C C (h230.control.isHalt_eq.trans (by host_kernel_rfl)) r230
    apply runC_cons P.F 17 s231 s232 s249 C C C (h231.control.isHalt_eq.trans (by host_kernel_rfl)) r231
    apply runC_cons P.F 16 s232 s233 s249 C C C (h232.control.isHalt_eq.trans (by host_kernel_rfl)) r232
    apply runC_cons P.F 15 s233 s234 s249 C C C (h233.control.isHalt_eq.trans (by host_kernel_rfl)) r233
    apply runC_cons P.F 14 s234 s235 s249 C C C (h234.control.isHalt_eq.trans (by host_kernel_rfl)) r234
    apply runC_cons P.F 13 s235 s236 s249 C C C (h235.control.isHalt_eq.trans (by host_kernel_rfl)) r235
    apply runC_cons P.F 12 s236 s237 s249 C C C (h236.control.isHalt_eq.trans (by host_kernel_rfl)) r236
    apply runC_cons P.F 11 s237 s238 s249 C C C (h237.control.isHalt_eq.trans (by host_kernel_rfl)) r237
    apply runC_cons P.F 10 s238 s239 s249 C C C (h238.control.isHalt_eq.trans (by host_kernel_rfl)) r238
    apply runC_cons P.F 9 s239 s240 s249 C C C (h239.control.isHalt_eq.trans (by host_kernel_rfl)) r239
    apply runC_cons P.F 8 s240 s241 s249 C C C (h240.control.isHalt_eq.trans (by host_kernel_rfl)) r240
    apply runC_cons P.F 7 s241 s242 s249 C C C (h241.control.isHalt_eq.trans (by host_kernel_rfl)) r241
    apply runC_cons P.F 6 s242 s243 s249 C C C (h242.control.isHalt_eq.trans (by host_kernel_rfl)) r242
    apply runC_cons P.F 5 s243 s244 s249 C C C (h243.control.isHalt_eq.trans (by host_kernel_rfl)) r243
    apply runC_cons P.F 4 s244 s245 s249 C C C (h244.control.isHalt_eq.trans (by host_kernel_rfl)) r244
    apply runC_cons P.F 3 s245 s246 s249 C C C (h245.control.isHalt_eq.trans (by host_kernel_rfl)) r245
    apply runC_cons P.F 2 s246 s247 s249 C C C (h246.control.isHalt_eq.trans (by host_kernel_rfl)) r246
    apply runC_cons P.F 1 s247 s248 s249 C C C (h247.control.isHalt_eq.trans (by host_kernel_rfl)) r247
    apply runC_cons P.F 0 s248 s249 s249 C C C (h248.control.isHalt_eq.trans (by host_kernel_rfl)) r248
    rfl
  · intro a ha
    rw [heap249,heap248,heap247,heap246,heap245,heap244,heap243,heap242,heap241,heap240,heap239,heap238,heap237,heap236,heap235,heap234,heap233,heap232,heap231,heap230,heap229,heap228,heap227,heap226 a ha,heap225]

end Host.Load.Run.Full.Ordinary
