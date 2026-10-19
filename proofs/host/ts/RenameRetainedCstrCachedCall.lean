import host.ts.RenameCstrCallData
import host.ts.RenameRetainedCstrCachedBody

set_option Elab.async false
set_option maxHeartbeats 1000000
set_option maxRecDepth 100000
namespace Host.Ts.Owned.Annotated
open Parametric

noncomputable def cstrCallResult {S : Type} (source : St S) (env : Env) (receiver : Val)
    (key : Name) (buffer : Nat) : St S :=
  cstrBodyResult (cstrEntry source env receiver key) (source.next+2) buffer source.stack

noncomputable def cstrCallNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env)
    (receiver : Val) (key : Name) (buffer : Nat) (thisRole : Value) : RetainedNotes :=
  cstrBodyNotes (singleArgumentEntryNotes notes source (some chars!"cstr") chars!"s" cstrStatements
    env receiver (.str key) (.str key) thisRole) (source.next+2) buffer notes.runtime.stack

/-- The entire original cached cstr invocation: receiver, parameter and local
allocation, Map lookup, cached guard and return to the incoming caller.
Only the initial captured cache is assumed; all intermediate and target
resources are derived from current ownership and the original 29 steps. -/
theorem RetainedInventory.cstr_cached_call
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address : Nat) (function : Obj) (env : Env) (receiver : Val) (key : Name) (buffer : Nat)
    (current : CstrCacheBefore source env key buffer)
    (control : source.ctl = .call (.obj address) receiver [.str key])
    (read : source.heap.get address = some (.obj function))
    (kind : function.kind = .fn (.closure cstrFunction env false .undef))
    (fnRole thisRole : Value) (controlNote : notes.runtime.control = callNote fnRole thisRole [.str key])
    (sourceBound : source.next+4 ≤ 2^64) (targetBound : target.next+4 ≤ 2^64) :
    let reachedLive := CellsLive (ClosureLive live source.next false .undef cstrFunction) (source.next+2) [chars!"b"]
    ∃ result,
      runC F 29 source C₀ = some (cstrCallResult source env receiver key buffer,C₀) ∧
      runC F 29 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R reachedLive framed before after old old'
        (cstrCallResult source env receiver key buffer) result ∧
      RetainedInventory (cstrCallNotes notes source env receiver key buffer thisRole)
        ν₀ ν C₀ C R reachedLive (cstrCallResult source env receiver key buffer) result := by
  dsimp only
  have functionLive : live address := by
    have supported := h.controlLive
    rw [control] at supported
    exact supported.1
  obtain ⟨_,_,_,functionSupport⟩ := h.heap.readObject address function functionLive
    (h.heap.function_notFramed address function _ functionLive read kind) read
  have kindSupport := functionSupport.1
  rw [kind] at kindSupport
  have envLive : treeSupport live (Encode.env env) := kindSupport.1.2.1
  obtain ⟨bodyData⟩ := current.entry h.heap envLive receiver (by omega)
  obtain ⟨targetBody,left4,right4,h4,inv4⟩ := inventory.single_argument_entry h address function
    (some chars!"cstr") chars!"s" cstrStatements env receiver (.str key) (.str key) fnRole thisRole
    control read kind controlNote cstr_no_functions
    (by simpa only [cstr_block_names,List.length_cons,List.length_nil] using sourceBound)
    (by simpa only [cstr_block_names,List.length_cons,List.length_nil] using targetBound)
  have targetNext : targetBody.next = target.next+3 := by
    have first := h4.heap.fresh 0
    have second := h.heap.fresh 3
    change R.a ((cstrEntry source env receiver key).next+0) = targetBody.next+0 at first
    simp only [Nat.add_zero,cstr_entry_next] at first
    exact first.symm.trans second
  obtain ⟨result,left25,right25,post,retained,_,_⟩ := inv4.cstr_cached_body_from_source h4
    (cstrEntryEnv source env) source.stack key (source.next+2) buffer bodyData
    (cstr_entry_control source env receiver key) (cstr_entry_stack source env receiver key)
    (blockFrameNote cstrStatements (cstrEntryEnv source env)) emptyScopeNote callBoundaryNote notes.runtime.stack rfl
    (by change (cstrEntry source env receiver key).next ≤ 2^64; rw [cstr_entry_next]; omega)
    (by rw [targetNext]; omega)
  exact ⟨result,runC_join F left4 left25,runC_join F right4 right25,post,retained⟩

end Host.Ts.Owned.Annotated
