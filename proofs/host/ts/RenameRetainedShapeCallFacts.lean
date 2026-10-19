import host.ts.RenameRetainedShapeCallEntry
import host.ts.RenameTwoParameterEntryFields

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.ShapeCall
open Parametric

theorem entry_next {S : Type} (source : St S) (env : Env) (home : Val) (owner getter : Nat) :
    (entry source env home owner getter).next = (closure source env home owner).next+2 := by
  change (closure source env home owner).next+1+1 = _
  omega
theorem entry_counter_le {S : Type} (source : St S) (env : Env) (home : Val) (owner getter : Nat) :
    (entry source env home owner getter).next ≤ source.next+4 := by
  rw [entry_next]
  have room := closure_room source env home (.obj owner) []
  change (closure source env home owner).next ≤ source.next+2 at room
  omega
theorem closure_counter_gt {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    source.next < (closure source env home owner).next := by
  cases home <;> first
    | change source.next < source.next+1; omega
    | change source.next < source.next+1+1; omega
theorem entry_environment {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    bodyEnv source env home owner = (pointerName,(closure source env home owner).next+1)::
      (rankName,(closure source env home owner).next)::lexicalEnv source env home owner := rfl
theorem entry_environment_other {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) (name : Name)
    (pointer : nameEq name pointerName = false) (rank : nameEq name rankName = false)
    (receiver : nameEq name nThis = false) (homeName : nameEq name nHome = false) :
    lookupEnv name (bodyEnv source env home owner) = lookupEnv name env := by
  rw [entry_environment,lookupEnv_skip name pointerName _ _ pointer,lookupEnv_skip name rankName _ _ rank]
  exact NdimCall.entry_environment_other source env home owner name receiver homeName
theorem entry_environment_this {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    lookupEnv nThis (bodyEnv source env home owner) = some source.next := by
  rw [entry_environment,lookupEnv_skip nThis pointerName _ _ (by decide +kernel),lookupEnv_skip nThis rankName _ _ (by decide +kernel)]
  exact getter_environment_this source none env home owner chars!"disposed" chars!"handle" (.block [])
theorem entry_environment_rank {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    lookupEnv rankName (bodyEnv source env home owner) = some (closure source env home owner).next := by
  rw [entry_environment,lookupEnv_skip rankName pointerName _ _ (by decide +kernel)]
  exact lookupEnv_head _ _ _
theorem entry_environment_pointer {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    lookupEnv pointerName (bodyEnv source env home owner) = some ((closure source env home owner).next+1) := by
  rw [entry_environment]
  exact lookupEnv_head _ _ _
theorem entry_native (source : St Host.Load.LSt) (env : Env) (home : Val) (owner getter : Nat) :
    (entry source env home owner getter).ffi = source.ffi := by
  change (enterBlock _ statements (lexicalEnv source env home owner)).ffi = _
  rw [enterBlock_ffi _ _ _ rfl]
  exact closureState_ffi source function env false home (.obj owner) [] .call
theorem entry_heap_below (source : St Host.Load.LSt) (env : Env) (home : Val) (owner getter : Nat)
    (bound : source.next+4 ≤ 2^64) (a : Nat) (below : a < source.next) :
    (entry source env home owner getter).heap.get a = source.heap.get a := by
  have belowClosure : a < (closure source env home owner).next := Nat.lt_trans below (closure_counter_gt source env home owner)
  have room : (closure source env home owner).next+(blockNames statements).length ≤ 2^64 := by
    change (closure source env home owner).next+2 ≤ 2^64
    have le := closure_room source env home (.obj owner) []
    change (closure source env home owner).next ≤ source.next+2 at le
    omega
  exact (enterBlock_heap_below _ statements (lexicalEnv source env home owner) a belowClosure room rfl).trans
    (closureState_heap_below Host.Load.ffi source function env false home (.obj owner) [] .call (by change source.next+2 ≤ 2^64; omega) a below)
theorem entry_receiver (source : St Host.Load.LSt) (env : Env) (home : Val) (owner getter : Nat)
    (bound : source.next+4 ≤ 2^64) :
    (entry source env home owner getter).heap.get source.next = some (.cell (some (.obj owner))) := by
  have room : (closure source env home owner).next+(blockNames statements).length ≤ 2^64 := by
    change (closure source env home owner).next+2 ≤ 2^64
    have le := closure_room source env home (.obj owner) []
    change (closure source env home owner).next ≤ source.next+2 at le
    omega
  exact (enterBlock_heap_below _ statements (lexicalEnv source env home owner) source.next (closure_counter_gt source env home owner) room rfl).trans
    (closureState_receiver Host.Load.ffi source function env home (.obj owner) [] .call (by change source.next+2 ≤ 2^64; omega))
theorem entry_rank_cell (source : St Host.Load.LSt) (env : Env) (home : Val) (owner getter : Nat)
    (bound : source.next+4 ≤ 2^64) :
    (entry source env home owner getter).heap.get (closure source env home owner).next = some (.cell none) := by
  let first := (closure source env home owner).next
  have room : first+2 ≤ 2^64 := by
    have le := closure_room source env home (.obj owner) []
    change first ≤ source.next+2 at le
    omega
  change (((closure source env home owner).heap.set first (.cell none)).set (first+1) (.cell none)).get first = _
  rw [PTrie.get_set_u64 _ _ _ (by omega)]
  simp only [Nat.ne_of_lt (Nat.lt_succ_self first),ite_false]
  rw [PTrie.get_set_u64 _ _ _ (by omega)]
  simp only [ite_true]
theorem entry_pointer_cell (source : St Host.Load.LSt) (env : Env) (home : Val) (owner getter : Nat)
    (bound : source.next+4 ≤ 2^64) :
    (entry source env home owner getter).heap.get ((closure source env home owner).next+1) = some (.cell none) := by
  let first := (closure source env home owner).next
  have room : first+2 ≤ 2^64 := by
    have le := closure_room source env home (.obj owner) []
    change first ≤ source.next+2 at le
    omega
  change (((closure source env home owner).heap.set first (.cell none)).set (first+1) (.cell none)).get (first+1) = _
  rw [PTrie.get_set_u64 _ _ _ (by omega)]
  simp only [ite_true]

theorem ndim_heap_below (source : St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter handle rank : Nat) (bound : source.next+4 ≤ 2^64)
    (a : Nat) (below : a < source.next) :
    (NdimCall.callResult source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter handle rank).heap.get a = source.heap.get a := by
  let input := NdimCall.callInput source env home numberFn nativeFn module owner getter
  have entryNext := NdimCall.entry_next source env home owner
  have belowInput : a < input.next := Nat.lt_of_lt_of_le below (by
    cases home <;> first
      | change source.next ≤ source.next+1; omega
      | change source.next ≤ source.next+1+1; omega)
  change (getterCallResult input name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))).heap.get a = _
  exact (NdimCall.getter_heap_below input name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))
    (by change (NdimCall.entry source env home owner).next+2 ≤ _; omega) a belowInput).trans
    (NdimCall.entry_heap_below source env home owner (by omega) a below)

theorem ndim_counter_le (source : St Host.Load.LSt) (env : Env) (home : Val) (owner : Nat)
    (name : Option Name) (getEnv : Env) (getHome : Val) (disposed field : Name) (yes : Stmt)
    (numberFn nativeFn module getter handle rank : Nat) :
    (NdimCall.callResult source env home owner name getEnv getHome disposed field yes numberFn nativeFn module getter handle rank).next ≤ source.next+4 := by
  let input := NdimCall.callInput source env home numberFn nativeFn module owner getter
  have first := NdimCall.entry_next source env home owner
  have last : (getterCallResult input name getEnv getHome owner disposed field yes (.big (Int.ofNat handle))).next ≤ input.next+2 := by
    cases getHome <;> first
      | change input.next+1 ≤ input.next+2; omega
      | change input.next+1+1 ≤ input.next+2; omega
  exact Nat.le_trans last (by change (NdimCall.entry source env home owner).next+2 ≤ source.next+4; omega)

theorem ndim_notes_below (notes : RetainedNotes) (source : St Host.Load.LSt) (env : Env) (home : Val)
    (owner numberFn nativeFn module getter rank a : Nat) (below : a < source.next) :
    (NdimCall.callNotes notes source env home owner numberFn nativeFn module getter rank).runtime.cells.cells a = notes.runtime.cells.cells a := by
  have belowEntry : a < (NdimCall.entry source env home owner).next := by
    cases home <;> first
      | change a < source.next+1; omega
      | change a < source.next+1+1; omega
  change ((notes.runtime.cells.write source.next (.obj owner)).write (NdimCall.entry source env home owner).next (.obj owner)).cells a = _
  simp only [Notes.write,Nat.ne_of_lt belowEntry,Nat.ne_of_lt below,ite_false]

end Host.Ts.Owned.Annotated.ShapeCall
