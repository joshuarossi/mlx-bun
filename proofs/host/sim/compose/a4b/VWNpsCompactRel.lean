import host.sim.compose.a4b.VWNpsJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def npsPair (x : SegInst FF) := prefillCompactPair setupP PRE_first_tail_x15_r0.kappa1
  θZ1 PRE_first_tail_x15_r0.s18 PRE_first_tail_x15_r0.s19 x

theorem nps_compact_rel {NB T L : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (hR : (mergedCut NB T tk L).R x PRE_first_tail_x15_r0.s18 ⟨PRE_first_tail_x15_r0.S18.tab, []⟩)
    (hB : (mergedCut NB T tk L).B x) :
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP []
      (npsPair x).M (npsPair x).ν (npsPair x).K PRE_first_tail_x15_r0.s19
      ⟨PRE_first_tail_x15_r0.S19.tab, []⟩ x.t x.C ∧
    Disp.KpJ setupJ 4096 (npsPair x).K ∧ (npsPair x).K.fr 4910 = none ∧
    (∃ π : List Nat, π.length = L ∧ (∀ k ∈ π, k < 248320) ∧
      (npsPair x).K.fr 2665 = some ([], π.map natV)) ∧
    (npsPair x).K.D = x.K.D + 14 := by
  obtain ⟨hr, ν, hν, hvb, hkp, hmap⟩ := hR
  obtain ⟨⟨⟨hk, hmemo, π, hlen, hvocab, hframe, hfresh⟩, hsmall, hoffset⟩,
    hins, hids, hbase, hcall, hNB, hnative⟩ := hB
  have hr0 := inactiveMemo hr.ofJ (fun a ha => (wideInactive hmemo a ha).symm)
  have hs := npsShift hkp hframe hcall hnative
  have hnext : (mlxOf PRE_first_tail_x15_r0.s19.ffi).next = 18155 := congrArg Prod.fst PRE_first_tail_x15_r0.ccounters1
  have hD : x.t.next - PRE_first_tail_x15_r0.s19.next = x.K.D + 14 := by
    have h := hr.offset
    change x.t.next = PRE_first_tail_x15_r0.s18.next + x.K.D at h
    rw [PRE_first_tail_x15_r0.zsmn1] at h
    rw [h, PRE_first_tail_x15_r0.cnext1]
    omega
  have hfree := Conv.jclean_noBigSt (lo := (mlxOf PRE_first_tail_x15_r0.s19.ffi).next) (E := setupP.E)
    (PRE_first_tail_x15_r0.cjcl1 npsCallClean) (by rw [hnext]) (by decide : setupP.E ≤ RData.bigHi)
    PRE_first_tail_x15_r0.zroots21
  have hband : ∀ i : Int, ((mlxOf PRE_first_tail_x15_r0.s19.ffi).next : Int) ≤ i ∧ i < setupP.E →
      ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56 := by
    intro i hi
    rw [hnext] at hi
    have hlo : x.K.lo = 18151 := hk.1.1
    have hhi : x.K.hi = 131072 := hk.1.2.1
    rw [hlo, hhi]
    change 18155 ≤ i ∧ i < 131072 at hi
    unfold BigFixed
    constructor
    · omega
    · constructor <;> omega
  have sameH : (mlxOf PRE_first_tail_x15_r0.s18.ffi).next = (mlxOf PRE_first_tail_x15_r0.s19.ffi).next :=
    PRE_first_tail_x15_r0.cnh11.symm.trans hnext.symm
  have sameN : (mlxOf PRE_first_tail_x15_r0.s18.ffi).nnext = (mlxOf PRE_first_tail_x15_r0.s19.ffi).nnext :=
    PRE_first_tail_x15_r0.cnn11.symm.trans (congrArg Prod.snd PRE_first_tail_x15_r0.ccounters1).symm
  have hroomN : NRoom setupP (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi)
      (Host.Load.Layers.toLoad x.t.ffi) := by
    obtain ⟨P', hP, hf⟩ := hr.ffi.1
    obtain ⟨_, hE, hNE, _⟩ := Raised.restart (.inl rfl) hP
    constructor
    · have h := hf.load.mlx.hroom.2
      rw [hE] at h
      change (mlxOf x.t.ffi).next + (setupP.E - (mlxOf PRE_first_tail_x15_r0.s18.ffi).next) < 2 ^ 46 at h
      rw [sameH] at h
      exact h
    · have h := hf.load.mlx.nroom.2.2
      rw [hNE] at h
      change (mlxOf x.t.ffi).nnext + (setupP.NE - (mlxOf PRE_first_tail_x15_r0.s18.ffi).nnext) < 2 ^ 62 at h
      rw [sameN] at h
      exact h
  have hc := Conv.full_compactQXD NB (P := setupP) (r := machReads T tk)
    (s0 := PRE_first_tail_x15_r0.s19) (s1 := PRE_first_tail_x15_r0.s18)
    (S0 := ⟨PRE_first_tail_x15_r0.S19.tab, []⟩) (S1 := ⟨PRE_first_tail_x15_r0.S18.tab, []⟩)
    PRE_first_tail_x15_r0.raised1 hNB hr0 hs PRE_first_tail_x15_r0.cbigs1 hfree hband
    (fun _ h => nomatch h) (by rw [hD]; change x.K.D + 14 < Sim.bound; have := hoffset; simp only [Sim.bound]; omega) hroomN
  let N := (x.M.after PRE_first_tail_x15_r0.kappa1).rebig (mlxOf PRE_first_tail_x15_r0.s19.ffi).next
    setupP.E (mlxOf x.t.ffi).next
  let K' : Ctx := ⟨Shift.framedNext x.M x.K PRE_first_tail_x15_r0.s18,
    PRE_first_tail_x15_r0.s19.trace, x.t.trace, x.t.next - PRE_first_tail_x15_r0.s19.next, x.K.lo, x.K.hi⟩
  have hJs : NoBigSt (JsBad N) K'.base PRE_first_tail_x15_r0.s19 :=
    npsJsFree (fun i hi => jsBad_after (M := x.M) (N := N) (σ := PRE_first_tail_x15_r0.kappa1) hr.ffi.2 rfl
      (fun _ h => jsBig_rebig (by decide : setupP.E ≤ 2 ^ 56) h) hi)
  have hcJ := (hc.withJs (by change x.K.lo ≤ 2 ^ 56; rw [hk.1.1]; decide) hJs
    (fullRXD_withJs hc.ffi npsJsNative)).toJ (BigJs.withJs N)
  have hctx : Disp.KpJ setupJ 4096 K' :=
    ⟨Kp_restart hkp _ _ _, by change x.t.next - PRE_first_tail_x15_r0.s19.next ≤ 4096; rw [hD]; omega⟩
  have hmemo' : K'.fr 4910 = none :=
    (framedNext_none_iff (M := x.M) (s1 := (PRE_first_tail_x15_r0.s18 : St FF.S)) 4910).mpr hmemo
  have hcW := inactiveMemo hcJ (wideInactive hmemo')
  refine ⟨hcW, hctx, hmemo', ⟨π, hlen, hvocab, ?_⟩, hD⟩
  obtain ⟨o, ho, hkind⟩ := PRE_first_tail_x15_r0.arr1_2665
  have hknd : o.kind = .array ([] ++ []) := by
    simpa only [npsPromptEmpty, PRE_first_tail_x15_r0.arrEl1_2665] using hkind
  have h := framedNext_of (M := x.M) hframe ho hknd
  change Shift.framedNext x.M x.K PRE_first_tail_x15_r0.s18 2665 = some ([], π.map natV)
  simpa only [Map.vals, List.map_nil, List.append_nil] using h
end Host.Ts.Sim.Compose.VWFirst
