import host.ts.RenameParametricTypedBuffer
import host.mlx.OwnedMetadata

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

/-- Typed-array enumeration calls the original getter at each position. This
composes checked getters without assuming an entire target enumeration. -/
theorem typedElems_of_getters (F : Ffi) (s : St F.S) (k : EltK) (b off : Nat)
    (vs : List Val) (i : Nat)
    (getters : ∀ j, j < vs.length →
      typedGet F s k b off (i+vs.length) (i+j) =
        M.pure (some (.data (nthD .undef vs j) true true))) :
    typedElems F s k b off vs.length i = M.pure vs := by
  induction vs generalizing i with
  | nil => rfl
  | cons v vs ih =>
    have hhead := getters 0 (by simp)
    simp only [List.length_cons,Nat.add_zero,nthD] at hhead
    have htail : ∀ j, j < vs.length →
        typedGet F s k b off (i+1+vs.length) (i+1+j) =
          M.pure (some (.data (nthD .undef vs j) true true)) := by
      intro j hj
      have hh := getters (j+1) (by simpa using Nat.succ_lt_succ hj)
      simpa only [List.length_cons,nthD,Nat.add_assoc,Nat.add_comm 1 j,Nat.add_comm 1 vs.length] using hh
    simp only [List.length_cons,typedElems,show i+vs.length+1 = i+(vs.length+1) from by omega,hhead]
    have ht := ih (i+1) htail
    rw [ht]
    rfl

theorem elemsOf_typed_of_getters (F : Ffi) (s : St F.S) (a b off : Nat) (o : Obj)
    (k : EltK) (vs : List Val) (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .typed k b off vs.length)
    (getters : ∀ j, j < vs.length → typedGet F s k b off vs.length j =
      M.pure (some (.data (nthD .undef vs j) true true))) :
    elemsOf F s (.obj a) = M.pure (some vs) := by
  obtain ⟨kind,proto,props,priv,ext⟩ := o
  dsimp only at hk
  subst kind
  have ht := typedElems_of_getters F s k b off vs 0 (by simpa only [Nat.zero_add] using getters)
  simp only [elemsOf,St.obj?,ho,ht]
  rfl

theorem len_list_length {α : Type} (xs : List α) : len xs = xs.length := by
  have h : ∀ (xs : List α) (n : Nat), lenL xs n = xs.length + n := by
    intro xs
    induction xs with
    | nil => intro n; simp only [lenL,List.length_nil,Nat.zero_add]
    | cons x xs ih => intro n; simp only [lenL,List.length_cons,ih]; omega
  simpa only [len,Nat.add_zero] using h xs 0

theorem nth_map_exists {α β : Type} (f : α → β) (fallback : β) (xs : List α)
    (i : Nat) (hi : i < xs.length) :
    ∃ x, nth? xs i = some x ∧ nthD fallback (xs.map f) i = f x := by
  induction xs generalizing i with
  | nil => simp at hi
  | cons x xs ih =>
    cases i with
    | zero => exact ⟨x,rfl,rfl⟩
    | succ i => exact ih i (Nat.lt_of_succ_lt_succ hi)

end Host.Ts.Owned.Parametric

namespace Host.Load.Parametric
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi

/-- Enumerating the actual native int32 shape view returns every carrier
dimension. Each getter is derived from the owned shape region and native node;
there is no target enumeration or per-element read assumption. -/
theorem elemsOf_shape (s : Host.Ts.St LSt) (a b handle : Nat) (o bo : Host.Ts.Obj) (node : Node)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .typed .i32 b 0 (len node.shape))
    (hbo : s.heap.get b = some (.obj bo)) (hbk : bo.kind = .extBuf (4*handle) 0 (len node.shape*4))
    (hn : s.ffi.mlx.node? handle = some node) :
    elemsOf ffi s (.obj a) = M.pure (some (node.shape.map (fun d => .num d.num))) := by
  have hk' : o.kind = .typed .i32 b 0 (node.shape.map (fun d => Val.num d.num)).length := by
    simpa only [List.length_map,len_list_length] using hk
  apply elemsOf_typed_of_getters ffi s a b 0 o .i32 _ ho hk'
  intro j hj
  have hj' : j < node.shape.length := by simpa only [List.length_map] using hj
  obtain ⟨d,hd,hvalue⟩ := nth_map_exists (fun d : Dim => Val.num d.num) .undef node.shape j hj'
  have hbound : Nat.blt j (len node.shape) = true := by
    rw [Nat.blt_eq,len_list_length]
    exact hj'
  have hget := Owned.typedGet_shape_dimension s b handle j bo node d
    (by simp only [Host.Ts.St.obj?,hbo]) hbk hn hd hbound
  simpa only [List.length_map,len_list_length,hvalue] using hget

end Host.Load.Parametric
