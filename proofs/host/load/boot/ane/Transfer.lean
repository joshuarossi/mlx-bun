import host.load.boot.ane.Data
namespace Host.Load.Boot
open Host.Ts Host.Load Host.Load.Extract

/-! # Reading the buckets does not touch the prompt array

`Tr s1 s2`: `s2` agrees with `s1` except at the object `2665` (the prompt array), which `s1` holds as
`anePoison` — no prototype, properties or private fields, so every read through it fails — and `s2`'s host
and graph handles and nodes are `s1`'s. A read that succeeds on `s1` never went through `2665`, so it
succeeds with the same value on `s2` (`aneX_tr`): the buckets read at the poisoned state are those of every
state the prompt and the unread readbacks vary. -/

def anePoison : Obj := ⟨.ordinary, .null, [], [], true⟩

structure Tr (s1 s2 : St LSt) : Prop where
  obj : ∀ a, a ≠ 2665 → s2.obj? a = s1.obj? a
  cell : ∀ c, s2.cell? c = s1.cell? c
  poison : s1.obj? 2665 = some anePoison
  host : s2.ffi.host = s1.ffi.host
  arrs : s2.ffi.mlx.arrs = s1.ffi.mlx.arrs
  nodes : s2.ffi.mlx.nodes = s1.ffi.mlx.nodes

theorem bind_tr {α β : Type} {x1 x2 : Option α} {f1 f2 : α → Option β} {b : β}
    (hx : ∀ a, x1 = some a → x2 = some a) (hf : ∀ a c, f1 a = some c → f2 a = some c)
    (e : x1.bind f1 = some b) : x2.bind f2 = some b := by
  obtain ⟨a, ha, e⟩ := Option.bind_eq_some_iff.mp e
  exact Option.bind_eq_some_iff.mpr ⟨a, hx a ha, hf a b e⟩

theorem findProp_nil (k : PKey) : findProp k [] = none := by
  rw [findProp_eq_linear]
  rfl

theorem object_obj (s : St LSt) (a : Nat) : object s (.obj a) = s.obj? a := rfl

theorem map_tr {α β : Type} {x1 x2 : Option α} {g : α → β} {b : β} (hx : ∀ a, x1 = some a → x2 = some a)
    (e : x1.map g = some b) : x2.map g = some b := by
  obtain ⟨a, ha, rfl⟩ := Option.map_eq_some_iff.mp e
  rw [hx a ha]
  rfl

theorem mapM_tr {α β : Type} {f1 f2 : α → Option β} (hf : ∀ x y, f1 x = some y → f2 x = some y) :
    ∀ (xs : List α) {ys : List β}, xs.mapM f1 = some ys → xs.mapM f2 = some ys
  | [], _, e => e
  | x :: xs, ys, e => by
    simp only [List.mapM_cons, Option.bind_eq_bind] at e ⊢
    obtain ⟨y, hy, e⟩ := Option.bind_eq_some_iff.mp e
    obtain ⟨zs, hz, e⟩ := Option.bind_eq_some_iff.mp e
    exact Option.bind_eq_some_iff.mpr ⟨y, hf x y hy, Option.bind_eq_some_iff.mpr ⟨zs, mapM_tr hf xs hz, e⟩⟩

section
variable {s1 s2 : St LSt} (h : Tr s1 s2)
include h

theorem object_ne {v : Val} (hv : v ≠ .obj 2665) : object s2 v = object s1 v := by
  cases v with
  | obj a => exact h.obj a (fun e => hv (by rw [e]))
  | _ => rfl


theorem own_tr {v : Val} {n : List Char} {w : Val} (hw : own s1 v n = some w) : own s2 v n = some w := by
  by_cases hv : v = .obj 2665
  · subst hv
    unfold own at hw
    rw [object_obj, h.poison] at hw
    simp [anePoison, findProp_nil] at hw
  · unfold own
    rw [object_ne h hv]
    exact hw

theorem privateField_tr {v : Val} {n : List Char} {w : Val} (hw : privateField s1 v n = some w) :
    privateField s2 v n = some w := by
  by_cases hv : v = .obj 2665
  · subst hv
    unfold privateField at hw
    rw [object_obj, h.poison] at hw
    simp [anePoison] at hw
  · unfold privateField
    rw [object_ne h hv]
    exact hw

theorem elements_tr {v : Val} {w : List Val} (hw : elements s1 v = some w) : elements s2 v = some w := by
  by_cases hv : v = .obj 2665
  · subst hv
    unfold elements at hw
    rw [object_obj, h.poison] at hw
    simp [anePoison] at hw
  · unfold elements
    rw [object_ne h hv]
    exact hw

theorem bindingOf_tr (env : Env) (n : Name) : bindingOf s2 env n = bindingOf s1 env n := by
  unfold bindingOf
  simp only [h.cell]

theorem closureBinding_tr {v : Val} {n : List Char} {w : Val} (hw : closureBinding s1 v n = some w) :
    closureBinding s2 v n = some w := by
  by_cases hv : v = .obj 2665
  · subst hv
    unfold closureBinding at hw
    rw [object_obj, h.poison] at hw
    simp [anePoison] at hw
  · unfold closureBinding
    rw [object_ne h hv]
    simp only [bindingOf_tr h]
    exact hw

theorem className_tr {v : Val} {w : List Char} (hw : className s1 v = some w) : className s2 v = some w := by
  unfold className at hw ⊢
  obtain ⟨o, ho, hw⟩ := Option.bind_eq_some_iff.mp hw
  have ho2 : object s2 v = some o := by
    by_cases hv : v = .obj 2665
    · subst hv
      rw [object_obj, h.poison] at ho
      cases ho
      simp [anePoison, own, object] at hw
    · rw [object_ne h hv]
      exact ho
  obtain ⟨x, hx, hw⟩ := Option.bind_eq_some_iff.mp hw
  refine Option.bind_eq_some_iff.mpr ⟨o, ho2, Option.bind_eq_some_iff.mpr ⟨x, own_tr h hx, ?_⟩⟩
  cases x with
  | obj c =>
    obtain ⟨co, hco, hw⟩ := Option.bind_eq_some_iff.mp hw
    have hco2 : s2.obj? c = some co := by
      by_cases hc : c = 2665
      · subst hc
        rw [h.poison] at hco
        cases hco
        simp [anePoison] at hw
      · rw [h.obj c hc]
        exact hco
    refine Option.bind_eq_some_iff.mpr ⟨co, hco2, ?_⟩
    simpa only [h.cell] using hw
  | _ => simp at hw

theorem tensor_tr {v : Val} {t : Tensor} (ht : tensor s1 v = some t) : tensor s2 v = some t := by
  unfold tensor at ht ⊢
  obtain ⟨hd, hh, ht⟩ := Option.bind_eq_some_iff.mp ht
  refine Option.bind_eq_some_iff.mpr ⟨hd, bind_tr (fun _ e => privateField_tr h e) (fun _ _ e => e) hh, ?_⟩
  simpa only [Host.Mlx.Ffi.St.nodeId?, h.arrs, h.nodes] using ht

theorem fieldTensor_tr {v : Val} {n : List Char} {t : Tensor} (ht : fieldTensor s1 v n = some t) :
    fieldTensor s2 v n = some t :=
  bind_tr (fun _ e => own_tr h e) (fun _ _ e => tensor_tr h e) ht

theorem natOwn_tr {v : Val} {n : List Char} {k : Nat} (hk : (own s1 v n).bind nat = some k) :
    (own s2 v n).bind nat = some k :=
  bind_tr (fun _ e => own_tr h e) (fun _ _ e => e) hk

theorem progCreate_tr {pg : Val} {n : Nat} (hp : progCreate s1 pg = some n) : progCreate s2 pg = some n := by
  unfold progCreate at hp ⊢
  rw [h.host]
  exact bind_tr (fun _ e => privateField_tr h e) (fun _ _ e => e) hp

theorem aTrel_tr {v : Val} {x : ATrel} (hx : aTrel s1 v = some x) : aTrel s2 v = some x := by
  unfold aTrel at hx ⊢
  exact bind_tr (fun _ e => own_tr h e) (fun _ _ e => bind_tr (fun _ e => fieldTensor_tr h e)
    (fun _ _ e => bind_tr (fun _ e => fieldTensor_tr h e) (fun _ _ e => bind_tr (fun _ e => natOwn_tr h e)
      (fun _ _ e => e) e) e) e) hx

theorem aLin_tr {v : Val} {w sc b : List Char} {x : ALin} (hx : aLin s1 v w sc b = some x) :
    aLin s2 v w sc b = some x := by
  unfold aLin at hx ⊢
  exact bind_tr (fun _ e => fieldTensor_tr h e) (fun _ _ e => bind_tr (fun _ e => fieldTensor_tr h e)
    (fun _ _ e => bind_tr (fun _ e => fieldTensor_tr h e) (fun _ _ e => e) e) e) hx

theorem ownTrel_tr {v : Val} {n : List Char} {x : ATrel} (hx : (own s1 v n).bind (aTrel s1) = some x) :
    (own s2 v n).bind (aTrel s2) = some x :=
  bind_tr (fun _ e => own_tr h e) (fun _ _ e => aTrel_tr h e) hx

theorem aMlp_tr {v : Val} {x : AMlp} (hx : aMlp s1 v = some x) : aMlp s2 v = some x := by
  unfold aMlp at hx ⊢
  exact bind_tr (fun _ e => own_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => bind_tr (fun _ e => own_tr h e) (fun _ _ e => progCreate_tr h e) e) (fun _ _ e =>
    bind_tr (fun _ e => className_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => ownTrel_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => ownTrel_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => ownTrel_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => ownTrel_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => ownTrel_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => ownTrel_tr h e) (fun _ _ e => e) e) e) e) e) e) e) e) e) e) e) hx

theorem aAff_tr {v : Val} {x : AAff} (hx : aAff s1 v = some x) : aAff s2 v = some x := by
  unfold aAff at hx ⊢
  exact bind_tr (fun _ e => own_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => bind_tr (fun _ e => own_tr h e) (fun _ _ e => progCreate_tr h e) e) (fun _ _ e =>
    bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => bind_tr (fun _ e => own_tr h e) (fun _ _ e => aLin_tr h e) e) (fun _ _ e =>
    bind_tr (fun _ e => bind_tr (fun _ e => own_tr h e) (fun _ _ e => aLin_tr h e) e) (fun _ _ e => e)
      e) e) e) e) e) e) hx

theorem aLayer_tr {aff : Bool} {p : Nat} {l : Val} {x : ALayer} (hx : aLayer s1 aff p l = some x) :
    aLayer s2 aff p l = some x := by
  unfold aLayer at hx ⊢
  refine bind_tr (fun _ e => bind_tr (fun _ e => own_tr h e)
    (fun _ _ e => bind_tr (fun _ e => own_tr h e) (fun _ _ e => aMlp_tr h e) e) e) (fun _ _ e =>
    bind_tr (fun _ e => own_tr h e) (fun mx _ e => bind_tr (fun a e => ?_) (fun _ _ e => e) e) e) hx
  cases aff
  · exact e
  · exact mapM_tr (fun j _ e => map_tr (fun _ e => bind_tr (fun _ e => own_tr h e) (fun _ _ e => aAff_tr h e) e) e) _ e

theorem aBucket_tr {r : Val} {x : ABucket} (hx : aBucket s1 r = some x) : aBucket s2 r = some x := by
  unfold aBucket at hx ⊢
  exact bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => natOwn_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => own_tr h e) (fun _ _ e =>
    bind_tr (fun _ e => bind_tr (fun _ e => closureBinding_tr h e) (fun _ _ e => elements_tr h e) e) (fun _ _ e =>
    bind_tr (fun _ e => mapM_tr (fun _ _ e => bind_tr (fun _ e => e) (fun _ _ e => aLayer_tr h e) e) _ e)
      (fun _ _ e => e) e) e) e) e) hx

theorem isAne_tr {r : Val} (hs : (own s1 r chars!"unit").isSome = true) : isAne s2 r = isAne s1 r := by
  obtain ⟨u, hu⟩ := Option.isSome_iff_exists.mp hs
  unfold isAne
  rw [own_tr h hu, hu]

/-- **The buckets transfer**: read at `s1`, they are `s2`'s, when every prompt range of the model names its
unit at `s1`. -/
theorem aneX_tr {model : Val} {D : List ABucket}
    (hall : ∀ pr, (own s1 model chars!"prompt").bind (elements s1) = some pr →
      ∀ r ∈ pr, (own s1 r chars!"unit").isSome = true)
    (hx : aneX s1 model = some D) : aneX s2 model = some D := by
  unfold aneX at hx ⊢
  obtain ⟨pr, hpr, hx⟩ := Option.bind_eq_some_iff.mp hx
  refine Option.bind_eq_some_iff.mpr ⟨pr, bind_tr (fun _ e => own_tr h e) (fun _ _ e => elements_tr h e) hpr, ?_⟩
  have hf : pr.filter (isAne s2) = pr.filter (isAne s1) :=
    List.filter_congr (fun r hr => isAne_tr h (hall pr hpr r hr))
  rw [hf]
  exact mapM_tr (fun _ _ e => aBucket_tr h e) _ hx

end

end Host.Load.Boot
