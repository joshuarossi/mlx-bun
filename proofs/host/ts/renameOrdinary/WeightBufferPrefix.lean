import host.ts.renameOrdinary.WeightBufferCase
import host.ts.RenameRuntimeSeeds
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem buffer_pointer_value : BufferPointer.sourceValue = .ptr (.ext 5460) 0 := by host_kernel_rfl
theorem buffer_pointer_heap : BufferPointer.input.heap.get BufferPointer.address = some (.cell (some (.ptr (.ext 5460) 0))) := by host_kernel_rfl
theorem buffer_pointer_live : forestHasAddress BufferPointer.address (BufferPointer.input.stack.map Encode.frame) = true := by host_kernel_rfl
theorem buffer_rank_live : forestHasAddress ByteRank.address (BufferPointer.input.stack.map Encode.frame) = true := by host_kernel_rfl
theorem buffer_rank_heap : BufferPointer.input.heap.get ByteRank.address = some (.cell (some (natV 3))) := by host_kernel_rfl
theorem buffer_addresses_ne : ByteRank.address ≠ BufferPointer.address := by decide +kernel

theorem buffer_initial_stack : BufferPointer.input.stack = .c (.args 0 PointerArgument.sourceFunction PointerArgument.sourceThis []
    PointerArgument.sourceRest PointerArgument.sourceEnv)::PointerArgument.sourceTail := by host_kernel_rfl

theorem pointer_argument_control : PointerArgument.input.ctl = .ret BufferPointer.sourceValue := by host_kernel_rfl
theorem buffer_pointer_post : BufferPointer.input.ret BufferPointer.sourceValue = PointerArgument.input := by host_kernel_rfl
theorem pointer_argument_stack : PointerArgument.input.stack = .c (.args 0 PointerArgument.sourceFunction PointerArgument.sourceThis []
    PointerArgument.sourceRest PointerArgument.sourceEnv)::PointerArgument.sourceTail := by host_kernel_rfl

theorem pointer_argument_post : argumentState {PointerArgument.input with stack := PointerArgument.sourceTail} 0
    PointerArgument.sourceFunction PointerArgument.sourceThis [BufferPointer.sourceValue] PointerArgument.sourceRest PointerArgument.sourceEnv = BufferZero.input := by host_kernel_rfl

theorem zero_argument_stack : ZeroArgument.input.stack = .c (.args 0 PointerArgument.sourceFunction PointerArgument.sourceThis
    [BufferPointer.sourceValue] ZeroArgument.sourceRest PointerArgument.sourceEnv)::ZeroArgument.sourceTail := by host_kernel_rfl

theorem zero_argument_control : ZeroArgument.input.ctl = .ret BufferZero.sourceValue := by host_kernel_rfl
theorem buffer_zero_post : BufferZero.input.ret BufferZero.sourceValue = ZeroArgument.input := by host_kernel_rfl

theorem zero_argument_post : argumentState {ZeroArgument.input with stack := ZeroArgument.sourceTail} 0
    PointerArgument.sourceFunction PointerArgument.sourceThis [BufferZero.sourceValue,BufferPointer.sourceValue]
    ZeroArgument.sourceRest PointerArgument.sourceEnv = ByteBinary.input := by host_kernel_rfl

theorem buffer_zero_role : BufferZero.parsed.role = .literal (.lit (F64.ofNat 0)) := by host_kernel_rfl

theorem count_argument_control : CountArgument.input.ctl = .ret (natV 12) := by host_kernel_rfl

theorem count_argument_stack : CountArgument.input.stack = .c (.args 0 PointerArgument.sourceFunction PointerArgument.sourceThis
    [BufferZero.sourceValue,BufferPointer.sourceValue] [] PointerArgument.sourceEnv)::CountArgument.sourceTail := by host_kernel_rfl

theorem count_argument_post : argumentState {CountArgument.input with stack := CountArgument.sourceTail} 0
    PointerArgument.sourceFunction PointerArgument.sourceThis [natV 12,BufferZero.sourceValue,BufferPointer.sourceValue]
    [] PointerArgument.sourceEnv = BufferNative.input := by host_kernel_rfl

theorem count_source_heap : ByteMultiply.output.heap = ByteBinary.input.heap := by host_kernel_rfl
theorem count_source_stack : ByteMultiply.output.stack = ByteBinary.input.stack := by host_kernel_rfl
theorem pointer_rest_shape : PointerArgument.sourceRest = .expr (.lit BufferZero.sourceLiteral)::PointerArgument.sourceRest.tail := by host_kernel_rfl
theorem zero_rest_shape : ZeroArgument.sourceRest = .expr ByteBinary.descent.whole::[] := by host_kernel_rfl
theorem buffer_arguments_next : BufferNative.input.next = BufferPointer.input.next := by host_kernel_rfl

/-- All original arguments to the weight-shape buffer call are computed in
source order. The pointer and zero are retained in the annotated accumulator;
the executed rank expression supplies literal twelve. -/
theorem buffer_arguments_transport (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' BufferPointer.input s)
    (rank : s.heap.get (R.a ByteRank.address) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' BufferNative.input result ∧
      (Annotated.Value.literal (.lit (F64.ofNat 0))).Holds ν C R (callArgument result.ctl 1) ∧
      (Annotated.Value.literal (.lit (F64.ofNat 12))).Holds ν C R (callArgument result.ctl 2) ∧
      result.heap = s.heap ∧ result.next = s.next ∧ result.stack = s.stack.tail ∧ result.aux = s.aux := by
  let rankRole : Annotated.Value := .literal (.lit (F64.ofNat 3))
  let pointerRole : Annotated.Value := .ptr (.ext 5460) 0
  let zeroRole : Annotated.Value := .literal (.lit (F64.ofNat 0))
  let countRole : Annotated.Value := .literal (.lit (F64.ofNat 12))
  have rankAlive := h.stack_address_live ByteRank.address buffer_rank_live
  have pointerAlive := h.stack_address_live BufferPointer.address buffer_pointer_live
  have sourceRank : rankRole.Holds ν₀ C₀ identity (cellValueAt BufferPointer.input ByteRank.address) := by
    simpa only [rankRole,cellValueAt,buffer_rank_heap,natV] using (Annotated.Value.Holds.literal (.lit (F64.ofNat 3)) (F64.ofNat 3) (NumDenote.literal ν₀ C₀ _))
  have targetRank : rankRole.Holds ν C R (cellValueAt s (R.a ByteRank.address)) := by
    simpa only [rankRole,cellValueAt,rank,natV] using (Annotated.Value.Holds.literal (.lit (F64.ofNat 3)) (F64.ofNat 3) (NumDenote.literal ν C _))
  obtain ⟨pointerValue,pointerCell,pointerRelation,_⟩ := h.heap.readCell BufferPointer.address (.ptr (.ext 5460) 0) pointerAlive buffer_pointer_heap
  have targetPointer : pointerValue = .ptr (.ext (R.region 5460)) 0 := by cases pointerRelation; rfl
  rw [targetPointer] at pointerCell
  have sourcePointerRole : pointerRole.Holds ν₀ C₀ identity (cellValueAt BufferPointer.input BufferPointer.address) := by
    change pointerRole.Holds ν₀ C₀ identity (.ptr (.ext 5460) 0)
    exact Annotated.Value.Holds.ptr (.ext 5460) 0
  have targetPointerRole : pointerRole.Holds ν C R (cellValueAt s (R.a BufferPointer.address)) := by
    simpa only [pointerRole,cellValueAt,pointerCell,Ren.mem] using Annotated.Value.Holds.ptr (ν:=ν) (C:=C) (R:=R) (.ext 5460) 0
  let cells := (Notes.empty.write ByteRank.address rankRole).write BufferPointer.address pointerRole
  have cellInventory : CellInventory cells ν₀ ν C₀ C R live BufferPointer.input s :=
    (CellInventory.empty.annotate ByteRank.address rankRole rankAlive sourceRank targetRank).annotate
      BufferPointer.address pointerRole pointerAlive sourcePointerRole targetPointerRole
  obtain ⟨control,fnRole,thisRole,tailNotes,inventory⟩ := RuntimeInventory.argument_entry h cellInventory
    0 PointerArgument.sourceFunction PointerArgument.sourceThis PointerArgument.sourceRest PointerArgument.sourceEnv
    PointerArgument.sourceTail buffer_initial_stack
  let n0 : RuntimeNotes := ⟨control,argumentFrameNote false 0 fnRole thisRole [] PointerArgument.sourceRest PointerArgument.sourceEnv::tailNotes,cells⟩
  obtain ⟨v43,r42,r42t,h43,i43⟩ := inventory.variable_step P.F FR n0 ν₀ ν C₀ C R live framed before after old old'
    BufferPointer.input s h BufferPointer.sourceName BufferPointer.sourceEnv BufferPointer.address BufferPointer.sourceValue pointerRole
    BufferPointer.source_control BufferPointer.source_lookup BufferPointer.source_cell (by change cells.cells BufferPointer.address = some pointerRole; simp only [cells,Notes.write,ite_true])
  let s43 := s.ret v43
  have h43' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' PointerArgument.input s43 := buffer_pointer_post ▸ h43
  have i43' : RuntimeInventory (n0.returning pointerRole) ν₀ ν C₀ C R live PointerArgument.input s43 := buffer_pointer_post ▸ i43
  obtain ⟨v44,fn44,this44,acc44,fs44,r43,r43t,h44,i44⟩ := i43'.argument_step P.F FR _ ν₀ ν C₀ C R live framed before after old old'
    PointerArgument.input s43 h43' BufferPointer.sourceValue pointerRole fnRole thisRole [] 0
    PointerArgument.sourceFunction PointerArgument.sourceThis [] PointerArgument.sourceRest PointerArgument.sourceEnv PointerArgument.sourceTail
    tailNotes pointer_argument_control pointer_argument_stack (by decide) rfl rfl
  let s44 := argumentState {s43 with stack := fs44} 0 fn44 this44 (v44::acc44) PointerArgument.sourceRest (R.env PointerArgument.sourceEnv)
  let n44 := ({n0.returning pointerRole with stack := tailNotes}).arguments 0 fnRole thisRole [pointerRole] PointerArgument.sourceRest PointerArgument.sourceEnv
  have h44' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' BufferZero.input s44 := pointer_argument_post ▸ h44
  have i44' : RuntimeInventory n44 ν₀ ν C₀ C R live BufferZero.input s44 := pointer_argument_post ▸ i44
  obtain ⟨r44,r44t,h45,i45⟩ := i44'.literal_step P.F FR _ ν₀ ν C₀ C R live framed before after old old'
    BufferZero.input s44 h44' BufferZero.sourceLiteral BufferZero.sourceValue BufferZero.sourceEnv BufferZero.parsed BufferZero.source_control
  let s45 := s44.ret BufferZero.sourceValue
  have h45' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ZeroArgument.input s45 := buffer_zero_post ▸ h45
  have i45a := i45
  simp only [buffer_zero_role] at i45a
  have i45' : RuntimeInventory (n44.returning zeroRole) ν₀ ν C₀ C R live ZeroArgument.input s45 :=
    buffer_zero_post ▸ i45a
  obtain ⟨v46,fn46,this46,acc46,fs46,r45,r45t,h46,i46⟩ := i45'.argument_step P.F FR _ ν₀ ν C₀ C R live framed before after old old'
    ZeroArgument.input s45 h45' BufferZero.sourceValue zeroRole fnRole thisRole [pointerRole] 0 PointerArgument.sourceFunction PointerArgument.sourceThis
    [BufferPointer.sourceValue] ZeroArgument.sourceRest PointerArgument.sourceEnv ZeroArgument.sourceTail tailNotes zero_argument_control zero_argument_stack (by decide) rfl rfl
  let s46 := argumentState {s45 with stack := fs46} 0 fn46 this46 (v46::acc46) ZeroArgument.sourceRest (R.env PointerArgument.sourceEnv)
  let n46 := ({n44.returning zeroRole with stack := tailNotes}).arguments 0 fnRole thisRole [zeroRole,pointerRole] ZeroArgument.sourceRest PointerArgument.sourceEnv
  have h46' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteBinary.input s46 := zero_argument_post ▸ h46
  have i46' : RuntimeInventory n46 ν₀ ν C₀ C R live ByteBinary.input s46 := zero_argument_post ▸ i46
  have heap46 : s46.heap = s.heap := by
    change (argumentState _ _ _ _ _ _ _).heap = _
    rw [argumentState_heap]
    change s44.heap = s.heap
    rw [argumentState_heap]
    rfl
  have rank46 : s46.heap.get (R.a ByteRank.address) = some (.cell (some (natV 3))) := heap46 ▸ rank
  obtain ⟨s51,r46t,h51,ctl51,heap51,next51,stack51,aux51⟩ := byte_count_transport_frame FR R ν₀ ν C₀ C live framed before after old old' s46 h46' rank46
  have i51 : RuntimeInventory (n46.returning countRole) ν₀ ν C₀ C R live CountArgument.input s51 :=
    i46'.return_frame countRole (natV 12) (natV 12)
      (.literal _ _ (NumDenote.literal ν₀ C₀ _)) (.literal _ _ (NumDenote.literal ν C _))
      count_argument_control ctl51 count_source_heap heap51 count_source_stack stack51
  obtain ⟨v52,fn52,this52,acc52,fs52,r51,r51t,h52,i52⟩ := i51.argument_step P.F FR _ ν₀ ν C₀ C R live framed before after old old'
    CountArgument.input s51 h51 (natV 12) countRole fnRole thisRole [zeroRole,pointerRole] 0 PointerArgument.sourceFunction PointerArgument.sourceThis
    [BufferZero.sourceValue,BufferPointer.sourceValue] [] PointerArgument.sourceEnv CountArgument.sourceTail tailNotes count_argument_control count_argument_stack (by decide) rfl rfl
  let result := argumentState {s51 with stack := fs52} 0 fn52 this52 (v52::acc52) [] (R.env PointerArgument.sourceEnv)
  have h52' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' BufferNative.input result := count_argument_post ▸ h52
  have i52' : RuntimeInventory ⟨callNote fnRole thisRole [pointerRole,zeroRole,countRole],tailNotes,cells⟩ ν₀ ν C₀ C R live BufferNative.input result := count_argument_post ▸ i52
  have offset := (i52'.call_argument_role fnRole thisRole [pointerRole,zeroRole,countRole] (.obj 2639) .undef
    [.ptr (.ext 5460) 0,natV 0,natV 12] BufferNative.source_control rfl 1 zeroRole rfl).2
  have count := (i52'.call_argument_role fnRole thisRole [pointerRole,zeroRole,countRole] (.obj 2639) .undef
    [.ptr (.ext 5460) 0,natV 0,natV 12] BufferNative.source_control rfl 2 countRole rfl).2
  have stack44 := step_argument_expression_stack_tail P.F (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
    PointerArgument.input s43 s44 C C h43' BufferPointer.sourceValue 0 PointerArgument.sourceFunction PointerArgument.sourceThis []
    PointerArgument.sourceRest PointerArgument.sourceEnv PointerArgument.sourceTail pointer_argument_control pointer_argument_stack (by decide)
    (.lit BufferZero.sourceLiteral) PointerArgument.sourceRest.tail pointer_rest_shape r43t
  have stack46 := step_argument_expression_stack_tail P.F (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
    ZeroArgument.input s45 s46 C C h45' BufferZero.sourceValue 0 PointerArgument.sourceFunction PointerArgument.sourceThis [BufferPointer.sourceValue]
    ZeroArgument.sourceRest PointerArgument.sourceEnv ZeroArgument.sourceTail zero_argument_control zero_argument_stack (by decide)
    ByteBinary.descent.whole [] zero_rest_shape r45t
  have stack52 := step_argument_done_stack P.F (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
    CountArgument.input s51 result C C h51 (natV 12) 0 PointerArgument.sourceFunction PointerArgument.sourceThis
    [BufferZero.sourceValue,BufferPointer.sourceValue] [] PointerArgument.sourceEnv CountArgument.sourceTail
    count_argument_control count_argument_stack (by decide) rfl r51t
  refine ⟨result,?_,h52',offset,count,?_,h.target_next_eq h52' buffer_arguments_next,?_,aux51⟩
  · have run4 : runC P.F 4 s C = some (s46,C) := by
      apply runC_cons P.F 3 s s43 s46 C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r42t
      apply runC_cons P.F 2 s43 s44 s46 C C C (h43'.control.isHalt_eq.trans (by host_kernel_rfl)) r43t
      apply runC_cons P.F 1 s44 s45 s46 C C C (h44'.control.isHalt_eq.trans (by host_kernel_rfl)) r44t
      apply runC_cons P.F 0 s45 s46 s46 C C C (h45'.control.isHalt_eq.trans (by host_kernel_rfl)) r45t
      rfl
    have run1 : runC P.F 1 s51 C = some (result,C) := by
      apply runC_cons P.F 0 s51 result result C C C (h51.control.isHalt_eq.trans (by host_kernel_rfl)) r51t
      rfl
    exact runC_join P.F (m:=9) (n:=1) (runC_join P.F (m:=4) (n:=5) run4 r46t) run1
  · change s51.heap = s.heap
    exact heap51.trans heap46
  · exact stack52.trans ((congrArg List.tail stack51).trans (stack46.trans stack44))
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
