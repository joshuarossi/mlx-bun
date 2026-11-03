import host.route.PrefStep
import host.simgraph.family.MatchOn
import host.simgraph.compose.Split
import host.simgraph.prompt.EmbedRoute
import host.simgraph.prompt.RowsRead
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter
open Host.Mlx.SimGraph.Mach (CacheValuesV routeVal cacheValuesV_of_facts)
open Host.Mlx.SimGraph.Ref (refRows refNu rowSem rowIds stepEnv handlesOf)

/-! # A row family's forward from a certificate on the chain's end state

The reference reads a family's dimensions at `refRows` (offset at variable 0, rows at 1); a chain's first forward has
offset 0 and its rows at its own variable `x`.

* `rowsAt x`: the reference's dimension at the chain's variables; `rowsAt_eval`: evaluation agrees.
* `cert_route`: a kernel-checked match of the chain's end graph against the family's expected graph at `rowsAt x` gives
  the match on the route's graph at the reference's valuation.
* `rowStep_of_matches`: from that match, the inputs and the plain kernels, the forward's output handles at their carriers
  (`rowStep_values` without a `FamilyTemplate`). -/

theorem termsEval_rowsTerms (ν : Nat → Int) (x n : Nat) (hx : ν x = n) :
    ∀ ts : List (Int × Nat), termsEval ν (rowsTerms x ts) = termsEval (refNu 0 n) ts
  | [] => rfl
  | t :: ts => by
    have ih := termsEval_rowsTerms ν x n hx ts
    unfold rowsTerms at ih ⊢
    rw [List.filterMap_cons]
    by_cases h1 : t.2 = 1
    · simp only [h1, ↓reduceIte, termsEval, ih, hx]
      simp [refNu]
    · simp only [h1, ↓reduceIte, termsEval, ih]
      by_cases h0 : t.2 = 0
      · simp [refNu, h0]
      · simp [refNu, h0, h1]

/-- **The rewrite keeps the value.** -/
theorem rowsAt_eval (ν : Nat → Int) (x n : Nat) (hx : ν x = n) :
    ∀ d : PDim, (rowsAt x d).eval ν = d.eval (refNu 0 n)
  | .lit _ => rfl
  | .lin c ts => by
    simp only [rowsAt, Aff.eval_toP, Aff.eval, PDim.eval]
    rw [termsEval_rowsTerms ν x n hx]
  | .fdiv d k => by simp only [rowsAt, PDim.eval, rowsAt_eval ν x n hx d]
  | .cdiv d k => by simp only [rowsAt, PDim.eval, rowsAt_eval ν x n hx d]
  | .rup k d => by simp only [rowsAt, PDim.eval, rowsAt_eval ν x n hx d]

section
variable {κ : Type} [DecidableEq κ]

/-- The family's graph at the reference's valuation is the chain's reading of it at the chain's. -/
theorem graph_rows (E : List (RNode PDim κ)) (ν : Nat → Int) (r : PDim → PDim) (n : Nat) (hr : ∀ d, (r d).eval ν = d.eval (refNu 0 n)) :
    (E.map (Host.Mlx.SimGraph.mapN r)).map (Host.Mlx.SimGraph.mapN (PDim.eval ν)) = E.map (Host.Mlx.SimGraph.mapN (PDim.eval (refNu 0 n))) := by
  rw [List.map_map]
  refine List.map_congr_left fun nd _ => ?_
  show mapN (PDim.eval ν) (Host.Mlx.SimGraph.mapN r nd) = _
  obtain ⟨p, ins⟩ := nd
  simp only [Host.Mlx.SimGraph.mapN, mapP_comp]
  congr 2
  funext d
  exact hr d

/-! A closure's kind is read only where a table names one, so a match survives any table agreeing on the names. -/

theorem closureBody_mono {kind kind' : Nat → Option Compiled} (h : ∀ c k, kind c = some k → kind' c = some k)
    (cls : Nat) (p : RPrim Int κ) (r : RNode Int κ) (b : Nat → Option (RNode Int κ)) (x : Compiled × List Nat)
    (hx : closureBody kind cls p r b = some x) : closureBody kind' cls p r b = some x := by
  unfold closureBody at hx ⊢
  cases hk : kind cls with
  | none => rw [hk] at hx; cases hx
  | some k =>
    rw [hk] at hx
    rw [h cls k hk]
    exact hx

theorem closureLeaves_mono {kind kind' : Nat → Option Compiled} (h : ∀ c k, kind c = some k → kind' c = some k)
    (G : Nat → Option (RNode Int κ)) (i : Nat) (x : Compiled × List Nat) (hx : closureLeaves kind G i = some x) :
    closureLeaves kind' G i = some x := by
  unfold closureLeaves at hx ⊢
  obtain ⟨r, hr, ha⟩ := Option.bind_eq_some_iff.mp hx
  rw [hr, Option.bind_some]
  unfold closureAux at ha ⊢
  split at ha
  · rename_i cls p hp
    split at ha
    · rename_i he
      simp only [hp, he, ↓reduceIte]
      exact closureBody_mono h _ _ _ _ _ ha
    · cases ha
  · cases ha

theorem matchesED_mono {δ : Type} [DecidableEq δ] {kind kind' : Nat → Option Compiled}
    (h : ∀ c k, kind c = some k → kind' c = some k) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (cert : List Nat)
    (hm : MatchesED kind G E cert = true) : MatchesED kind' G E cert = true := by
  unfold MatchesED at hm ⊢
  refine List.all_eq_true.mpr fun k hk => ?_
  have hok := List.all_eq_true.mp hm k hk
  cases hE : E[k]? with
  | none => rw [hE] at hok; cases hok
  | some e =>
    rw [hE] at hok
    dsimp only at hok ⊢
    have hc : (closureCheck kind G cert k e).getD (plainCheck G cert k e) = true →
        (closureCheck kind' G cert k e).getD (plainCheck G cert k e) = true := by
      unfold closureCheck
      cases closureOf? e.prim with
      | none => exact id
      | some c =>
        simp only [Option.map_some, Option.getD_some, decide_eq_true_eq]
        exact closureLeaves_mono h _ _ _
    simp only [nodeOkED, Bool.and_eq_true] at hok ⊢
    refine ⟨hok.1, ?_⟩
    have h2 := hok.2
    split at h2
    · rw [if_pos ‹_›]; exact h2
    · rw [if_neg ‹_›]
      split at h2
      · rw [if_pos ‹_›]; exact h2
      · rw [if_neg ‹_›]; exact hc h2

/-- **The certificate on the route's graph.** A check of the chain's end graph `Gs` against the family's expected graph
read at the rows' variable `x`, at the chain's valuation `ν`, along the embedding into the route. -/
theorem cert_route (F : RowFamily κ) (d : κ) (o₀ n₀ : Nat) (ss₀ : List StageLayout) (ν : Nat → Int) (r : PDim → PDim) (n : Nat)
    (hr : ∀ d, (r d).eval ν = d.eval (refNu 0 n)) (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig o₀ n₀ 0 n) ss₀ ss)
    (Gs : Nat → Option (RNode PDim κ)) (kind : Nat → Option Compiled) (cert : List Nat)
    (hlen : (familyGraph F.ops id o₀ n₀ ss₀).1.length ≤ cert.length)
    (h : MatchesSeg d kind Gs ((familyGraph F.ops id o₀ n₀ ss₀).1.map (Host.Mlx.SimGraph.mapN r)) cert 0
      ((familyGraph F.ops id o₀ n₀ ss₀).1.map (Host.Mlx.SimGraph.mapN r)).length = true)
    (G : Nat → Option (RNode Int κ)) {σ cl : Nat → Nat} (emb : Embeds σ cl (mapG (PDim.eval ν) Gs) G)
    (kind' : Nat → Option Compiled) (hk : ∀ c k, kind c = some k → kind' (cl c) = some k) :
    MatchesED kind' G (familyGraph F.ops (PDim.eval (refNu 0 n)) 0 n ss).1 (cert.map σ) = true := by
  have hm := matchesSeg_map (PDim.eval ν) d kind Gs _ cert 0 _ h
  rw [graph_rows _ ν r n hr,
    show (familyGraph F.ops id o₀ n₀ ss₀).1.map (Host.Mlx.SimGraph.mapN (PDim.eval (refNu 0 n))) = (familyGraph F.ops (PDim.eval (refNu 0 n)) 0 n ss).1 from
      congrArg Prod.fst (family_eval F o₀ n₀ ss₀ (refNu 0 n) 0 n ss hsig)] at hm
  have hl : (familyGraph F.ops (PDim.eval (refNu 0 n)) 0 n ss).1.length ≤ cert.length := by
    rw [← congrArg Prod.fst (family_eval F o₀ n₀ ss₀ (refNu 0 n) 0 n ss hsig), List.length_map]
    exact hlen
  have hm' := matchesSeg_embed d (fun c => kind' (cl c)) kind' (fun _ => rfl) _ G emb _ cert 0 _ hl
    (matchesED_mono hk _ _ _ hm)
  refine matchesSeg_whole d kind' G _ _ ?_
  have hlenE : ((familyGraph F.ops id o₀ n₀ ss₀).1.map (Host.Mlx.SimGraph.mapN r)).length =
      (familyGraph F.ops (PDim.eval (refNu 0 n)) 0 n ss).1.length := by
    rw [← congrArg Prod.fst (family_eval F o₀ n₀ ss₀ (refNu 0 n) 0 n ss hsig), List.length_map, List.length_map]
  rw [← hlenE]
  exact hm'

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled) (Z : Nat → Option Value)

/-- **A GPU row forward's step at the route's values, from the match on the route's graph.** -/
theorem rowStep_of_matches (tab : List F64) (x : Ffi.St) (w : PipelineWeights) (π : List Nat) (pk : ProjKind) (mk : MlpKind)
    (rd : Read) (o n : Nat) (hs hs' : List Handles)
    (hv : rowSem P KR env.weights w π (rowTpl refRows pk mk rd) o n hs = some hs') (cert : List Nat)
    (hm : MatchesED kind (GrK tab x)
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).1 cert = true)
    (hin : ∀ ids, rowIds π o n = some ids →
      InputsHeldR P KR (stepEnv env.weights w o n ids hs) kind (GrK tab x)
        (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).1 cert)
    (hG : ∀ k e, (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n
        (chainLayout (stageWeights w) hs)).1[k]? = some e → ∀ nd name c out, e.prim = .kernel name c out →
      GrK tab x (certAt cert k) = some nd → nd.prim = e.prim)
    (nextCache : List Cache)
    (hout : nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).2.2.map
        (fun (a, b) => (some (certAt cert a), some (certAt cert b))))
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
  have hall := rowTpl_eval (P := P) (K := KR.toKernelContract) (env := stepEnv env.weights w o n ids hs)
    (ks := ksR P KR (stepEnv env.weights w o n ids hs)) refRows pk mk rd (refNu o n) o n _ r.1 r.2 hr
  refine cacheValuesV_of_facts nextCache _ hs' (fun a => certAt cert a) hout hlen
    (handles_populated _ _ _ hh) fun q hq => ?_
  refine routeVal_of_keyed P KR env kind Z tab x (stepEnv env.weights w o n ids hs) rfl _ _ ?_
  refine kernelsPlainOn_values P KR _ kind (GrK tab x) _ cert hm (hin ids hids) hG q.1 q.2 (hall q ?_)
  simp only [facts_prod]
  exact List.mem_append_right _ (cacheFacts_of_handlesOf _ _ _ _ hh q hq)

end

end Host.Route.PrefGraph
