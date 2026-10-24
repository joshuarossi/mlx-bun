import host.simgraph.family.KernelSlot
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx

/-! # Per-piece certificates and their composition

A forward's expected graph (`familyGraph`) is carried by the route's graph piece by piece: the forward body's
template carries most of it, each bridged stage's template (a KV append, an SSM recurrence, …) carries its
segment, each through its own embedding into the route (`Embeds`, the isolate and merge conversions). Here:

* `maskSeg d lo hi E`: `E` with every node outside `[lo, hi)` replaced by an input (`d`), which checks
  vacuously; `MatchesSeg kind G E cert lo hi` (`MatchesED` of the mask): the segment's nodes are carried, their
  arguments at `cert`'s carriers — below `lo` those are the segment's boundary carriers.
* `matchesSeg_map`, `matchesSeg_embed`: a piece's symbolic check covers every instance, and it transports
  along the piece's embedding into the route (`matchesED_map`, `matchesED_embed` of the mask).
* `nodeOkED_congr`; `matchesSeg_split`: **two adjacent pieces compose** — if one certificate carries
  `[lo, mid)`, another `[mid, hi)`, and the second's boundary carriers (the arguments below `mid` of its
  nodes) are the first's carriers of those nodes, the merged certificate (`mergeCert`) carries `[lo, hi)`.
  `matchesSeg_whole`: a certificate carrying `[0, |E|)` is a `MatchesED` of the whole forward.
* `forward_matches3`: a forward body with one bridged stage — body `[0, a)`, stage `[a, b)`, body `[b, n)` —
  through carriers at both boundaries; `piece_route`, `forward_pieces`: the same from the pieces' symbolic
  checks on their own template graphs, each along its embedding into the route (the isolate and merge
  conversions give the boundary carriers); `pieces_values`: the merged certificate's carriers hold the family's
  graph values (`EvE`) at the route contract (`family_template_stepR`'s conclusion without a single template).
* `deps_carrier`, `anc_carrier` (`host.simgraph.compose.Anc`): through a closure-aware match whose input
  carriers are leaves, every route ancestor of a carrier is a carrier of an ancestor in the expected graph
  (`srcAt_of`'s premise). -/

section
variable {δ κ : Type}

/-- `E` with every node outside `[lo, hi)` an input (`d`, no arguments). -/
def maskSeg (d : κ) (lo hi : Nat) (E : List (RNode δ κ)) : List (RNode δ κ) :=
  E.mapIdx fun k e => if lo ≤ k ∧ k < hi then e else ⟨.input d, []⟩

@[simp] theorem maskSeg_length (d : κ) (lo hi : Nat) (E : List (RNode δ κ)) : (maskSeg d lo hi E).length = E.length := by
  simp [maskSeg]

theorem maskSeg_get (d : κ) (lo hi : Nat) (E : List (RNode δ κ)) (k : Nat) :
    (maskSeg d lo hi E)[k]? = E[k]?.map fun e => if lo ≤ k ∧ k < hi then e else ⟨.input d, []⟩ := by
  simp [maskSeg, List.getElem?_mapIdx]

theorem maskSeg_whole (d : κ) (E : List (RNode δ κ)) : maskSeg d 0 E.length E = E := by
  apply List.ext_getElem?
  intro k
  rw [maskSeg_get]
  cases h : E[k]? with
  | none => rfl
  | some e =>
    have : k < E.length := (List.getElem?_eq_some_iff.mp h).1
    simp [this]

theorem maskSeg_map {δ' : Type} (f : δ → δ') (d : κ) (lo hi : Nat) (E : List (RNode δ κ)) :
    (maskSeg d lo hi E).map (mapN f) = maskSeg d lo hi (E.map (mapN f)) := by
  apply List.ext_getElem?
  intro k
  rw [List.getElem?_map, maskSeg_get, maskSeg_get, List.getElem?_map]
  cases E[k]? with
  | none => rfl
  | some e =>
    simp only [Option.map_some]
    split <;> rfl

end

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]

/-- **A piece's certificate**: `cert` carries the nodes `[lo, hi)` of `E` in `G`. -/
def MatchesSeg (d : κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (cert : List Nat) (lo hi : Nat) : Bool :=
  MatchesED kind G (maskSeg d lo hi E) cert

theorem nodeOkED_input (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat)
    (d : κ) : nodeOkED kind G cert k ⟨.input d, []⟩ = true := by
  simp [nodeOkED, isInputD]

/-- A segment's check, node by node. -/
theorem matchesSeg_iff (d : κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (cert : List Nat) (lo hi : Nat) :
    MatchesSeg d kind G E cert lo hi = true ↔ ∀ k (hk : k < E.length), lo ≤ k → k < hi → nodeOkED kind G cert k E[k] = true := by
  unfold MatchesSeg MatchesED
  rw [List.all_eq_true]
  constructor
  · intro h k hk h1 h2
    have := h k (List.mem_range.mpr (by simpa using hk))
    rw [maskSeg_get, List.getElem?_eq_getElem hk] at this
    simpa [h1, h2] using this
  · intro h k hk
    have hk' : k < E.length := by simpa using List.mem_range.mp hk
    rw [maskSeg_get, List.getElem?_eq_getElem hk']
    dsimp only [Option.map_some]
    split
    · rename_i hc; exact h k hk' hc.1 hc.2
    · exact nodeOkED_input kind G cert k d

/-- **The whole forward** from a certificate carrying every node. -/
theorem matchesSeg_whole (d : κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (cert : List Nat) (h : MatchesSeg d kind G E cert 0 E.length = true) : MatchesED kind G E cert = true := by
  unfold MatchesSeg at h
  rwa [maskSeg_whole] at h

/-- A node's check reads the certificate only at the node and its arguments. -/
theorem nodeOkED_congr (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (c c' : List Nat) (k : Nat)
    (e : RNode δ κ) (hk : certAt c k = certAt c' k) (hj : ∀ j ∈ e.ins, certAt c j = certAt c' j) :
    nodeOkED kind G c k e = nodeOkED kind G c' k e := by
  have hm : e.ins.map (certAt c) = e.ins.map (certAt c') := List.map_congr_left hj
  have ha : (e.ins.all fun j => decide (certAt c j < certAt c' k)) = e.ins.all fun j => decide (certAt c' j < certAt c' k) := by
    rw [Bool.eq_iff_iff, List.all_eq_true, List.all_eq_true]
    exact ⟨fun h j hj' => by rw [← hj j hj']; exact h j hj', fun h j hj' => by rw [hj j hj']; exact h j hj'⟩
  simp only [nodeOkED, closureCheck, plainCheck, hk, hm, ha]

/-- Two certificates merged at `mid`: the first's carriers below, the second's from `mid` (length `n`). -/
def mergeCert (c1 c2 : List Nat) (mid n : Nat) : List Nat :=
  (List.range n).map fun k => if k < mid then certAt c1 k else certAt c2 k

theorem certAt_merge (c1 c2 : List Nat) (mid n k : Nat) (hk : k < n) :
    certAt (mergeCert c1 c2 mid n) k = if k < mid then certAt c1 k else certAt c2 k := by
  simp [mergeCert, certAt, hk]

/-- **Two adjacent pieces compose**: `c1` carries `[lo, mid)`, `c2` carries `[mid, hi)`, and `c2`'s boundary
carriers — the arguments below `mid` of its nodes — are `c1`'s. The merged certificate carries `[lo, hi)`. -/
theorem matchesSeg_split (d : κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (c1 c2 : List Nat) (lo mid hi : Nat)
    (h1 : MatchesSeg d kind G E c1 lo mid = true) (h2 : MatchesSeg d kind G E c2 mid hi = true)
    (hb : ∀ k (hk : k < E.length), mid ≤ k → k < hi → ∀ j ∈ E[k].ins, j < mid → certAt c2 j = certAt c1 j) :
    MatchesSeg d kind G E (mergeCert c1 c2 mid E.length) lo hi = true := by
  rw [matchesSeg_iff] at h1 h2 ⊢
  intro k hk hl hh
  have hargs : ∀ j ∈ E[k].ins, j < k := by
    have hok : nodeOkED kind G (if k < mid then c1 else c2) k E[k] = true := by
      split
      · exact h1 k hk hl (by omega)
      · exact h2 k hk (by omega) hh
    simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at hok
    exact hok.1.1
  by_cases hm : k < mid
  · rw [nodeOkED_congr kind G _ c1 k E[k] (by rw [certAt_merge _ _ _ _ _ hk, ite_eq_left hm])
      (fun j hj => by rw [certAt_merge _ _ _ _ _ (by have := hargs j hj; omega), ite_eq_left (by have := hargs j hj; omega)])]
    exact h1 k hk hl hm
  · rw [nodeOkED_congr kind G _ c2 k E[k] (by rw [certAt_merge _ _ _ _ _ hk, ite_eq_right hm]) (fun j hj => by
      have hjk := hargs j hj
      rw [certAt_merge _ _ _ _ _ (by omega)]
      by_cases hjm : j < mid
      · rw [ite_eq_left hjm, hb k hk (by omega) hh j hj hjm]
      · rw [ite_eq_right hjm])]
    exact h2 k hk (by omega) hh

end

section
variable {κ : Type} [DecidableEq κ]

/-- **A piece's symbolic check covers every instance.** -/
theorem matchesSeg_map {δ : Type} [DecidableEq δ] (f : δ → Int) (d : κ) (kind : Nat → Option Compiled)
    (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (cert : List Nat) (lo hi : Nat)
    (h : MatchesSeg d kind G E cert lo hi = true) :
    MatchesSeg d kind (mapG f G) (E.map (mapN f)) cert lo hi = true := by
  unfold MatchesSeg at h ⊢
  rw [← maskSeg_map]
  exact matchesED_map f kind G _ cert h

/-- **A piece's certificate along its embedding into the route** (closure objects renamed by `cl`). -/
theorem matchesSeg_embed {σ cl : Nat → Nat} (d : κ) (kind kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c)
    (G G' : Nat → Option (RNode Int κ)) (h : Embeds σ cl G G') (E : List (RNode Int κ)) (cert : List Nat) (lo hi : Nat)
    (hlen : E.length ≤ cert.length) (hm : MatchesSeg d kind G E cert lo hi = true) :
    MatchesSeg d kind' G' E (cert.map σ) lo hi = true :=
  matchesED_embed kind kind' hk G G' h _ cert (by simpa using hlen) hm

/-- **A forward body with one bridged stage**, through carriers at both boundaries: the body's certificate carries
`[0, a)` and `[b, n)`, the stage's `[a, b)`; the stage's arguments below `a` are at the body's carriers, the body's
arguments in `[a, b)` (the stage's results) at the stage's. The merged certificate carries the whole forward. -/
theorem forward_matches3 (d : κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ)) (E : List (RNode Int κ))
    (cb cs : List Nat) (a b : Nat)
    (h1 : MatchesSeg d kind G E cb 0 a = true) (h2 : MatchesSeg d kind G E cs a b = true)
    (h3 : MatchesSeg d kind G E cb b E.length = true)
    (hin : ∀ k (hk : k < E.length), a ≤ k → k < b → ∀ j ∈ E[k].ins, j < a → certAt cs j = certAt cb j)
    (hout : ∀ k (hk : k < E.length), b ≤ k → ∀ j ∈ E[k].ins, a ≤ j → j < b → certAt cb j = certAt cs j) :
    MatchesED kind G E (mergeCert (mergeCert cb cs a E.length) cb b E.length) = true := by
  have h12 := matchesSeg_split d kind G E cb cs 0 a b h1 h2 hin
  refine matchesSeg_whole d kind G E _ (matchesSeg_split d kind G E _ cb 0 b E.length h12 h3 ?_)
  intro k hk hbk _ j hj hjb
  have hjk : j < k := by
    have := (matchesSeg_iff d kind G E cb b E.length).mp h3 k hk hbk hk
    simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
    exact this.1.1 j hj
  rw [certAt_merge _ _ _ _ _ (by omega)]
  by_cases hja : j < a
  · rw [ite_eq_left hja]
  · rw [ite_eq_right hja, hout k hk hbk j hj (by omega) hjb]

end

/-! ## Pieces at the route -/

section
variable {κ : Type} [DecidableEq κ]

/-- **A piece's symbolic certificate at the route**: checked once on its template graph against the family's
symbolic graph, it carries the family's segment at every instance `ν` in the same branches, along the piece's
embedding into the route. -/
theorem piece_route (F : RowFamily κ) (d : κ) (o₀ n₀ : Nat) (ss₀ : List StageLayout) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig o₀ n₀ o n) ss₀ ss)
    (Gs : Nat → Option (RNode PDim κ)) (kind : Nat → Option Compiled) (cert : List Nat) (lo hi : Nat)
    (hlen : (familyGraph F.ops id o₀ n₀ ss₀).1.length ≤ cert.length)
    (h : MatchesSeg d kind Gs (familyGraph F.ops id o₀ n₀ ss₀).1 cert lo hi = true)
    (G : Nat → Option (RNode Int κ)) {σ cl : Nat → Nat} (emb : Embeds σ cl (mapG (PDim.eval ν) Gs) G)
    (kind' : Nat → Option Compiled) (hk : ∀ c, kind' (cl c) = kind c) :
    MatchesSeg d kind' G (familyGraph F.ops (PDim.eval ν) o n ss).1 (cert.map σ) lo hi = true := by
  have hm := matchesSeg_map (PDim.eval ν) d kind Gs _ cert lo hi h
  rw [show (familyGraph F.ops id o₀ n₀ ss₀).1.map (mapN (PDim.eval ν)) = (familyGraph F.ops (PDim.eval ν) o n ss).1 from
    congrArg Prod.fst (family_eval F o₀ n₀ ss₀ ν o n ss hsig)] at hm
  have hl : (familyGraph F.ops (PDim.eval ν) o n ss).1.length ≤ cert.length := by
    rw [← congrArg Prod.fst (family_eval F o₀ n₀ ss₀ ν o n ss hsig), List.length_map]; exact hlen
  exact matchesSeg_embed d kind kind' hk _ G emb _ cert lo hi hl hm

/-- **A forward body and one bridged stage at the route**: the body's template carries `[0, a)` and `[b, n)`, the
stage's `[a, b)`, each along its own embedding; at the route the stage's arguments below `a` are the body's
carriers (the isolate conversion), the body's arguments in `[a, b)` the stage's (the merge conversion). The merged
route certificate carries the whole forward. -/
theorem forward_pieces (F : RowFamily κ) (d : κ) (o₀ n₀ : Nat) (ss₀ : List StageLayout) (ν : Nat → Int) (o n : Nat)
    (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig o₀ n₀ o n) ss₀ ss) (a b : Nat)
    (Gb Gt : Nat → Option (RNode PDim κ)) (kb kt : Nat → Option Compiled) (cb ct : List Nat)
    (hlb : (familyGraph F.ops id o₀ n₀ ss₀).1.length ≤ cb.length) (hlt : (familyGraph F.ops id o₀ n₀ ss₀).1.length ≤ ct.length)
    (h1 : MatchesSeg d kb Gb (familyGraph F.ops id o₀ n₀ ss₀).1 cb 0 a = true)
    (h2 : MatchesSeg d kt Gt (familyGraph F.ops id o₀ n₀ ss₀).1 ct a b = true)
    (h3 : MatchesSeg d kb Gb (familyGraph F.ops id o₀ n₀ ss₀).1 cb b (familyGraph F.ops id o₀ n₀ ss₀).1.length = true)
    (G : Nat → Option (RNode Int κ)) {σb clb σt clt : Nat → Nat} (eb : Embeds σb clb (mapG (PDim.eval ν) Gb) G)
    (et : Embeds σt clt (mapG (PDim.eval ν) Gt) G) (kind' : Nat → Option Compiled) (hkb : ∀ c, kind' (clb c) = kb c)
    (hkt : ∀ c, kind' (clt c) = kt c)
    (hin : ∀ k (hk : k < (familyGraph F.ops (PDim.eval ν) o n ss).1.length), a ≤ k → k < b →
      ∀ j ∈ (familyGraph F.ops (PDim.eval ν) o n ss).1[k].ins, j < a → σt (certAt ct j) = σb (certAt cb j))
    (hout : ∀ k (hk : k < (familyGraph F.ops (PDim.eval ν) o n ss).1.length), b ≤ k →
      ∀ j ∈ (familyGraph F.ops (PDim.eval ν) o n ss).1[k].ins, a ≤ j → j < b → σb (certAt cb j) = σt (certAt ct j)) :
    MatchesED kind' G (familyGraph F.ops (PDim.eval ν) o n ss).1
      (mergeCert (mergeCert (cb.map σb) (ct.map σt) a (familyGraph F.ops (PDim.eval ν) o n ss).1.length) (cb.map σb) b
        (familyGraph F.ops (PDim.eval ν) o n ss).1.length) = true := by
  have hlen : (familyGraph F.ops (PDim.eval ν) o n ss).1.length = (familyGraph F.ops id o₀ n₀ ss₀).1.length := by
    rw [← congrArg Prod.fst (family_eval F o₀ n₀ ss₀ ν o n ss hsig), List.length_map]
  have r1 := piece_route F d o₀ n₀ ss₀ ν o n ss hsig Gb kb cb 0 a hlb h1 G eb kind' hkb
  have r2 := piece_route F d o₀ n₀ ss₀ ν o n ss hsig Gt kt ct a b hlt h2 G et kind' hkt
  have r3 := piece_route F d o₀ n₀ ss₀ ν o n ss hsig Gb kb cb b _ hlb h3 G eb kind' hkb
  rw [← hlen] at r3
  have hargs : ∀ k (hk : k < (familyGraph F.ops (PDim.eval ν) o n ss).1.length),
      ∀ j ∈ (familyGraph F.ops (PDim.eval ν) o n ss).1[k].ins, j < (familyGraph F.ops (PDim.eval ν) o n ss).1.length := by
    intro k hk j hj
    by_cases ha : k < a
    · have := (matchesSeg_iff d kind' G _ _ 0 a).mp r1 k hk (Nat.zero_le k) ha
      simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
      have := this.1.1 j hj; omega
    · by_cases hb : k < b
      · have := (matchesSeg_iff d kind' G _ _ a b).mp r2 k hk (by omega) hb
        simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
        have := this.1.1 j hj; omega
      · have := (matchesSeg_iff d kind' G _ _ b _).mp r3 k hk (by omega) hk
        simp only [nodeOkED, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at this
        have := this.1.1 j hj; omega
  refine forward_matches3 d kind' G _ (cb.map σb) (ct.map σt) a b r1 r2 r3 (fun k hk h1 h2 j hj hja => ?_)
    (fun k hk h1 j hj h2 h3 => ?_)
  · have hjl := hargs k hk j hj
    rw [certAt_map σt ct j (by omega), certAt_map σb cb j (by omega)]
    exact hin k hk h1 h2 j hj hja
  · have hjl := hargs k hk j hj
    rw [certAt_map σt ct j (by omega), certAt_map σb cb j (by omega)]
    exact hout k hk h1 j hj h2 h3

end

/-! ## Values -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) {κ : Type} [DecidableEq κ]

/-- **The composed pieces' carriers hold the family's values**: a certificate carrying the whole forward (e.g.
`forward_matches3`'s), its input carriers holding the inputs (`InputsHeldR`), no replayed kernel node — every value
the family's graph has (`EvE`, e.g. from its reference computation, `rowTpl_eval`) is its carrier's in `evalRR`. -/
theorem pieces_values (env : Env κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ))
    (E : List (RNode Int κ)) (cert : List Nat) (hm : MatchesED kind G E cert = true)
    (hin : InputsHeldR P K env kind G E cert) (hG : KernelsPlain G) (i : Nat) (v : Value)
    (hv : EvE P K.toKernelContract env (ksR P K env) E i v) : evalRR P K env kind G (certAt cert i) = some v :=
  matches_evalG P K.toKernelContract env (ksR P K env) kind (evalRR P K env kind) (primEvalR P K env)
    (evalRR_eq P K env kind) G E cert hm hin (primsAgree_R P K env G hG) i hv.1 v hv.2

end

end Host.Mlx.SimGraph
