import host.sim.full.BridgeOps

/-! # Classifying new nodes under the map

After an MLX call the bridge classifies the call's new nodes (`FfiAne.classify`): a node over an
alias is a view, a reader or a writer of surfaces. On related states (`G.MR` at the states after the
call, every node fully corresponding, the template's nodes below its counter present) the target
classifies the images of the template's new nodes as the template does (`classify_rel`):

* the renaming is injective below the template's node counter and sends nodes from it on to the
  target's from its counter on (`G.MR.nfresh`), where neither bridge records anything, so the inputs'
  aliases agree (`aliasIns_map`);
* a node's image has the image primitive and inputs (`G.NodeR`), and the classification reads the
  primitive's constructor, a slice's strides only where they are literal ones, which the map keeps,
  an `astype`'s source dtype and a kernel's output count. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim
open Host.Mlx.FfiAne (Alias Touch)
open Host.Mlx.Ffi (Node Prim Dim)

theorem get_set_eq_of_lt {α : Type} (t : PTrie α) {n : Nat} (v : α) (hn : n < 2 ^ 62) : (t.set n v).get n = some v :=
  PTrie.get_set_self _ _ _ (Nat.lt_of_le_of_lt (Nat.div_le_self _ 4096) (by rw [show (4 : Nat) ^ 31 = 2 ^ 62 from rfl]; exact hn))

theorem isSome_set_cases {α : Type} (t : PTrie α) (n : Nat) (v : α) (m : Nat) (h : ((t.set n v).get m).isSome = true) :
    (t.get m).isSome = true ∨ m = n := by
  rcases PTrie.get_set_cases t n v m with e | ⟨e1, _⟩
  · rw [e] at h; exact .inl h
  · exact .inr e1

theorem unitStrides_map (M : Map) {sr : List Dim} (hs : Host.Mlx.FfiAne.unitStrides sr = true) :
    Host.Mlx.FfiAne.unitStrides (M.dims sr) = true := by
  unfold Host.Mlx.FfiAne.unitStrides at hs ⊢
  rw [List.all_eq_true] at hs ⊢
  intro d hd
  obtain ⟨d0, hd0, rfl⟩ := List.mem_map.mp hd
  have := of_decide_eq_true (hs d0 hd0)
  subst this
  exact decide_eq_true rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y)
  (hF : ∀ i, Full P i) (hd : ∀ i, i < x.nnext → PN x i)
include hr hF hd

theorem _root_.Host.Ts.Sim.G.MR.bnode_inj {i j : Nat} (hi : i < x.nnext) (hj : j < x.nnext) (h : M.node i = M.node j) : i = j :=
  hr.ninj i j (hd i hi) (hd j hj) h

theorem _root_.Host.Ts.Sim.G.MR.bnode_lt {i : Nat} (hi : i < x.nnext) : M.node i < y.nnext := hr.nimg i (hd i hi)

theorem _root_.Host.Ts.Sim.G.MR.bnode_ge {j : Nat} (hj : x.nnext ≤ j) : y.nnext ≤ M.node j := by
  have := hr.nfresh (j - x.nnext)
  rw [show x.nnext + (j - x.nnext) = j by omega] at this
  omega

theorem _root_.Host.Ts.Sim.G.MR.bnode_lt62 {i : Nat} (hi : i < x.nnext) : M.node i < 2 ^ 62 := by
  have := hr.bnode_lt hF hd hi; have := hr.ynnext_lt; omega

theorem _root_.Host.Ts.Sim.G.MR.bnode_mono {i j : Nat} (hi : i < x.nnext) (hj : j < x.nnext) : i < j ↔ M.node i < M.node j := by
  constructor
  · intro h; exact hr.norder j (hd j hj) (hF j) i h
  · intro h
    rcases Nat.lt_or_ge i j with e | e
    · exact e
    · rcases Nat.lt_or_eq_of_le e with e | e
      · have := hr.norder i (hd i hi) (hF i) j e; omega
      · subst e; omega

variable {b b' : BSt} (h : BRel M x.nnext y.nnext b b')
include h

theorem BRel.aliasOf_map (j : Nat) : b'.aliasOf (M.node j) = b.aliasOf j := by
  by_cases hj : j < x.nnext
  · exact h.aliases j hj
  · have hg := hr.bnode_ge hF hd (Nat.not_lt.mp hj)
    have e1 : b.aliases.get j = none := by
      cases e : b.aliases.get j with
      | none => rfl
      | some _ => exact absurd (h.aliasX j (by rw [e]; rfl)) hj
    have e2 : b'.aliases.get (M.node j) = none := by
      cases e : b'.aliases.get (M.node j) with
      | none => rfl
      | some _ => have := h.aliasY _ (by rw [e]; rfl); omega
    show b'.aliases.get (M.node j) = b.aliases.get j
    rw [e1, e2]

theorem BRel.aliasIns_map : ∀ ins : List Nat,
    Host.Mlx.FfiAne.aliasIns b' (ins.map M.node) = Host.Mlx.FfiAne.aliasIns b ins
  | [] => rfl
  | j :: js => by
    have ih := BRel.aliasIns_map js
    simp only [List.map_cons, Host.Mlx.FfiAne.aliasIns, h.aliasOf_map hr hF hd j]
    split <;> rw [ih]

theorem BRel.asView {n : Nat} (hn : n < x.nnext) (a : Alias) :
    BRel M x.nnext y.nnext (Host.Mlx.FfiAne.asView b n a) (Host.Mlx.FfiAne.asView b' (M.node n) a) :=
  { h with
    aliases := fun m hm => by
      show (b'.aliases.set (M.node n) _).get (M.node m) = (b.aliases.set n _).get m
      by_cases e : m = n
      · subst e
        rw [get_set_eq_of_lt _ _ (hr.bnode_lt62 hF hd hn), get_set_eq_of_lt _ _ (by have := hr.xnnext_lt; omega)]
      · have e' : M.node m ≠ M.node n := fun h' => e (hr.bnode_inj hF hd hm hn h')
        rw [PTrie.get_set_ne' _ _ _ _ e', PTrie.get_set_ne' _ _ _ _ e]
        exact h.aliases m hm
    aliasX := fun m hm => by
      rcases isSome_set_cases _ _ _ _ hm with e | e
      · exact h.aliasX m e
      · rw [e]; exact hn
    aliasY := fun m hm => by
      rcases isSome_set_cases _ _ _ _ hm with e | e
      · exact h.aliasY m e
      · rw [e]; exact hr.bnode_lt hF hd hn }

theorem BRel.register {n : Nat} (hn : n < x.nnext) (t : Touch) :
    BRel M x.nnext y.nnext (Host.Mlx.FfiAne.register b n t) (Host.Mlx.FfiAne.register b' (M.node n) t) :=
  { h with
    touch := fun m hm => by
      show (b'.touch.set (M.node n) t).get (M.node m) = (b.touch.set n t).get m
      by_cases e : m = n
      · subst e
        rw [get_set_eq_of_lt _ _ (hr.bnode_lt62 hF hd hn), get_set_eq_of_lt _ _ (by have := hr.xnnext_lt; omega)]
      · have e' : M.node m ≠ M.node n := fun h' => e (hr.bnode_inj hF hd hm hn h')
        rw [PTrie.get_set_ne' _ _ _ _ e', PTrie.get_set_ne' _ _ _ _ e]
        exact h.touch m hm
    touchX := fun m hm => by
      rcases isSome_set_cases _ _ _ _ hm with e | e
      · exact h.touchX m e
      · rw [e]; exact hn
    touchY := fun m hm => by
      rcases isSome_set_cases _ _ _ _ hm with e | e
      · exact h.touchY m e
      · rw [e]; exact hr.bnode_lt hF hd hn
    unscheduled := by
      show b'.unscheduled ++ [M.node n] = (b.unscheduled ++ [n]).map M.node
      rw [h.unscheduled, List.map_append]; rfl
    queued := fun m hm => by
      have hm' : m ∈ (b.unscheduled ++ [n]) ++ b.running := hm
      rcases List.mem_append.mp hm' with hm' | hm'
      · rcases List.mem_append.mp hm' with hm' | hm'
        · exact h.queued m (List.mem_append_left _ hm')
        · rw [List.mem_singleton.mp hm']; exact hn
      · exact h.queued m (List.mem_append_right _ hm') }


/-- **A new node classified under the map.** -/
theorem BRel.classifyNode {n : Nat} (hn : n < x.nnext) {b1 : BSt}
    (e : Host.Mlx.FfiAne.classifyNode b x n = some b1) :
    ∃ b1', Host.Mlx.FfiAne.classifyNode b' y (M.node n) = some b1' ∧ BRel M x.nnext y.nnext b1 b1' := by
  obtain ⟨nd, hnd⟩ := Option.isSome_iff_exists.mp (hd n hn)
  obtain ⟨nd', hnd', hnr⟩ := hr.nodes n nd hnd
  obtain ⟨hpr, hins⟩ := hnr.2.2.2 (hF n)
  unfold Host.Mlx.FfiAne.classifyNode at e ⊢
  rw [hnd] at e
  rw [hnd']
  dsimp only at e ⊢
  rw [hins, h.aliasIns_map hr hF hd]
  cases ha : Host.Mlx.FfiAne.aliasIns b nd.ins with
  | nil => rw [ha] at e; cases e; exact ⟨b', rfl, h⟩
  | cons a as =>
    rw [ha] at e
    simp only [] at e ⊢
    rcases hpr with hpr | ⟨hso, bs, hbs⟩
    · rw [hpr]
      revert e
      generalize nd.prim = p
      generalize nd.ins = ins
      intro e
      cases p
      case slice a0 b0 sr =>
        rcases ins with _ | ⟨i, _ | ⟨j, rest⟩⟩
        · simp at e
        · simp only [Map.prim, List.map_cons, List.map_nil] at e ⊢
          cases hs : x.nodes.get i with
          | none => rw [hs] at e; simp at e
          | some src =>
            rw [hs] at e
            obtain ⟨src', hs', hsr⟩ := hr.nodes i src hs
            rw [hs']
            dsimp only at e ⊢
            have hl : Host.Ts.len src'.shape = Host.Ts.len src.shape := by rw [hsr.1]; exact Native.len_map _ _
            cases hc : (Nat.beq (Host.Ts.len src.shape) 1 && Host.Mlx.FfiAne.unitStrides sr)
            · rw [hc, Bool.cond_false] at e; simp at e
            · rw [hc, Bool.cond_true] at e
              cases e
              have hc' : (Nat.beq (Host.Ts.len src'.shape) 1 && Host.Mlx.FfiAne.unitStrides (M.dims sr)) = true := by
                rw [hl]
                simp only [Bool.and_eq_true] at hc ⊢
                exact ⟨hc.1, unitStrides_map M hc.2⟩
              rw [hc', Bool.cond_true]
              exact ⟨_, rfl, h.asView hr hF hd hn a⟩
        · simp at e
      case reshape s0 =>
        rcases ins with _ | ⟨i, _ | ⟨j, rest⟩⟩
        · simp at e
        · simp only [Map.prim, List.map_cons, List.map_nil] at e ⊢
          cases e
          exact ⟨_, rfl, h.asView hr hF hd hn a⟩
        · simp at e
      case astype d =>
        rcases ins with _ | ⟨i, _ | ⟨j, rest⟩⟩
        · simp at e
        · simp only [Map.prim, List.map_cons, List.map_nil] at e ⊢
          cases hs : x.nodes.get i with
          | none => rw [hs] at e; simp at e
          | some src =>
            rw [hs] at e
            obtain ⟨src', hs', hsr⟩ := hr.nodes i src hs
            rw [hs']
            dsimp only at e ⊢
            rw [hsr.2.1]
            cases hc : Nat.beq src.dtype d
            · rw [hc, Bool.cond_false] at e; rw [Bool.cond_false]
              cases e; exact ⟨_, rfl, h.register hr hF hd hn _⟩
            · rw [hc, Bool.cond_true] at e; rw [Bool.cond_true]
              cases e; exact ⟨_, rfl, h.asView hr hF hd hn a⟩
        · simp at e
      case kernel kh c o =>
        dsimp only [Map.prim] at e ⊢
        have hl : Host.Ts.len (M.cfg c).outs = Host.Ts.len c.outs := Native.len_map _ _
        rw [hl]
        cases hc : ((a :: as).all Alias.isWrap && Nat.beq (Host.Ts.len c.outs) 1)
        · rw [hc, Bool.cond_false] at e; simp at e
        · rw [hc, Bool.cond_true] at e; rw [Bool.cond_true]
          cases e; exact ⟨_, rfl, h.register hr hF hd hn _⟩
      case unary op =>
        dsimp only [Map.prim] at e ⊢
        cases e; exact ⟨_, rfl, h.register hr hF hd hn _⟩
      case binary op =>
        dsimp only [Map.prim] at e ⊢
        cases e; exact ⟨_, rfl, h.register hr hF hd hn _⟩
      case concat ax =>
        dsimp only [Map.prim] at e ⊢
        cases e; exact ⟨_, rfl, h.register hr hF hd hn _⟩
      all_goals simp at e
    · exfalso
      have hdat : ∃ d, nd.prim = .data d := by
        unfold G.shapeOnly at hso
        revert hso
        cases nd.prim <;> simp
      obtain ⟨d, hdd⟩ := hdat
      rw [hdd] at e
      simp at e

end

section
variable {P : LoadP} {NB : Nat} {M : Map} {k : Nat} {x y : NSt} (hr : G.MR P NB M k x y)
  (hF : ∀ i, Full P i) (hd : ∀ i, i < x.nnext → PN x i)
include hr hF hd

/-- **The new nodes classified under the map**, from `n0` (the template's counter before the call) and its
image `m0`, the fresh nodes in step. -/
theorem BRel.classify {n0 m0 : Nat} (hn0 : n0 ≤ x.nnext) (hY : m0 + (x.nnext - n0) = y.nnext)
    (hfr : ∀ i, M.node (n0 + i) = m0 + i) :
    ∀ (f i : Nat) {b b' : BSt}, BRel M x.nnext y.nnext b b' → ∀ {b1 : BSt},
      Host.Mlx.FfiAne.classify b x f (n0 + i) = some b1 →
      ∃ b1', Host.Mlx.FfiAne.classify b' y f (m0 + i) = some b1' ∧ BRel M x.nnext y.nnext b1 b1'
  | 0, _, _, _, h, _, e => by cases e; exact ⟨_, rfl, h⟩
  | f + 1, i, b, b', h, b1, e => by
    unfold Host.Mlx.FfiAne.classify at e ⊢
    have hc : Nat.blt (m0 + i) y.nnext = Nat.blt (n0 + i) x.nnext := by
      rw [Bool.eq_iff_iff, Nat.blt_eq, Nat.blt_eq]; omega
    rw [hc]
    cases hlt : Nat.blt (n0 + i) x.nnext
    · rw [hlt, Bool.cond_false] at e; rw [Bool.cond_false]; cases e; exact ⟨_, rfl, h⟩
    · rw [hlt, Bool.cond_true] at e; rw [Bool.cond_true]
      have hlt' : n0 + i < x.nnext := by have := hlt; rw [Nat.blt_eq] at this; exact this
      cases e2 : Host.Mlx.FfiAne.classifyNode b x (n0 + i) with
      | none => rw [e2] at e; cases e
      | some b2 =>
        rw [e2] at e
        obtain ⟨b2', e2', h2⟩ := h.classifyNode hr hF hd hlt' e2
        have e2'' : Host.Mlx.FfiAne.classifyNode b' y (m0 + i) = some b2' := by rw [← hfr i]; exact e2'
        rw [e2'']
        simp only [Option.bind_some] at e ⊢
        have := BRel.classify hn0 hY hfr f (i + 1) h2 (b1 := b1) (by rw [← Nat.add_assoc]; exact e)
        rw [← Nat.add_assoc] at this
        exact this
end

end Host.Ts.Sim.Full
