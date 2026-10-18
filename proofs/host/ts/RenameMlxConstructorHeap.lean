import host.ts.RenameRetainedMlxClassBlock

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def initializedInstance (proto brand token : Nat) : Obj :=
  defineField (defineField (defineField (defineField (freshInstance proto) brand chars!"handle" .undef)
    brand chars!"disposed" (.bool false)) brand chars!"token" (.obj token))
    brand chars!"pinId" (.num (.lit (F64.ofNat 0)))

theorem initialized_handle (proto brand token : Nat) :
    findPriv brand chars!"handle" (initializedInstance proto brand token).priv = some (.data .undef true false) := by
  have hd : nameEq chars!"handle" chars!"disposed" = false := by decide +kernel
  have ht : nameEq chars!"handle" chars!"token" = false := by decide +kernel
  have hp : nameEq chars!"handle" chars!"pinId" = false := by decide +kernel
  have dh : nameEq chars!"disposed" chars!"handle" = false := by decide +kernel
  have th : nameEq chars!"token" chars!"handle" = false := by decide +kernel
  have td : nameEq chars!"token" chars!"disposed" = false := by decide +kernel
  have ph : nameEq chars!"pinId" chars!"handle" = false := by decide +kernel
  have pd : nameEq chars!"pinId" chars!"disposed" = false := by decide +kernel
  have pt : nameEq chars!"pinId" chars!"token" = false := by decide +kernel
  simp only [initializedInstance,defineField,freshInstance,setPrivL,findPriv,privEq,Nat.beq_refl,
    Bool.true_and,hd,ht,hp,dh,th,td,ph,pd,pt,Bool.cond_false]
  simp only [nameEq,Nat.beq_refl,Bool.cond_true]

theorem parameter_environment {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) :
    parameterEnvironment source env proto brand argument =
      (chars!"handle",source.next+4)::(nThis,source.next+3)::env := rfl

theorem parameter_lookup_handle {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) :
    lookupEnv chars!"handle" (parameterEnvironment source env proto brand argument) = some (source.next+4) := by
  rw [parameter_environment]
  simp only [lookupEnv,Nat.beq_refl,brec]

theorem parameter_lookup_this {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) :
    lookupEnv nThis (parameterEnvironment source env proto brand argument) = some (source.next+3) := by
  rw [parameter_environment]
  simp only [lookupEnv, show Nat.beq (pack nThis) (pack chars!"handle") = false by decide +kernel, Nat.beq_refl,brec]


theorem parameter_lookup_other {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val)
    (name : Name) (differentHandle : nameEq name chars!"handle" = false) (differentThis : nameEq name nThis = false) :
    lookupEnv name (parameterEnvironment source env proto brand argument) = lookupEnv name env := by
  rw [parameter_environment]
  change brec (nameEq name chars!"handle") (some (source.next+4))
    (brec (nameEq name nThis) (some (source.next+3)) (lookupEnv name env)) = _
  rw [differentHandle,differentThis]

theorem parameters_this (F : Ffi) (source : St F.S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) :
    (parametersOutput source env proto brand argument).heap.get (source.next+3) = some (.cell (some (.obj source.next))) := by
  exact closureState_receiver F {classFieldsOutput source env proto brand argument with stack := source.stack}
    constructorFunction env .undef (.obj source.next) [argument] (.ctor (.obj source.next))
    (by change source.next+3+3 ≤ 2^64; omega)

theorem parameters_parameter {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) :
    (parametersOutput source env proto brand argument).heap.get (source.next+4) = some (.cell none) := by
  let bodyStart := ({classFieldsOutput source env proto brand argument with stack := source.stack}.alloc
    (.cell (some (.obj source.next)))).2
  change (bodyStart.heap.set (source.next+4) (.cell none)).get (source.next+4) = _
  rw [PTrie.get_set_u64 _ _ _ (show source.next+4 < 2^64 by omega),ite_eq_left rfl]

theorem parameters_instance (F : Ffi) (source : St F.S) (env : Env) (proto brand : Nat) (argument : Val)
    (bound : source.next+6 ≤ 2^64) :
    (parametersOutput source env proto brand argument).heap.get source.next =
      some (.obj (initializedInstance proto brand (source.next+2))) := by
  unfold parametersOutput
  rw [closureState_heap_below F _ constructorFunction env false .undef (.obj source.next) [argument]
    (.ctor (.obj source.next)) (by change source.next+3+3 ≤ 2^64; omega) source.next (by change source.next < source.next+3; omega)]
  simp only [classFieldsOutput,fields7,PrivateNext.advance,St.ret,St.setObj,
    PTrie.get_set_u64 _ _ _ (show source.next < 2^64 by omega)]
  rfl

theorem parameters_this_note {S : Type} (notes : RetainedNotes) (source : St S) (env : Env)
    (proto brand : Nat) (argument : Val) (role : Value) :
    (parametersNotes notes source env proto brand argument role).runtime.cells.cells (source.next+3) =
      some (.obj source.next) := by
  simp only [parametersNotes,RuntimeNotes.constructorBody,Notes.write,RetainedNotes.withRuntime,ite_true]

end Host.Ts.Owned.Annotated.MlxConstruction
