import host.ts.RenameRetainedGetterReturn
import host.ts.RenameRetainedClosedComparison
import host.ts.RenameRuntimeDescent
import host.ts.RenameRuntimePureCases

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

def outArraySuccessStatements (status handle : Name) (failure : Stmt) : List Stmt :=
  [.if_ (.bin .sne (.id status) (.lit (.num ['0']))) failure none,.ret (some (.id handle))]

private theorem outArray_one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- The successful `outArray` suffix consumes its current status and handle
cell meanings. It evaluates the original strict comparison, skips the error
branch, reads the handle, and resumes the caller in fifteen real transitions.
Heaps, environments, handles, callers and fresh counters are arbitrary. -/
theorem RetainedInventory.outArray_success_return
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (statusName handleName : Name) (statusCell handleCell : Nat)
    (failure : Stmt) (value : Val) (role : Value) (caller : List Frame)
    (blockNote scopeNote callNote : Tree) (callerNotes : List Tree)
    (control : s₀.ctl = .ret .undef)
    (stack : s₀.stack = .s (.block (outArraySuccessStatements statusName handleName failure) env)::
      .s (.scope [])::.k (.fn .call)::caller)
    (statusLookup : lookupEnv statusName env = some statusCell)
    (handleLookup : lookupEnv handleName env = some handleCell)
    (statusRead : s₀.heap.get statusCell = some (.cell (some (.num (.lit (.zero false))))))
    (handleRead : s₀.heap.get handleCell = some (.cell (some value)))
    (statusNote : notes.runtime.cells.cells statusCell = some (.literal (.lit (.zero false))))
    (handleNote : notes.runtime.cells.cells handleCell = some role)
    (stackNotes : notes.runtime.stack = blockNote::scopeNote::callNote::callerNotes) :
    ∃ result,
      runC F 15 s₀ C₀ = some ({s₀ with ctl := .ret value,stack := caller},C₀) ∧
      runC F 15 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret value,stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret value,stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  let test := Expr.bin .sne (.id statusName) (.lit (.num ['0']))
  let done := Stmt.ret (some (.id handleName))
  let fs := Frame.s (.scope [])::Frame.k (.fn .call)::caller
  let ns := scopeNote::callNote::callerNotes
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' s₀ s h .undef (.if_ test failure none) [done] env fs blockNote ns control stack stackNotes
  have pure1 := PureRuntimeCase.blockNext h .undef (.if_ test failure none) [done] env fs control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  obtain ⟨left2,right2,h2,runtime2⟩ := runtime1.statement_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h1 (.ifTest test failure none) env rfl
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨left3,right3,h3,runtime3⟩ := runtime2.descent_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h2 (.binary .sne (.id statusName) (.lit (.num ['0']))) env rfl
  have inv3 := inv2.heap_step runtime3 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨status,left4,right4,h4,runtime4⟩ := runtime3.variable_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h3 statusName env statusCell (.num (.lit (.zero false)))
    (.literal (.lit (.zero false))) rfl statusLookup statusRead statusNote
  have inv4 := inv3.heap_step runtime4 rfl rfl (.refl C₀) (.refl C)
  let tails := Frame.s (.if_ failure none env)::Frame.s (.block [done] env)::fs
  let tailNotes := (statementFrameNotes env (.ifTest test failure none)).headD (.node "" [])::blockFrameNote [done] env::ns
  obtain ⟨_,_,left5,right5,h5,runtime5,_⟩ := runtime4.binary_left_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h4 (.num (.lit (.zero false))) (.literal (.lit (.zero false)))
    .sne (.lit (.num ['0'])) env tails (binaryLeftNote .sne (.lit (.num ['0'])) env) tailNotes rfl rfl rfl rfl
  have inv5 := inv4.heap_step runtime5 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨left6,right6,h6,runtime6⟩ := runtime5.literal_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h5 (.num ['0']) (.num (.lit (.zero false))) env (.number ['0'] (.zero false) rfl) rfl
  have inv6 := inv5.heap_step runtime6 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,left7,right7,h7,inv7⟩ := inv6.closed_literal_comparison_step h6 .sne (.zero false) (.zero false)
    (.lit (.zero false)) (.lit (.zero false)) tails tailNotes rfl rfl rfl rfl rfl rfl
  have pure7 := PureRuntimeCase.comparison h6 .sne (.lit (.zero false)) (.lit (.zero false)) tails rfl rfl
  have effects7 := pure7.effects left7 right7
  simp only [RetainedNotes.withRuntime,RuntimeNotes.binaryResult,RuntimeNotes.binaryLeft,
    RuntimeNotes.returning,RuntimeNotes.descent,RuntimeNotes.statement,RuntimeNotes.blockNext,
    statementFrameNotes,statementControlNote,descentFrameNote,List.cons_append,List.nil_append] at inv7
  let source7 : St F.S := {s₀ with ctl := .ret (.bool false),stack := tails}
  change Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source7 _ at h7
  change RetainedInventory (notes.withRuntime ⟨returnNote (.bool false),tailNotes,notes.runtime.cells⟩)
    ν₀ ν C₀ C R live source7 _ at inv7
  obtain ⟨_,left8,right8,h8,inv8⟩ := inv7.if_bool_step h7 false failure none env
    (Frame.s (.block [done] env)::fs) (tailNotes.headD (.node "" [])) (blockFrameNote [done] env::ns) rfl rfl rfl
  obtain ⟨s9,left9,right9,h9,runtime9⟩ := inv8.runtime.block_next_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h8 .undef done [] env fs (blockFrameNote [done] env) ns rfl rfl rfl
  have pure9 := PureRuntimeCase.blockNext h8 .undef done [] env fs rfl rfl
  have effects9 := pure9.effects left9 right9
  have inv9 := inv8.pure_step runtime9 pure9 left9 right9 (.refl C₀) (.refl C)
  obtain ⟨left10,right10,h10,runtime10⟩ := runtime9.statement_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h9 (.returnExpression (.id handleName)) env rfl
  have inv10 := inv9.heap_step runtime10 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨_,left11,right11,h11,runtime11⟩ := runtime10.variable_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h10 handleName env handleCell value role rfl handleLookup handleRead handleNote
  have inv11 := inv10.heap_step runtime11 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨result,left15,right15,h15,inv15,heap15,ffi15,next15,_⟩ := inv11.getter_return_block h11
    value role env caller (.node "Frame.s" [.node "StmtF.ret" []]) (blockFrameNote [] env)
    scopeNote callNote callerNotes rfl rfl rfl rfl
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  have source1 := outArray_one F _ _ C₀ active left1
  have target1 := outArray_one F _ _ C (h.control.isHalt_eq.trans active) right1
  have source2 := outArray_one F _ _ C₀ rfl left2
  have target2 := outArray_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2
  have source3 := outArray_one F _ _ C₀ rfl left3
  have target3 := outArray_one F _ _ C (h2.control.isHalt_eq.trans rfl) right3
  have source4 := outArray_one F _ _ C₀ rfl left4
  have target4 := outArray_one F _ _ C (h3.control.isHalt_eq.trans rfl) right4
  have source5 := outArray_one F _ _ C₀ rfl left5
  have target5 := outArray_one F _ _ C (h4.control.isHalt_eq.trans rfl) right5
  have source6 := outArray_one F _ _ C₀ rfl left6
  have target6 := outArray_one F _ _ C (h5.control.isHalt_eq.trans rfl) right6
  have source7 := outArray_one F _ _ C₀ rfl left7
  have target7 := outArray_one F _ _ C (h6.control.isHalt_eq.trans rfl) right7
  have source8 := outArray_one F _ _ C₀ rfl left8
  have target8 := outArray_one F _ _ C (h7.control.isHalt_eq.trans rfl) right8
  have source9 := outArray_one F _ _ C₀ rfl left9
  have target9 := outArray_one F _ _ C (h8.control.isHalt_eq.trans rfl) right9
  have source10 := outArray_one F _ _ C₀ rfl left10
  have target10 := outArray_one F _ _ C (h9.control.isHalt_eq.trans rfl) right10
  have source11 := outArray_one F _ _ C₀ rfl left11
  have target11 := outArray_one F _ _ C (h10.control.isHalt_eq.trans rfl) right11
  refine ⟨result,?_,?_,h15,?_,?_,?_,?_⟩
  · exact runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
      (runC_join F (runC_join F (runC_join F (runC_join F source1 source2) source3) source4) source5) source6) source7) source8) source9) source10) (runC_join F source11 left15)
  · exact runC_join F (runC_join F (runC_join F (runC_join F (runC_join F (runC_join F
      (runC_join F (runC_join F (runC_join F (runC_join F target1 target2) target3) target4) target5) target6) target7) target8) target9) target10) (runC_join F target11 right15)
  · exact inv15
  · exact heap15.trans (effects9.2.heap.trans (effects7.2.heap.trans effects1.2.heap))
  · exact ffi15.trans (effects9.2.native.trans (effects7.2.native.trans effects1.2.native))
  · exact next15.trans (effects9.2.next.trans (effects7.2.next.trans effects1.2.next))

end Host.Ts.Owned.Annotated
