import host.simgraph.prompt.PromptBuild
import host.simgraph.prompt.MatchMap
import host.simgraph.Step
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # A multi-row step from a checked template

`PromptTemplate F` generalizes `Template` (Step.lean) to a row family `F`:
the family's graph built once at representative control (offset `o₀`, rows
`n₀`) and layouts `ss₀` with symbolic `PDim` dimensions, and a certificate
`cert` carrying it in the symbolic template graph `Gs` (`MatchesD`, checked
once by the kernel).

* `prompt_template_instance`/`_matches`/`_inputs`: at any valuation `ν` and
  control and layouts in the template's branches (`SigRelR F.ops.sig`), the
  template evaluated at `ν` is the family's graph at `ν`, and a graph
  carrying `Gs` evaluated at `ν` carries it.
* `prompt_template_step`: the graph side of a step — each value the family's
  expected graph has (`EvA`, supplied by the family's value theorem) is the
  value of its carrier.
* `chainLayout_sigR`, `chainLayout_sigR_null`: layouts of populated caches at
  capacities in the same branches, and of the null caches of a first step,
  are related.
* The decode step is the D1 instance: `d1_familyGraph` (the D1 family at a
  position whose value is `time` is `stepGraphOf` at `time`),
  `Template.toD1` (a decode template is a D1 prompt template, by mapping its
  dimensions through `SDim.toP`; no new kernel check), and
  `d1_template_step` (`template_step` for a D1 template at a symbolic
  position, e.g. `L - 1` for the last prompt row). -/

/-- A multi-row step template of family `F`, checked once. -/
structure PromptTemplate {κ : Type} [DecidableEq κ] (F : RowFamily κ) where
  o₀ : Nat
  n₀ : Nat
  ss₀ : List StageLayout
  Gs : Nat → Option (RNode PDim κ)
  cert : List Nat
  checked : MatchesD Gs (familyGraph F.ops id o₀ n₀ ss₀).1 cert = true
  length : (familyGraph F.ops id o₀ n₀ ss₀).1.length ≤ cert.length

section
variable {κ : Type} [DecidableEq κ] {F : RowFamily κ} (T : PromptTemplate F) (ν : Nat → Int) (o n : Nat)
  (ss : List StageLayout) (hsig : List.Forall₂ (SigRelR F.ops.sig T.o₀ T.n₀ o n) T.ss₀ ss)
include hsig

theorem prompt_template_instance :
    ((familyGraph F.ops id T.o₀ T.n₀ T.ss₀).1.map (mapN (PDim.eval ν)), (familyGraph F.ops id T.o₀ T.n₀ T.ss₀).2) =
      familyGraph F.ops (PDim.eval ν) o n ss :=
  family_eval F T.o₀ T.n₀ T.ss₀ ν o n ss hsig

theorem prompt_template_length :
    (familyGraph F.ops (PDim.eval ν) o n ss).1.length ≤ T.cert.length := by
  rw [← congrArg Prod.fst (prompt_template_instance T ν o n ss hsig), List.length_map]
  exact T.length

theorem prompt_template_matches (G : Nat → Option (RNode Int κ)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G) :
    Matches G (familyGraph F.ops (PDim.eval ν) o n ss).1 (T.cert.map σ) = true := by
  rw [← congrArg Prod.fst (prompt_template_instance T ν o n ss hsig)]
  exact matches_embed _ G emb _ _ (by rw [List.length_map]; exact T.length)
    (matchesD_map (PDim.eval ν) T.Gs _ T.cert T.checked)

theorem prompt_template_inputs (σ : Nat → Nat) (ins ins' : κ → Option Nat)
    (checked : inputCarriersMatchD (familyGraph F.ops id T.o₀ T.n₀ T.ss₀).1 T.cert ins = true)
    (renamed : ∀ key j, ins key = some j → ins' key = some (σ j)) :
    inputCarriersMatch (familyGraph F.ops (PDim.eval ν) o n ss).1 (T.cert.map σ) ins' = true := by
  rw [← congrArg Prod.fst (prompt_template_instance T ν o n ss hsig)]
  refine inputCarriers_embed _ T.cert (by rw [List.length_map]; exact T.length) ins ins' renamed ?_
  rw [inputCarriersMatch_map]
  exact checked

/-- **The graph side of a multi-row step.** A graph carrying the template at
`ν` whose input carriers hold the inputs carries every value of the family's
expected graph at `ν`. -/
theorem prompt_template_step {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : Env κ)
    (G : Nat → Option (RNode Int κ)) (σ cl : Nat → Nat) (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (hin : InputsHeld M K env G (familyGraph F.ops (PDim.eval ν) o n ss).1 (T.cert.map σ))
    (i : Nat) (v : Value) (hv : EvA M K env (familyGraph F.ops (PDim.eval ν) o n ss).1 i v) :
    evalR M K env G (σ (certAt T.cert i)) = some v := by
  have hm := prompt_template_matches T ν o n ss hsig G σ cl emb
  have hl := prompt_template_length T ν o n ss hsig
  rw [← certAt_map σ T.cert i (by have := hv.1; omega), matches_eval M K env G _ _ hm hin i hv.1]
  exact hv.2

end

/-! ## Layouts in the same branches -/

theorem stageLayout_sigR (sig : Option Nat → Nat → Nat → KvSig) (w : StageWeights) (h h' : Handles)
    (c c' o n o' n' : Nat) (hc : StageCap c w h) (hc' : StageCap c' w h')
    (hsig : sig (some c) o n = sig (some c') o' n') :
    SigRelR sig o n o' n' (stageLayout w h) (stageLayout w h') := by
  cases w with
  | delta w =>
    cases h with
    | attention _ _ => exact hc.elim
    | delta conv rec =>
      cases h' with
      | attention _ _ => exact hc'.elim
      | delta conv' rec' =>
        cases conv <;> cases rec <;> cases conv' <;> cases rec' <;>
          first | exact hc.elim | exact hc'.elim | exact (rfl : deltaLayout w _ _ = deltaLayout w _ _)
  | attention w =>
    cases h with
    | delta _ _ => exact hc.elim
    | attention kb vb =>
      cases h' with
      | delta _ _ => exact hc'.elim
      | attention kb' vb' =>
        cases kb <;> cases vb <;> cases kb' <;> cases vb' <;> try (first | exact hc.elim | exact hc'.elim)
        rename_i a b a' b'
        obtain ⟨ha, hb⟩ := hc
        obtain ⟨ha', hb'⟩ := hc'
        have e : ∀ (v : Value) (k : Nat), v.shape = [1, 4, k, 256] → capOf (some v) = some k := fun v k hv => by
          simp [capOf, hv]
        refine ⟨rfl, rfl, rfl, rfl, rfl, ?_, ?_⟩ <;>
          simp only [attnLayout, e a c ha, e b c hb, e a' c' ha', e b' c' hb', hsig]

/-- **Populated caches** at capacities `c`, `c'` taking the same branches. -/
theorem chainLayout_sigR (sig : Option Nat → Nat → Nat → KvSig) (c c' o n o' n' : Nat)
    (hsig : sig (some c) o n = sig (some c') o' n') :
    ∀ (ws : List StageWeights) (hs hs' : List Handles), CapsFor c ws hs → CapsFor c' ws hs' →
      List.Forall₂ (SigRelR sig o n o' n') (chainLayout ws hs) (chainLayout ws hs')
  | [], [], [], .nil, .nil => .nil
  | w :: ws, h :: hs, h' :: hs', .cons hc rest, .cons hc' rest' =>
    .cons (stageLayout_sigR sig w h h' c c' o n o' n' hc hc' hsig)
      (chainLayout_sigR sig c c' o n o' n' hsig ws hs hs' rest rest')

/-- A stage's caches before the first step: none. -/
def StageNull : StageWeights → Handles → Prop
  | .delta _, .delta none none => True
  | .attention _, .attention none none => True
  | _, _ => False

theorem stageLayout_sigR_null (sig : Option Nat → Nat → Nat → KvSig) (w : StageWeights) (h h' : Handles)
    (o n o' n' : Nat) (hc : StageNull w h) (hc' : StageNull w h') (hsig : sig none o n = sig none o' n') :
    SigRelR sig o n o' n' (stageLayout w h) (stageLayout w h') := by
  cases w with
  | delta w =>
    cases h with
    | attention _ _ => exact hc.elim
    | delta conv rec =>
      cases h' with
      | attention _ _ => exact hc'.elim
      | delta conv' rec' =>
        cases conv <;> cases rec <;> cases conv' <;> cases rec' <;>
          first | exact hc.elim | exact hc'.elim | exact (rfl : deltaLayout w none none = deltaLayout w none none)
  | attention w =>
    cases h with
    | delta _ _ => exact hc.elim
    | attention kb vb =>
      cases h' with
      | delta _ _ => exact hc'.elim
      | attention kb' vb' =>
        cases kb <;> cases vb <;> cases kb' <;> cases vb' <;>
          first | exact hc.elim | exact hc'.elim | exact ⟨rfl, rfl, rfl, rfl, rfl, hsig, hsig⟩

/-- **Null caches** (a first step) in the same branches. -/
theorem chainLayout_sigR_null (sig : Option Nat → Nat → Nat → KvSig) (o n o' n' : Nat)
    (hsig : sig none o n = sig none o' n') :
    ∀ (ws : List StageWeights) (hs hs' : List Handles), List.Forall₂ (StageNull) ws hs → List.Forall₂ StageNull ws hs' →
      List.Forall₂ (SigRelR sig o n o' n') (chainLayout ws hs) (chainLayout ws hs')
  | [], [], [], .nil, .nil => .nil
  | w :: ws, h :: hs, h' :: hs', .cons hc rest, .cons hc' rest' =>
    .cons (stageLayout_sigR_null sig w h h' o n o' n' hc hc' hsig)
      (chainLayout_sigR_null sig o n o' n' hsig ws hs hs' rest rest')

/-! ## The decode step is the D1 instance -/

section D1
variable (w : PipelineWeights)

/-- The D1 family of the loaded head at the symbolic position `pos`. -/
abbrev d1Of (pos pos1 : PDim) : RowFamily InKey := d1Family id (linLayout .affineRow w.head) pos pos1

/-- **The D1 family is the decode step** at the position's value `time`. -/
theorem d1_familyGraph (hs : List Handles) (pos pos1 : PDim) (ν : Nat → Int) (time n : Nat)
    (hpos : pos.eval ν = time) (hpos1 : pos1.eval ν = time + 1) :
    familyGraph (d1Of w pos pos1).ops (PDim.eval ν) time n (chainLayout (stageWeights w) hs) = stepGraphOf w hs time := by
  unfold familyGraph stepGraphOf stepGraph
  rw [show (d1Of w pos pos1).ops = d1Ops id (linLayout .affineRow w.head) pos pos1 from rfl, forwardP_d1, hpos, hpos1]
  rfl

/-- The decode template's expected graph mapped through `SDim.toP p` is the D1
template's at the offset position `p`. -/
theorem templateOf_toP (hs₀ : List Handles) (n₀ p : Nat) :
    ((templateOf w hs₀ n₀).1.map (mapN (SDim.toP p)), (templateOf w hs₀ n₀).2) =
      familyGraph (d1Of w (.lin 0 [(1, p)]) (.lin 1 [(1, p)])).ops id n₀ 1 (chainLayout (stageWeights w) hs₀) := by
  have hnat := stepG_natural (SDim.toP p) n₀ SDim.lit .pos .pos1 id (chainLayout (stageWeights w) hs₀)
    (linLayout .affineRow w.head) []
  simp only [List.map_nil] at hnat
  unfold familyGraph templateOf template
  rw [show (d1Of w (.lin 0 [(1, p)]) (.lin 1 [(1, p)])).ops =
    d1Ops id (linLayout .affineRow w.head) (.lin 0 [(1, p)]) (.lin 1 [(1, p)]) from rfl, forwardP_d1]
  exact (congrArg (fun r => (r.2, r.1)) hnat).symm

/-- **A decode template is a D1 prompt template** at the offset position `p`:
its graph's dimensions mapped through `SDim.toP p`, its kernel check transported
by `matchesD_mapD`. -/
def Template.toD1 (T : Template w) (p : Nat) : PromptTemplate (d1Of w (.lin 0 [(1, p)]) (.lin 1 [(1, p)])) where
  o₀ := T.n₀
  n₀ := 1
  ss₀ := chainLayout (stageWeights w) T.hs₀
  Gs := mapG (SDim.toP p) T.Gs
  cert := T.cert
  checked := by
    rw [← congrArg Prod.fst (templateOf_toP w T.hs₀ T.n₀ p)]
    exact matchesD_mapD (SDim.toP p) T.Gs _ T.cert T.checked
  length := by
    rw [← congrArg Prod.fst (templateOf_toP w T.hs₀ T.n₀ p), List.length_map]
    exact T.length

/-- The D1 template's branches from the capacities, as for `Template`. -/
theorem d1_sig_of_caps (pos pos1 : PDim) (hs₀ hs : List Handles) (c₀ c o₀ time : Nat)
    (caps₀ : CapsFor c₀ (stageWeights w) hs₀) (caps : CapsFor c (stageWeights w) hs)
    (branch : kvSig (some c₀) o₀ = kvSig (some c) time) :
    List.Forall₂ (SigRelR (d1Of w pos pos1).ops.sig o₀ 1 time 1) (chainLayout (stageWeights w) hs₀)
      (chainLayout (stageWeights w) hs) :=
  chainLayout_sigR _ c₀ c o₀ 1 time 1 branch _ _ _ caps₀ caps

/-- The converted template evaluated at `ν` is the decode template evaluated at
the offset `n = ν p` (both are `stepGraphOf` at `n`). -/
theorem toD1_instance (T : Template w) (p : Nat) (ν : Nat → Int) (n : Nat) (hp : ν p = n) (hs : List Handles)
    (c : Nat) (caps : CapsFor c (stageWeights w) hs) (branch : kvSig (some T.c₀) T.n₀ = kvSig (some c) n) :
    ((familyGraph (d1Of w (.lin 0 [(1, p)]) (.lin 1 [(1, p)])).ops id (T.toD1 w p).o₀ (T.toD1 w p).n₀
        (T.toD1 w p).ss₀).1.map (mapN (PDim.eval ν)),
      (familyGraph (d1Of w (.lin 0 [(1, p)]) (.lin 1 [(1, p)])).ops id (T.toD1 w p).o₀ (T.toD1 w p).n₀
        (T.toD1 w p).ss₀).2) =
      ((templateOf w T.hs₀ T.n₀).1.map (mapN (SDim.eval n)), (templateOf w T.hs₀ T.n₀).2) := by
  rw [prompt_template_instance (T.toD1 w p) ν n 1 (chainLayout (stageWeights w) hs)
      (d1_sig_of_caps w _ _ T.hs₀ hs T.c₀ c T.n₀ n T.caps₀ caps branch),
    d1_familyGraph w hs _ _ ν n 1 (by simp [PDim.eval, termsEval, hp]) (by simp [PDim.eval, termsEval, hp]; omega),
    template_instance w T hs c n caps branch]

/-- The last prompt row's position `L - 1`, `L` at position `v`: the final
prefill step `[L-1, L)` is a D1 step there. -/
def lastRow (v : Nat) : PDim := ((Aff.var v).sub (.const 1)).toP

/-- Its successor `L` (canonical: the position itself). -/
def lastRow1 (v : Nat) : PDim := (((Aff.var v).sub (.const 1)).add (.const 1)).toP

theorem lastRow_eq (v : Nat) : lastRow v = .lin (-1) [(1, v)] ∧ lastRow1 v = .lin 0 [(1, v)] := ⟨rfl, rfl⟩

theorem lastRow_eval (ν : Nat → Int) (v L : Nat) (hL : ν v = L) (h1 : 1 ≤ L) :
    (lastRow v).eval ν = ((L - 1 : Nat) : Int) ∧ (lastRow1 v).eval ν = ((L - 1 : Nat) : Int) + 1 := by
  rw [(lastRow_eq v).1, (lastRow_eq v).2]
  simp only [PDim.eval, termsEval, hL]
  omega

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- **The graph side of a D1 step at a symbolic position** (`template_step` for
a D1 prompt template): `pos` evaluates to the reached time at `ν`. -/
theorem d1_template_step (p : TokenInference.Pipeline) (hl : PipelineLoaded M K p w)
    (parameters : TokenSequenceRanges.Parameters p) (token : Fin 248320) (time : Nat) (supported : time + 1 ≤ 262144)
    (ids : Value)
    (hids : TokenBuffer ids ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).token.val)
    (hs : List Handles)
    (hh : ChainHolds p.graph.stages hs ((GlueM1Max.context M K p w hl parameters).run token time (by omega)).cache)
    (c : Nat) (caps : CapsFor c (stageWeights w) hs)
    (pos pos1 : PDim) (T : PromptTemplate (d1Of w pos pos1)) (ν : Nat → Int)
    (hpos : pos.eval ν = time) (hpos1 : pos1.eval ν = time + 1)
    (hsig : List.Forall₂ (SigRelR (d1Of w pos pos1).ops.sig T.o₀ T.n₀ time 1) T.ss₀ (chainLayout (stageWeights w) hs))
    (weights : List Char → List Char → Option Value) (G : Nat → Option (RNode Int InKey)) (σ cl : Nat → Nat)
    (emb : Embeds σ cl (mapG (PDim.eval ν) T.Gs) G)
    (hin : InputsHeld M K (stepEnvWithIds weights w ids hs) G (stepGraphOf w hs time).1 (T.cert.map σ)) :
    ∃ hs', (∃ r, evalR M K (stepEnvWithIds weights w ids hs) G
        (σ (certAt T.cert (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.1)) = some r ∧
        itemUint32 r = some ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).token.val) ∧
      ChainHolds p.graph.stages hs' ((GlueM1Max.context M K p w hl parameters).run token (time + 1) supported).cache ∧
      CapsFor (kvCap (some c) time) (stageWeights w) hs' ∧
      (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2.2 hs',
        evalR M K (stepEnvWithIds weights w ids hs) G (σ (certAt T.cert q.1)) = some q.2 := by
  obtain ⟨hs', e, h'⟩ := GlueM1Max.contextStep M K p w hl parameters token time supported hs hh
  have hsh := shapes_of_holds M K _ _ _ _ (stages_loaded M K p w hl) hh
  have hembed := bufferEmbed_eq M w.embedWords w.embedScales w.embedBiases ids _ hids
    hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  have hinst := prompt_template_instance T ν time 1 _ hsig
  rw [d1_familyGraph w hs pos pos1 ν time 1 hpos hpos1] at hinst
  have hm := prompt_template_matches T ν time 1 _ hsig G σ cl emb
  rw [d1_familyGraph w hs pos pos1 ν time 1 hpos hpos1] at hm
  obtain ⟨ht, hc⟩ := ffi_step_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e G _ hm hin
  obtain ⟨⟨_, hlt, _, _⟩, hlen, hsome, hcf⟩ :=
    stepGraph_eval_ids M K weights w time _ ids hembed hs hs' _ hl.finalNorm.2.1 hsh e
  have h2 : (familyGraph (d1Of w pos pos1).ops id T.o₀ T.n₀ T.ss₀).2 = (stepGraphOf w hs time).2 :=
    congrArg Prod.snd hinst
  have hE : (stepGraphOf w hs time).1.length ≤ T.cert.length := by
    rw [← congrArg Prod.fst hinst, List.length_map]; exact T.length
  refine ⟨hs', ?_, h', capsFor_step M K w time _ hs hs' _ c caps e, by rw [h2]; exact hlen, hsome, ?_⟩
  · obtain ⟨r, hr, hi⟩ := ht
    refine ⟨r, ?_, hi⟩
    rw [h2, ← certAt_map σ T.cert _ (by omega)]
    exact hr
  · intro q hq
    rw [h2] at hq
    rw [← certAt_map σ T.cert _ (by have := (hcf q hq).1; omega)]
    exact hc q hq

end D1

end Host.Mlx.SimGraph
