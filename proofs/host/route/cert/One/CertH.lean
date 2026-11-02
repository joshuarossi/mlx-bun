import host.route.PostOne
import host.route.cert.One.CheckH
import host.sim.compose.PostCut
import host.simgraph.GenLoadRel
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr)
open Host.Ts.Sim (LoadP Map SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Compose.ColdGraph (fullExpected)
open Host.Route.PrefGraph

/-! # The one-token prompt's sampled cut, from its certificate -/

theorem boxH_cases {j : Nat} {l h : Int} (hg : Box.get boxH j = some (l, h)) :
    (j = 9 ∧ l = 1 ∧ h = 1) ∨ (j = 10 ∧ l = 1 ∧ h = 1) ∨ (j = 11 ∧ l = 1 ∧ h = 1) ∨ (j = 16 ∧ l = 256 ∧ h = 256) := by
  unfold Box.get boxH at hg
  by_cases h9 : j = 9
  · subst h9
    simp at hg
    exact .inl ⟨rfl, hg.1.symm, hg.2.symm⟩
  by_cases h10 : j = 10
  · subst h10
    simp at hg
    exact .inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩)
  by_cases h11 : j = 11
  · subst h11
    simp at hg
    exact .inr (.inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩))
  by_cases h16 : j = 16
  · subst h16
    simp at hg
    exact .inr (.inr (.inr ⟨rfl, hg.1.symm, hg.2.symm⟩))
  simp [Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

theorem nuH_box : InBox boxH nuH := by
  intro j l h hg
  rcases boxH_cases hg with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ <;> decide

/-- **The head and sampler's part of the first step at the sampled cut.** -/
theorem matchH (tab : List F64) {Pm : LoadP} {NB m : Nat} {M : Map} {y : Ffi.St} (hmr : Host.Ts.Sim.G.MR Pm NB M m nativeH y)
    (hband : Pm.NL = Pm.N0) (hrope : M.big 5554869888 = 5554869888) (ρ : Nat → F64)
    (hρ : ∀ x l h, Box.get boxH x = some (l, h) → ρ x = F64.ofInt (nuH x))
    (hnum : ∀ i e, nth? PRE_pl_common.S1.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ)) :
    Matches (Gr tab y) (maskSeg .tokenIds 4010 Expected.graph.length Expected.graph) (choice.cert.map M.node) = true := by
  have hchecked := matchesD_tail GsH fullExpected.1 .tokenIds 4010 choice.cert checkH.all
  have h1 := matchesD_map (PDim.eval (fun _ => 0)) GsH _ choice.cert hchecked
  have himg : NativeImage M.node (loadImg M) (exactTplDom 15235 15235 [5554869888] nativeH) nativeH y :=
    nativeImage_of_GMR hmr _
      (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
      (fun _ _ hi hn => exactTplDom_exact hi hn) (down_of_all downH hmr.nlt)
  have hcls : ClsSoundD (clsH PRE_pl_common.S1) (νsOf PRE_pl_common.S1 ρ) (PDim.eval (fun _ => 0)) := by
    intro x d hx
    obtain ⟨d0, h0, rfl⟩ := Option.map_eq_some_iff.mp hx
    exact clsOfX_sound PRE_pl_common.S1 boxH nuH ρ nuH_box hρ x d0 h0
  have emb := embeds_of_imageD (κ := InKey) (clsH PRE_pl_common.S1) PDim.lit (PDim.eval (fun _ => 0)) (fun _ => rfl)
    SourceKernels.sources nativeH y (exactTplDom 15235 15235 [5554869888] nativeH) (νsOf PRE_pl_common.S1 ρ) (CSrv.val ⟨tab⟩)
    M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl)
    (numbers_agree PRE_pl_common.S1 ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum) hcls
    (fun a => okArg [5554869888] a = true)
    (arg_fixed M [5554869888] (fun i hi => by obtain rfl := List.mem_singleton.mp hi; exact hrope))
    (fun _ _ hi hn => exactTplDom_args hi hn) (kernels_of_GMR hmr _) himg
  have h2 := matches_embed (σ := M.node) (cl := M.handle) _ _ emb _ choice.cert
    (by rw [List.length_map, maskSeg_length]; have := one_cert_length; simp [fullExpected] at this ⊢; omega) h1
  have hlen : fullExpected.1.length = Expected.graph.length := by
    have := congrArg List.length (full_expected_eval (fun _ => 0))
    rwa [List.length_map] at this
  rw [maskSeg_map, full_expected_eval, hlen] at h2
  exact h2

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)

/-- **`hsmp` of the one-token prompt**, at the sampled cut. -/
theorem hsmp (a : Nat) (ha : a < 248320) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, Host.Mlx.SimGraph.Mach.RefTokens P KR NE KR.inPlace net env [a] tab)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr 1 = oneCarriers) (Kept : Nat → List (Nat × Nat))
    (hKept : Kept 1 = oneKept) (Kn : Nat → Nat) (hKn : Kn 1 = 4010)
    (toks : Nat → Nat → Nat) (htoks : toks 1 0 = 17776) {NB T cap : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB) {y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut0 [2673479] NB T tk cap 15235 [a] PRE_pl_common.s1 PRE_pl_common.S1).R y
      PRE_pl_common.s1 ⟨PRE_pl_common.S1.tab, []⟩)
    (L : Nat) (hm : memFin P KR NE net env [a] Kept Kn L y) : memPost P KR NE net env [a] 0 toks Cr L y := by
  obtain ⟨γ, hr, hb⟩ := hy
  have hγ : γ = [a] := by rw [hb.lastRows]; rfl
  subst hγ
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M PRE_pl_common.S1.tab.length nativeH (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hcap : Host.Ts.Sim.capL [a].length = 256 := by simp [Host.Ts.Sim.capL]
  have hρ : ∀ x l h, Box.get boxH x = some (l, h) → y.ν x = F64.ofInt (nuH x) := by
    intro j l h hg
    rcases boxH_cases hg with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩
    · exact hb.promptValue
    · exact hb.rowValue
    · exact hb.offsetValue
    · exact hb.capValue.trans (by rw [hcap]; rfl)
  exact hsmpOne P KR NE net env a ha leaves typed hRT Cr hCr Kept hKept Kn hKn toks htoks
    (fun j hj => hmr.nid j (Nat.lt_of_lt_of_le hj hNB))
    (fun j hj => hmr.nall j (by rw [node_counter]; exact hj))
    (fun tab hC => matchH tab hmr hband hrope y.ν hρ (fun i e h => hC.val (hr.srv.num i e h)))
    hb.input L hm

end Host.Route.Cert.One
