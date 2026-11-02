import host.route.cert.Fin.Head
import host.simgraph.mach.Refine
import host.mlx.GraphStability
import host.route.GpuMem
import host.route.StepCert
import host.sim.compose.Gpu
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr cachesAt cachesAt_below cachesAt_nodes loadedAt tensorAt)
open Host.Mlx.SimGraph.Mach (routeVal CacheValuesV cacheValuesV_of_facts ffiGraph_route d1Sem_of_stepTrace
  WeightShapes weightShapes_of StageInit initial_init)
open Host.Mlx.SimGraph.Ref (routeStep tailStep d1Sem)
open Host.Ts.Sim (LoadP Map SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph
open Host.Ts.Sim.Compose.ColdGraph (coldIds coldIds_buffer cellsValue_singleton)

/-! # A two-token prompt's first forward

Its tail is one row, the decode step's forward (`d1Sem`): no head and no sampler run, so the step's cache values come from the forward's
part of its graph alone. `values_of_finAt`: those values at their carriers. `hfwdD1`: the pre-final bookkeeping, from a `D1Cert`. -/

theorem cacheFacts_lt {K : Nat} : ∀ {ps : List (Nat × Nat)} {hs : List Handles}, (∀ q ∈ ps, q.1 < K ∧ q.2 < K) →
    ∀ q ∈ cacheFacts ps hs, q.1 < K
  | [], _, _, _, hq => by cases hq
  | _ :: _, [], _, _, hq => by cases hq
  | c :: cs, h :: hs, hK, q, hq => by
    simp only [cacheFacts, List.mem_append] at hq
    rcases hq with hq | hq
    · cases hv : handleVals h with
      | none => rw [hv] at hq; cases hq
      | some ab =>
        obtain ⟨a, b⟩ := ab
        rw [hv] at hq
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hq
        have hc := hK c (List.mem_cons_self ..)
        rcases hq with rfl | rfl
        · exact hc.1
        · exact hc.2
    · exact cacheFacts_lt (fun r hr => hK r (List.mem_cons_of_mem _ hr)) q hq

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract

/-- **A step's handles at the forward's carriers**, from the forward's part alone. -/
theorem values_of_finAt (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {kind : Nat → Option Compiled}
    {tab : List F64} {hs : List Handles} {time tok K : Nat} {certT : List Nat} {x : Ffi.St}
    (hF : FinAt P KR env kind tab hs time tok K certT x) {t : Nat} {hs' : List Handles}
    (e : stepTrace Mx Kx (weights (firstValues Mx Kx env tab)) time tok hs = some (t, hs')) (htok : tok < 2 ^ 31)
    (hsh : ShapesOk (stageWeights (weights (firstValues Mx Kx env tab))) hs) {σ : Nat → Nat} {Cr : List (Option Nat × Option Nat)}
    (hCr : (cachesAt σ Cr).map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (stepGraphOf (weights (firstValues Mx Kx env tab)) hs time).2.2.map (fun (a, b) => (some (certAt certT a), some (certAt certT b))))
    (hKc : ∀ q ∈ (stepGraphOf (weights (firstValues Mx Kx env tab)) hs time).2.2, q.1 < K ∧ q.2 < K) :
    CacheValuesV (routeVal P KR env kind (fun _ => none) tab x) (cachesAt σ Cr) hs' := by
  have hl := firstPipeline_loaded Mx Kx env tab leaves typed
  have hembed := bufferEmbed_eq Mx _ _ _ _ _ (coldIds_buffer tok htok) hl.embedding.words.1 hl.embedding.words.2.1
    hl.embedding.scales.2.1 hl.embedding.biases.2.1
  obtain ⟨-, hlen, hsome, hcf⟩ := stepGraph_eval_ids Mx Kx env.weights _ time tok (coldIds tok) hembed hs hs' t hl.finalNorm.2.1 hsh e
  have hcarry := matches_evalZ P KR env (stepEnvWithIds env.weights (weights (firstValues Mx Kx env tab)) (coldIds tok) hs) kind
    (fun _ => none) rfl (fun j nd hj hne => ffiGraph_route _ _ _ j nd hj hne) (hF.seg x (Host.Mlx.Ffi.NGrow.refl _))
    (fun k e key v he hp hv => by
      have hk : k < K := by
        have := (List.getElem?_eq_some_iff.mp he).1
        rw [List.length_take] at this
        omega
      rw [List.getElem?_take_of_lt hk] at he
      exact hF.held k e key v hk he hp hv)
  refine cacheValuesV_of_facts _ _ hs' (certAt certT) hCr hlen hsome fun q hq => ?_
  obtain ⟨hql, hqv⟩ := hcf q hq
  have hqK := cacheFacts_lt hKc q hq
  have hpre := evalR_prefix Mx Kx (stepEnvWithIds env.weights (weights (firstValues Mx Kx env tab)) (coldIds tok) hs)
    (listGraph ((stepGraphOf (weights (firstValues Mx Kx env tab)) hs time).1.take K))
    (listGraph (stepGraphOf (weights (firstValues Mx Kx env tab)) hs time).1) q.1 (fun j hj => by
      show (List.take K _)[j]? = _
      rw [List.getElem?_take_of_lt (by omega)]
      rfl)
  exact hcarry q.1 (by rw [List.length_take]; omega) q.2 (hpre.trans hqv)

/-- The first step's forward part, as the certificate reads it. -/
def expS : List (RNode SDim InKey) := Expected.graph.map (SimGraph.mapN SDim.lit)

theorem expS_eval : expS.map (SimGraph.mapN (SDim.eval 0)) = Expected.graph := by
  unfold expS
  rw [List.map_map]
  have h : ∀ r : RNode Int InKey, SimGraph.mapN (SDim.eval 0) (SimGraph.mapN SDim.lit r) = r := fun r => by
    have hi := mapN_id r
    obtain ⟨p, ins⟩ := r
    show (⟨mapP (SDim.eval 0) (mapP SDim.lit p), ins⟩ : RNode Int InKey) = _
    rw [mapP_comp]
    exact hi
  conv_rhs => rw [← List.map_id Expected.graph]
  exact List.map_congr_left fun r _ => h r

kernel_rfl exp_outs : Expected.cacheOutputs.all (fun q => Nat.blt q.1 4010 && Nat.blt q.2 4010) = true

/-- The empty caches have their shapes. -/
theorem shapesOk_of_init {ws : List StageWeights} {hs : List Handles} (h : List.Forall₂ StageInit ws hs) :
    WeightShapes ws → ShapesOk ws hs := by
  induction h with
  | nil => exact fun _ => trivial
  | @cons w x ws hs hi _ ih =>
    intro hw
    cases w with
    | delta d =>
      cases x with
      | delta a b => exact ⟨hw.1, ih hw.2⟩
      | attention a b => exact hi.elim
    | attention d =>
      cases x with
      | delta a b => exact hi.elim
      | attention a b =>
        cases a with
        | some _ => exact hi.elim
        | none =>
          cases b with
          | some _ => exact hi.elim
          | none =>
            have hb0 : BufShape none := fun _ h => by cases h
            exact ⟨⟨hw.1.1, hw.1.2.1, hw.1.2.2, ⟨hb0, hb0⟩⟩, ih hw.2⟩

/-- A two-token prompt's first forward's checked certificate. -/
structure D1Cert (s : Ffi.St) (S : SSrv) (B : Box) (V : VarV) where
  cert : List Nat
  insT : InKey → Option Nat
  tok : Nat
  ps : List (Option Nat × Option Nat)
  hm : MatchesD (gsV s S B V (-2)) (expS.take 4010) cert = true
  hlen : 4010 ≤ cert.length
  hinp : inputCarriersMatchD (expS.take 4010) cert insT = true
  hins : ∀ σ : Nat → Nat, (∀ j, j < 15235 → σ j = j) → ∀ key j, insT key = some j →
    inputNode (loadedAt σ ps) (tensorAt (σ tok)) key = some (σ j)
  hbelow : ∀ k, k < 4010 → certAt cert k < s.nnext
  hdown : (List.range s.nnext).all (downB (exactTplDom 15235 15235 [5554869888] s) s) = true

/-- **The first forward of a two-token prompt.** -/
theorem hfwdD1 (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hstep : ∀ tab, ∃ t hs', stepTrace Mx Kx (weights (firstValues Mx Kx env tab)) 0 (π.getD 0 0) initialHandles = some (t, hs'))
    {s : Ffi.St} {S : SSrv} {B : Box} {V : VarV} (c : D1Cert s S B V) {NB : Nat} (hNB : 15235 ≤ NB) (hL2 : π.length = 2)
    (hB : InBox B (nuV V π.length)) (ha : π.getD 0 0 < 2 ^ 31) (Cr : Nat → List (Option Nat × Option Nat))
    (hCr : Cr π.length = Expected.cacheOutputs.map fun q => (some (certAt c.cert q.1), some (certAt c.cert q.2)))
    {x y : SegInst FF} {Pm : LoadP} {m : Nat} (hmr : Host.Ts.Sim.G.MR Pm NB y.M m s (mlxOf y.t.ffi)) (hband : Pm.NL = Pm.N0)
    (hrope : y.M.big 5554869888 = 5554869888)
    (hρ : ∀ j l h, B.get j = some (l, h) → y.ν j = F64.ofInt (nuV V π.length j))
    (hnum : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → ∀ i e, nth? S.tab i = some e →
      CSrv.val ⟨tab⟩ (y.M.nv (.ref i)) = some (e.eval y.ν))
    (hinp : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → HostInt32 (concrete (CSrv.val ⟨tab⟩)) (mlxOf y.t.ffi) (y.M.node c.tok)
      [Int.ofNat (π.getD 0 0)] [1, 1])
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memCold P KR net env π L x) : memPre P KR NE net env π Cr L y := by
  intro hLe
  subst hLe
  let κ : Nat → Option Compiled := fun _ => none
  refine ⟨κ, ?_⟩
  rw [hCr]
  refine ColdG.preG_tail hle (Host.Ts.Sim.Compose.Gpu.drains_short (by omega))
    (by rw [Host.Ts.Sim.Compose.Gpu.tailRows_short (by omega)]; omega) (hm rfl κ) fun tab hC hb _ => ?_
  obtain ⟨t, hs', e⟩ := hstep tab
  have hd1 := Host.Mlx.SimGraph.Mach.d1Sem_of_stepTrace P KR _ π 0 _ initialHandles hs' t rfl e
  have hby := hb.grow hg ht
  have hgr : stepGraphOf (weights (firstValues Mx Kx env tab)) initialHandles 0 =
      (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) := initial_step_graph _
  have hparam : ∀ j, j < 15235 → y.M.node j = j := fun j hj => hmr.nid j (Nat.lt_of_lt_of_le hj hNB)
  have hF : FinAt P KR env κ tab initialHandles 0 (π.getD 0 0) 4010 (c.cert.map y.M.node) (mlxOf y.t.ffi) := by
    have hrenamed : ∀ key j, c.insT key = some j →
        inputNode (loadedAt y.M.node c.ps) (tensorAt (y.M.node c.tok)) key = some (y.M.node j) := c.hins y.M.node hparam
    refine ⟨fun z hz => ?_, ?_, fun k hk => ?_, fun k e0 key v hk he hp hv => ?_⟩
    · rw [hgr]
      have h1 := matchesD_map (SDim.eval 0) _ _ c.cert c.hm
      have emb := embedsV s S B V (L := π.length) (n := 0) (d := -2) (by omega) hB tab hmr hband hrope y.ν hρ (hnum tab hC) c.hdown
      have emb' := embeds_grow (G := mapG (SDim.eval 0) (gsV s S B V (-2))) emb (fun i r hr => by
        obtain ⟨r0, h0, -⟩ := Option.map_eq_some_iff.mp hr
        refine hmr.nimg i ?_
        unfold gsV restrictTo at h0
        split at h0
        · obtain ⟨nd, hnd, -⟩ := Option.bind_eq_some_iff.mp h0
          show (s.nodes.get i).isSome = true
          rw [hnd]
          rfl
        · cases h0) hz
      have h2 := matches_embed (σ := y.M.node) (cl := y.M.handle) _ _ emb' _ c.cert
        (by rw [List.length_map, List.length_take]; exact Nat.le_trans (Nat.min_le_left _ _) c.hlen) h1
      rw [List.map_take, expS_eval] at h2
      exact h2
    · rw [List.length_map]
      exact c.hlen
    · rw [certAt_map _ _ _ (Nat.lt_of_lt_of_le hk c.hlen)]
      exact hmr.nall _ (c.hbelow k hk)
    · rw [hgr] at he
      have htok : routeVal P KR env κ (fun _ => none) tab (mlxOf y.t.ffi) (y.M.node c.tok) = some (coldIds (π.getD 0 0)) :=
        (Host.Mlx.SimGraph.Mach.routeVals_empty P KR env κ tab (mlxOf y.t.ffi) _).trans
          ((hostInt32_eval P KR env κ _ _ _ _ _ _ (hinp tab hC)).trans (cellsValue_singleton _ ha))
      have hin : inputCarriersMatch (Expected.graph.take 4010) (c.cert.map y.M.node)
          (inputNode (loadedAt y.M.node c.ps) (tensorAt (y.M.node c.tok))) = true := by
        refine inputCarriers_embed _ c.cert (by rw [List.length_take]; exact Nat.le_trans (Nat.min_le_left _ _) c.hlen)
          c.insT _ hrenamed ?_
        rw [← expS_eval, ← List.map_take, inputCarriersMatch_map]
        exact c.hinp
      have hh := heldV_initial _ y.M.node c.ps (tensorAt (y.M.node c.tok)) (firstValues Mx Kx env tab) env.weights
        (coldIds (π.getD 0 0)) _ _ (fun t' ht' => (hby.params t' ht').1) htok hin
      exact hh k e0 key v (by rw [List.getElem?_take_of_lt hk]; exact he) hp hv
  have hsh : ShapesOk (stageWeights (weights (firstValues Mx Kx env tab))) initialHandles :=
    shapesOk_of_init (Host.Mlx.SimGraph.Mach.initial_init _)
      (Host.Ts.Sim.Compose.weightShapes_first Mx Kx env leaves typed tab)
  have hqlt : ∀ q ∈ Expected.cacheOutputs, q.1 < 4010 ∧ q.2 < 4010 := fun q hq => by
    have h := List.all_eq_true.mp exp_outs q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact h
  have hvals := values_of_finAt P KR env leaves typed hF e ha hsh (σ := y.M.node)
    (Cr := Expected.cacheOutputs.map fun q => (some (certAt c.cert q.1), some (certAt c.cert q.2))) (by
      rw [hgr]
      refine (cachesAt_nodes y.M.node _).trans ?_
      simp only [List.map_map]
      refine List.map_congr_left fun q hq => ?_
      have h := hqlt q hq
      simp only [Function.comp, Option.map_some]
      rw [certAt_map _ _ _ (Nat.lt_of_lt_of_le h.1 c.hlen), certAt_map _ _ _ (Nat.lt_of_lt_of_le h.2 c.hlen)])
    (by
      rw [hgr]
      exact hqlt)
  refine ⟨{ refInit net with hs := hs' }, ?_, ⟨hby, hvals, ?_⟩, trivial⟩
  · have hstart : (tailStep π.length).start = 0 := by
      show Host.Ts.Sim.Prefill.drains π.length * _ = 0
      rw [Host.Ts.Sim.Compose.Gpu.drains_short (by omega), Nat.zero_mul]
    have hstop : (tailStep π.length).stop = 1 := by
      show π.length - 1 = 1
      omega
    show routeStep P KR NE KR.inPlace net env.weights _ π (tailStep π.length) (refInit net) = _
    unfold routeStep
    rw [hstart, hstop, ite_eq_left (by decide)]
    show (d1Sem P KR _ π 0 initialHandles).map _ = _
    rw [hd1]
    rfl
  · refine cachesAt_below _ _ _ fun p hp j hj => ?_
    obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hp
    have h := hqlt q hq
    rcases hj with hj | hj
    · obtain rfl := Option.some.inj hj
      exact hmr.nall _ (c.hbelow _ h.1)
    · obtain rfl := Option.some.inj hj
      exact hmr.nall _ (c.hbelow _ h.2)

end Host.Route.Cert.Fin
