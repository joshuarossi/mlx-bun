import host.ts.renameOrdinary.WeightByteCountSteps
import host.ts.RenameRuntimeArithmetic
import host.ts.RenameRuntimeRefinement
import host.ts.RenameLiveAddress
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem byte_binary_control : ByteBinary.input.ctl =
    .ev (.bin .mul (.id ByteRank.sourceName) (.lit ByteFour.sourceLiteral)) ByteBinary.sourceEnv := by host_kernel_rfl

theorem byte_binary_post :
    ((ByteBinary.input.push (.e (.binL .mul (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv))).go
      (.ev (.id ByteRank.sourceName) ByteBinary.sourceEnv)) = ByteRank.input := by host_kernel_rfl

theorem byte_rank_env : ByteRank.sourceEnv = ByteBinary.sourceEnv := by host_kernel_rfl
theorem byte_rank_value : ByteRank.sourceValue = natV 3 := by host_kernel_rfl
theorem byte_rank_post : ByteRank.input.ret (natV 3) = ByteLeft.input := by host_kernel_rfl
theorem byte_left_control : ByteLeft.input.ctl = .ret (natV 3) := by host_kernel_rfl
theorem byte_left_stack : ByteLeft.input.stack = .e (.binL .mul (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv)::ByteLeft.sourceTail := by host_kernel_rfl
theorem byte_left_post : binaryLeftState {ByteLeft.input with stack := ByteLeft.sourceTail}
    .mul (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv (natV 3) = ByteFour.input := by host_kernel_rfl

theorem byte_four_role : ByteFour.parsed.role = .literal (.lit (F64.ofNat 4)) := by host_kernel_rfl
theorem byte_four_post : ByteFour.input.ret ByteFour.sourceValue = ByteMultiply.input := by host_kernel_rfl
theorem byte_multiply_control : ByteMultiply.input.ctl = .ret (natV 4) := by host_kernel_rfl
theorem byte_multiply_stack : ByteMultiply.input.stack =
    .e (.binR .mul (natV 3))::ByteMultiply.sourceTail := by host_kernel_rfl
theorem byte_multiply_post : ({ByteMultiply.input with stack := ByteMultiply.sourceTail}.ret
    (.num (.lit (F64.bin .mul (F64.ofNat 3) (F64.ofNat 4))))) = ByteMultiply.output := by host_kernel_rfl

theorem byte_rank_address : ByteRank.address = WeightInitialize9.sourceAddress := by host_kernel_rfl
theorem byte_rank_entry : ByteBinary.input.heap.get ByteRank.address = some (.cell (some (natV 3))) := by host_kernel_rfl
theorem byte_rank_found : forestHasAddress ByteRank.address (ByteBinary.input.stack.map Encode.frame) = true := by host_kernel_rfl

theorem byte_product : F64.bin .mul (F64.ofNat 3) (F64.ofNat 4) = F64.ofNat 12 := by decide +kernel

/-- The actual source rank expression is dispatched with one retained cell
annotation. All five original steps run, the saved left operand keeps its
meaning, and literal folding derives the exact count required by the decoder. -/
theorem byte_count_transport (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteBinary.input s)
    (rank : s.heap.get (R.a ByteRank.address) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 5 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteMultiply.output result ∧
      result.ctl = .ret (natV 12) ∧ result.heap = s.heap ∧ result.next = s.next ∧ result.stack = s.stack := by
  let role : Annotated.Value := .literal (.lit (F64.ofNat 3))
  let cells := Annotated.Notes.empty.write ByteRank.address role
  have alive := h.stack_address_live ByteRank.address byte_rank_found
  have sourceRole : role.Holds ν₀ C₀ Annotated.identity (cellValueAt ByteBinary.input ByteRank.address) := by
    simpa only [cellValueAt,byte_rank_entry,role,natV] using (Annotated.Value.Holds.literal (.lit (F64.ofNat 3)) (F64.ofNat 3) (NumDenote.literal ν₀ C₀ _))
  have targetRole : role.Holds ν C R (cellValueAt s (R.a ByteRank.address)) := by
    simpa only [cellValueAt,rank,role,natV] using (Annotated.Value.Holds.literal (.lit (F64.ofNat 3)) (F64.ofNat 3) (NumDenote.literal ν C _))
  have cellInventory : Annotated.CellInventory cells ν₀ ν C₀ C R live ByteBinary.input s :=
    Annotated.CellInventory.empty.annotate ByteRank.address role alive sourceRole targetRole
  obtain ⟨controlNotes,stackNotes,inventory⟩ := Annotated.RuntimeInventory.of_state h cellInventory
  let notes : Annotated.RuntimeNotes := ⟨controlNotes,stackNotes,cells⟩
  obtain ⟨run46,run46t,h47,inv47⟩ := inventory.binary_descent_step P.F FR notes ν₀ ν C₀ C R live framed
    before after old old' ByteBinary.input s h .mul (.id ByteRank.sourceName) (.lit ByteFour.sourceLiteral)
    ByteBinary.sourceEnv byte_binary_control
  let s47 := (s.push (.e (.binL .mul (.lit ByteFour.sourceLiteral) (R.env ByteBinary.sourceEnv)))).go
    (.ev (.id ByteRank.sourceName) (R.env ByteBinary.sourceEnv))
  have h47' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteRank.input s47 := byte_binary_post ▸ h47
  have inv47' : RuntimeInventory (notes.binaryDescent .mul (.id ByteRank.sourceName) (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv)
      ν₀ ν C₀ C R live ByteRank.input s47 := byte_binary_post ▸ inv47
  obtain ⟨v48,run47,run47t,h48,inv48⟩ := inv47'.variable_step P.F FR _ ν₀ ν C₀ C R live framed before after old old'
    ByteRank.input s47 h47' ByteRank.sourceName ByteRank.sourceEnv ByteRank.address ByteRank.sourceValue role
    ByteRank.source_control ByteRank.source_lookup ByteRank.source_cell (by change cells.cells ByteRank.address = some role; simp only [cells,Annotated.Notes.write,ite_true])
  let s48 := s47.ret v48
  have rankPost : ByteRank.input.ret ByteRank.sourceValue = ByteLeft.input :=
    (congrArg (fun value => ByteRank.input.ret value) byte_rank_value).trans byte_rank_post
  have h48' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteLeft.input s48 := rankPost ▸ h48
  have inv48' : RuntimeInventory ((notes.binaryDescent .mul (.id ByteRank.sourceName) (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv).returning role)
      ν₀ ν C₀ C R live ByteLeft.input s48 := rankPost ▸ inv48
  obtain ⟨v49,frames49,run48,run48t,h49,inv49,stack48⟩ := inv48'.binary_left_step P.F FR _ ν₀ ν C₀ C R live framed
    before after old old' ByteLeft.input s48 h48' (natV 3) role .mul (.lit ByteFour.sourceLiteral)
    ByteBinary.sourceEnv ByteLeft.sourceTail (binaryLeftNote .mul (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv)
    stackNotes byte_left_control byte_left_stack rfl rfl
  let s49 := binaryLeftState {s48 with stack := frames49} .mul (.lit ByteFour.sourceLiteral) (R.env ByteBinary.sourceEnv) v49
  have h49' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteFour.input s49 := byte_left_post ▸ h49
  have inv49' : RuntimeInventory (((notes.binaryDescent .mul (.id ByteRank.sourceName) (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv).returning role).binaryLeft role .mul (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv stackNotes)
      ν₀ ν C₀ C R live ByteFour.input s49 := byte_left_post ▸ inv49
  obtain ⟨run49,run49t,h50,inv50⟩ := inv49'.literal_step P.F FR _ ν₀ ν C₀ C R live framed before after old old'
    ByteFour.input s49 h49' ByteFour.sourceLiteral ByteFour.sourceValue ByteFour.sourceEnv ByteFour.parsed ByteFour.source_control
  let s50 := s49.ret ByteFour.sourceValue
  have h50' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteMultiply.input s50 := byte_four_post ▸ h50
  have inv50' : RuntimeInventory ((((notes.binaryDescent .mul (.id ByteRank.sourceName) (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv).returning role).binaryLeft role .mul (.lit ByteFour.sourceLiteral) ByteBinary.sourceEnv stackNotes).returning ByteFour.parsed.role)
      ν₀ ν C₀ C R live ByteMultiply.input s50 := byte_four_post ▸ inv50
  obtain ⟨a,b,frames51,run50,run50t,h51,inv51,stack50⟩ := inv50'.literal_arithmetic_step P.F FR _ ν₀ ν C₀ C R live framed
    before after old old' ByteMultiply.input s50 h50' .mul (F64.ofNat 3) (F64.ofNat 4)
    (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)) ByteMultiply.sourceTail stackNotes byte_multiply_control byte_multiply_stack
    (by simp only [RuntimeNotes.returning,byte_four_role]) rfl
  let result := ({s50 with stack := frames51}.ret (.num (.lit (F64.bin .mul a b))))
  have h51' : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ByteMultiply.output result := byte_multiply_post ▸ h51
  have resultRole := inv51.target.control
  change (returnNote (.literal (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4))))).Holds ν C R
    (Encode.ctl (.ret (.num (.lit (F64.bin .mul a b))))) at resultRole
  have productRole := returnNote_view resultRole
  obtain ⟨x,equation,denotation⟩ := productRole.literal_view
  have count : F64.bin .mul a b = F64.ofNat 12 := by
    cases equation
    have value : F64.bin .mul a b = F64.bin .mul (F64.ofNat 3) (F64.ofNat 4) := Option.some.inj denotation
    exact value.trans byte_product
  have actual48 : s48.stack = .e (.binL .mul (.lit ByteFour.sourceLiteral) (R.env ByteBinary.sourceEnv))::s.stack := rfl
  have frames49eq : frames49 = s.stack := by
    exact (List.cons.inj (stack48.symm.trans actual48)).2
  have actual50 : s50.stack = .e (.binR .mul v49)::frames49 := rfl
  have frames51eq : frames51 = frames49 := (List.cons.inj (stack50.symm.trans actual50)).2
  refine ⟨result,?_,h51',?_,rfl,rfl,frames51eq.trans frames49eq⟩
  · apply runC_cons P.F 4 s s47 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) run46t
    apply runC_cons P.F 3 s47 s48 result C C C (h47'.control.isHalt_eq.trans (by host_kernel_rfl)) run47t
    apply runC_cons P.F 2 s48 s49 result C C C (h48'.control.isHalt_eq.trans (by host_kernel_rfl)) run48t
    apply runC_cons P.F 1 s49 s50 result C C C (h49'.control.isHalt_eq.trans (by host_kernel_rfl)) run49t
    apply runC_cons P.F 0 s50 result result C C C (h50'.control.isHalt_eq.trans (by host_kernel_rfl)) run50t
    rfl
  · exact congrArg (fun x => Ctl.ret (.num (.lit x))) count
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
