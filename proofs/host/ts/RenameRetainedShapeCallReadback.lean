import host.ts.RenameRetainedShapeCallGuard
import host.ts.RenameRetainedArraySpreadEntry
import host.ts.RenameRuntimeArithmetic

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric
namespace ShapeCall

def byteCount (rank : Nat) : F64 := F64.bin .mul (F64.ofInt (Int.ofNat rank)) (F64.ofNat 4)
def byteMeaning (rank : Nat) : SymE := .bin .mul (.lit (F64.ofInt (Int.ofNat rank))) (.lit (F64.ofNat 4))
theorem byteMeaning_closed (rank : Nat) (valuation : Nat → F64) : (byteMeaning rank).eval valuation = byteCount rank := rfl
def readbackResult {S : Type} (source : St S) (pointerCell handle rank typedFn bufferFn : Nat)
    (env : Env) (caller : List Frame) : St S :=
  {(source.setCell pointerCell (.ptr (.ext (4*handle)) 0)) with
    ctl := .call (.obj bufferFn) .undef [.ptr (.ext (4*handle)) 0,.num (.lit (F64.zero false)),.num (.lit (byteCount rank))],
    stack := (.c (.args 1 (.obj typedFn) .undef [] [] env)::.l (.spread [] [] env)::.s .ret::.s (.block [] env)::caller)}
def readbackNotes (notes : RetainedNotes) (pointerCell handle rank typedFn bufferFn : Nat)
    (env : Env) (caller : List Tree) : RetainedNotes :=
  notes.withRuntime ⟨callNote (.obj bufferFn) .undef [.ptr (.ext (4*handle)) 0,.literal (.lit (F64.zero false)),.literal (byteMeaning rank)],
    argumentFrameNote false 1 (.obj typedFn) .undef [] [] env::arraySpreadFrameNote [] [] env::
      (statementFrameNotes env (.returnExpression resultExpression)).headD callBoundaryNote::blockFrameNote [] env::caller,
    notes.runtime.cells.write pointerCell (.ptr (.ext (4*handle)) 0)⟩

private theorem one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The original pointer declaration and array/constructor/call scheduling
derive the concrete ABI byte count from the retained rank meaning. No buffer,
typed view, target operand or later annotation is a premise. -/
theorem pointer_readback_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (pointerCell rankCell handle rank typedFn bufferCell bufferFn : Nat) (global : Obj) (w e : Bool)
    (env : Env) (caller : List Frame) (declarationNote blockNote : Tree) (callerNotes : List Tree)
    (control : source.ctl = .ret (.ptr (.ext (4*handle)) 0))
    (stack : source.stack = .s (.decl .const (.id pointerName) [] env)::.s (.block [returnStatement] env)::caller)
    (pointerLookup : lookupEnv pointerName env = some pointerCell) (pointerRead : source.heap.get pointerCell = some (.cell none))
    (pointerLive : live pointerCell)
    (rankLookup : lookupEnv rankName env = some rankCell) (rankRead : source.heap.get rankCell = some (.cell (some (intV (Int.ofNat rank)))))
    (rankNote : notes.runtime.cells.cells rankCell = some (rankRole rank))
    (typedLookup : lookupEnv typedName env = none) (globalRead : source.heap.get aGlobal = some (.obj global))
    (globalKind : global.kind = .ordinary) (typedProperty : findProp (.str typedName) global.props = some (.data (.obj typedFn) w e))
    (bufferLookup : lookupEnv bufferName env = some bufferCell) (bufferRead : source.heap.get bufferCell = some (.cell (some (.obj bufferFn))))
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (controlNote : notes.runtime.control = returnNote (.ptr (.ext (4*handle)) 0))
    (stackNotes : notes.runtime.stack = declarationNote::blockNote::callerNotes)
    (sourceBound : source.next ≤ 2^64) (targetBound : target.next ≤ 2^64) :
    ∃ result, runC F 22 source C₀ = some (readbackResult source pointerCell handle rank typedFn bufferFn env caller,C₀) ∧
      runC F 22 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (readbackResult source pointerCell handle rank typedFn bufferFn env caller) result ∧
      RetainedInventory (readbackNotes notes pointerCell handle rank typedFn bufferFn env callerNotes) ν₀ ν C₀ C R live
        (readbackResult source pointerCell handle rank typedFn bufferFn env caller) result ∧ result.ffi = target.ffi ∧ result.next = target.next := by
  let pointer := Val.ptr (.ext (4*handle)) 0
  let role := Value.ptr (.ext (4*handle)) 0
  have pointerWord : pointerCell < 2^64 := Nat.lt_of_lt_of_le (state.heap.sourceBound pointerCell pointerLive) sourceBound
  have frame : ∀ a, a ≠ pointerCell → (source.setCell pointerCell pointer).heap.get a = source.heap.get a := by
    intro a different
    rw [St.setCell,PTrie.get_set_u64 _ _ _ pointerWord]
    simp only [different,ite_false]
  have globalDifferent : aGlobal ≠ pointerCell := by intro same; rw [same,pointerRead] at globalRead; cases globalRead
  have bufferDifferent : bufferCell ≠ pointerCell := by intro same; rw [same,pointerRead] at bufferRead; cases bufferRead
  have rankDifferent : rankCell ≠ pointerCell := by intro same; rw [same,pointerRead] at rankRead; cases rankRead
  obtain ⟨_,_,l1,r1,h1,runtime1⟩ := inventory.runtime.declaration_value_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ state pointer role .const (.id pointerName) [] env (.s (.block [returnStatement] env)::caller)
    declarationNote (blockNote::callerNotes) control stack rfl controlNote stackNotes
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h1, inv1
  obtain ⟨_,l2,r2,h2,inv2⟩ := inv1.init_step h1 pointerName env pointerCell pointer none .const role
    rfl pointerLookup pointerRead rfl sourceBound targetBound
  host_normalize_retained h2, inv2
  obtain ⟨_,l3,r3,h3,inv3⟩ := inv2.declaration_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h2 .undef .const [] env (.s (.block [returnStatement] env)::caller) (declarationNextNote .const [] env)
    (blockNote::callerNotes) rfl rfl rfl
  host_normalize_retained h3, inv3
  obtain ⟨_,l4,r4,h4,runtime4⟩ := inv3.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h3 .undef returnStatement [] env caller blockNote callerNotes rfl rfl rfl
  have pure4 := PureRuntimeCase.blockNext h3 .undef returnStatement [] env caller rfl rfl
  have effects4 := pure4.effects l4 r4
  have inv4 := inv3.pure_step runtime4 pure4 l4 r4 (.refl C₀) (.refl C)
  host_normalize_retained h4, inv4
  obtain ⟨l5,r5,h5,runtime5⟩ := inv4.runtime.statement_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h4 (.returnExpression resultExpression) env rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h5, inv5
  obtain ⟨l6,r6,h6,inv6⟩ := inv5.array_spread_entry_step h5 (.new (.id typedName) typedArgs) [] env rfl
  host_normalize_retained h6, inv6
  obtain ⟨l7,r7,h7,runtime7⟩ := inv6.runtime.descent_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h6 (.construct (.id typedName) typedArgs) env rfl
  have inv7 := inv6.heap_step runtime7 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h7, inv7
  obtain ⟨l8,r8,h8,inv8⟩ := inv7.ndim_global_object_step h7 typedName env global typedFn w e rfl typedLookup
    ((frame aGlobal globalDifferent).trans globalRead) globalKind typedProperty globalLive globalFixed
  host_normalize_retained h8, inv8
  let retNote := (statementFrameNotes env (.returnExpression resultExpression)).headD callBoundaryNote
  let retFrames := .l (.spread [] [] env)::.s .ret::.s (.block [] env)::caller
  let retNotes := arraySpreadFrameNote [] [] env::retNote::blockFrameNote [] env::callerNotes
  obtain ⟨_,_,l9,r9,h9,runtime9⟩ := inv8.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h8 .construct typedFn .undef .undef typedArgs env retFrames retNotes rfl rfl rfl
  have inv9 := inv8.heap_step runtime9 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h9, inv9
  obtain ⟨l10,r10,h10,runtime10⟩ := inv9.runtime.call_entry_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h9 (.identifier bufferName) bufferArgs false env rfl
  have inv10 := inv9.heap_step runtime10 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h10, inv10
  obtain ⟨l11,r11,h11,inv11⟩ := inv10.variable_object_step h10 bufferName env bufferCell bufferFn rfl bufferLookup
    ((frame bufferCell bufferDifferent).trans bufferRead)
  host_normalize_retained h11, inv11
  let ctorFrames := .c (.args 1 (.obj typedFn) .undef [] [] env)::retFrames
  let ctorNotes := argumentFrameNote false 1 (.obj typedFn) .undef [] [] env::retNotes
  obtain ⟨_,_,l12,r12,h12,runtime12⟩ := inv11.runtime.call_start_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h11 (.callee false) bufferFn .undef .undef bufferArgs env ctorFrames ctorNotes rfl rfl rfl
  have inv12 := inv11.heap_step runtime12 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h12, inv12
  have pointerInitialized : (source.setCell pointerCell pointer).heap.get pointerCell = some (.cell (some pointer)) := by
    rw [St.setCell,PTrie.get_set_u64 _ _ _ pointerWord]; simp only [ite_true]
  obtain ⟨_,l13,r13,h13,runtime13⟩ := inv12.runtime.variable_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h12 pointerName env pointerCell pointer role rfl pointerLookup pointerInitialized
    (by change (notes.runtime.cells.write pointerCell role).cells pointerCell = _; simp only [Notes.write,ite_true])
  have inv13 := inv12.heap_step runtime13 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h13, inv13
  obtain ⟨_,_,_,_,_,l14,r14,h14,runtime14⟩ := inv13.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h13 pointer role (.obj bufferFn) .undef [] 0 (.obj bufferFn) .undef [] [.expr zero,.expr countExpression] env
    ctorFrames ctorNotes rfl rfl (by decide) rfl rfl
  have inv14 := inv13.heap_step runtime14 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h14, inv14
  obtain ⟨l15,r15,h15,runtime15⟩ := inv14.runtime.literal_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h14 (.num chars!"0") (natV 0) env (.number _ _ rfl) rfl
  have inv15 := inv14.heap_step runtime15 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h15, inv15
  obtain ⟨_,_,_,_,_,l16,r16,h16,runtime16⟩ := inv15.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h15 (natV 0) (.literal (.lit (F64.ofNat 0))) (.obj bufferFn) .undef [role] 0 (.obj bufferFn) .undef [pointer] [.expr countExpression] env
    ctorFrames ctorNotes rfl rfl (by decide) rfl rfl
  have inv16 := inv15.heap_step runtime16 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h16, inv16
  obtain ⟨l17,r17,h17,runtime17⟩ := inv16.runtime.binary_descent_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h16 .mul (.id rankName) four env rfl
  have inv17 := inv16.heap_step runtime17 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h17, inv17
  obtain ⟨_,l18,r18,h18,runtime18⟩ := inv17.runtime.variable_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h17 rankName env rankCell (intV (Int.ofNat rank)) (rankRole rank) rfl rankLookup ((frame rankCell rankDifferent).trans rankRead)
    (by
      change (notes.runtime.cells.write pointerCell role).cells rankCell = _
      simpa only [Notes.write,rankDifferent,ite_false] using rankNote)
  have inv18 := inv17.heap_step runtime18 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h18, inv18
  let countFrames := .c (.args 0 (.obj bufferFn) .undef [natV 0,pointer] [] env)::ctorFrames
  let countNotes := argumentFrameNote false 0 (.obj bufferFn) .undef [.literal (.lit (F64.ofNat 0)),role] [] env::ctorNotes
  obtain ⟨_,_,l19,r19,h19,runtime19,_⟩ := inv18.runtime.binary_left_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h18 (intV (Int.ofNat rank)) (rankRole rank) .mul four env countFrames (binaryLeftNote .mul four env) countNotes rfl rfl rfl rfl
  have inv19 := inv18.heap_step runtime19 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h19, inv19
  obtain ⟨l20,r20,h20,runtime20⟩ := inv19.runtime.literal_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h19 (.num chars!"4") (natV 4) env (.number _ _ rfl) rfl
  have inv20 := inv19.heap_step runtime20 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h20, inv20
  obtain ⟨_,_,_,l21,r21,h21,runtime21,_⟩ := inv20.runtime.literal_arithmetic_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h20 .mul (F64.ofInt (Int.ofNat rank)) (F64.ofNat 4) (.lit (F64.ofInt (Int.ofNat rank))) (.lit (F64.ofNat 4))
    countFrames countNotes rfl rfl rfl rfl
  have inv21 := inv20.heap_step runtime21 rfl rfl (.refl C₀) (.refl C)
  host_normalize_retained h21, inv21
  obtain ⟨_,_,_,_,_,l22,r22,h22,runtime22⟩ := inv21.runtime.argument_step F FR _ ν₀ ν C₀ C R live framed before after old old'
    _ _ h21 (.num (.lit (byteCount rank))) (.literal (byteMeaning rank)) (.obj bufferFn) .undef
    [.literal (.lit (F64.ofNat 0)),role] 0 (.obj bufferFn) .undef [natV 0,pointer] [] env ctorFrames ctorNotes rfl rfl (by decide) rfl rfl
  have inv22 := inv21.heap_step runtime22 rfl rfl (.refl C₀) (.refl C)
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
  have sl12 := one F _ _ C₀ rfl l12
  have tr12 := one F _ _ C (h11.control.isHalt_eq.trans rfl) r12
  have sl13 := one F _ _ C₀ rfl l13
  have tr13 := one F _ _ C (h12.control.isHalt_eq.trans rfl) r13
  have sl14 := one F _ _ C₀ rfl l14
  have tr14 := one F _ _ C (h13.control.isHalt_eq.trans rfl) r14
  have sl15 := one F _ _ C₀ rfl l15
  have tr15 := one F _ _ C (h14.control.isHalt_eq.trans rfl) r15
  have sl16 := one F _ _ C₀ rfl l16
  have tr16 := one F _ _ C (h15.control.isHalt_eq.trans rfl) r16
  have sl17 := one F _ _ C₀ rfl l17
  have tr17 := one F _ _ C (h16.control.isHalt_eq.trans rfl) r17
  have sl18 := one F _ _ C₀ rfl l18
  have tr18 := one F _ _ C (h17.control.isHalt_eq.trans rfl) r18
  have sl19 := one F _ _ C₀ rfl l19
  have tr19 := one F _ _ C (h18.control.isHalt_eq.trans rfl) r19
  have sl20 := one F _ _ C₀ rfl l20
  have tr20 := one F _ _ C (h19.control.isHalt_eq.trans rfl) r20
  have sl21 := one F _ _ C₀ rfl l21
  have tr21 := one F _ _ C (h20.control.isHalt_eq.trans rfl) r21
  have sl22 := one F _ _ C₀ rfl l22
  have tr22 := one F _ _ C (h21.control.isHalt_eq.trans rfl) r22
  exact ⟨_,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (sl1) sl2) sl3) sl4) sl5) sl6) sl7) sl8) sl9) sl10) sl11) sl12) sl13) sl14) sl15) sl16) sl17) sl18) sl19) sl20) sl21) sl22,runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (tr1) tr2) tr3) tr4) tr5) tr6) tr7) tr8) tr9) tr10) tr11) tr12) tr13) tr14) tr15) tr16) tr17) tr18) tr19) tr20) tr21) tr22,h22,inv22,effects4.2.native,effects4.2.next⟩

end ShapeCall
end Host.Ts.Owned.Annotated
