import host.ts.Init
import host.ts.StoreLaws

set_option Elab.async false
namespace Host.Ts

/-- Property installation can change a builtin's properties, but never its
native code or captured values, even when it writes the selected owner. -/
theorem setP_kind {S : Type} (s : St S) (a b : Nat) (key : PKey) (value : PropV)
    (bound : a < 2^64) :
    (((setP a key value).run s).2.obj? b).map Obj.kind = (s.obj? b).map Obj.kind := by
  change ((match s.obj? a with
    | some o => s.setObj a {o with props := setPropL key value o.props}
    | none => s).obj? b).map Obj.kind = _
  cases object : s.obj? a with
  | none => rfl
  | some o =>
    by_cases same : b = a
    · subst b
      change ((s.setObj a {o with props := setPropL key value o.props}).obj? a).map Obj.kind = _
      simp only [St.setObj,St.obj?,PTrie.get_set_u64 _ _ _ bound,ite_true,Option.map_some]
      change some o.kind = (s.obj? a).map Obj.kind
      rw [object]
      rfl
    · change ((s.setObj a {o with props := setPropL key value o.props}).obj? b).map Obj.kind = _
      simp only [St.setObj,St.obj?,PTrie.get_set_u64 _ _ _ bound,ite_false,same]

theorem setP_next {S : Type} (s : St S) (a : Nat) (key : PKey) (value : PropV) :
    ((setP a key value).run s).2.next = s.next := by
  change (match s.obj? a with
    | some o => s.setObj a {o with props := setPropL key value o.props}
    | none => s).next = _
  cases s.obj? a <;> rfl

theorem ctorFn_run {S : Type} (s : St S) (code : Native) (proto : Nat) (data : List Val) :
    (ctorFn code proto data).run s =
      let allocated := (s.allocObj (.fn (.native code data)) (.obj aFunctionProto) []).2
      let first := ((setP s.next kPrototype (.data (.obj proto) false false)).run allocated).2
      (s.next,((setP proto kConstructor (.data (.obj s.next) true false)).run first).2) := rfl

theorem ctorFn_owner {S : Type} (s : St S) (code : Native) (proto : Nat) (data : List Val) :
    ((ctorFn code proto data).run s).1 = s.next := rfl

theorem ctorFn_next {S : Type} (s : St S) (code : Native) (proto : Nat) (data : List Val) :
    ((ctorFn code proto data).run s).2.next = s.next+1 := by
  rw [ctorFn_run]
  dsimp only
  rw [setP_next,setP_next]
  rfl

theorem ctorFn_native_kind {S : Type} (s : St S) (code : Native) (proto : Nat) (data : List Val)
    (bound : s.next < 2^64) (protoBound : proto < 2^64) :
    (((ctorFn code proto data).run s).2.obj? s.next).map Obj.kind = some (.fn (.native code data)) := by
  rw [ctorFn_run]
  dsimp only
  rw [setP_kind _ proto _ _ _ protoBound,setP_kind _ s.next _ _ _ bound]
  simp only [St.allocObj,St.alloc,St.obj?,PTrie.get_set_u64 _ _ _ bound,ite_true,Option.map_some]

theorem typedCtor_run {S : Type} (s : St S) (kind : EltK) (name : Name) :
    (typedCtor kind name).run s =
      let made := (ctorFn (.buf .typedCtor) (aTypedProtoOf kind) [natV kind.code,natV (aTypedProtoOf kind)]).run s
      let first := ((setP made.1 (.str chars!"BYTES_PER_ELEMENT") (.data (natV kind.size) false false)).run made.2).2
      let second := ((setP (aTypedProtoOf kind) (.str chars!"BYTES_PER_ELEMENT") (.data (natV kind.size) false false)).run first).2
      ((),((setP aGlobal (.str name) (.data (.obj made.1) true false)).run second).2) := rfl

/-- One original `realmIter` typed-constructor iteration installs the literal
element code and prototype before publishing the global constructor. -/
theorem typedCtor_native_kind {S : Type} (s : St S) (kind : EltK) (name : Name)
    (bound : s.next < 2^64) (protoBound : aTypedProtoOf kind < 2^64) :
    (((typedCtor kind name).run s).2.obj? s.next).map Obj.kind =
      some (.fn (.native (.buf .typedCtor) [natV kind.code,natV (aTypedProtoOf kind)])) := by
  rw [typedCtor_run]
  dsimp only
  rw [setP_kind _ aGlobal _ _ _ (by decide +kernel),setP_kind _ (aTypedProtoOf kind) _ _ _ protoBound,
    ctorFn_owner,setP_kind _ s.next _ _ _ bound]
  exact ctorFn_native_kind s _ _ _ bound protoBound

theorem typedCtor_next {S : Type} (s : St S) (kind : EltK) (name : Name) :
    ((typedCtor kind name).run s).2.next = s.next+1 := by
  rw [typedCtor_run]
  dsimp only
  rw [setP_next,setP_next,setP_next,ctorFn_next]

end Host.Ts
