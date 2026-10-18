import host.ts.RenameRetainedMlxHandleBlock

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

theorem parameters_old (F : Ffi) (source : St F.S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) (address : Nat) (old : address < source.next) :
    (parametersOutput source env proto brand argument).heap.get address = source.heap.get address := by
  unfold parametersOutput
  rw [closureState_heap_below F _ constructorFunction env false .undef (.obj source.next) [argument]
    (.ctor (.obj source.next)) (by change source.next+3+3 ≤ 2^64; omega) address (by change address < source.next+3; omega)]
  have b0 : source.next < 2^64 := by omega
  have b1 : source.next+1 < 2^64 := by omega
  have b2 : source.next+2 < 2^64 := by omega
  have d0 : address ≠ source.next := by omega
  have d1 : address ≠ source.next+1 := by omega
  have d2 : address ≠ source.next+2 := by omega
  simp only [classFieldsOutput,fields7,fields5,fields4,fields3,fields1,classStart,baseClassEntry,
    afterHandle,afterDisposed,afterToken,PrivateNext.advance,St.setObj,St.allocObj,St.alloc,St.go,St.push,St.ret,
    PTrie.get_set_u64 _ _ _ b0,PTrie.get_set_u64 _ _ _ b1,PTrie.get_set_u64 _ _ _ b2,
    ite_eq_right d0,ite_eq_right d1,ite_eq_right d2]

def storedInstance (proto brand token : Nat) (argument : Val) : Obj :=
  {initializedInstance proto brand token with priv := setPrivL brand chars!"handle" (.data argument true false) (initializedInstance proto brand token).priv}

theorem stored_token (proto brand token : Nat) (argument : Val) :
    findPriv brand chars!"token" (storedInstance proto brand token argument).priv = some (.data (.obj token) true false) := by
  have dh : nameEq chars!"disposed" chars!"handle" = false := by decide +kernel
  have th : nameEq chars!"token" chars!"handle" = false := by decide +kernel
  have td : nameEq chars!"token" chars!"disposed" = false := by decide +kernel
  have ph : nameEq chars!"pinId" chars!"handle" = false := by decide +kernel
  have pd : nameEq chars!"pinId" chars!"disposed" = false := by decide +kernel
  have pt : nameEq chars!"pinId" chars!"token" = false := by decide +kernel
  simp only [storedInstance,initializedInstance,defineField,freshInstance,setPrivL,privEq,Nat.beq_refl,
    Bool.true_and,dh,th,td,ph,pd,pt,Bool.cond_false]
  simp only [nameEq,Nat.beq_refl,Bool.cond_true]
  simp only [findPriv,privEq,Nat.beq_refl,Bool.true_and,th,td,Bool.cond_false]
  simp only [nameEq,Nat.beq_refl,Bool.cond_true]

theorem handle_old (F : Ffi) (source : St F.S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) (address : Nat) (old : address < source.next) :
    (handleOutput source env proto brand argument).heap.get address = source.heap.get address := by
  change (((parametersOutput source env proto brand argument).heap.set (source.next+4) (.cell (some argument))).set
    source.next (.obj (storedInstance proto brand (source.next+2) argument))).get address = _
  rw [PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega),ite_eq_right (show address ≠ source.next by omega),
    PTrie.get_set_u64 _ _ _ (show source.next+4 < 2^64 by omega),ite_eq_right (show address ≠ source.next+4 by omega)]
  exact parameters_old F source env proto brand argument bound address old

theorem handle_instance {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) :
    (handleOutput source env proto brand argument).heap.get source.next =
      some (.obj (storedInstance proto brand (source.next+2) argument)) := by
  change ((assignmentSource source env proto brand argument).heap.set source.next
    (.obj (storedInstance proto brand (source.next+2) argument))).get source.next = _
  rw [PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega),ite_eq_left rfl]

theorem handle_this (F : Ffi) (source : St F.S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) :
    (handleOutput source env proto brand argument).heap.get (source.next+3) = some (.cell (some (.obj source.next))) := by
  change (((parametersOutput source env proto brand argument).heap.set (source.next+4) (.cell (some argument))).set
    source.next (.obj (storedInstance proto brand (source.next+2) argument))).get (source.next+3) = _
  rw [PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega),ite_eq_right (show source.next+3 ≠ source.next by omega),
    PTrie.get_set_u64 _ _ _ (show source.next+4 < 2^64 by omega),ite_eq_right (show source.next+3 ≠ source.next+4 by omega)]
  exact parameters_this F source env proto brand argument bound

theorem handle_parameter {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) :
    (handleOutput source env proto brand argument).heap.get (source.next+4) = some (.cell (some argument)) := by
  change (((parametersOutput source env proto brand argument).heap.set (source.next+4) (.cell (some argument))).set
    source.next (.obj (storedInstance proto brand (source.next+2) argument))).get (source.next+4) = _
  rw [PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega),ite_eq_right (show source.next+4 ≠ source.next by omega),
    PTrie.get_set_u64 _ _ _ (show source.next+4 < 2^64 by omega),ite_eq_left rfl]

theorem handle_this_note {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (proto brand : Nat)
    (argument : Val) (role : Value) :
    (handleNotes notes source env proto brand argument role).runtime.cells.cells (source.next+3) = some (.obj source.next) := by
  change (if source.next+3 = source.next+4 then some role
    else (parametersNotes notes source env proto brand argument role).runtime.cells.cells (source.next+3)) = _
  rw [ite_eq_right (show source.next+3 ≠ source.next+4 by omega)]
  exact parameters_this_note notes source env proto brand argument role

theorem handle_parameter_note {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (proto brand : Nat)
    (argument : Val) (role : Value) :
    (handleNotes notes source env proto brand argument role).runtime.cells.cells (source.next+4) = some role := by
  change (if source.next+4 = source.next+4 then some role else _) = _
  rw [ite_eq_left rfl]

end Host.Ts.Owned.Annotated.MlxConstruction
