import host.simgraph.family.MatchE
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Family certificates along an embedding

`matchesED_embed`: a graph carrying `E` at `cert` (closures named by `kind`)
carries it at `cert.map σ` in any graph that embeds it (`Embeds σ cl`), the
closures there named by `kind'` with `kind' (cl c) = kind c` (closure
objects renamed by `cl`). With `matchesED_map` (template to instance) and
`matches_evalE` (values), this is the family analogue of `matches_embed`. -/

section
variable {κ : Type} [DecidableEq κ] {σ cl : Nat → Nat}

omit [DecidableEq κ] in
theorem renameCls_binary (p : RPrim Int κ) (op : List Char) : renameCls cl p = .binary op ↔ p = .binary op := by
  cases p <;> simp [renameCls]

omit [DecidableEq κ] in
theorem renameCls_astype (p : RPrim Int κ) (d : Nat) : renameCls cl p = .astype d ↔ p = .astype d := by
  cases p <;> simp [renameCls]

/-- A closure body survives the renaming. -/
theorem closureBody_embed (kind kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c) (cls : Nat)
    (p : RPrim Int κ) (r : RNode Int κ) (b b' : Nat → Option (RNode Int κ))
    (Re : Nat → Prop) (hr : ∀ k ∈ r.ins, Re k)
    (hb : ∀ j x, Re j → b j = some x → b' (σ j) = some (renameN σ cl x) ∧ ∀ k ∈ x.ins, Re k) (x : Compiled × List Nat)
    (h : closureBody kind cls p r b = some x) :
    closureBody kind' (cl cls) (renameCls cl p) (renameN σ cl r) b' = some (x.1, x.2.map σ) ∧ ∀ a ∈ x.2, Re a := by
  have hrin : (renameN σ cl r).ins = r.ins.map σ := rfl
  have hpr : ∀ (y : RNode Int κ) (c : Nat) (q : RPrim Int κ), y.prim = .replayed c q → renameCls cl q = q →
      (renameN σ cl y).prim = .replayed (cl c) q := by
    intro y c q hy hq; simp [renameN, hy, renameCls, hq]
  have hnd : ∀ (y : RNode Int κ) (c : Nat) (op : List Char) (l : List Nat),
      y = ⟨.replayed c (.unary op), l⟩ → renameN σ cl y = ⟨.replayed (cl c) (.unary op), l.map σ⟩ := by
    intro y c op l hy; subst hy; rfl
  unfold closureBody at h ⊢
  rw [hk]
  cases hkc : kind cls with
  | none => simp [hkc] at h
  | some k =>
    simp only [hkc, Option.bind_eq_bind, Option.bind_some] at h ⊢
    cases k with
    | silu =>
      simp only at h ⊢
      by_cases hp : p = .binary chars!"multiply"
      · simp only [hp, ↓reduceIte] at h
        simp only [show renameCls cl p = .binary chars!"multiply" from (renameCls_binary p _).mpr hp, ↓reduceIte]
        obtain ⟨⟨x0, sg⟩, h2, h⟩ := Option.bind_eq_some_iff.mp h
        obtain ⟨sn, hsn, h⟩ := Option.bind_eq_some_iff.mp h
        split at h
        · rename_i hs
          cases h
          have hm := two?_mem h2
          have Bs := hb _ _ (hr _ hm.2) hsn
          refine ⟨?_, ?_⟩
          · rw [hrin, two?_map, h2, Option.map_some, Option.bind_some]
            simp only
            rw [Bs.1, Option.bind_some, hnd sn cls _ [x0] hs]
            simp
          · intro a ha
            obtain rfl := List.mem_singleton.mp ha
            exact hr _ hm.1
        · cases h
      · simp [hp] at h
    | swiglu =>
      simp only at h ⊢
      by_cases hp : p = .binary chars!"multiply"
      · simp only [hp, ↓reduceIte] at h
        simp only [show renameCls cl p = .binary chars!"multiply" from (renameCls_binary p _).mpr hp, ↓reduceIte]
        obtain ⟨⟨m, u⟩, h2, h⟩ := Option.bind_eq_some_iff.mp h
        obtain ⟨mn, hmn, h⟩ := Option.bind_eq_some_iff.mp h
        split at h
        · rename_i hm
          obtain ⟨⟨g, sg⟩, h3, h⟩ := Option.bind_eq_some_iff.mp h
          obtain ⟨sn, hsn, h⟩ := Option.bind_eq_some_iff.mp h
          split at h
          · rename_i hs
            cases h
            have m2 := two?_mem h2
            have Bm := hb _ _ (hr _ m2.1) hmn
            have m3 := two?_mem h3
            have Bs := hb _ _ (Bm.2 _ m3.2) hsn
            refine ⟨?_, ?_⟩
            · rw [hrin, two?_map, h2, Option.map_some, Option.bind_some]
              simp only
              rw [Bm.1, Option.bind_some, hpr mn cls _ hm rfl]
              simp only [↓reduceIte]
              rw [show (renameN σ cl mn).ins = mn.ins.map σ from rfl, two?_map, h3, Option.map_some, Option.bind_some]
              simp only
              rw [Bs.1, Option.bind_some, hnd sn cls _ [g] hs]
              simp
            · intro a ha
              simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
              rcases ha with rfl | rfl
              · exact Bm.2 _ m3.1
              · exact hr _ m2.2
          · cases h
        · cases h
      · simp [hp] at h
    | preciseSwiglu =>
      simp only at h ⊢
      by_cases hp : p = .astype Ffi.dtBf16
      · simp only [hp, ↓reduceIte] at h
        simp only [show renameCls cl p = .astype Ffi.dtBf16 from (renameCls_astype p _).mpr hp, ↓reduceIte]
        obtain ⟨pr, h1, h⟩ := Option.bind_eq_some_iff.mp h
        obtain ⟨prn, hprn, h⟩ := Option.bind_eq_some_iff.mp h
        by_cases hpm : prn.prim = .replayed cls (.binary chars!"multiply")
        · simp only [hpm, ↓reduceIte] at h
          obtain ⟨⟨sl, xf⟩, h3, h⟩ := Option.bind_eq_some_iff.mp h
          obtain ⟨sln, hsln, h⟩ := Option.bind_eq_some_iff.mp h
          by_cases hsm : sln.prim = .replayed cls (.binary chars!"multiply")
          · simp only [hsm, ↓reduceIte] at h
            obtain ⟨⟨gf, sg⟩, h4, h⟩ := Option.bind_eq_some_iff.mp h
            obtain ⟨sn, hsn, h⟩ := Option.bind_eq_some_iff.mp h
            by_cases hs : sn = ⟨.replayed cls (.unary chars!"sigmoid"), [gf]⟩
            · simp only [hs, ↓reduceIte] at h
              obtain ⟨gfn, hgfn, h⟩ := Option.bind_eq_some_iff.mp h
              by_cases hga : gfn.prim = .replayed cls (.astype Ffi.dtF32)
              · simp only [hga, ↓reduceIte] at h
                obtain ⟨g, h5, h⟩ := Option.bind_eq_some_iff.mp h
                obtain ⟨xfn, hxfn, h⟩ := Option.bind_eq_some_iff.mp h
                by_cases hxa : xfn.prim = .replayed cls (.astype Ffi.dtF32)
                · simp only [hxa, ↓reduceIte] at h
                  obtain ⟨xx, h6, h⟩ := Option.bind_eq_some_iff.mp h
                  cases h
                  have Bp := hb _ _ (hr _ (one?_mem h1)) hprn
                  have m3 := two?_mem h3
                  have Bl := hb _ _ (Bp.2 _ m3.1) hsln
                  have m4 := two?_mem h4
                  have Bs := hb _ _ (Bl.2 _ m4.2) hsn
                  have Bg := hb _ _ (Bl.2 _ m4.1) hgfn
                  have Bx := hb _ _ (Bp.2 _ m3.2) hxfn
                  refine ⟨?_, ?_⟩
                  · rw [hrin, one?_map, h1, Option.map_some, Option.bind_some, Bp.1, Option.bind_some,
                      hpr prn cls _ hpm rfl]
                    simp only [↓reduceIte]
                    rw [show (renameN σ cl prn).ins = prn.ins.map σ from rfl, two?_map, h3, Option.map_some,
                      Option.bind_some]
                    simp only
                    rw [Bl.1, Option.bind_some, hpr sln cls _ hsm rfl]
                    simp only [↓reduceIte]
                    rw [show (renameN σ cl sln).ins = sln.ins.map σ from rfl, two?_map, h4, Option.map_some,
                      Option.bind_some]
                    simp only
                    rw [Bs.1, Option.bind_some, hnd sn cls _ [gf] hs]
                    simp only [↓reduceIte, List.map_cons, List.map_nil]
                    rw [Bg.1, Option.bind_some, hpr gfn cls _ hga rfl]
                    simp only [↓reduceIte]
                    rw [show (renameN σ cl gfn).ins = gfn.ins.map σ from rfl, one?_map, h5, Option.map_some,
                      Option.bind_some, Bx.1, Option.bind_some, hpr xfn cls _ hxa rfl]
                    simp only [↓reduceIte]
                    rw [show (renameN σ cl xfn).ins = xfn.ins.map σ from rfl, one?_map, h6, Option.map_some,
                      Option.bind_some]
                    simp
                  · intro a ha
                    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
                    rcases ha with rfl | rfl
                    · exact Bg.2 _ (one?_mem h5)
                    · exact Bx.2 _ (one?_mem h6)
                · simp [hxa] at h
              · simp [hga] at h
            · simp [hs] at h
          · simp [hsm] at h
        · simp [hpm] at h
      · simp [hp] at h

theorem closureLeaves_gen (kind kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c)
    (G G' : Nat → Option (RNode Int κ)) (hn : ∀ j r, G j = some r → G' (σ j) = some (renameN σ cl r)) (i : Nat)
    (Re : Nat → Prop) (hlt : ∀ j, Re j → j < i → σ j < σ i) (hroot : ∀ r, G i = some r → ∀ k ∈ r.ins, Re k)
    (hstep : ∀ j x, Re j → j < i → G j = some x → ∀ k ∈ x.ins, Re k) (x : Compiled × List Nat)
    (hc : closureLeaves kind G i = some x) : closureLeaves kind' G' (σ i) = some (x.1, x.2.map σ) ∧ ∀ a ∈ x.2, Re a := by
  unfold closureLeaves at hc ⊢
  obtain ⟨r, hr, ha⟩ := Option.bind_eq_some_iff.mp hc
  rw [hn i r hr, Option.bind_some]
  unfold closureAux at ha ⊢
  split at ha
  · rename_i cls p hp
    split at ha
    · rename_i he
      have hpr : (renameN σ cl r).prim = .replayed (cl cls) (renameCls cl p) := by simp [renameN, hp, renameCls]
      simp only [hpr, elementwise_rename, he, ↓reduceIte]
      refine closureBody_embed kind kind' hk cls p r _ _ Re (hroot r hr) (fun j y hj hy => ?_) x ha
      by_cases hji : j < i
      · rw [ite_eq_left hji] at hy
        refine ⟨?_, hstep j y hj hji hy⟩
        rw [ite_eq_left (hlt j hj hji)]
        exact hn j y hy
      · rw [ite_eq_right hji] at hy; cases hy
    · cases ha
  · cases ha

theorem closureLeaves_reach (kind kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c)
    (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (i : Nat) (x : Compiled × List Nat)
    (hc : closureLeaves kind G i = some x) : closureLeaves kind' G' (σ i) = some (x.1, x.2.map σ) ∧ ∀ a ∈ x.2, σ a < σ i :=
  closureLeaves_gen kind kind' hk G G' h.node i (fun j => σ j < σ i) (fun _ hj _ => hj) (fun r hr => h.order i r hr)
    (fun j y hj _ hy k hk' => Nat.lt_trans (h.order j y hy k hk') hj) x hc

theorem closureLeaves_embed (kind kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c)
    (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (i : Nat) (x : Compiled × List Nat)
    (hc : closureLeaves kind G i = some x) : closureLeaves kind' G' (σ i) = some (x.1, x.2.map σ) :=
  (closureLeaves_reach kind kind' hk G G' h i x hc).1

/-- **Family certificates transport along an embedding.** -/
theorem matchesED_embed (kind kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c)
    (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (E : List (RNode Int κ)) (cert : List Nat)
    (hlen : E.length ≤ cert.length) (hm : MatchesED kind G E cert = true) :
    MatchesED kind' G' E (cert.map σ) = true := by
  unfold MatchesED at hm ⊢
  refine List.all_eq_true.mpr fun k hk' => ?_
  have hkE : k < E.length := List.mem_range.mp hk'
  have hok := List.all_eq_true.mp hm k hk'
  rw [List.getElem?_eq_getElem hkE] at hok ⊢
  dsimp only at hok ⊢
  generalize E[k] = e at hok ⊢
  simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok ⊢
  obtain ⟨⟨hlt, hcl⟩, hrest⟩ := hok
  have hcm : ∀ j ∈ e.ins, certAt (cert.map σ) j = σ (certAt cert j) := fun j hj =>
    certAt_map σ cert j (by have := hlt j hj; omega)
  have hck : certAt (cert.map σ) k = σ (certAt cert k) := certAt_map σ cert k (by omega)
  have hins : e.ins.map (certAt (cert.map σ)) = (e.ins.map (certAt cert)).map σ := by
    rw [List.map_map]
    exact List.map_congr_left fun j hj => hcm j hj
  by_cases hi : isInputD e.prim = true
  · refine ⟨⟨hlt, ?_⟩, by rw [ite_eq_left hi] at hrest ⊢; exact hrest⟩
    intro j hj
    rw [ite_eq_left hi] at hrest
    have : e.ins = [] := by simpa using hrest
    rw [this] at hj; cases hj
  · rw [ite_eq_right hi] at hrest ⊢
    refine ⟨⟨hlt, fun j hj => ?_⟩, ?_⟩
    · rw [hcm j hj, hck]
      have hm : certAt cert j ∈ e.ins.map (certAt cert) := List.mem_map_of_mem hj
      by_cases hc : e.prim = .computeG
      · rw [ite_eq_left hc] at hrest
        simp only [decide_eq_true_eq] at hrest
        exact (cgLeaves_reach G G' h _ _ hrest).2 _ hm
      · rw [ite_eq_right hc] at hrest
        cases hk2 : closureOf? e.prim with
        | some c =>
          simp only [closureCheck, hk2, Option.map_some, Option.getD_some, decide_eq_true_eq] at hrest
          rw [closureLeavesD_int] at hrest
          exact (closureLeaves_reach kind kind' hk G G' h _ _ hrest).2 _ hm
        | none =>
          simp only [closureCheck, hk2, Option.map_none, Option.getD_none, plainCheck, Bool.and_eq_true] at hrest
          obtain ⟨_, hg⟩ := hrest
          cases hr : G (certAt cert k) with
          | none => rw [hr] at hg; cases hg
          | some r =>
            rw [hr] at hg
            simp only [decide_eq_true_eq] at hg
            obtain ⟨_, _, hrins⟩ := hg
            exact h.order _ r hr _ (hrins ▸ hm)
    · by_cases hc : e.prim = .computeG
      · rw [ite_eq_left hc] at hrest ⊢
        simp only [decide_eq_true_eq] at hrest ⊢
        rw [hck, cgLeaves_embed G G' h _ _ hrest, hins]
      · rw [ite_eq_right hc] at hrest ⊢
        cases hk2 : closureOf? e.prim with
        | some c =>
          simp only [closureCheck, hk2, Option.map_some, Option.getD_some, decide_eq_true_eq] at hrest ⊢
          rw [closureLeavesD_int] at hrest ⊢
          rw [hck, closureLeaves_embed kind kind' hk G G' h _ _ hrest, hins]
        | none =>
          simp only [closureCheck, hk2, Option.map_none, Option.getD_none, plainCheck, Bool.and_eq_true] at hrest ⊢
          obtain ⟨hx, hg⟩ := hrest
          refine ⟨hx, ?_⟩
          rw [hck]
          cases hr : G (certAt cert k) with
          | none => rw [hr] at hg; cases hg
          | some r =>
            rw [hr] at hg
            simp only [decide_eq_true_eq] at hg
            obtain ⟨hs, hor, hrins⟩ := hg
            rw [h.node _ r hr]
            simp only [decide_eq_true_eq]
            refine ⟨by rw [renameN, strip_rename, hs], ?_, by rw [renameN, hrins, hins]⟩
            rcases hor with hor | hor
            · left
              show renameCls cl r.prim = e.prim
              rw [hor]
              cases hp : e.prim with
              | replayed _ _ =>
                have := strip_not_replayed (κ := κ) r.prim
                rw [← hor] at hp
                exact absurd (hs.trans (hor.symm.trans hp)) (this _ _)
              | _ => rfl
            · exact .inr hor

end

end Host.Mlx.SimGraph
