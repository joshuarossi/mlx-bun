import host.sim.conv.ReindexNum
import host.sim.RestartDrop

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim

/-- Substitute one table reference by a literal and close the gap after it. -/
def eraseNum (cut : Nat) (x : F64) : Map :=
  { Map.id with num := fun i => if i < cut then .ref i else if i = cut then .lit x else .ref (i - 1) }

theorem eraseNum_after (M : Map) (cut : Nat) (x : F64) (hx : M.num cut = .lit x) :
    (M.skipNum cut).after (eraseNum cut x) = M := by
  cases M with
  | mk a num big region node =>
    change (⟨a, _, big, region, node⟩ : Map) = ⟨a, num, big, region, node⟩
    congr 1
    funext i
    show Map.nv _ (if i < cut then .ref i else if i = cut then .lit x else .ref (i - 1)) = num i
    by_cases hi : i < cut
    · simp only [Map.nv, Map.skipNum, Sim.skipNum, ite_eq_left hi]
    · rw [ite_eq_right hi]
      by_cases he : i = cut
      · subst i; rw [ite_eq_left rfl]; exact hx.symm
      · rw [ite_eq_right he]
        have hge : cut ≤ i - 1 := by omega
        have hs : i - 1 + 1 = i := by omega
        simp only [Map.nv, Map.skipNum, Sim.skipNum, ite_eq_right (by omega : ¬ i - 1 < cut), hs]

theorem eraseNum_supp {A : Nat → Prop} {cut n j : Nat} (x : F64) (hcut : cut ≤ n) (hj : j < n + 1) :
    Supp.nv A n ((eraseNum cut x).num j) := by
  change Supp.nv A n (if j < cut then .ref j else if j = cut then .lit x else .ref (j - 1))
  split
  · change j < n; omega
  · split
    · trivial
    · change j - 1 < n; omega

section
variable {M N σ : Map} (ha : σ.a = id) (hc : N.after σ = M)

include ha
theorem numImage_key (k : PKey) : σ.key k = k :=
  (Map.key_ext (M := Map.id) ha k).trans (Map.key_id k)

include hc
theorem numImage_a : N.a = M.a := by
  funext a
  have h := congrFun (congrArg Map.a hc) a
  simpa only [Map.after_a, congrFun ha a, id_eq] using h

theorem props_numImage {ks : List PKey} {l l' : Props} (h : PropsW M ks l l') :
    PropsW N ks (σ.props l) l' := by
  have hkey := Map.key_ext (numImage_a ha hc)
  induction h with
  | nil => exact .nil
  | both k p p' l l' hk hp _ ih =>
    have hp' : p' = N.prop (σ.prop p) := by rw [Map.prop_after, hc]; exact hp
    simpa only [Map.props, List.map_cons, numImage_key ha, hkey] using
      (PropsW.both k (σ.prop p) p' (σ.props l) l' hk hp' ih)
  | ghostL k p l l' hk _ ih =>
    simpa only [Map.props, List.map_cons, numImage_key ha] using
      (PropsW.ghostL k (σ.prop p) (σ.props l) l' hk ih)
  | ghostR k p' l l' hk _ ih =>
    apply PropsW.ghostR k p' (σ.props l) l' _ ih
    obtain ⟨k0, hk0, he⟩ := hk
    refine ⟨k0, hk0, ?_⟩
    have hm : N.a = M.a := numImage_a ha hc
    exact (Map.key_ext hm k0).trans he

theorem privs_numImage {ps : List (Nat × Name)} {l l' : List ((Nat × Name) × PropV)}
    (h : PrivsW M ps l l') : PrivsW N ps (σ.privs l) l' := by
  have ha' : ∀ b, σ.a b = b := fun b => congrFun ha b
  have hm : N.a = M.a := numImage_a ha hc
  induction h with
  | nil => exact .nil
  | both b n p p' l l' hk hp _ ih =>
    have hp' : p' = N.prop (σ.prop p) := by rw [Map.prop_after, hc]; exact hp
    simpa only [Map.privs, List.map_cons, ha', hm] using
      (PrivsW.both b n (σ.prop p) p' (σ.privs l) l' hk hp' ih)
  | ghostL b n p l l' hk _ ih =>
    simpa only [Map.privs, List.map_cons, ha'] using
      (PrivsW.ghostL b n (σ.prop p) (σ.privs l) l' hk ih)
  | ghostR b' n p' l l' hk _ ih =>
    exact .ghostR b' n p' (σ.privs l) l' (by simpa only [hm] using hk) ih

omit ha in
theorem mapW_numImage {gs : List Nat} {es es' : List (Val × Val)} (h : MapW M gs es es') :
    MapW N gs (σ.pairs es) es' := by
  intro c v hv
  rw [bi_firstValue σ c es] at hv
  cases hs : StringIndex.firstValue c es with
  | none => simp only [hs, Option.map_none] at hv; cases hv
  | some v0 =>
    simp only [hs, Option.map_some, Option.some.injEq] at hv
    subst v
    obtain ⟨v', he, hm⟩ := h c v0 hs
    refine ⟨v', he, hm.imp id ?_⟩
    intro hm
    rw [Map.val_after, hc]
    exact hm

omit ha hc in
theorem mapNone_numImage {gs : List Nat} {es es' : List (Val × Val)} (h : MapNone gs es es') :
    MapNone gs (σ.pairs es) es' := by
  intro c hg he
  rw [bi_firstValue σ c es] at he
  apply h c hg
  cases hs : StringIndex.firstValue c es with
  | none => rfl
  | some v => simp only [hs, Option.map_some] at he; cases he

theorem wide_numImage {w : WFrame} {o : HObj} {o' : Option HObj}
    (h : WideOK M w o o') : WideOK N w (σ.hobj o) o' := by
  have ha' : ∀ b, σ.a b = b := fun b => congrFun ha b
  have hm : N.a = M.a := numImage_a ha hc
  have ho : ∀ o, N.obj (σ.obj o) = M.obj o := fun o => by rw [Map.obj_after, hc]
  have hk : ∀ k, N.kind (σ.kind k) = M.kind k := fun k => by rw [Map.kind_after, hc]
  have hv : ∀ v, N.val (σ.val v) = M.val v := fun v => by rw [Map.val_after, hc]
  have hw : ∀ k, Wideable k → Wideable (σ.kind k) := by
    intro k h; cases k <;> simp_all [Wideable, Map.kind]
  cases o with
  | cell v =>
    cases w <;> cases o' with
    | none => exact h.elim
    | some z => cases z <;> trivial
  | obj o =>
    cases o' with
    | none => cases w <;> exact h.elim
    | some z =>
      cases z with
      | cell v => cases w <;> exact h.elim
      | obj o' =>
        cases w with
        | buf bs =>
          refine ⟨?_, ?_⟩
          · change σ.kind o.kind = .ordinary; rw [h.1]; rfl
          · change o' = { N.obj (σ.obj o) with kind := .buf bs }; rw [ho]; exact h.2
        | typed k b off n =>
          refine ⟨?_, ?_⟩
          · change σ.kind o.kind = .ordinary; rw [h.1]; rfl
          · change o' = { N.obj (σ.obj o) with kind := .typed k (N.a b) off n }
            rw [ho, hm]; exact h.2
        | ghost => exact ⟨hw _ h.1, h.2⟩
        | fields ks ps =>
          exact ⟨hw _ h.1, h.2.1.trans (hk _).symm, h.2.2.1.trans (hv _).symm,
            h.2.2.2.1, props_numImage ha hc h.2.2.2.2.1, privs_numImage ha hc h.2.2.2.2.2⟩
        | mapKeys gs =>
          obtain ⟨es, es', hes, hobj, hmap⟩ := h
          exact ⟨σ.pairs es, es', by change σ.kind o.kind = _; rw [hes]; rfl,
            by change o' = { N.obj (σ.obj o) with kind := .map es' }; rw [ho]; exact hobj,
            mapW_numImage hc hmap⟩
        | memo gs =>
          obtain ⟨es, es', hes, hobj, hmap, hnone⟩ := h
          exact ⟨σ.pairs es, es', by change σ.kind o.kind = _; rw [hes]; rfl,
            by change o' = { N.obj (σ.obj o) with kind := .map es' }; rw [ho]; exact hobj,
            mapW_numImage hc hmap, mapNone_numImage hnone⟩

omit ha in
theorem slotOK_numImage {fr : Nat → Option (List Val × List Val)} {a : Nat} {o : HObj} {o' : Option HObj}
    (hpre : ∀ pre pre', fr a = some (pre, pre') → σ.vals pre = pre)
    (h : SlotOK M fr a o o') : SlotOK N fr a (σ.hobj o) o' := by
  cases hf : fr a with
  | none =>
    simp only [SlotOK, hf] at h ⊢
    change o' = some (M.hobj o) at h
    rwa [Map.hobj_after, hc]
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    simp only [SlotOK, hf] at h ⊢
    change ∃ s t, o = .obj s ∧ o' = some (.obj t) ∧ FramedObj M pre pre' s t at h
    obtain ⟨s, t, rfl, rfl, xs, hkind, hout⟩ := h
    refine ⟨σ.obj s, t, rfl, rfl, σ.vals xs, ?_, ?_⟩
    · change σ.kind s.kind = .array (pre ++ σ.vals xs)
      rw [hkind]
      change Kind.array (σ.vals (pre ++ xs)) = _
      rw [show σ.vals (pre ++ xs) = σ.vals pre ++ σ.vals xs from List.map_append ..,
        hpre pre pre' hf]
    · change t = { N.obj (σ.obj s) with kind := .array (pre' ++ N.vals (σ.vals xs)) }
      rwa [Map.obj_after, Map.vals_after, hc]

theorem slot_numImage {fr : Nat → Option (List Val × List Val)} {W : Nat → Option WFrame}
    {a : Nat} {o : HObj} {o' : Option HObj}
    (hpre : ∀ pre pre', fr a = some (pre, pre') → σ.vals pre = pre)
    (h : SlotW M fr W a o o') : SlotW N fr W a (σ.hobj o) o' := by
  cases hw : W a with
  | none =>
    exact (SlotW.of_w_none hw).2 (slotOK_numImage hc hpre ((SlotW.of_w_none hw).1 h))
  | some w =>
    cases hf : fr a with
    | none =>
      apply (SlotW.of_fr_none hf).2
      rw [Map.hobj_after, hc]
      exact (SlotW.of_fr_none hf).1 h
    | some p =>
      exact (SlotW.of_wide hf hw).2 (wide_numImage ha hc ((SlotW.of_wide hf hw).1 h))

end
end Host.Ts.Sim.Compose
