import host.ts.RenameRetainedShapeCallEntry
import host.ts.RenameRetainedStores
import host.ts.RuntimeInventoryArrayBinding
import host.ts.RenameRuntimeComparison
import host.ts.RenameRetainedBranch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric
namespace ShapeCall

def rankRole (rank : Nat) : Value := .literal (.lit (F64.ofInt (Int.ofNat rank)))
def guardResult {S : Type} (source : St S) (rankCell rank : Nat) (env : Env) (caller : List Frame) : St S :=
  {(source.setCell rankCell (intV (Int.ofNat rank))) with ctl := .ret .undef,stack := (.s (.block [pointerDeclaration,returnStatement] env)::caller)}
def guardNotes (notes : RetainedNotes) (rankCell rank : Nat) (env : Env) (caller : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨returnNote .undef,blockFrameNote [pointerDeclaration,returnStatement] env::caller,
    notes.runtime.cells.write rankCell (rankRole rank)⟩

private theorem one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The result of the native ndim call initializes the real rank cell. Its
literal meaning decides the original nonzero branch in eleven transitions. -/
theorem rank_binding_nonzero_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (rankCell rank : Nat) (env : Env) (caller : List Frame) (declarationNote blockNote : Tree) (callerNotes : List Tree)
    (control : source.ctl = .ret (intV (Int.ofNat rank)))
    (stack : source.stack = .s (.decl .const (.id rankName) [] env)::
      .s (.block [guard,pointerDeclaration,returnStatement] env)::caller)
    (lookup : lookupEnv rankName env = some rankCell) (cell : source.heap.get rankCell = some (.cell none)) (rankLive : live rankCell)
    (controlNote : notes.runtime.control = returnNote (rankRole rank))
    (stackNotes : notes.runtime.stack = declarationNote::blockNote::callerNotes)
    (nonzero : F64.test .eq (F64.ofInt (Int.ofNat rank)) (F64.ofNat 0) = false)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result, runC F 11 source C₀ = some (guardResult source rankCell rank env caller,C₀) ∧
      runC F 11 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (guardResult source rankCell rank env caller) result ∧
      RetainedInventory (guardNotes notes rankCell rank env callerNotes) ν₀ ν C₀ C R live
        (guardResult source rankCell rank env caller) result ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  obtain ⟨_,_,l1,r1,h1,runtime1⟩ := inventory.runtime.declaration_value_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ state (intV (Int.ofNat rank)) (rankRole rank) .const (.id rankName) [] env
    (.s (.block [guard,pointerDeclaration,returnStatement] env)::caller) declarationNote (blockNote::callerNotes)
    control stack rfl controlNote stackNotes
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨_,l2,r2,h2,inv2⟩ := inv1.init_step h1 rankName env rankCell (intV (Int.ofNat rank)) none .const (rankRole rank)
    rfl lookup cell rfl sourceBound targetBound
  host_normalize_retained h2, inv2
  obtain ⟨_,l3,r3,h3,inv3⟩ := inv2.declaration_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 .undef .const [] env (.s (.block [guard,pointerDeclaration,returnStatement] env)::caller)
    (declarationNextNote .const [] env) (blockNote::callerNotes) rfl rfl rfl
  host_normalize_retained h3, inv3
  obtain ⟨_,l4,r4,h4,runtime4⟩ := inv3.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h3 .undef guard [pointerDeclaration,returnStatement] env caller blockNote callerNotes rfl rfl rfl
  have pure4 := PureRuntimeCase.blockNext h3 .undef guard [pointerDeclaration,returnStatement] env caller rfl rfl
  have effects4 := pure4.effects l4 r4
  have inv4 := inv3.pure_step runtime4 pure4 l4 r4 (.refl C₀) (.refl C)
  host_normalize_retained h4, inv4
  obtain ⟨l5,r5,h5,runtime5⟩ := inv4.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h4 (.ifTest (.bin .seq (.id rankName) zero) (.ret (some (.array []))) none) env rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h5, inv5
  obtain ⟨l6,r6,h6,runtime6⟩ := inv5.runtime.binary_descent_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h5 .seq (.id rankName) zero env rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h6, inv6
  have initialized : ((source.setCell rankCell (intV (Int.ofNat rank))).heap).get rankCell =
      some (.cell (some (intV (Int.ofNat rank)))) := by
    rw [St.setCell,PTrie.get_set_u64 _ _ _ (Nat.lt_of_lt_of_le (state.heap.sourceBound rankCell rankLive) sourceBound)]
    simp only [ite_true]
  obtain ⟨_,l7,r7,h7,runtime7⟩ := inv6.runtime.variable_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h6 rankName env rankCell (intV (Int.ofNat rank)) (rankRole rank) rfl lookup initialized
    (by change (notes.runtime.cells.write rankCell (rankRole rank)).cells rankCell = _; simp only [Notes.write,ite_true])
  have inv7 := inv6.heap_step runtime7 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h7, inv7
  let ifNote := (statementFrameNotes env (.ifTest (.bin .seq (.id rankName) zero) (.ret (some (.array []))) none)).headD callBoundaryNote
  let restNotes := ifNote::blockFrameNote [pointerDeclaration,returnStatement] env::callerNotes
  let rest := .s (.if_ (.ret (some (.array []))) none env)::.s (.block [pointerDeclaration,returnStatement] env)::caller
  obtain ⟨_,_,l8,r8,h8,runtime8,_⟩ := inv7.runtime.binary_left_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h7 (intV (Int.ofNat rank)) (rankRole rank) .seq zero env rest (binaryLeftNote .seq zero env) restNotes rfl rfl rfl rfl
  have inv8 := inv7.heap_step runtime8 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h8, inv8
  obtain ⟨l9,r9,h9,runtime9⟩ := inv8.runtime.literal_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h8 (.num chars!"0") (natV 0) env (.number _ _ rfl) rfl
  have inv9 := inv8.heap_step runtime9 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h9, inv9
  obtain ⟨_,l10,r10,h10,runtime10⟩ := inv9.runtime.comparison_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h9 .seq (.lit (F64.ofInt (Int.ofNat rank))) (.lit (F64.ofNat 0))
    (.lit (F64.ofInt (Int.ofNat rank))) (.lit (F64.ofNat 0)) (rankRole rank) (.literal (.lit (F64.ofNat 0)))
    (.literal _) (.literal _) rest restNotes rfl rfl rfl rfl false nonzero nonzero
  have inv10 := inv9.heap_step runtime10 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h10, inv10
  obtain ⟨_,l11,r11,h11,inv11⟩ := inv10.if_bool_step h10 false (.ret (some (.array []))) none env
    (.s (.block [pointerDeclaration,returnStatement] env)::caller) ifNote
    (blockFrameNote [pointerDeclaration,returnStatement] env::callerNotes) rfl rfl rfl
  have sl1 := one F _ _ C₀ (by rw [control]; rfl) l1
  have tr1 := one F _ _ C (state.control.isHalt_eq.trans (by rw [control]; rfl)) r1
  have sl2 := one F _ _ C₀ rfl l2
  have tr2 := one F _ _ C (h1.control.isHalt_eq.trans rfl) r2
  have sl3 := one F _ _ C₀ rfl l3
  have tr3 := one F _ _ C (h2.control.isHalt_eq.trans rfl) r3
  have sl4 := one F _ _ C₀ rfl l4
  have tr4 := one F _ _ C (h3.control.isHalt_eq.trans rfl) r4
  have sl5 := one F _ _ C₀ rfl l5
  have tr5 := one F _ _ C (h4.control.isHalt_eq.trans rfl) r5
  have sl6 := one F _ _ C₀ rfl l6
  have tr6 := one F _ _ C (h5.control.isHalt_eq.trans rfl) r6
  have sl7 := one F _ _ C₀ rfl l7
  have tr7 := one F _ _ C (h6.control.isHalt_eq.trans rfl) r7
  have sl8 := one F _ _ C₀ rfl l8
  have tr8 := one F _ _ C (h7.control.isHalt_eq.trans rfl) r8
  have sl9 := one F _ _ C₀ rfl l9
  have tr9 := one F _ _ C (h8.control.isHalt_eq.trans rfl) r9
  have sl10 := one F _ _ C₀ rfl l10
  have tr10 := one F _ _ C (h9.control.isHalt_eq.trans rfl) r10
  have sl11 := one F _ _ C₀ rfl l11
  have tr11 := one F _ _ C (h10.control.isHalt_eq.trans rfl) r11
  refine ⟨_,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
    (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F sl1 sl2) sl3) sl4) sl5) sl6) sl7) sl8) sl9) sl10) sl11,
    runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
    (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F tr1 tr2) tr3) tr4) tr5) tr6) tr7) tr8) tr9) tr10) tr11,
    h11,inv11,?_,?_⟩
  · exact effects4.2.native
  · exact effects4.2.next

end ShapeCall
end Host.Ts.Owned.Annotated
