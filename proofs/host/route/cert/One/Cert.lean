import host.route.PostOne
import host.route.cert.One.Check
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
open Host.Mlx.SimGraph.Mach (RefTokens)
open Host.Ts.Sim (LoadP Map SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Compose.ColdGraph (fullExpected choice.cert cert_length)
open Host.Route.PrefGraph

/-! # The one-token prompt's sampled cut, from its certificate -/

kernel_rfl node_counter : native.nnext = 17777

theorem nu_box : InBox box nu := by
  intro x l h hg
  unfold Box.get box at hg
  by_cases h9 : x = 9
  · subst h9; simp at hg; obtain ⟨rfl, rfl⟩ := hg; decide
  · by_cases h10 : x = 10
    · subst h10; simp at hg; obtain ⟨rfl, rfl⟩ := hg; decide
    · by_cases h11 : x = 11
      · subst h11; simp at hg; obtain ⟨rfl, rfl⟩ := hg; decide
      · by_cases h16 : x = 16
        · subst h16; simp at hg; obtain ⟨rfl, rfl⟩ := hg; decide
        · simp [List.find?_cons, Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

theorem cls_sound (S : SSrv) (ρ : Nat → F64) (hρ : ∀ x l h, box.get x = some (l, h) → ρ x = F64.ofInt (nu x)) (ν : Nat → Int) :
    ClsSoundD (cls S) (νsOf S ρ) (PDim.eval ν) := by
  intro x d hx
  obtain ⟨dim, hs, rfl⟩ := Option.map_eq_some_iff.mp hx
  exact clsOfX_sound S box nu ρ nu_box hρ x dim hs

/-- **The first step's graph at the target.** -/
theorem matchOne (tab : List F64) {Pm : LoadP} {NB m : Nat} {M : Map} {y : Ffi.St} (hmr : Host.Ts.Sim.G.MR Pm NB M m native y)
    (hband : Pm.NL = Pm.N0) (hrope : M.big 5554869888 = 5554869888) (ρ : Nat → F64)
    (hρ : ∀ x l h, box.get x = some (l, h) → ρ x = F64.ofInt (nu x))
    (hnum : ∀ i e, nth? PRE_pl_common.S4.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ)) :
    Matches (Gr tab y) Expected.graph (choice.cert.map M.node) = true := by
  have hchecked := matchesD_of_checkNodes Gs fullExpected.1 choice.cert check.all
  have h1 := matchesD_map (PDim.eval (fun _ => 0)) Gs fullExpected.1 choice.cert hchecked
  have himg : NativeImage M.node (loadImg M) (exactTplDom 15235 15235 [5554869888] native) native y :=
    nativeImage_of_GMR hmr _
      (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
      (fun _ _ hi hn => exactTplDom_exact hi hn)
  have emb := embeds_of_imageD (κ := InKey) (cls PRE_pl_common.S4) PDim.lit (PDim.eval (fun _ => 0)) (fun _ => rfl)
    SourceKernels.sources native y (exactTplDom 15235 15235 [5554869888] native) (νsOf PRE_pl_common.S4 ρ) (CSrv.val ⟨tab⟩)
    M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl)
    (numbers_agree PRE_pl_common.S4 ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum) (cls_sound _ ρ hρ _)
    (fun a => okArg [5554869888] a = true)
    (arg_fixed M [5554869888] (fun i hi => by obtain rfl := List.mem_singleton.mp hi; exact hrope))
    (fun _ _ hi hn => exactTplDom_args hi hn) (kernels_of_GMR hmr _) himg
  have h2 := matches_embed (σ := M.node) (cl := M.handle) _ _ emb _ choice.cert
    (by rw [List.length_map]; exact cert_length) h1
  rwa [Host.Ts.Sim.Compose.ColdGraph.One.full_expected_eval] at h2

theorem box_values {j : Nat} {l h : Int} (hg : box.get j = some (l, h)) : j = 9 ∨ j = 10 ∨ j = 11 ∨ j = 16 := by
  unfold Box.get box at hg
  by_cases h9 : j = 9
  · exact .inl h9
  · by_cases h10 : j = 10
    · exact .inr (.inl h10)
    · by_cases h11 : j = 11
      · exact .inr (.inr (.inl h11))
      · by_cases h16 : j = 16
        · exact .inr (.inr (.inr h16))
        · simp [List.find?_cons, Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)

/-- **`hsmp` of the one-token prompt**, at the template `PRE_pl_common.s4`. -/
theorem hsmp (a : Nat) (ha : a < 248320) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env [a] tab)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr 1 = oneCarriers)
    (toks : Nat → Nat → Nat) (htoks : toks 1 0 = 17776) {NB T cap : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB) {x y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap 15235 [a] PRE_pl_common.s4 PRE_pl_common.S4).R y PRE_pl_common.s4
      ⟨PRE_pl_common.S4.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memExit P KR NE net env [a] Cr L x) : memPost P KR NE net env [a] 0 toks Cr L y := by
  obtain ⟨γ, hr, hb⟩ := hy
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M PRE_pl_common.S4.tab.length native (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact Int.le_of_lt (by decide)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hγ : γ = [a] := hb.lastRows
  subst hγ
  have hρ : ∀ j l h, box.get j = some (l, h) → y.ν j = F64.ofInt (nu j) := by
    intro j l h hget
    rcases box_values hget with rfl | rfl | rfl | rfl
    · exact hb.promptValue
    · exact hb.rowValue
    · exact hb.offsetValue
    · exact hb.capValue
  exact hsmpOne P KR NE net env a ha leaves typed hRT Cr hCr toks htoks
    (fun j hj => hmr.nid j (Nat.lt_of_lt_of_le hj hNB))
    (fun j hj => hmr.nall j (by rw [node_counter]; exact hj))
    (fun tab hC => matchOne tab hmr hband hrope y.ν hρ (fun i e h => hC.val (hr.srv.num i e h)))
    hb.input hle hg ht L hm

end Host.Route.Cert.One
