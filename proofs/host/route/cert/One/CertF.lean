import host.route.PostOne
import host.route.cert.One.CheckF
import host.sim.compose.a4b.D1BodyFill
import host.sim.compose.a4b.GraphColdEmbedding
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
open Host.Ts.Sim.Compose.ColdGraph (fullExpected choice.cert cert_length)
open Host.Route.PrefGraph

/-! # The one-token prompt's final forward, from its certificate -/

theorem head_cert {k : Nat} (hk : k < 4010) : certAt choice.cert k < 17764 := by
  have hlen : k < choice.cert.length := by rw [one_cert_len]; omega
  have hget : (choice.cert.take 4010)[k]? = some (certAt choice.cert k) := by
    rw [List.getElem?_take_of_lt hk]
    simp [certAt, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hlen]
  exact Nat.blt_eq.mp (List.all_eq_true.mp head_below _ (List.mem_of_getElem? hget))

/-- **The forward's part of the first step at the target and every growth of it.** -/
theorem matchF (tab : List F64) {Pm : LoadP} {NB m : Nat} {M : Map} {y : Ffi.St} (hmr : Host.Ts.Sim.G.MR Pm NB M m nativeF y)
    (hband : Pm.NL = Pm.N0) (hrope : M.big 5554869888 = 5554869888) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1Body.S155.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ))
    (z : Ffi.St) (hz : Host.Mlx.Ffi.NGrow y z) :
    Matches (Gr tab z) (Expected.graph.take 4010) (choice.cert.map M.node) = true := by
  have hchecked := matchesD_head GsF fullExpected.1 4010 choice.cert checkF.all
  have h1 := matchesD_map (PDim.eval (fun _ => 0)) GsF _ choice.cert hchecked
  have himg : NativeImage M.node (loadImg M) (exactTplDom 15235 15235 [5554869888] nativeF) nativeF y :=
    nativeImage_of_GMR hmr _
      (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
      (fun _ _ hi hn => exactTplDom_exact hi hn)
  have emb := Host.Ts.Sim.Compose.ColdGraph.embeds_cold_image D1Body.S155 ρ hρ (fun _ => 0) SourceKernels.sources nativeF y
    (exactTplDom 15235 15235 [5554869888] nativeF) (CSrv.val ⟨tab⟩) M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl)
    (numbers_agree D1Body.S155 ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum)
    (fun a => okArg [5554869888] a = true)
    (arg_fixed M [5554869888] (fun i hi => by obtain rfl := List.mem_singleton.mp hi; exact hrope))
    (fun _ _ hi hn => exactTplDom_args hi hn) (kernels_of_GMR hmr _) himg
  have emb' := embeds_grow (G := mapG (PDim.eval fun _ => 0) GsF) emb (fun i r hr => by
    obtain ⟨r0, h0, -⟩ := Option.map_eq_some_iff.mp hr
    refine hmr.nimg i ?_
    unfold GsF restrictTo at h0
    split at h0
    · obtain ⟨nd, hnd, -⟩ := Option.bind_eq_some_iff.mp h0
      show (nativeF.nodes.get i).isSome = true
      rw [hnd]
      rfl
    · cases h0) hz
  have h2 := matches_embed (σ := M.node) (cl := M.handle) _ _ emb' _ choice.cert
    (by rw [List.length_map, List.length_take]; have := cert_length; omega) h1
  rw [List.map_take, Host.Ts.Sim.Compose.ColdGraph.One.full_expected_eval] at h2
  exact h2

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)

/-- **`hfin` of the one-token prompt**, at the forward's return. -/
theorem hfin (a : Nat) (Cr : Nat → List (Option Nat × Option Nat)) (Kept : Nat → List (Nat × Nat)) (hKept : Kept 1 = oneKept)
    (Kn : Nat → Nat) (hKn : Kn 1 = 4010) (ha : a < 248320) {NB T : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB) {x y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.D1First.returnedPromptCut NB T tk [a]).R y D1Body.s155 ⟨D1Body.S155.tab, []⟩)
    (hyb : (Host.Ts.Sim.Compose.D1First.returnedPromptCut NB T tk [a]).B y)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memExit P KR NE net env [a] Cr L x) : memFin P KR NE net env [a] Kept Kn L y := by
  obtain ⟨π, K0, hr, hb, hip, -, -⟩ := hy
  obtain ⟨⟨_, _⟩, hp⟩ := hyb
  obtain ⟨_, hfb, _⟩ := hb
  have e : [a] = π := (Host.Ts.Sim.Compose.SetupDrop.promptEq hfb.vocab (by simpa using ha)
    (Host.Ts.Sim.Compose.SetupD1PromptIdentity.forward_prompt hfb) hp).symm
  subst e
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M D1Body.S155.tab.length nativeF (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  exact hfinOne P KR NE net env a ha Cr Kept hKept Kn hKn
    (fun j hj => hmr.nid j (Nat.lt_of_lt_of_le hj hNB))
    (fun j hj => hmr.nall j (by rw [show nativeF.nnext = 17764 from D1Body.nodeCounter]; exact hj))
    (fun _ hk => head_cert hk)
    (fun tab hC z hz => matchF tab hmr hband hrope y.ν hfb.singleton (fun i e h => hC.val (hr.srv.num i e h)) z hz)
    hip hle hg ht L hm

end Host.Route.Cert.One
