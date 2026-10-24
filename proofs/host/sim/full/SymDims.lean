import host.sim.native.InferV
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf Out)

/-! # Products of dimensions with values

`dMul_simV` and `dProd_simV`: `host.sim.native.DimV`'s `dAdd_simV` for products. A product of
dimensions with values below `2 ^ 53` is computed exactly by binary64 arithmetic, so the source's
server product and the target's (literal or server) product denote the same natural. -/

theorem mul_natExact53 (m n : Nat) (h : m * n < 2 ^ 53) :
    F64.mul (F64.natExact m) (F64.natExact n) = F64.natExact (m * n) := by
  cases m with
  | zero => cases n <;> simp [F64.natExact, F64.mul]
  | succ m => cases n with
    | zero => simp [F64.natExact, F64.mul]
    | succ n =>
      have hs : Nat.blt ((m + 1) * (n + 1)) F64.small = true := by rw [Nat.blt_eq]; exact h
      have hne : (m + 1) * (n + 1) ≠ 0 := Nat.mul_ne_zero (Nat.succ_ne_zero _) (Nat.succ_ne_zero _)
      change (bif Nat.blt (Nat.mul (m + 1) (n + 1)) F64.small then F64.fin (false != false) (Nat.mul (m + 1) (n + 1)) 0
        else F64.round F64.b64 (false != false) (Nat.mul (m + 1) (n + 1)) 1 0) = F64.natExact ((m + 1) * (n + 1))
      rw [show Nat.mul (m + 1) (n + 1) = (m + 1) * (n + 1) from rfl, hs]
      simp [F64.natExact, hne]

theorem bin_mul_ofNat (m n : Nat) (hm : m < 2 ^ 53) (hn : n < 2 ^ 53) (h : m * n < 2 ^ 53) :
    F64.bin .mul (F64.ofNat m) (F64.ofNat n) = F64.ofNat (m * n) := by
  show F64.mul _ _ = _
  rw [F64.ofNat_exact53 m hm, F64.ofNat_exact53 n hn, F64.ofNat_exact53 _ h]
  exact mul_natExact53 m n h

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

omit hs in
private theorem bothLit_or' {a b : Dim} :
    (∃ i j, a = .lit i ∧ b = .lit j) ∨ ¬ (∃ i j, a = .lit i ∧ b = .lit j) := Classical.em _

theorem dMul_simV {a b : Dim} {ka kb : Nat} (ha : DV M C a ka) (hb : DV M C b kb) (hsa : SD (· < S.tab.length) a)
    (hsb : SD (· < S.tab.length) b) (hk : ka * kb < 2 ^ 53) (hka : ka < 2 ^ 53) (hkb : kb < 2 ^ 53) :
    MSim (DPost M ν S C (ka * kb)) S C (Host.Mlx.Ffi.dMul a b) (Host.Mlx.Ffi.dMul (M.dim a) (M.dim b)) := by
  rcases bothLit_or' (a := a) (b := b) with ⟨i, j, rfl, rfl⟩ | hn
  · obtain rfl := DV.lit_eq ha
    obtain rfl := DV.lit_eq hb
    exact MSim.pure ⟨rfl, .inl (by simp), trivial, GrowL.refl hs⟩
  · have e1 : Host.Mlx.Ffi.dMul a b = Host.Ts.M.bind (numBin .mul a.num b.num) fun q => Host.Ts.M.pure (dimOf q) := by
      cases a <;> cases b <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hn
    have e2 := dArith_tgt ha hb hka hkb .mul (· * ·) (ka * kb) hk (by simp) (bin_mul_ofNat ka kb hka hkb hk)
      Host.Mlx.Ffi.dMul (fun _ _ => rfl) (fun x y hxy => by
        cases x <;> cases y <;> first | rfl | exact absurd ⟨_, _, rfl, rfl⟩ hxy)
    rw [e1, e2]
    refine MSim.bind (numBin_simV hs .mul a.num b.num) fun M' S' C' q q' ⟨hq, hg, hsq, hv⟩ => MSim.pure (M := M') ?_
    refine ⟨by rw [hq, Map.dim_dimOf], DV.ofVal ?_ hk, SD.dimOf hsq, hg⟩
    rw [← hq, hv _ _ ha.num hb.num, bin_mul_ofNat ka kb hka hkb hk]

end

/-- The product of naturals. -/
def natProd : List Nat → Nat
  | [] => 1
  | k :: ks => k * natProd ks

/-- Every suffix's product is below `2 ^ 53`. -/
def ProdB (ks : List Nat) : Prop := ∀ n, natProd (ks.drop n) < 2 ^ 53

theorem ProdB.tail {k : Nat} {ks : List Nat} (h : ProdB (k :: ks)) : ProdB ks := fun n => h (n + 1)

/-- **The product of dimensions with values.** -/
theorem dProd_simV : ∀ {M : Map} {S : SSrv} {C : CSrv} {ds : List Dim} {ks : List Nat}, Srv M ν S C →
    DVSs M C S ds ks → (∀ k ∈ ks, k < 2 ^ 53) → ProdB ks →
    MSim (DPost M ν S C (natProd ks)) S C (Host.Mlx.Ffi.dProd ds) (Host.Mlx.Ffi.dProd (M.dims ds))
  | M, S, C, [], [], hs, _, _, _ => MSim.pure ⟨rfl, .inl (by simp [natProd]), trivial, GrowL.refl hs⟩
  | M, S, C, d :: ds, k :: ks, hs, ⟨hd, hds⟩, hb, hp => by
    have hk : k < 2 ^ 53 := hb k List.mem_cons_self
    have hbs : ∀ k ∈ ks, k < 2 ^ 53 := fun k' h => hb k' (List.mem_cons_of_mem _ h)
    have hp0 : k * natProd ks < 2 ^ 53 := hp 0
    have hp1 : natProd ks < 2 ^ 53 := hp 1
    show MSim _ S C (Host.Ts.M.bind (Host.Mlx.Ffi.dProd ds) fun p => Host.Mlx.Ffi.dMul d p)
      (Host.Ts.M.bind (Host.Mlx.Ffi.dProd (M.dims ds)) fun p => Host.Mlx.Ffi.dMul (M.dim d) p)
    refine MSim.bind (dProd_simV hs hds hbs hp.tail) fun M' S' C' p p' ⟨hpe, hpv, hps, hg⟩ => ?_
    obtain ⟨hd', hdm⟩ := DVS.lift hd hg
    rw [hpe, ← hdm]
    exact MSim.mono (dMul_simV hg.grow.srv hd'.1 hpv hd'.2 hps hp0 hk hp1) fun M'' S'' C'' r r' ⟨h1, h2, h3, h4⟩ =>
      ⟨h1, h2, h3, hg.trans h4⟩

end Host.Ts.Sim
