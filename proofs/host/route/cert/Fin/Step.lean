import host.route.cert.Fin.Caps
import host.route.cert.Row.Tmpl
import host.route.FinGraph
import host.route.GpuMem
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr cachesAt loadedAt tensorAt)
open Host.Mlx.SimGraph.Mach (refPrompt refPrompt_start HeldV heldV_cached CacheValuesV routeVal compat_of_caps routeVals_empty)
open Host.Ts.Sim (LoadP Map SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Load.Run.Full.Cached.Expected2 (stages head)
open Host.Route.PrefGraph
open Host.Route.Cert.Row (templateOf_eq layout_eq head_eq caps_eq)
open Host.Ts.Sim.Compose.ColdGraph (coldIds cellsValue_singleton)

/-! # A tailed class's final forward, from its certificate

`FinCert`: the forward's part of the ordinary template at a class's numbers. `hfinV`: `memFin` at the forward's return, from the
reference's handles at its start. -/

/-- A final forward's checked certificate: the match of the template's first `K` nodes and their inputs. -/
structure FinCert (s : Ffi.St) (S : SSrv) (B : Box) (V : VarV) (d : Int) (K : Nat) where
  cert : List Nat
  insT : InKey → Option Nat
  tok : Nat
  ps : List (Option Nat × Option Nat)
  hm : MatchesD (gsV s S B V d) (Tpl.Ordinary.graph.take K) cert = true
  hlen : K ≤ cert.length
  hinp : inputCarriersMatchD (Tpl.Ordinary.graph.take K) cert insT = true
  hins : ∀ σ : Nat → Nat, (∀ j, j < 15235 → σ j = j) → ∀ key j, insT key = some j →
    inputNode (loadedAt σ ps) (tensorAt (σ tok)) key = some (σ j)
  hdown : (List.range s.nnext).all (downB (exactTplDom 15235 15235 [5554869888] s) s) = true

section Template
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = stages) (hhead : linLayout .affineRow w.head = head)

include hcaps₀ hlay hhead in
/-- The step's graph at an interior time is the ordinary template's. -/
theorem step_graph (hs : List Handles) (c n : Nat) (caps : CapsFor c (stageWeights w) hs) (interior : n + 1 < c) :
    (stepGraphOf w hs n).1 = Tpl.Ordinary.graph.map (mapN (SDim.eval n)) := by
  have h : ((templateOf w hs₀ 1).1.map (mapN (SDim.eval n)), (templateOf w hs₀ 1).2) = stepGraphOf w hs n :=
    template_eval SDim.lit 1 .pos .pos1 _ _ (SDim.eval n) n _ (fun _ => rfl) rfl rfl
      (chainLayout_sig 256 c 1 n (kvSig_interior c n interior).symm _ _ _ hcaps₀ caps)
  rw [← h, templateOf_eq w hs₀ hlay hhead]

include hcaps₀ hlay hhead in
/-- The whole step at an interior time is the ordinary template's. -/
theorem step_eq (hs : List Handles) (c n : Nat) (caps : CapsFor c (stageWeights w) hs) (interior : n + 1 < c) :
    stepGraphOf w hs n = (Tpl.Ordinary.graph.map (mapN (SDim.eval n)), Tpl.Ordinary.tokenNode, Tpl.Ordinary.cacheOutputs) := by
  have h : ((templateOf w hs₀ 1).1.map (mapN (SDim.eval n)), (templateOf w hs₀ 1).2) = stepGraphOf w hs n :=
    template_eval SDim.lit 1 .pos .pos1 _ _ (SDim.eval n) n _ (fun _ => rfl) rfl rfl
      (chainLayout_sig 256 c 1 n (kvSig_interior c n interior).symm _ _ _ hcaps₀ caps)
  rw [← h, templateOf_eq w hs₀ hlay hhead]

include hcaps₀ hlay hhead in
/-- **The forward's part of the step matches** at a certificate's carriers. -/
theorem fin_match {s : Ffi.St} {S : SSrv} {B : Box} {V : VarV} {d : Int} {K : Nat} (c : FinCert s S B V d K)
    (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat) (n : Nat) (emb : Embeds σ cl (mapG (SDim.eval n) (gsV s S B V d)) G)
    (hs : List Handles) (cap : Nat) (caps : CapsFor cap (stageWeights w) hs) (interior : n + 1 < cap) :
    Matches G ((stepGraphOf w hs n).1.take K) (c.cert.map σ) = true := by
  rw [step_graph w hs₀ hcaps₀ hlay hhead hs cap n caps interior, ← List.map_take]
  exact matches_embed _ G emb _ _ (by rw [List.length_map, List.length_take]; exact Nat.le_trans (Nat.min_le_left _ _) c.hlen)
    (matchesD_map (SDim.eval n) _ _ c.cert c.hm)

include hcaps₀ hlay hhead in
/-- **The forward's inputs** at a certificate's carriers. -/
theorem fin_inputs {s : Ffi.St} {S : SSrv} {B : Box} {V : VarV} {d : Int} {K : Nat} (c : FinCert s S B V d K) (σ : Nat → Nat)
    (ins : InKey → Option Nat) (hs : List Handles) (cap n : Nat) (caps : CapsFor cap (stageWeights w) hs) (interior : n + 1 < cap)
    (renamed : ∀ key j, c.insT key = some j → ins key = some (σ j)) :
    inputCarriersMatch ((stepGraphOf w hs n).1.take K) (c.cert.map σ) ins = true := by
  rw [step_graph w hs₀ hcaps₀ hlay hhead hs cap n caps interior, ← List.map_take]
  refine inputCarriers_embed _ c.cert (by rw [List.length_map, List.length_take]; exact Nat.le_trans (Nat.min_le_left _ _) c.hlen)
    c.insT ins renamed ?_
  rw [inputCarriersMatch_map]
  exact c.hinp

end Template

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract

/-- A cached step's inputs at values `ev`, the token's given. -/
theorem held_first (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) (tab : List F64)
    (ev : Nat → Option Value) (l : Loaded) (token : Tensor) (ids : Value) (E : List (RNode Int InKey)) (cert : List Nat)
    (hs : List Handles) (hmodel : l.model = parameterChoice.model)
    (hpar : ∀ t ∈ parameterTensors parameterChoice, ev t.node = some (firstValues Mx Kx env tab t))
    (compat : List.Forall₂ CacheCompatible (stageWeights (weights (firstValues Mx Kx env tab))) hs)
    (caches : CacheValuesV ev l.cache hs) (hids : ev token.node = some ids)
    (inputs : inputCarriersMatch E cert (inputNode l token) = true) :
    HeldV ev E cert (stepEnvWithIds env.weights (weights (firstValues Mx Kx env tab)) ids hs) := by
  have hl := firstPipeline_loaded Mx Kx env tab leaves typed
  have hp : ∀ t, t ∈ parameterTensors l → ev t.node = some (firstValues Mx Kx env tab t) := by
    intro t ht
    have ht' : t ∈ parameterTensors parameterChoice := by
      simpa only [parameterTensors, hmodel] using ht
    exact hpar t ht'
  apply heldV_cached _ l token (firstValues Mx Kx env tab) _ _ _ hs hp
  · intro key hk hnc
    have parameters : parameterInput l key = parameterInput parameterChoice key := by
      cases key <;> simp only [parameterInput, hmodel]
    rw [parameters]
    have loaded := stages_loaded Mx Kx (firstPipeline Mx Kx env tab leaves typed) _ hl
    have initial := cacheCompatible_of_holds Mx Kx _ _ initialHandles _ loaded (initialChainHolds _)
    exact (stepInputsWithIds_parameter_eq _ ids hs initialHandles compat initial key hnc).trans
      (initial_input_values _ ids key hk)
  · exact caches
  · intro q i
    exact stepInputsWithIds_cache_value _ ids hs compat caches.populated q i
  · intro v hv
    have : ids = v := by simpa [stepEnvWithIds, stepInputsWithIds] using hv
    rw [← this]
    exact hids
  · exact inputs

/-- **`hfin` of a tailed class**, at the forward's return. -/
theorem hfinV (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1)) (stageWeights (weights (firstValues Mx Kx env tab))) s.hs)
    {s : Ffi.St} {S : SSrv} {B : Box} {V : VarV} {K : Nat}
    (c : FinCert s S B V (-1) K) (hbelow : ∀ k, k < K → certAt c.cert k < s.nnext) {NB : Nat} (hNB : 15235 ≤ NB)
    (hL1 : 2 ≤ π.length) (hL2 : π.length ≤ 224) (hB : InBox B (nuV V π.length))
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = c.ps) (Kept : Nat → List (Nat × Nat))
    (hKept : ∀ q ∈ Kept π.length, q.1 < c.cert.length ∧ certAt c.cert q.1 = q.2) (Kn : Nat → Nat) (hKn : Kn π.length = K)
    {x y : SegInst FF} {Pm : LoadP} (hmr : Host.Ts.Sim.G.MR Pm NB y.M S.tab.length s (mlxOf y.t.ffi)) (hband : Pm.NL = Pm.N0)
    (hrope : y.M.big 5554869888 = 5554869888)
    (hρ : ∀ j l h, B.get j = some (l, h) → y.ν j = F64.ofInt (nuV V π.length j))
    (hnum : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → ∀ i e, nth? S.tab i = some e →
      CSrv.val ⟨tab⟩ (y.M.nv (.ref i)) = some (e.eval y.ν))
    (hinp : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → HostInt32 (concrete (CSrv.val ⟨tab⟩)) (mlxOf y.t.ffi) (y.M.node c.tok)
      [Int.ofNat (π.getD (π.length - 1) 0)] [1, 1])
    (ha : π.getD (π.length - 1) 0 < 2 ^ 31)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node) (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memExit P KR NE net env π Cr L x) : memFin P KR NE net env π Kept Kn L y := by
  intro hL
  subst hL
  obtain ⟨-, h2⟩ := hm rfl
  obtain ⟨kind, hp⟩ := h2 hL1
  refine ⟨kind, fun tab hC => ?_⟩
  obtain ⟨s', hs', hheld, -⟩ := hp.prefillAt (by omega) (by omega) tab (hle.trans hC)
  obtain ⟨s2, e2, hpre2⟩ := hpre tab
  obtain rfl : s2 = s' := Option.some.inj (e2.symm.trans hs')
  have hy := hheld.grow hg ht
  rw [hCr, ← hnode] at hy
  have hcaps0 := capsFor_of_pre (o := π.length - 1) (by omega) hpre2 hy.values.populated
  rw [show Host.Mlx.SimGraph.Mach.capL (π.length - 1) = 256 by unfold Host.Mlx.SimGraph.Mach.capL; omega] at hcaps0
  have emb0 := embedsV s S B V (L := π.length) (n := π.length - 1) (d := -1) (by omega) hB tab hmr hband hrope y.ν hρ (hnum tab hC) c.hdown
  have hin := c.hins y.M.node (fun j hj => hmr.nid j (Nat.lt_of_lt_of_le hj hNB))
  refine ⟨π.getD (π.length - 1) 0, s2.hs, c.cert.map y.M.node, by rw [refPrompt_start, hs']; rfl, ?_, hy.toBase, ?_, fun _ => hcaps0⟩
  · rw [hKn]
    refine ⟨fun z hz => ?_, ?_, fun k hk => ?_, fun k e key v hk he hpk hv => ?_⟩
    · have emb' := embeds_grow (G := mapG (SDim.eval (π.length - 1)) (gsV s S B V (-1))) emb0 (fun i r hr => by
        obtain ⟨r0, h0, -⟩ := Option.map_eq_some_iff.mp hr
        refine hmr.nimg i ?_
        unfold gsV restrictTo at h0
        split at h0
        · obtain ⟨nd, hnd, -⟩ := Option.bind_eq_some_iff.mp h0
          show (s.nodes.get i).isSome = true
          rw [hnd]
          rfl
        · cases h0) hz
      exact fin_match _ (populatedLayoutHandles 256) (caps_eq P KR env tab) (layout_eq P KR env tab) (head_eq P KR env tab) c
        (Gr tab z) y.M.node y.M.handle (π.length - 1) emb' s2.hs 256 hcaps0 (by omega)
    · rw [List.length_map]
      exact c.hlen
    · rw [certAt_map _ _ _ (Nat.lt_of_lt_of_le hk c.hlen)]
      exact hmr.nall _ (hbelow k hk)
    · have htok : routeVal P KR env kind (fun _ => none) tab (mlxOf y.t.ffi) (y.M.node c.tok) =
          some (coldIds (π.getD (π.length - 1) 0)) :=
        (routeVals_empty P KR env kind tab (mlxOf y.t.ffi) _).trans
          ((hostInt32_eval P KR env kind _ _ _ _ _ _ (hinp tab hC)).trans (cellsValue_singleton _ ha))
      have hh := held_first P KR env leaves typed tab (routeVal P KR env kind (fun _ => none) tab (mlxOf y.t.ffi))
        (loadedAt y.M.node c.ps) (tensorAt (y.M.node c.tok)) (coldIds (π.getD (π.length - 1) 0))
        ((stepGraphOf (weights (firstValues Mx Kx env tab)) s2.hs (π.length - 1)).1.take K) (c.cert.map y.M.node) s2.hs rfl
        (fun t ht' => (hy.params t ht').1) (compat_of_caps hcaps0) hy.values htok
        (fin_inputs _ (populatedLayoutHandles 256) (caps_eq P KR env tab) (layout_eq P KR env tab) (head_eq P KR env tab) c
          y.M.node _ s2.hs 256 (π.length - 1) hcaps0 (by omega) hin)
      exact hh k e key v (by rw [List.getElem?_take_of_lt hk]; exact he) hpk hv
  · intro q hq
    obtain ⟨hlt, he⟩ := hKept q hq
    rw [certAt_map _ _ _ hlt, he]

end Host.Route.Cert.Fin
