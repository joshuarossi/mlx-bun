import host.mlx.FfiEval
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval

/-! # The decode-step graph at a symbolic cache offset

`stepG` is generic in the dimension type `δ`: integer literals enter through
`L`, the cache offset `n` and `n + 1` through `nD`, `n1D`. Its only other
use of the offset is control: the KV builder's data-dependent branches
(`kvGrownG`: grow iff `c < n + 1`; `kvOldG`: trim iff `n % 256 ≠ 0`;
`kvViewG`: view slice iff `kvCap cap n ≠ n + 1`). Capacities never appear as
dimensions.

* `mapP`/`mapN`: a dimension map on resolved primitives and nodes.
* `stepG_natural`: building at `L`, `nD`, `n1D` and mapping the dimensions by
  `f` is building at `f ∘ L`, `f nD`, `f n1D`.
* `kvSig`: the KV branch decisions; `stepG_sig`: the builder depends on the
  offset and the capacities only through them (`SigRel`).
* `template_eval`: a graph built once at a representative offset `n₀` with
  symbolic offset dimensions, evaluated at `n`, is `stepGraph` at `n` for
  every layout in the same branches. -/

section Maps
variable {δ δ' κ : Type}

def mapC (f : δ → δ') (c : RCfg δ) : RCfg δ' :=
  ⟨c.outs.map fun o => (o.1.map f, o.2), c.grid.map f, c.group.map f,
    c.ints.map fun t => (t.1, f t.2), c.dtypes, c.init.map f⟩

def mapP (f : δ → δ') : RPrim δ κ → RPrim δ' κ
  | .input k => .input k
  | .computeG => .computeG
  | .data b s d => .data b (s.map f) d
  | .load a b => .load a b
  | .zeros s d => .zeros (s.map f) d
  | .unsupported => .unsupported
  | .reshape s => .reshape (s.map f)
  | .transpose ax => .transpose ax
  | .slice a b c => .slice (a.map f) (b.map f) (c.map f)
  | .sliceUpdate a b c => .sliceUpdate (a.map f) (b.map f) (c.map f)
  | .sliceDynamic ax sz => .sliceDynamic ax (sz.map f)
  | .concat a => .concat a
  | .unary op => .unary op
  | .binary op => .binary op
  | .astype d => .astype d
  | .contiguous => .contiguous
  | .rmsNorm e => .rmsNorm e
  | .rope d t b s off => .rope d t b s (f off)
  | .sdpa s m => .sdpa s m
  | .qmm t g b m => .qmm t g b m
  | .dequantize g b m d => .dequantize g b m d
  | .take a => .take a
  | .conv1d a b c d => .conv1d a b c d
  | .logsumexp a k => .logsumexp a k
  | .kernel n c o => .kernel n (mapC f c) o
  | .replayed c p => .replayed c (mapP f p)

def mapN (f : δ → δ') (r : RNode δ κ) : RNode δ' κ := ⟨mapP f r.prim, r.ins⟩

/-- A graph with its dimensions mapped. -/
def mapG (f : δ → δ') (G : Nat → Option (RNode δ κ)) (i : Nat) : Option (RNode δ' κ) := (G i).map (mapN f)

theorem mapP_comp {δ'' : Type} (f : δ → δ') (g : δ' → δ'') (p : RPrim δ κ) :
    mapP g (mapP f p) = mapP (fun d => g (f d)) p := by
  induction p <;> simp_all [mapP, mapC, List.map_map, Function.comp_def, Option.map_map]

end Maps

/-! ## Naturality of the builders -/

section Natural
variable {δ δ' κ : Type} (f : δ → δ')

/-- `b'` is `b` with its emitted dimensions mapped by `f`. -/
def Natural {α : Type} (b : Build δ κ α) (b' : Build δ' κ α) : Prop :=
  ∀ g, run b' (g.map (mapN f)) = ((run b g).1, (run b g).2.map (mapN f))

variable {f}

theorem natural_pure {α : Type} (a : α) : Natural (κ := κ) f (pure a) (pure a) := fun _ => rfl

theorem natural_bind {α β : Type} {x : Build δ κ α} {x' : Build δ' κ α} {k : α → Build δ κ β}
    {k' : α → Build δ' κ β} (hx : Natural f x x') (hk : ∀ a, Natural f (k a) (k' a)) :
    Natural f (x >>= k) (x' >>= k') := by
  intro g
  show run (k' (run x' (g.map (mapN f))).1) (run x' (g.map (mapN f))).2 = _
  rw [hx g]
  exact hk _ _

theorem natural_emit {p : RPrim δ κ} {p' : RPrim δ' κ} (ins : List Nat) (h : mapP f p = p') :
    Natural f (emit p ins) (emit p' ins) := by
  intro g
  subst h
  simp [run, emit, mapN]

theorem natural_map {α β : Type} (g : α → β) {x : Build δ κ α} {x' : Build δ' κ α} (hx : Natural f x x') :
    Natural f (g <$> x) (g <$> x') := by
  intro gs
  show (g (run x' (gs.map (mapN f))).1, (run x' (gs.map (mapN f))).2) = _
  rw [hx gs]
  rfl

variable (f)

theorem D_map (L : Int → δ) (l : List Nat) : (D L l).map f = D (fun i => f (L i)) l := by
  simp [D, List.map_map, Function.comp_def]

theorem cfgOf_map (L : Int → δ) (c : Config) : mapC f (cfgOf L c) = cfgOf (fun i => f (L i)) c := by
  simp [mapC, cfgOf, D, List.map_map, Function.comp_def]

theorem kern_map (L : Int → δ) (name : List Char) (c : Config) (out : Nat) :
    mapP f (kern (κ := κ) L name c out) = kern (fun i => f (L i)) name c out := by
  simp [kern, mapP, cfgOf_map]

theorem projPrim_map (L : Int → δ) (lay : LinLayout) :
    mapP f (projPrim (κ := κ) L lay) = projPrim (fun i => f (L i)) lay := by
  unfold projPrim; split <;> simp [kern_map, mapP]

/-- Close the side conditions of `natural_emit`. -/
macro "dim_map" : tactic =>
  `(tactic| first | rfl | simp [mapP, D_map, kern_map, projPrim_map, D, List.map_map, Function.comp_def])

theorem nat_inp (k : κ) : Natural f (inp (δ := δ) k) (inp k) := natural_emit [] rfl

theorem nat_optInp (b : Bool) (key : κ) (zp : RPrim δ κ) (zp' : RPrim δ' κ) (h : mapP f zp = zp') :
    Natural f (optInp b key zp) (optInp b key zp') := by
  cases b
  · exact natural_emit [] h
  · exact nat_inp f key

theorem nat_normG (key : κ) (x : Nat) : Natural f (normG (δ := δ) key x) (normG key x) :=
  natural_bind (nat_inp f key) fun _ => natural_emit _ rfl

theorem nat_projectG (L : Int → δ) (lay : LinLayout) (key : LinKey → κ) (x : Nat) :
    Natural f (projectG L lay key x) (projectG (fun i => f (L i)) lay key x) :=
  natural_bind (nat_inp f _) fun _ => natural_bind (nat_inp f _) fun _ => natural_bind (nat_inp f _) fun _ =>
    natural_emit _ (projPrim_map f L lay)

theorem nat_embedG (key : InKey → κ) : Natural f (embedG (δ := δ) key) (embedG key) := by
  unfold embedG
  refine natural_bind (nat_inp f _) fun _ => natural_bind (nat_inp f _) fun _ =>
    natural_bind (nat_inp f _) fun _ => natural_bind (nat_inp f _) fun _ => ?_
  exact natural_bind (natural_emit _ rfl) fun _ => natural_bind (natural_emit _ rfl) fun _ =>
    natural_bind (natural_emit _ rfl) fun _ => natural_emit _ rfl

/-- Peel binds: emits, inputs and the sub-builders already shown natural
(matching reducibly, so a failed alternative does not unfold the monad);
then close the emitted primitives' side conditions. -/
macro "nat_peel" : tactic => `(tactic| ((repeat' (first
  | with_reducible refine natural_map _ ?_
  | with_reducible exact nat_projectG _ _ _ _ _
  | with_reducible exact nat_inp _ _
  | with_reducible refine natural_bind (nat_inp _ _) fun _ => ?_
  | with_reducible refine natural_bind (nat_projectG _ _ _ _ _) fun _ => ?_
  | with_reducible refine natural_bind (nat_normG _ _ _) fun _ => ?_
  | with_reducible refine natural_bind (natural_emit _ ?_) fun _ => ?_
  | with_reducible exact natural_pure _
  | with_reducible refine natural_emit _ ?_)); all_goals (try dim_map)))

theorem nat_suffixG (L : Int → δ) (m : MlpLayout) (key : MlpKey → κ) (x mixed : Nat) :
    Natural f (suffixG L m key x mixed) (suffixG (fun i => f (L i)) m key x mixed) := by
  unfold suffixG
  nat_peel

theorem nat_deltaMixerG (L : Int → δ) (d : DeltaLayout) (key : SKey → κ) (x : Nat) :
    Natural f (deltaMixerG L d key x) (deltaMixerG (fun i => f (L i)) d key x) := by
  unfold deltaMixerG
  nat_peel
  refine natural_bind (nat_optInp f _ _ _ _ (by dim_map)) fun _ => ?_
  nat_peel
  refine natural_bind (nat_optInp f _ _ _ _ (by dim_map)) fun _ => ?_
  nat_peel

theorem nat_deltaLayerG (L : Int → δ) (d : DeltaLayout) (key : SKey → κ) (x : Nat) :
    Natural f (deltaLayerG L d key x) (deltaLayerG (fun i => f (L i)) d key x) := by
  unfold deltaLayerG
  refine natural_bind (nat_normG f _ _) fun _ => natural_bind (nat_deltaMixerG f L d key _) fun ⟨_, _, _⟩ => ?_
  dsimp only
  exact natural_bind (nat_suffixG f L _ _ _ _) fun _ => natural_pure _

variable (n : Nat)

theorem nat_kvOldG (L : Int → δ) (nD : δ) (b : Nat) :
    Natural f (kvOldG (κ := κ) L n nD b) (kvOldG (fun i => f (L i)) n (f nD) b) := by
  unfold kvOldG
  by_cases h : n % 256 = 0
  · simp only [h, ↓reduceIte]; exact natural_pure _
  · simp only [h, ↓reduceIte]; exact natural_emit _ (by dim_map)

theorem nat_kvGrownG (L : Int → δ) (nD : δ) (c b : Nat) :
    Natural f (kvGrownG (κ := κ) L n nD c b) (kvGrownG (fun i => f (L i)) n (f nD) c b) := by
  unfold kvGrownG
  by_cases h : c < n + 1
  · simp only [h, ↓reduceIte]
    exact natural_bind (nat_kvOldG f n L nD b) fun _ => natural_bind (natural_emit _ (by dim_map)) fun _ =>
      natural_emit _ rfl
  · simp only [h, ↓reduceIte]; exact natural_pure _

theorem nat_kvGrowG (L : Int → δ) (nD : δ) (cap : Option Nat) (key : κ) :
    Natural f (kvGrowG L n nD cap key) (kvGrowG (fun i => f (L i)) n (f nD) cap key) := by
  cases cap with
  | none => exact natural_emit _ (by dim_map)
  | some c => exact natural_bind (nat_inp f key) fun b => nat_kvGrownG f n L nD c b

theorem nat_kvViewG (L : Int → δ) (n1D : δ) (cap : Option Nat) (b : Nat) :
    Natural f (kvViewG (κ := κ) L n n1D cap b) (kvViewG (fun i => f (L i)) n (f n1D) cap b) := by
  unfold kvViewG
  by_cases h : kvCap cap n = n + 1
  · simp only [h, ↓reduceIte]; exact natural_pure _
  · simp only [h, ↓reduceIte]; exact natural_emit _ (by dim_map)

theorem nat_kvStepG (L : Int → δ) (nD n1D : δ) (cap : Option Nat) (key : κ) (x : Nat) :
    Natural f (kvStepG L n nD n1D cap key x) (kvStepG (fun i => f (L i)) n (f nD) (f n1D) cap key x) := by
  unfold kvStepG
  exact natural_bind (nat_kvGrowG f n L nD cap key) fun _ => natural_bind (natural_emit _ (by dim_map)) fun _ =>
    natural_map _ (nat_kvViewG f n L n1D cap _)

theorem nat_attentionG (L : Int → δ) (nD n1D : δ) (a : AttnLayout) (key : SKey → κ) (qp kp vp : Nat) :
    Natural f (attentionG L n nD n1D a key qp kp vp)
      (attentionG (fun i => f (L i)) n (f nD) (f n1D) a key qp kp vp) := by
  unfold attentionG
  nat_peel
  refine natural_bind (nat_kvStepG f n L nD n1D _ _ _) fun ⟨_, _⟩ => ?_
  refine natural_bind (nat_kvStepG f n L nD n1D _ _ _) fun ⟨_, _⟩ => ?_
  nat_peel

theorem nat_attentionLayerG (L : Int → δ) (nD n1D : δ) (a : AttnLayout) (key : SKey → κ) (x : Nat) :
    Natural f (attentionLayerG L n nD n1D a key x) (attentionLayerG (fun i => f (L i)) n (f nD) (f n1D) a key x) := by
  unfold attentionLayerG
  nat_peel
  refine natural_bind (nat_attentionG f n L nD n1D a key _ _ _) fun ⟨_, _, _⟩ => ?_
  exact natural_bind (nat_projectG f L _ _ _) fun _ => natural_map _ (nat_suffixG f L _ _ _ _)

theorem nat_stageG (L : Int → δ) (nD n1D : δ) (s : StageLayout) (key : SKey → κ) (x : Nat) :
    Natural f (stageG L n nD n1D s key x) (stageG (fun i => f (L i)) n (f nD) (f n1D) s key x) := by
  cases s with
  | delta d => exact nat_deltaLayerG f L d key x
  | attention a => exact nat_attentionLayerG f n L nD n1D a key x

theorem nat_chainG (L : Int → δ) (nD n1D : δ) (key : InKey → κ) :
    ∀ (p : Nat) (ss : List StageLayout) (x : Nat),
      Natural f (chainG L n nD n1D key p ss x) (chainG (fun i => f (L i)) n (f nD) (f n1D) key p ss x)
  | _, [], _ => natural_pure _
  | p, s :: ss, x =>
    natural_bind (nat_stageG f n L nD n1D s _ x) fun ⟨y, _, _⟩ =>
      natural_bind (nat_chainG L nD n1D key (p + 1) ss y) fun ⟨_, _⟩ => natural_pure _

theorem stepG_natural (L : Int → δ) (nD n1D : δ) (key : InKey → κ) (ss : List StageLayout) (head : LinLayout) :
    Natural f (stepG L n nD n1D key ss head) (stepG (fun i => f (L i)) n (f nD) (f n1D) key ss head) := by
  unfold stepG
  refine natural_bind (nat_embedG f key) fun _ => natural_bind (nat_chainG f n L nD n1D key 0 ss _) fun ⟨_, _⟩ => ?_
  nat_peel

end Natural

/-! ## The KV branches -/

/-- The KV builder's decisions at capacity `cap` and offset `n`: whether a
buffer exists, then (grow, trim) and whether the view is the whole buffer. -/
def kvSig (cap : Option Nat) (n : Nat) : Option (Bool × Bool) × Bool :=
  (cap.map fun c => (decide (c < n + 1), decide (c < n + 1) && decide (n % 256 ≠ 0)),
    decide (kvCap cap n = n + 1))

/-- Layouts agreeing except in attention capacities, which take the same
branches at offsets `n` and `n'`. -/
def SigRel (n n' : Nat) : StageLayout → StageLayout → Prop
  | .delta d, .delta d' => d = d'
  | .attention a, .attention a' => a.q = a'.q ∧ a.k = a'.k ∧ a.v = a'.v ∧ a.o = a'.o ∧ a.mlp = a'.mlp ∧
      kvSig a.kcap n = kvSig a'.kcap n' ∧ kvSig a.vcap n = kvSig a'.vcap n'
  | _, _ => False

section Sig
variable {δ κ : Type} (L : Int → δ)

theorem kvGrowG_sig (n n' : Nat) (nD : δ) (cap cap' : Option Nat) (key : κ)
    (h : (kvSig cap n).1 = (kvSig cap' n').1) : kvGrowG L n nD cap key = kvGrowG L n' nD cap' key := by
  cases cap with
  | none =>
    cases cap' with
    | none => rfl
    | some _ => simp [kvSig] at h
  | some c =>
    cases cap' with
    | none => simp [kvSig] at h
    | some c' =>
      simp only [kvSig, Option.map_some, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨h1, h2⟩ := h
      have hc : c < n + 1 ↔ c' < n' + 1 := by simpa using h1
      show (inp key >>= kvGrownG L n nD c) = (inp key >>= kvGrownG L n' nD c')
      congr 1
      funext b
      unfold kvGrownG
      by_cases g : c < n + 1
      · have g' : c' < n' + 1 := hc.mp g
        simp only [g, g', ↓reduceIte]
        have ht : n % 256 = 0 ↔ n' % 256 = 0 := by simp [g, g'] at h2; omega
        unfold kvOldG
        by_cases t : n % 256 = 0
        · simp only [t, ht.mp t, ↓reduceIte]
        · have t' : ¬ n' % 256 = 0 := fun e => t (ht.mpr e)
          simp only [t, t', ↓reduceIte]
      · have g' : ¬ c' < n' + 1 := fun e => g (hc.mpr e)
        simp only [g, g', ↓reduceIte]

theorem kvViewG_sig (n n' : Nat) (n1D : δ) (cap cap' : Option Nat) (b : Nat)
    (h : (kvSig cap n).2 = (kvSig cap' n').2) : kvViewG (κ := κ) L n n1D cap b = kvViewG L n' n1D cap' b := by
  have h' : kvCap cap n = n + 1 ↔ kvCap cap' n' = n' + 1 := by simpa [kvSig] using h
  unfold kvViewG
  by_cases v : kvCap cap n = n + 1
  · simp only [v, h'.mp v, ↓reduceIte]
  · have v' : ¬ kvCap cap' n' = n' + 1 := fun e => v (h'.mpr e)
    simp only [v, v', ↓reduceIte]

theorem kvStepG_sig (n n' : Nat) (nD n1D : δ) (cap cap' : Option Nat) (key : κ) (x : Nat)
    (h : kvSig cap n = kvSig cap' n') : kvStepG L n nD n1D cap key x = kvStepG L n' nD n1D cap' key x := by
  unfold kvStepG
  rw [kvGrowG_sig L n n' nD cap cap' key (congrArg Prod.fst h)]
  congr 1; funext g; congr 1; funext b
  rw [kvViewG_sig L n n' n1D cap cap' b (congrArg Prod.snd h)]

theorem stageG_sig (n n' : Nat) (nD n1D : δ) (s s' : StageLayout) (h : SigRel n n' s s') (key : SKey → κ) (x : Nat) :
    stageG L n nD n1D s key x = stageG L n' nD n1D s' key x := by
  cases s with
  | delta d =>
    cases s' with
    | delta d' => cases (h : d = d'); rfl
    | attention _ => exact h.elim
  | attention a =>
    cases s' with
    | delta _ => exact h.elim
    | attention a' =>
      obtain ⟨hq, hk, hv, ho, hm, hkc, hvc⟩ := h
      show attentionLayerG L n nD n1D a key x = attentionLayerG L n' nD n1D a' key x
      unfold attentionLayerG attentionG
      rw [hq, hk, hv, ho, hm]
      simp only [kvStepG_sig L n n' nD n1D a.kcap a'.kcap _ _ hkc, kvStepG_sig L n n' nD n1D a.vcap a'.vcap _ _ hvc]

theorem chainG_sig (n n' : Nat) (nD n1D : δ) (key : InKey → κ) :
    ∀ (p : Nat) (ss ss' : List StageLayout), List.Forall₂ (SigRel n n') ss ss' → ∀ x : Nat,
      chainG L n nD n1D key p ss x = chainG L n' nD n1D key p ss' x
  | _, [], [], .nil, _ => rfl
  | p, s :: ss, s' :: ss', .cons hs hss, x => by
    show (stageG L n nD n1D s (fun k => key (.stage p k)) x >>= _) =
      (stageG L n' nD n1D s' (fun k => key (.stage p k)) x >>= _)
    rw [stageG_sig L n n' nD n1D s s' hs]
    congr 1; funext r
    obtain ⟨y, c1, c2⟩ := r
    dsimp only
    rw [chainG_sig n n' nD n1D key (p + 1) ss ss' hss y]

theorem stepG_sig (n n' : Nat) (nD n1D : δ) (key : InKey → κ) (ss ss' : List StageLayout)
    (h : List.Forall₂ (SigRel n n') ss ss') (head : LinLayout) :
    stepG L n nD n1D key ss head = stepG L n' nD n1D key ss' head := by
  unfold stepG
  congr 1; funext x
  rw [chainG_sig L n n' nD n1D key 0 ss ss' h x]

end Sig

/-! ## The template graph and its instances -/

/-- The decode-step graph built once at representative offset `n₀` and
layout `ss₀`, with dimensions in `δ` and the offset dimensions `nD`, `n1D`
symbolic: the expected graph, token node and cache nodes. -/
def template {δ : Type} (L : Int → δ) (n₀ : Nat) (nD n1D : δ) (ss₀ : List StageLayout) (head : LinLayout) :
    List (RNode δ InKey) × Nat × List (Nat × Nat) :=
  let r := run (stepG L n₀ nD n1D id ss₀ head) []
  (r.2, r.1)

/-- **Instances of the template.** Evaluating the template's dimensions at
offset `n` gives the expected graph `stepGraph` at `n`, for every layout
whose attention capacities take the template's branches at `n`. -/
theorem template_eval {δ : Type} (L : Int → δ) (n₀ : Nat) (nD n1D : δ) (ss₀ : List StageLayout)
    (head : LinLayout) (ev : δ → Int) (n : Nat) (ss : List StageLayout)
    (hL : ∀ i, ev (L i) = i) (hn : ev nD = n) (hn1 : ev n1D = n + 1)
    (hsig : List.Forall₂ (SigRel n₀ n) ss₀ ss) :
    ((template L n₀ nD n1D ss₀ head).1.map (mapN ev), (template L n₀ nD n1D ss₀ head).2) =
      stepGraph ss head n := by
  have hnat := stepG_natural ev n₀ L nD n1D id ss₀ head []
  have hL' : (fun i => ev (L i)) = id := funext hL
  rw [hL', hn, hn1] at hnat
  simp only [List.map_nil] at hnat
  unfold template stepGraph
  rw [← stepG_sig id n₀ n (n : Int) ((n : Int) + 1) id ss₀ ss hsig head, hnat]

end Host.Mlx.SimGraph
