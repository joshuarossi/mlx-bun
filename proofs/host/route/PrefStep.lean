import host.route.PrefGraph
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter
open Host.Mlx.SimGraph.Mach (CacheValuesV cacheValuesV_of_facts routeVal GrR)
open Host.Mlx.SimGraph.Ref (refRows refNu rowSem rowIds stepEnv handlesOf)

/-! # A prefill forward's graph step at the route's values

A generated GPU row forward's endpoint supplies `hstep` of `DrainG.succ` through `rowStep_values`: the family's
checked template (`FamilyTemplate`) embedded in the route graph, keyed by `PKey.base`, the carriers of its inputs, and
its output carriers. The value comes from `rowTpl_graph_stepR`: the reference's `rowSem` returning handles `hs'`, the
output carriers hold them. -/

section
variable {κ κ' : Type} (f : κ → κ') (env : Env κ') (env₀ : Env κ)

/-- The resolved FFI graph has no step-input leaves, whatever its key type. -/
theorem resolvePrim_keyAgree (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (r : RPrim Int κ), resolvePrim N kn shape dtype p = some r → KeyAgree f env env₀ r := by
  intro p
  induction p with
  | replayed c p ih =>
    intro r h
    simp only [resolvePrim, Option.map_eq_some_iff] at h
    obtain ⟨q, hq, rfl⟩ := h
    exact ih q hq
  | _ =>
    intro r h
    simp only [resolvePrim, Option.map_eq_some_iff, Option.bind_eq_bind, Option.bind_eq_some_iff,
      Option.pure_def, Option.some.injEq] at h
    aesop (add norm KeyAgree)

theorem resolvePrimP_keyAgree (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ (p : Ffi.Prim) (r : RPrim Int κ), resolvePrimP N kn shape dtype p = some r → KeyAgree f env env₀ r := by
  intro p
  induction p with
  | replayed c p ih =>
    intro r h
    simp only [resolvePrimP, Option.map_eq_some_iff] at h
    obtain ⟨q, hq, rfl⟩ := h
    exact ih q hq
  | arange a b c =>
    intro r h
    simp only [resolvePrimP, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def] at h
    aesop (add norm KeyAgree)
  | _ => intro r h; exact resolvePrim_keyAgree f env env₀ N kn shape dtype _ r h

theorem ffiGraphR_keyAgree (N : Nums Int) (S : KernelSources) (x : Ffi.St) (j : Nat) (nd : RNode Int κ)
    (h : ffiGraphR N S x j = some nd) : KeyAgree f env env₀ nd.prim := by
  simp only [ffiGraphR, Option.bind_eq_some_iff] at h
  obtain ⟨n, _, hn⟩ := h
  simp only [resolveNodeP, Option.map_eq_some_iff] at hn
  obtain ⟨p, hp, rfl⟩ := hn
  exact resolvePrimP_keyAgree f env env₀ N _ n.shape n.dtype n.prim p hp

end

/-- A family's facts about the caches, read at the handles the reference returns. -/
theorem cacheFacts_of_handlesOf : ∀ (ws : List StageWeights) (cs : List (Value × Value)) (hs : List Handles)
    (ps : List (Nat × Nat)), handlesOf ws cs = some hs → ∀ q ∈ cacheFacts ps hs, q ∈ Handle.facts ps cs
  | [], [], hs, ps, h, q, hq => by
    simp only [handlesOf, Option.some.injEq] at h
    subst h
    cases ps <;> simp [cacheFacts] at hq
  | .delta w :: ws, (a, b) :: cs, hs, ps, h, q, hq => by
    simp only [handlesOf, Option.map_eq_some_iff] at h
    obtain ⟨hs', e, rfl⟩ := h
    cases ps with
    | nil => simp [cacheFacts] at hq
    | cons p ps =>
      simp only [cacheFacts, handleVals, List.cons_append, List.nil_append, List.mem_cons] at hq
      simp only [facts_list, List.zip_cons_cons, List.flatMap_cons, facts_prod, facts_nat, List.cons_append,
        List.nil_append, List.mem_cons]
      rcases hq with rfl | rfl | hq
      · exact .inl rfl
      · exact .inr (.inl rfl)
      · exact .inr (.inr (cacheFacts_of_handlesOf ws cs hs' ps e q hq))
  | .attention w :: ws, (a, b) :: cs, hs, ps, h, q, hq => by
    simp only [handlesOf, Option.map_eq_some_iff] at h
    obtain ⟨hs', e, rfl⟩ := h
    cases ps with
    | nil => simp [cacheFacts] at hq
    | cons p ps =>
      simp only [cacheFacts, handleVals, List.cons_append, List.nil_append, List.mem_cons] at hq
      simp only [facts_list, List.zip_cons_cons, List.flatMap_cons, facts_prod, facts_nat, List.cons_append,
        List.nil_append, List.mem_cons]
      rcases hq with rfl | rfl | hq
      · exact .inl rfl
      · exact .inr (.inl rfl)
      · exact .inr (.inr (cacheFacts_of_handlesOf ws cs hs' ps e q hq))
  | [], _ :: _, _, _, h, _, _ => by simp [handlesOf] at h
  | _ :: _, [], _, _, h, _, _ => by cases ‹StageWeights› <;> simp [handlesOf] at h

theorem handles_populated : ∀ (ws : List StageWeights) (cs : List (Value × Value)) (hs : List Handles),
    handlesOf ws cs = some hs → ∀ h ∈ hs, (handleVals h).isSome
  | [], [], hs, e, h, hh => by
    simp only [handlesOf, Option.some.injEq] at e
    subst e
    cases hh
  | .delta w :: ws, (a, b) :: cs, hs, e, h, hh => by
    simp only [handlesOf, Option.map_eq_some_iff] at e
    obtain ⟨hs', e', rfl⟩ := e
    rcases List.mem_cons.mp hh with rfl | hh
    · rfl
    · exact handles_populated ws cs hs' e' h hh
  | .attention w :: ws, (a, b) :: cs, hs, e, h, hh => by
    simp only [handlesOf, Option.map_eq_some_iff] at e
    obtain ⟨hs', e', rfl⟩ := e
    rcases List.mem_cons.mp hh with rfl | hh
    · rfl
    · exact handles_populated ws cs hs' e' h hh
  | [], _ :: _, _, e, _, _ => by simp [handlesOf] at e
  | _ :: _, [], _, e, _, _ => by cases ‹StageWeights› <;> simp [handlesOf] at e

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled) (Z : Nat → Option Value)

/-- The route graph read at prompt keys: `PKey.base` of its nodes. -/
noncomputable abbrev GrK (tab : List F64) (x : Ffi.St) : Nat → Option (RNode Int SimGraph.PKey) :=
  keyG SimGraph.PKey.base (GrR tab x)

/-- The keyed graph's values are the route's. -/
theorem routeVal_of_keyed (tab : List F64) (x : Ffi.St) (envP : FfiEval.Env SimGraph.PKey) (hw : envP.weights = env.weights)
    (i : Nat) (v : Value) (h : evalRR P KR envP kind (GrK tab x) i = some v) :
    routeVal P KR env kind Z tab x i = some v := by
  rw [evalRR_keyG SimGraph.PKey.base P KR envP env kind (GrR tab x) hw
    (fun j nd hj => ffiGraphR_keyAgree SimGraph.PKey.base envP env _ _ x j nd hj)] at h
  exact evalRR_evalZ P KR env kind Z _ i v h

/-- **A GPU row forward's graph step at the route's values.** The family's template embedded in the route graph and
its inputs held, the reference's `rowSem` returning `hs'`, the output carriers hold `hs'`. -/
theorem rowStep_values (tab : List F64) (x : Ffi.St) (w : PipelineWeights) (π : List Nat) (pk : ProjKind) (mk : MlpKind)
    (rd : Read) (o n : Nat) (hs hs' : List Handles)
    (hv : rowSem P KR env.weights w π (rowTpl refRows pk mk rd) o n hs = some hs')
    (T : FamilyTemplate (rowFamily refRows pk mk rd))
    (hsig : List.Forall₂ (SigRelR kvSigP T.o₀ T.n₀ o n) T.ss₀ (chainLayout (stageWeights w) hs))
    (σ cl : Nat → Nat) (emb : Embeds σ cl (mapG (PDim.eval (refNu o n)) T.Gs) (GrK tab x))
    (hk : ∀ c, kind (cl c) = T.kind c)
    (hin : ∀ ids, rowIds π o n = some ids →
      InputsHeldR P KR (stepEnv env.weights w o n ids hs) kind (GrK tab x)
        (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).1
        (T.cert.map σ))
    (hG : KernelsPlain (GrK tab x)) (nextCache : List Cache)
    (hout : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).2.2.map
        (fun (a, b) => (some (σ (certAt T.cert a)), some (σ (certAt T.cert b)))))
    (hlen : (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n
      (chainLayout (stageWeights w) hs)).2.2.length = hs'.length) :
    CacheValuesV (routeVal P KR env kind Z tab x) nextCache hs' := by
  unfold rowSem at hv
  cases hids : rowIds π o n with
  | none => rw [hids] at hv; cases hv
  | some ids =>
  rw [hids] at hv
  dsimp only [bind, Option.bind] at hv
  cases hr : forwardT (rowTpl refRows pk mk rd) (valueB P KR.toKernelContract (stepEnv env.weights w o n ids hs)
      (ksR P KR (stepEnv env.weights w o n ids hs))) (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs) with
  | none => rw [hr] at hv; cases hv
  | some r =>
  rw [hr] at hv
  have hh : handlesOf (stageWeights w) r.2 = some hs' := hv
  have hfacts := rowTpl_graph_stepR P KR refRows pk mk rd (stepEnv env.weights w o n ids hs) T (refNu o n) o n _ hsig
    (GrK tab x) σ cl emb kind hk (hin ids hids) hG r.1 r.2 hr
  refine cacheValuesV_of_facts nextCache _ hs' (fun a => σ (certAt T.cert a)) hout hlen
    (handles_populated _ _ _ hh) fun q hq => ?_
  refine routeVal_of_keyed P KR env kind Z tab x _ rfl _ _ (hfacts q ?_)
  simp only [facts_prod]
  exact List.mem_append_right _ (cacheFacts_of_handlesOf _ _ _ _ hh q hq)

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The reference at time `L`** is the final forward's handles and the head's and sampler's token, from the state
the prefill's exit cut holds (`ExitG`). -/
theorem refPrompt_last (tab : List F64) (h1 : 1 ≤ π.length) {s : Host.Mlx.SimGraph.Ref.RSt} {hidden : Value}
    {hs : List Handles} (hp : Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s)
    (hf : finalForward P KR env π tab s.hs = some (hidden, hs)) :
    Host.Mlx.SimGraph.Mach.refPrompt P KR NE KR.inPlace net env π tab π.length =
      (finalToken P KR env tab hidden).map fun t => (t, hs) := by
  have hsucc := Host.Mlx.SimGraph.Mach.refPrompt_succ P KR NE KR.inPlace net env π tab (π.length - 1) le_rfl
  rw [show π.length - 1 + 1 = π.length by omega, Host.Mlx.SimGraph.Mach.refPrompt_start, hp] at hsucc
  rw [hsucc]
  simp only [Option.map_some, Option.bind_some]
  rw [stepTrace_final P KR env π tab s.hs, hf]
  rfl

end

end Host.Route.PrefGraph
