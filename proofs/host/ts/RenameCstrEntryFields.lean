import host.ts.RenameRetainedSingleArgumentEntry
import host.ts.RenameCstrCachedData

set_option Elab.async false
set_option maxHeartbeats 1000000
set_option maxRecDepth 100000
namespace Host.Ts.Owned.Annotated
open Parametric

noncomputable def cstrEntry {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name) : St S :=
  singleArgumentEntry source (some chars!"cstr") chars!"s" cstrStatements env receiver (.str key)

def cstrEntryEnv {S : Type} (source : St S) (env : Env) : Env :=
  (chars!"b",source.next+2)::(chars!"s",source.next+1)::(nThis,source.next)::env

theorem cstr_block_names : blockNames cstrStatements = [chars!"b"] := rfl
theorem cstr_no_functions : noInitFunctions cstrStatements = true := rfl

theorem cstr_entry_control {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name) :
    (cstrEntry source env receiver key).ctl = .ret .undef := rfl

theorem cstr_entry_stack {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name) :
    (cstrEntry source env receiver key).stack =
      .s (.block cstrStatements (cstrEntryEnv source env))::.s (.scope [])::.k (.fn .call)::source.stack := rfl

theorem cstr_entry_next {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name) :
    (cstrEntry source env receiver key).next = source.next+3 := by
  change source.next+1+1+1 = source.next+3
  omega

theorem cstr_entry_heap {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name) :
    (cstrEntry source env receiver key).heap =
      ((((source.heap.set source.next (.cell (some receiver))).set (source.next+1) (.cell none)).set
        (source.next+1) (.cell (some (.str key)))).set (source.next+2) (.cell none)) := rfl

theorem cstr_entry_heap_below {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name)
    (address : Nat) (below : address < source.next) (bound : source.next+3 ≤ 2^64) :
    (cstrEntry source env receiver key).heap.get address = source.heap.get address := by
  rw [cstr_entry_heap]
  simp only [PTrie.get_set_u64 _ _ _ (show source.next+2 < 2^64 by omega),
    PTrie.get_set_u64 _ _ _ (show source.next+1 < 2^64 by omega),
    PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega),
    ite_eq_right (show address ≠ source.next+2 by omega),
    ite_eq_right (show address ≠ source.next+1 by omega),
    ite_eq_right (show address ≠ source.next by omega)]

theorem cstr_entry_parameter {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name)
    (bound : source.next+3 ≤ 2^64) :
    (cstrEntry source env receiver key).heap.get (source.next+1) = some (.cell (some (.str key))) := by
  rw [cstr_entry_heap]
  simp only [PTrie.get_set_u64 _ _ _ (show source.next+2 < 2^64 by omega),
    PTrie.get_set_u64 _ _ _ (show source.next+1 < 2^64 by omega),
    ite_eq_right (show source.next+1 ≠ source.next+2 by omega),ite_true]

theorem cstr_entry_local {S : Type} (source : St S) (env : Env) (receiver : Val) (key : Name)
    (bound : source.next+3 ≤ 2^64) :
    (cstrEntry source env receiver key).heap.get (source.next+2) = some (.cell none) := by
  rw [cstr_entry_heap,PTrie.get_set_u64 _ _ _ (by omega)]
  simp only [ite_true]

end Host.Ts.Owned.Annotated
