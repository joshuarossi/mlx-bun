import host.ts.RenameRetainedDisposeGuard
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.Dispose
open Parametric

theorem environment_nonempty {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat)
    (nonempty : home ≠ .undef) :
    closureEnvironment source function env false home (.obj owner) =
      (nHome,source.next+1)::(nThis,source.next)::env := by
  unfold closureEnvironment
  rw [closureStart_home source env home (.obj owner) nonempty]
  rfl

theorem environment_this {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    lookupEnv nThis (closureEnvironment source function env false home (.obj owner)) = some source.next := by
  by_cases empty : home = .undef
  · subst home
    change lookupEnv nThis ((nThis,source.next)::env) = _
    exact lookupEnv_head nThis source.next env
  · rw [environment_nonempty source env home owner empty,
      lookupEnv_skip nThis nHome (source.next+1) ((nThis,source.next)::env) (by decide +kernel)]
    exact lookupEnv_head nThis source.next env

theorem environment_lookup {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat)
    (name : Name) (address : Nat) (names : nameEq name nThis = false ∧ nameEq name nHome = false)
    (lookup : lookupEnv name env = some address) :
    lookupEnv name (closureEnvironment source function env false home (.obj owner)) = some address := by
  by_cases empty : home = .undef
  · subst home
    change lookupEnv name ((nThis,source.next)::env) = _
    rw [lookupEnv_skip name nThis source.next env names.1]
    exact lookup
  · rw [environment_nonempty source env home owner empty,
      lookupEnv_skip name nHome (source.next+1) ((nThis,source.next)::env) names.2,
      lookupEnv_skip name nThis source.next env names.1]
    exact lookup

theorem entry_heap {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    (entryState source env home owner).heap = (closureState source function env false home (.obj owner) [] .call).heap := by
  rfl

theorem entry_next {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    (entryState source env home owner).next = (closureState source function env false home (.obj owner) [] .call).next := by
  rfl

theorem entry_native {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    (entryState source env home owner).ffi = source.ffi := by cases home <;> rfl

theorem entry_next_le {S : Type} (source : St S) (env : Env) (home : Val) (owner : Nat) :
    (entryState source env home owner).next ≤ source.next+2 := by
  rw [entry_next]
  cases home <;> first | change source.next+1 ≤ source.next+2; omega | change source.next+1+1 ≤ source.next+2; omega

theorem entry_heap_below (F : Ffi) (source : St F.S) (env : Env) (home : Val) (owner address : Nat)
    (bound : source.next+2 ≤ 2^64) (below : address < source.next) :
    (entryState source env home owner).heap.get address = source.heap.get address := by
  rw [entry_heap]
  exact closureState_heap_below F source function env false home (.obj owner) [] .call bound address below

theorem entry_receiver (F : Ffi) (source : St F.S) (env : Env) (home : Val) (owner : Nat)
    (bound : source.next+2 ≤ 2^64) :
    (entryState source env home owner).heap.get source.next = some (.cell (some (.obj owner))) := by
  rw [entry_heap]
  exact closureState_receiver F source function env home (.obj owner) [] .call bound

/-- Changing only private fields preserves the current ordinary property path,
including a path that traverses the same object. -/
theorem lookup_private_write {S : Type} {source : St S} {name : Name} {fuel address : Nat}
    {property : Option PropV} (path : OrdinaryLookup source name fuel address property)
    (owner : Nat) (object : Obj) (privates : Privs)
    (read : source.heap.get owner = some (.obj object)) (bound : owner < 2^64) :
    OrdinaryLookup (source.setObj owner {object with priv := privates}) name fuel address property := by
  induction path with
  | hit fuel a o p ho hk hp =>
    by_cases equal : a = owner
    · subst a
      have same := HObj.obj.inj (Option.some.inj (ho.symm.trans read))
      subst o
      exact .hit fuel owner {object with priv := privates} p
        (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]) hk hp
    · exact .hit fuel a o p
        (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right equal]; exact ho) hk hp
  | next fuel a b o ho hk hp proto next ih =>
    by_cases equal : a = owner
    · subst a
      have same := HObj.obj.inj (Option.some.inj (ho.symm.trans read))
      subst o
      exact .next fuel owner b {object with priv := privates}
        (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]) hk hp proto ih
    · exact .next fuel a b o
        (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right equal]; exact ho) hk hp proto ih
  | stop fuel a o ho hk hp proto =>
    by_cases equal : a = owner
    · subst a
      have same := HObj.obj.inj (Option.some.inj (ho.symm.trans read))
      subst o
      exact .stop fuel owner {object with priv := privates}
        (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_true]) hk hp proto
    · exact .stop fuel a o
        (by simp only [St.setObj,PTrie.get_set_u64 _ _ _ bound,ite_eq_right equal]; exact ho) hk hp proto
theorem lookup_same_heap {S : Type} {source target : St S} {name : Name} {fuel address : Nat}
    {property : Option PropV} (path : OrdinaryLookup source name fuel address property)
    (heap : target.heap = source.heap) : OrdinaryLookup target name fuel address property := by
  have read (a : Nat) : target.heap.get a = source.heap.get a := congrArg (fun h : PTrie HObj => h.get a) heap
  induction path with
  | hit fuel a object property objectRead kind descriptor =>
    exact .hit fuel a object property ((read a).trans objectRead) kind descriptor
  | next fuel a b object objectRead kind absent proto child ih =>
    exact .next fuel a b object ((read a).trans objectRead) kind absent proto ih
  | stop fuel a object objectRead kind absent proto =>
    exact .stop fuel a object ((read a).trans objectRead) kind absent proto

end Host.Ts.Owned.Annotated.Dispose
