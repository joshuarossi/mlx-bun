import host.ts.RenameRetainedMapperEntry
import host.ts.RenameRuntimeDescent
import host.ts.RenameRuntimeReturns
import host.ts.RenameRuntimePureCases

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

private theorem mapper_one (F : Ffi) (s t : St F.S) (C : CSrv)
    (active : isHalt s.ctl = false) (execution : interpC (step F s).run C = some (t,C)) :
    runC F 1 s C = some (t,C) := runC_cons F 0 s t t C C C active execution rfl

/-- Evaluate the mapper's lexical receiver with its retained object meaning.
The same two original transitions work for any initialized parameter cell. -/
theorem RetainedInventory.mapper_member_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (env : Env) (name field : Name) (cell owner : Nat)
    (control : s₀.ctl = .ev (.member (.id name) field false) env)
    (lookup : lookupEnv name env = some cell)
    (read : s₀.heap.get cell = some (.cell (some (.obj owner))))
    (entry : notes.runtime.cells.cells cell = some (.obj owner)) :
    ∃ result,
      runC F 2 s₀ C₀ = some ((s₀.push (.e (.member (.str field) false))).ret (.obj owner),C₀) ∧
      runC F 2 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.push (.e (.member (.str field) false))).ret (.obj owner)) result ∧
      RetainedInventory (notes.withRuntime ((notes.runtime.descent (.member (.id name) field false) env).returning (.obj owner)))
        ν₀ ν C₀ C R live ((s₀.push (.e (.member (.str field) false))).ret (.obj owner)) result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨left1,right1,h1,runtime1⟩ := inventory.runtime.descent_step F FR notes.runtime ν₀ ν C₀ C R
    live framed before after old old' s₀ s h (.member (.id name) field false) env control
  have inv1 := inventory.heap_step runtime1 rfl rfl (.refl C₀) (.refl C)
  obtain ⟨value,left2,right2,h2,runtime2⟩ := runtime1.variable_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' _ _ h1 name env cell (.obj owner) (.obj owner) rfl lookup read entry
  have inv2 := inv1.heap_step runtime2 rfl rfl (.refl C₀) (.refl C)
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  exact ⟨_,runC_join F (mapper_one F _ _ C₀ active left1) (mapper_one F _ _ C₀ rfl left2),
    runC_join F (mapper_one F _ _ C (h.control.isHalt_eq.trans active) right1) (mapper_one F _ _ C rfl right2),
    h2,inv2,rfl,rfl,rfl⟩

/-- An expression-bodied callback returns the selected fixed meaning through
its real explicit-return and function-boundary transitions. -/
theorem RetainedInventory.mapper_return_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : Val) (role : Value) (env : Env) (caller : List Frame)
    (retNote callNote : Tree) (callerNotes : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .s .ret :: .k (.fn .call) :: caller)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = retNote::callNote::callerNotes) :
    ∃ result,
      runC F 2 s₀ C₀ = some ({s₀ with ctl := .ret value,stack := caller},C₀) ∧
      runC F 2 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        {s₀ with ctl := .ret value,stack := caller} result ∧
      RetainedInventory (notes.withRuntime ⟨returnNote role,callerNotes,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live {s₀ with ctl := .ret value,stack := caller} result ∧
      result.heap = s.heap ∧ result.ffi = s.ffi ∧ result.next = s.next := by
  obtain ⟨s1,left1,right1,h1,runtime1⟩ := inventory.runtime.return_exit_step F FR _ ν₀ ν C₀ C R live
    framed before after old old' s₀ s h value role .explicitReturn env (.k (.fn .call)::caller)
    retNote (callNote::callerNotes) control stack controlNote stackNotes
  have pure1 := PureRuntimeCase.returnExit h value env .explicitReturn (.k (.fn .call)::caller) control stack
  have effects1 := pure1.effects left1 right1
  have inv1 := inventory.pure_step runtime1 pure1 left1 right1 (.refl C₀) (.refl C)
  obtain ⟨result,left2,right2,h2,runtime2⟩ := runtime1.return_unwind_step F FR _ ν₀ ν C₀ C R live
    framed before after old old' _ _ h1 value role .call env caller callNote callerNotes rfl rfl rfl rfl
  have pure2 := PureRuntimeCase.returnUnwind h1 value env .call caller rfl rfl
  have effects2 := pure2.effects left2 right2
  have inv2 := inv1.pure_step runtime2 pure2 left2 right2 (.refl C₀) (.refl C)
  have active : isHalt s₀.ctl = false := by rw [control]; rfl
  exact ⟨result,runC_join F (mapper_one F _ _ C₀ active left1) (mapper_one F _ _ C₀ rfl left2),
    runC_join F (mapper_one F _ _ C (h.control.isHalt_eq.trans active) right1)
      (mapper_one F _ _ C (h1.control.isHalt_eq.trans rfl) right2),h2,inv2,
    effects2.2.heap.trans effects1.2.heap,effects2.2.native.trans effects1.2.native,effects2.2.next.trans effects1.2.next⟩

def mapperReceiverSource {S : Type} (s : St S) (env : Env) (name field : Name)
    (receiver : Val) (owner : Nat) (extraArgs : List Val) : St S :=
  ((mapperEntrySource s env name field receiver owner extraArgs).push (.e (.member (.str field) false))).ret (.obj owner)

def RuntimeNotes.mapperReceiver (notes : RuntimeNotes) (env : Env) (name field : Name) (cell owner : Nat) : RuntimeNotes :=
  ((notes.mapperEntry env name field cell owner).descent (.member (.id name) field false) ((name,cell)::env)).returning (.obj owner)

/-- Closure entry, parameter initialization, and receiver evaluation are one
six-step callback contract. Every parameter-cell premise is discharged by the
preceding original allocation and store. -/
theorem RetainedInventory.mapper_receiver_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (callee owner : Nat) (object : Obj) (env : Env) (name field : Name) (receiver : Val)
    (fnRole thisRole : Value) (extraArgs : List Val) (extraRoles : List Value)
    (control : s₀.ctl = .call (.obj callee) receiver (.obj owner::extraArgs))
    (read : s₀.heap.get callee = some (.obj object))
    (kind : object.kind = .fn (.closure (mapperFunction name field) env true .undef))
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj owner::extraRoles))
    (sourceBound : s₀.next+3 ≤ 2^64) (targetBound : s.next+3 ≤ 2^64) :
    ∃ result,
      runC F 6 s₀ C₀ = some (mapperReceiverSource s₀ env name field receiver owner extraArgs,C₀) ∧
      runC F 6 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
        (ClosureLive live s₀.next true .undef (mapperFunction name field)) framed before after old old'
        (mapperReceiverSource s₀ env name field receiver owner extraArgs) result ∧
      RetainedInventory (notes.withRuntime (notes.runtime.mapperReceiver env name field s₀.next owner))
        ν₀ ν C₀ C R (ClosureLive live s₀.next true .undef (mapperFunction name field))
        (mapperReceiverSource s₀ env name field receiver owner extraArgs) result ∧
      result.ffi = s.ffi ∧ result.next = s.next+1 ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨s4,left4,right4,h4,inv4,ffi4,next4,heap4⟩ := inventory.mapper_entry_block h
    callee owner object env name field receiver fnRole thisRole extraArgs extraRoles control read kind controlNote sourceBound targetBound
  have parameterRead : (mapperEntrySource s₀ env name field receiver owner extraArgs).heap.get s₀.next =
      some (.cell (some (.obj owner))) := by
    have word : s₀.next < 2^64 := by omega
    change ((s₀.heap.set s₀.next (.cell none)).set s₀.next (.cell (some (.obj owner)))).get s₀.next = _
    rw [PTrie.get_set_u64 _ _ _ word]
    simp
  obtain ⟨result,left6,right6,h6,inv6,heap6,ffi6,next6⟩ := inv4.mapper_member_block h4
    (mapperEnvironment s₀ env name) name field s₀.next owner rfl
    (by simp [mapperEnvironment,lookupEnv,brec]) parameterRead (by simp [RetainedNotes.withRuntime,RuntimeNotes.mapperEntry,Notes.write])
  exact ⟨result,runC_join F left4 left6,runC_join F right4 right6,h6,inv6,
    ffi6.trans ffi4,next6.trans next4,fun a below => (congrArg (fun heap : PTrie HObj => heap.get a) heap6).trans (heap4 a below)⟩

end Host.Ts.Owned.Annotated
