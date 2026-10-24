import host.sim.native.RebigR
import host.sim.native.gen.Shift
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.RebigR` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

theorem MRw.agreeB {P : LoadP} {NB : Nat} {M M' : Map} {n : Nat} {x y : NSt} {Q : Int → Prop} (hr : MRw P NB M n x y)
    (h : BAgree Q M M') (hlo : ∀ i : Int, i < P.lo → Q i) (hhi : ∀ i : Int, (P.E : Int) ≤ i → i < 2 ^ 56 → Q i)
    (hph : ∀ k, PH x k → Q (Int.ofNat k))
    (hzero : ∀ i, (M'.big i == 0) = (i == 0)) (hb : BigsOut Q x) (r : List NumV) :
    MRw { P with rest := r } NB M' n x y := by
  have hH : ∀ k, PH x k → M'.handle k = M.handle k := fun k hk => h.handle (hph k hk)
  have hcl := hr.cl
  refine
    { lo := hr.lo
      bigFix := fun i hi => by rw [h.big i (hlo i hi)]; exact hr.bigFix i hi
      bigFixHi := fun i h1 h2 => by rw [h.big i (hhi i h1 h2)]; exact hr.bigFixHi i h1 h2
      present := fun k hk => by
        rw [hH k hk]
        have hm := hr.present k hk
        exact ⟨by rw [h.big _ (hph k hk)]; exact hm.1, by rw [h.region]; exact hm.2.1, by rw [h.region]; exact hm.2.2⟩
      hinj := fun a b ha hb he => hr.hinj a b ha hb (by rw [← hH a ha, ← hH b hb]; exact he)
      hlt := hr.hlt
      himg := fun k hk => by rw [hH k hk]; exact hr.himg k hk
      hband := fun k hk hl => by rw [hH k hk]; exact hr.hband k hk hl
      hfreshR := fun k hk => by rw [h.region]; exact hr.hfreshR k hk
      zero := hzero
      hnext := hr.hnext
      hroom := hr.hroom
      absent0 := hr.absent0
      yabsent := hr.yabsent
      arrs := fun k hk => by rw [hH k hk, h.node]; exact hr.arrs k hk
      objs := fun k hk => by
        rw [hH k hk, hr.objs k hk]
        cases ho : x.objs.get k with
        | none => rfl
        | some o => simp only [Option.map_some, h.nobj (hb.objs k o ho) (hcl.2.1 k o ho)]
      cfgCanon := fun k c hc p hp d hd => DimCanon.bagree h (hr.cfgCanon k c hc p hp d hd)
      traced := hr.traced
      node0 := by rw [h.node]; exact hr.node0
      nid := fun j hj => by rw [h.node]; exact hr.nid j hj
      nbl := hr.nbl
      nall := fun j hj => by rw [h.node]; exact hr.nall j hj
      norder := fun i hi hf j hj => by rw [h.node]; exact hr.norder i hi hf j hj
      nodes := fun i nd hn => by
        obtain ⟨nd', h1, hs, hd, hc, hf⟩ := hr.nodes i nd hn
        refine ⟨nd', by rw [h.node]; exact h1, by rw [h.dims]; exact hs, hd,
          fun d hm => DimCanon.bagree h (hc d hm), fun hfull => ?_⟩
        rw [h.node]
        refine ⟨?_, (hf hfull).2⟩
        rcases (hf hfull).1 with e | e
        · exact .inl (by rw [h.prim (hb.nodes i nd hn) (hcl.1 i nd hn).1]; exact e)
        · exact .inr e
      ninj := fun a b ha hb he => hr.ninj a b ha hb (by rw [← h.node]; exact he)
      nlt := hr.nlt
      nimg := fun i hi => by rw [h.node]; exact hr.nimg i hi
      nfresh := fun k => by rw [h.node]; exact hr.nfresh k
      nband := hr.nband
      nroom := hr.nroom
      tokens := by
        obtain ⟨rest, hrest⟩ := hr.tokens
        exact ⟨rest, by rw [hrest, List.map_congr_left fun t _ => h.nv t]⟩
      items := fun k hk => by
        rw [h.node, hr.items k hk]
        cases x.items.get k with
        | none => rfl
        | some t => simp only [Option.map_some, h.nv]
      itemsPresent := hr.itemsPresent
      yitems := hr.yitems
      pending := by rw [hr.pending]; exact List.map_congr_left fun p hp => (h.pend (hb.pending p hp)).symm
      errh := by
        rw [hr.errh]
        cases he : x.errh with
        | none => rfl
        | some a => simp only [Option.map_some, h.arg (hb.errh a he) (hcl.2.2.2.2 a he)]
      files := hr.files
      arch := hr.arch
      sizes := hr.sizes
      wired := hr.wired
      cl := hcl }

/-- **Rebig.** The weak relation at the template start (tokens cleared), with the
start's data free of bigints in `[x0.next, P.E)`, becomes the native relation under
`M.rebig x0.next P.E z.next`, the start's tokens bound to the target's next readbacks. -/
theorem LoadRw.rebig {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x0 z : Host.Load.LSt} (hr : LoadRw P NB M n (clearTokens x0) z)
    (hb : bigsOutB x0.mlx.next P.E x0.mlx = true) (htc : ∀ t ∈ x0.mlx.tokens, SN (· < n) t)
    {rest' : List NumV} (hz : z.mlx.tokens = x0.mlx.tokens.map M.nv ++ rest') :
    LoadR { P with rest := rest' } NB (M.rebig x0.mlx.next P.E z.mlx.next) n x0 z := by
  have hm := hr.mlx
  have hag := rebig_bagree M x0.mlx.next P.E z.mlx.next
  have hlo := hm.lo
  have hnx : P.lo ≤ x0.mlx.next ∧ x0.mlx.next ≤ z.mlx.next := hm.hnext
  have hbo : BigsOut (fun i => outB x0.mlx.next P.E i = true) (clearTokens x0).mlx := bigsOutB_sound hb
  have hQlo : ∀ i : Int, i < P.lo → outB x0.mlx.next P.E i = true := fun i hi => by
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not, not_and, Int.not_lt]
    intro h1; exfalso; have : (x0.mlx.next : Int) ≥ P.lo := by exact_mod_cast hnx.1
    omega
  have hQph : ∀ k, PH (clearTokens x0).mlx k → outB x0.mlx.next P.E (Int.ofNat k) = true := fun k hk => by
    have := hm.hlt k hk
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not, not_and, Int.not_lt]
    intro h1; exfalso
    simp only [Int.ofNat_eq_natCast] at h1
    change k < x0.mlx.next at this
    omega
  have hzero : ∀ i, ((M.rebig x0.mlx.next P.E z.mlx.next).big i == 0) = (i == 0) := by
    intro i
    simp only [Map.rebig]
    split
    · rename_i hi
      have h1 : (x0.mlx.next : Int) ≥ 1 := by have : P.lo ≤ x0.mlx.next := hnx.1; omega
      have h2 : (z.mlx.next : Int) ≥ 1 := by have : x0.mlx.next ≤ z.mlx.next := hnx.2; omega
      have e1 : (i - ↑x0.mlx.next + ↑z.mlx.next == 0) = false := by
        simp only [beq_eq_false_iff_ne, ne_eq]; omega
      have e2 : (i == 0) = false := by simp only [beq_eq_false_iff_ne, ne_eq]; omega
      rw [e1, e2]
    · exact hm.zero i
  have hQhi : ∀ i : Int, (P.E : Int) ≤ i → i < 2 ^ 56 → outB x0.mlx.next P.E i = true := fun i h1 _ => by
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not, not_and, Int.not_lt]
    intro _; exact h1
  have hw := hm.agreeB hag hQlo hQhi hQph hzero hbo rest'
  refine ⟨hr.host, fun k hk => hr.hostReg k hk, hr.hostLt, fun a => hr.cbr a, ?_⟩
  exact
    { hw with
      tokens := ⟨rest', by rw [hz]; rfl⟩
      cl := ⟨hm.cl.1, hm.cl.2.1, htc, hm.cl.2.2.2.1, hm.cl.2.2.2.2⟩
      hfreshB := fun k hk => by
        change x0.mlx.next + k < P.E at hk
        show (if (x0.mlx.next : Int) ≤ Int.ofNat (x0.mlx.next + k) ∧ Int.ofNat (x0.mlx.next + k) < P.E then
          Int.ofNat (x0.mlx.next + k) - x0.mlx.next + z.mlx.next else M.big _) = _
        rw [if_pos (by simp only [Int.ofNat_eq_natCast]; omega)]
        simp only [Int.ofNat_eq_natCast]; omega
      tokensX := by rw [hz]; rfl }

end Host.Ts.Sim.G
