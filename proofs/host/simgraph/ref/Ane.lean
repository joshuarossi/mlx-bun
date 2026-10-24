import host.simgraph.family.ane.Close
import host.simgraph.ref.Steps
namespace Host.Mlx.SimGraph.Ref
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.GlueStep Host.Mlx.SimGraph Inference.Contracts.Mlx

/-! # The Neural Engine forwards' reference values

A Neural Engine forward (`aneTpl`: #aneSmall, #aneDense, #aneAffine) hands each split's sources to
in-place fills of its program's input surfaces, evaluates the program and reads its output back
(host/mlx/ane: `Fill`, `Call`, `call_readback`, `forward_run`). The readbacks are inputs of the family
(`AKey.linOut p j`, `AKey.mlpOut p`), and a split's sources depend on the readbacks before it, so the
readback values are defined here, split by split in effect order, from the family's own values:

* `aneNodes`: the family's expected graph (`familyGraph (aneTpl …).toTpl.ops`) evaluated node by node
  (`primEvalE`, as `evalE`), each readback input the split of its key (`AneNet.split`): the site's tap
  values (`tapsOf`), the fills from them in launch order, each a launch on its surface's whole
  previous contents (`Fill.result`, stale bytes included), the program on its input surfaces
  (`NeuralEngine.eval`), its output laid over the output surface, the readback of the output surface
  (`runCall`, `readback`). The surfaces are threaded from the forward's start; every call is logged
  (`CallRec`).
* `aneNodes_evalE`: **the readbacks are a fixpoint** — at the environment holding them at their keys
  (`withRb`), the expected graph's evaluation `evalE` is the node-by-node values, so the family's
  graph facts (`EvE`, the input of `family_template_stepR`) hold at that environment.
* `aneNodes_calls`: every logged call ran (`runCall`, its readback the key's value) and the calls
  chain the surfaces (`CallsChain`); `runCall_step`, `callRec_step`: a logged call is `Call.Step` of the
  route's call whose fills launch as the logged ones (`fillSem`), and a reader with the split's geometry
  holds the readback — `mlpLayer_ok`, `affineDeltaLayer_ok`, `affineAttnLayer_ok`'s call and readback
  premises, with `V` the readbacks at the readers' keys.

The bucket families and the step on the prefill's state are `host.simgraph.ref.Route` (`aneTplOf`, `aneStep`). -/

/-! ## The Neural Engine side of the loaded model -/

/-- A fill's source: one of its site's taps, or a value made at construction (the ANE rows' codes and scales). -/
inductive FillSrc where
  | tap (i : Nat)
  | val (v : Value)

/-- A fill of a split's program input: in-place kernel `k` at `cfg` onto surface `sid` (its wrap's dtype and
shape, the launch's one output `o`) from `srcs`. -/
structure FillSpec where
  k : InPlaceKernel
  cfg : Config
  sid : Nat
  dt : Dtype
  sh : List Nat
  o : List Nat × Dtype
  srcs : List FillSrc

/-- A split call: its layer and tap site, its program (inputs, output surface), its fills in launch order, its
reader's geometry (the first `M·D` halves of `len`). -/
structure SplitSpec where
  layer : Nat
  site : Nat
  prog : FfiAne.Program
  fills : List FillSpec
  len : Nat
  M : Nat
  D : Nat

/-- **The Neural Engine side of the loaded model** (the load's facts): for a forward of `r` rows, the split of
each readback key and the inputs made at construction (`AKey.part`, `AKey.mlpRest`: head and rest rows, which
depend on the bucket: the MLP split's rest rows are 11264 up to 768 rows, 10752 above); the surfaces after the
load. -/
structure AneNet where
  split : Nat → AKey → Option SplitSpec
  inputs : Nat → AKey → Option Value
  surfaces : Nat → Surface

/-! ## Calls on surfaces -/

/-- A fill with its sources' values (writer, wrap and source nodes are the route's; the launch reads none). -/
def FillSpec.fill (f : FillSpec) (xs : List Value) : Fill :=
  ⟨0, f.sid, 0, f.k, f.cfg, xs.map fun _ => 0, xs, f.dt, f.sh, f.o⟩

/-- What a fill's launch reads: kernel, configuration, sources, surface, wrap type, written input's index. -/
def fillSem (f : Fill) : InPlaceKernel × Config × List Value × Nat × Dtype × List Nat × Nat :=
  (f.k, f.cfg, f.xs, f.sid, f.dt, f.sh, f.pre.length)

def srcVal (site : List Value) : FillSrc → Option Value
  | .tap i => site[i]?
  | .val v => some v

/-- A fill's launch on surface contents `S`: the written input's final bytes, the launch completing. -/
def fillRun (IP : InPlace) (f : Fill) (S : Surface) : Option ByteMemory.Bytes := do
  let res ← IP.launchAll f.k (f.xs ++ [surfaceValue S f.dt f.sh]) f.cfg
  let _ ← res[f.pre.length + 1]?
  res[f.pre.length]?

/-- The fills in launch order. -/
def runFills (IP : InPlace) : List Fill → (Nat → Surface) → Option (Nat → Surface)
  | [], σ => some σ
  | f :: fs, σ => (fillRun IP f (σ f.sid)).bind fun R => runFills IP fs (upd σ f.sid (toSurface R))

/-- A call: the fills, the program on its input surfaces as they left them, its output over the output surface. -/
def runCall (NE : NeuralEngine) (IP : InPlace) (pr : FfiAne.Program) (fs : List Fill) (σ : Nat → Surface) :
    Option (Nat → Surface) := do
  let σ1 ← runFills IP fs σ
  let out ← NE.eval pr.prog (pr.ins.map σ1)
  pure (upd σ1 pr.out (overlay out pr.prog.outputBytes (σ1 pr.out)))

theorem fillRun_step (IP : InPlace) (f f' : Fill) (σ : Nat → Surface) (R : ByteMemory.Bytes)
    (he : fillSem f = fillSem f') (h : fillRun IP f (σ f.sid) = some R) : f'.Step IP σ (upd σ f'.sid (toSurface R)) := by
  simp only [fillSem, Prod.mk.injEq] at he
  obtain ⟨hk, hc, hx, hs, hd, hsh, hp⟩ := he
  unfold fillRun at h
  obtain ⟨res, hl, h2⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨done, hdone, hR⟩ := Option.bind_eq_some_iff.mp h2
  refine ⟨res, R, done, ?_, ?_, ?_, rfl⟩
  · rw [← hk, ← hx, ← hs, ← hd, ← hsh, ← hc]; exact hl
  · rw [← hp]; exact hR
  · rw [← hp]; exact hdone

theorem runFills_step (IP : InPlace) :
    ∀ (fs fs' : List Fill) (σ σ' : Nat → Surface), fs.map fillSem = fs'.map fillSem →
      runFills IP fs σ = some σ' → Fills.Step IP fs' σ σ'
  | [], [], σ, σ', _, h => by cases h; exact .nil σ
  | f :: fs, f' :: fs', σ, σ', he, h => by
    simp only [List.map_cons, List.cons.injEq] at he
    obtain ⟨R, hR, h2⟩ := Option.bind_eq_some_iff.mp h
    have hsid : f'.sid = f.sid := by
      have := he.1; simp only [fillSem, Prod.mk.injEq] at this; exact this.2.2.2.1.symm
    have hs := fillRun_step IP f f' σ R he.1 hR
    rw [hsid] at hs
    exact .cons f' fs' σ _ σ' hs (runFills_step IP fs fs' _ σ' he.2 h2)
  | [], _ :: _, _, _, he, _ => by simp at he
  | _ :: _, [], _, _, he, _ => by simp at he

/-- **A logged call is the route's call step**: the route's call `c` with program `pr` and fills launching as
`fs` steps from `σ` to the call's result. -/
theorem runCall_step (NE : NeuralEngine) (IP : InPlace) (G : Graph) (c : Call) (pr : FfiAne.Program) (fs : List Fill)
    (σ σ' : Nat → Surface) (hq : G.program c.q = some pr) (he : fs.map fillSem = c.fills.map fillSem)
    (h : runCall NE IP pr fs σ = some σ') : c.Step NE IP G σ σ' := by
  unfold runCall at h
  obtain ⟨σ1, h1, h2⟩ := Option.bind_eq_some_iff.mp h
  obtain ⟨out, h3, h4⟩ := Option.bind_eq_some_iff.mp h2
  cases h4
  exact ⟨σ1, pr, out, hq, runFills_step IP fs c.fills σ σ1 he h1, h3, rfl⟩

/-! ## A forward's values, split by split -/

/-- A logged split call: its key and split, its site's tap values, its fills, the surfaces before and after,
its readback. -/
structure CallRec where
  key : AKey
  sp : SplitSpec
  site : List Value
  fills : List Fill
  σ0 : Nat → Surface
  σ1 : Nat → Surface
  y : Value

/-- The node-by-node evaluation's state: the values so far, the readbacks so far, the surfaces, the calls. -/
structure AneSt where
  vals : List Value
  rb : AKey → Option Value
  surf : Nat → Surface
  log : List CallRec

/-- The prims whose value reads no input (`noInput` at any key type). -/
def noInputK {κ : Type} : RPrim Int κ → Bool
  | .input _ => false
  | .replayed _ p => noInputK p
  | _ => true

/-- The environment holding the readbacks `rb` at their keys, `base` elsewhere. -/
def withRb (base : Env AKey) (rb : AKey → Option Value) : Env AKey :=
  ⟨base.weights, fun k => (rb k).orElse fun _ => base.inputs k⟩

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (rows : Nat) (base : Env AKey) (tapsN : List (List (List Nat)))

/-- One split at its readback node: the site's taps from the values so far, the fills, the call, the readback. -/
noncomputable def splitRun (k : AKey) (sp : SplitSpec) (st : AneSt) : Option AneSt := do
  let tn ← (tapsN[sp.layer]?).bind (·[sp.site]?)
  let site ← tn.mapM (st.vals[·]?)
  let fills ← sp.fills.mapM fun f => (f.srcs.mapM (srcVal site)).map f.fill
  let σ' ← runCall NE IP sp.prog fills st.surf
  let y ← readback (σ' sp.prog.out) sp.len sp.M sp.D
  pure ⟨st.vals ++ [y], fun k' => if k' = k then some y else st.rb k', σ',
    st.log ++ [⟨k, sp, site, fills, st.surf, σ', y⟩]⟩

/-- One node: a readback input runs its split (once), another input reads `base`, an operation its value. -/
noncomputable def aneNode (nd : RNode Int AKey) (st : AneSt) : Option AneSt :=
  match nd.prim with
  | .input k =>
    if nd.ins = [] then
      match st.rb k, net.split rows k with
      | some y, _ => some { st with vals := st.vals ++ [y] }
      | none, some sp => splitRun NE IP tapsN k sp st
      | none, none => (base.inputs k).map fun v => { st with vals := st.vals ++ [v] }
    else none
  | p =>
    if noInputK p then
      (nd.ins.mapM (st.vals[·]?)).bind fun xs =>
        (primEvalE P K.toKernelContract base (ksR P K base) p xs).map fun v => { st with vals := st.vals ++ [v] }
    else none

/-- **The family graph's values node by node**, the Neural Engine calls at the readback inputs. -/
noncomputable def aneNodes : List (RNode Int AKey) → AneSt → Option AneSt
  | [], st => some st
  | nd :: E, st => (aneNode P K NE IP net rows base tapsN nd st).bind (aneNodes E)

end

/-! ## The environment is read only at the inputs -/

section
variable {C : M1Max.Contract} {κ : Type}

theorem primEval_envK (M : MlxContract C) (K : KernelContract C) (w : List Char → List Char → Option Value)
    (v v' : κ → Option Value) :
    ∀ (p : RPrim Int κ) (xs : List Value), noInputK p = true → primEval M K ⟨w, v⟩ p xs = primEval M K ⟨w, v'⟩ p xs := by
  intro p
  induction p with
  | input k => intro xs h; simp [noInputK] at h
  | replayed c q ih =>
    intro xs h
    show (if elementwise q then none else primEval M K ⟨w, v⟩ q xs) = (if elementwise q then none else primEval M K ⟨w, v'⟩ q xs)
    rw [ih xs h]
  | _ => intro xs _; rcases xs with _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _⟩⟩⟩⟩⟩ <;> rfl

theorem primEvalE_envK (P : MlxPrefillContract C) (K : RouteKernelContract C) (env env' : Env κ)
    (hw : env.weights = env'.weights) (p : RPrim Int κ) (xs : List Value) (h : noInputK p = true) :
    primEvalE P K.toKernelContract env (ksR P K env) p xs = primEvalE P K.toKernelContract env' (ksR P K env') p xs := by
  obtain ⟨w, v⟩ := env
  obtain ⟨w', v'⟩ := env'
  dsimp only at hw
  subst hw
  have hP : ∀ q : RPrim Int κ, noInputK q = true →
      primEvalP P K.toKernelContract ⟨w, v⟩ q xs = primEvalP P K.toKernelContract ⟨w, v'⟩ q xs := fun q hq => by
    simp only [primEvalP, primEval_envK P.toMlxContract K.toKernelContract w v v' q xs hq]
  unfold primEvalE
  split
  · simp only [ksR, primEvalR, hP _ h]
  · rfl
  · split
    · rfl
    · exact hP p h

theorem primEvalE_input (P : MlxPrefillContract C) (K : KernelContract C) (env : Env κ) (ks : KernelSem) (k : κ) :
    primEvalE P K env ks (.input k) [] = env.inputs k := by
  simp only [primEvalE, closureOf?, primEvalP, primEval, Option.orElse]
  cases env.inputs k <;> rfl

end

/-! ## The fixpoint -/

/-- Node `nd` at index `i` has value `v` given the final readbacks `rb` and values `vals`: an input its readback
or `base`'s value, an operation its primitive on the earlier values. -/
def NodeOk {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (base : Env AKey)
    (rb : AKey → Option Value) (vals : List Value) (i : Nat) (nd : RNode Int AKey) (v : Value) : Prop :=
  (∃ k, nd.prim = .input k ∧ nd.ins = [] ∧ (rb k).orElse (fun _ => base.inputs k) = some v) ∨
  (noInputK nd.prim = true ∧
    (nd.ins.mapM fun j => if j < i then vals[j]? else none).bind
      (primEvalE P K.toKernelContract base (ksR P K base) nd.prim) = some v)

/-- The calls chain the surfaces: each from the previous one's result. -/
def CallsChain : (Nat → Surface) → List CallRec → (Nat → Surface) → Prop
  | σ, [], σ' => σ' = σ
  | σ, c :: cs, σ' => c.σ0 = σ ∧ CallsChain c.σ1 cs σ'

theorem callsChain_snoc : ∀ (σ : Nat → Surface) (cs : List CallRec) (c : CallRec),
    CallsChain σ cs c.σ0 → CallsChain σ (cs ++ [c]) c.σ1
  | _, [], _, h => ⟨h, rfl⟩
  | _, d :: cs, c, ⟨h1, h2⟩ => ⟨h1, callsChain_snoc d.σ1 cs c h2⟩

/-- A logged call's facts: its split is its key's, its site's taps are the values at the site's tap nodes, its
fills are the split's from them, it ran, its readback is the key's. -/
structure CallOk (NE : NeuralEngine) (IP : InPlace) (net : AneNet) (rows : Nat) (tapsN : List (List (List Nat)))
    (vals : List Value) (rb : AKey → Option Value) (c : CallRec) : Prop where
  split : net.split rows c.key = some c.sp
  site : ∃ tn, (tapsN[c.sp.layer]?).bind (·[c.sp.site]?) = some tn ∧ tn.mapM (vals[·]?) = some c.site
  fills : c.sp.fills.mapM (fun f => (f.srcs.mapM (srcVal c.site)).map f.fill) = some c.fills
  run : runCall NE IP c.sp.prog c.fills c.σ0 = some c.σ1
  readback : readback (c.σ1 c.sp.prog.out) c.sp.len c.sp.M c.sp.D = some c.y
  key : rb c.key = some c.y

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (rows : Nat) (base : Env AKey) (tapsN : List (List (List Nat)))

theorem mapM_prefix (ins : List Nat) (vals rest : List Value) :
    (ins.mapM fun j => vals[j]?) = ins.mapM fun j => if j < vals.length then (vals ++ rest)[j]? else none :=
  mapM_congr' ins _ _ fun j _ => by
    by_cases h : j < vals.length
    · rw [ite_eq_left h, List.getElem?_append_left h]
    · rw [ite_eq_right h, List.getElem?_eq_none (by omega)]

theorem mapM_get_append (vals rest : List Value) :
    ∀ (l : List Nat) (ys : List Value), (l.mapM fun j => vals[j]?) = some ys → (l.mapM fun j => (vals ++ rest)[j]?) = some ys
  | [], ys, h => h
  | j :: l, ys, h => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq] at h ⊢
    obtain ⟨x, hx, xs, hxs, rfl⟩ := h
    have hj : j < vals.length := (List.getElem?_eq_some_iff.mp hx).1
    exact ⟨x, by rw [List.getElem?_append_left hj, hx], xs, mapM_get_append vals rest l xs hxs, rfl⟩

theorem callOk_mono {vals vals' : List Value} {rb rb' : AKey → Option Value} {c : CallRec}
    (h : CallOk NE IP net rows tapsN vals rb c) (hv : ∃ rest, vals' = vals ++ rest)
    (hr : ∀ k y, rb k = some y → rb' k = some y) : CallOk NE IP net rows tapsN vals' rb' c := by
  obtain ⟨rest, rfl⟩ := hv
  obtain ⟨tn, h1, h2⟩ := h.site
  exact ⟨h.split, ⟨tn, h1, mapM_get_append vals rest tn _ h2⟩, h.fills, h.run, h.readback, hr _ _ h.key⟩

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (rows : Nat) (base : Env AKey) (tapsN : List (List (List Nat)))

/-- What one node does to the state: its value appended; an input's value its readback (kept or new) or, at a
key without a split, `base`'s; an operation's its primitive on the values so far. -/
structure NodeStep (nd : RNode Int AKey) (st st' : AneSt) : Prop where
  vals : ∃ v, st'.vals = st.vals ++ [v] ∧
    ((∃ k, nd.prim = .input k ∧ nd.ins = [] ∧
        (st'.rb k = some v ∨ (st.rb k = none ∧ net.split rows k = none ∧ base.inputs k = some v))) ∨
      (noInputK nd.prim = true ∧
        (nd.ins.mapM (st.vals[·]?)).bind (primEvalE P K.toKernelContract base (ksR P K base) nd.prim) = some v))
  mono : ∀ k y, st.rb k = some y → st'.rb k = some y
  keys : ∀ k, st'.rb k ≠ none → st.rb k ≠ none ∨ net.split rows k ≠ none
  chain : ∀ σ0, CallsChain σ0 st.log st.surf → CallsChain σ0 st'.log st'.surf
  log : ∀ c ∈ st'.log, c ∈ st.log ∨ CallOk NE IP net rows tapsN st'.vals st'.rb c

theorem splitRun_step (nd : RNode Int AKey) (k : AKey) (sp : SplitSpec) (st st' : AneSt)
    (hp : nd.prim = .input k) (hins : nd.ins = []) (hr : st.rb k = none) (hs : net.split rows k = some sp)
    (h : splitRun NE IP tapsN k sp st = some st') : NodeStep P K NE IP net rows base tapsN nd st st' := by
  simp only [splitRun, Option.bind_eq_bind, Option.bind_eq_some_iff, Option.pure_def, Option.some.injEq] at h
  obtain ⟨tn, htn, site, hsite, fills, hfills, σ', hσ, y, hy, rfl⟩ := h
  refine ⟨⟨y, rfl, .inl ⟨k, hp, hins, .inl (by simp)⟩⟩, fun k' y' h' => ?_, fun k' h' => ?_, fun σ0 hc => ?_,
    fun c hc => ?_⟩
  · by_cases e : k' = k
    · subst e; rw [hr] at h'; cases h'
    · simp [e, h']
  · by_cases e : k' = k
    · subst e; exact .inr (by rw [hs]; simp)
    · left; simpa [e] using h'
  · exact callsChain_snoc σ0 st.log ⟨k, sp, site, fills, st.surf, σ', y⟩ hc
  · rcases List.mem_append.mp hc with hc | hc
    · exact .inl hc
    · simp only [List.mem_singleton] at hc
      subst hc
      refine .inr ⟨hs, ⟨tn, Option.bind_eq_some_iff.mpr htn, mapM_get_append st.vals [y] tn site hsite⟩, hfills, hσ, hy, by simp⟩

theorem aneNode_step (nd : RNode Int AKey) (st st' : AneSt) (h : aneNode P K NE IP net rows base tapsN nd st = some st') :
    NodeStep P K NE IP net rows base tapsN nd st st' := by
  unfold aneNode at h
  split at h
  · rename_i k hp
    by_cases hins : nd.ins = []
    · rw [ite_eq_left hins] at h
      split at h
      · rename_i y hr
        cases h
        exact ⟨⟨y, rfl, .inl ⟨k, hp, hins, .inl (by simpa using hr)⟩⟩, fun _ _ h => h, fun k' h' => .inl h',
          fun _ hc => hc, fun c hc => .inl hc⟩
      · rename_i sp hr hs
        exact splitRun_step P K NE IP net rows base tapsN nd k sp st st' hp hins hr hs h
      · rename_i hr hs
        obtain ⟨v, hv, rfl⟩ := Option.map_eq_some_iff.mp h
        exact ⟨⟨v, rfl, .inl ⟨k, hp, hins, .inr ⟨hr, hs, hv⟩⟩⟩, fun _ _ h => h, fun k' h' => .inl h',
          fun _ hc => hc, fun c hc => .inl hc⟩
    · rw [ite_eq_right hins] at h; cases h
  · rename_i p hp
    by_cases hn : noInputK nd.prim = true
    · rw [ite_eq_left hn] at h
      obtain ⟨xs, hxs, h2⟩ := Option.bind_eq_some_iff.mp h
      obtain ⟨v, hv, rfl⟩ := Option.map_eq_some_iff.mp h2
      exact ⟨⟨v, rfl, .inr ⟨hn, by rw [hxs, Option.bind_some]; exact hv⟩⟩, fun _ _ h => h, fun k' h' => .inl h',
        fun _ hc => hc, fun c hc => .inl hc⟩
    · rw [ite_eq_right hn] at h; cases h

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C) (NE : NeuralEngine)
  (IP : InPlace) (net : AneNet) (rows : Nat) (base : Env AKey) (tapsN : List (List (List Nat)))

/-- **A run's facts**: the values extend by one per node, the readbacks only grow and only at split keys, every
node's value is correct in the final state, the calls chain the surfaces and every new one is ok there. -/
theorem aneNodes_spec : ∀ (E : List (RNode Int AKey)) (st stF : AneSt),
    aneNodes P K NE IP net rows base tapsN E st = some stF →
    (∃ rest, stF.vals = st.vals ++ rest ∧ rest.length = E.length) ∧
    (∀ k y, st.rb k = some y → stF.rb k = some y) ∧
    (∀ k, stF.rb k ≠ none → st.rb k ≠ none ∨ net.split rows k ≠ none) ∧
    (∀ j (hj : j < E.length), ∃ v, stF.vals[st.vals.length + j]? = some v ∧
      NodeOk P K base stF.rb stF.vals (st.vals.length + j) E[j] v) ∧
    (∀ σ0, CallsChain σ0 st.log st.surf → CallsChain σ0 stF.log stF.surf) ∧
    (∀ c ∈ stF.log, c ∈ st.log ∨ CallOk NE IP net rows tapsN stF.vals stF.rb c)
  | [], st, stF, h => by
    cases h
    exact ⟨⟨[], by simp, rfl⟩, fun _ _ h => h, fun _ h => .inl h, fun j hj => absurd hj (by simp), fun _ h => h,
      fun c hc => .inl hc⟩
  | nd :: E, st, stF, h => by
    obtain ⟨st', h1, h2⟩ := Option.bind_eq_some_iff.mp h
    have ns := aneNode_step P K NE IP net rows base tapsN nd st st' h1
    obtain ⟨⟨rest, hrest, hlen⟩, hmono, hkeys, hnodes, hchain, hlog⟩ := aneNodes_spec E st' stF h2
    obtain ⟨v, hv, hnd⟩ := ns.vals
    have hvals : stF.vals = st.vals ++ (v :: rest) := by rw [hrest, hv]; simp
    have hmono' : ∀ k y, st.rb k = some y → stF.rb k = some y := fun k y h => hmono k y (ns.mono k y h)
    refine ⟨⟨v :: rest, hvals, by simp [hlen]⟩, hmono', fun k hk => ?_, fun j hj => ?_, fun σ0 hc => hchain σ0 (ns.chain σ0 hc),
      fun c hc => ?_⟩
    · rcases hkeys k hk with h' | h'
      · rcases ns.keys k h' with h'' | h''
        · exact .inl h''
        · exact .inr h''
      · exact .inr h'
    · cases j with
      | zero =>
        refine ⟨v, by rw [hvals]; simp, ?_⟩
        rcases hnd with ⟨k, hp, hins, hk⟩ | ⟨hn, hx⟩
        · refine .inl ⟨k, hp, hins, ?_⟩
          rcases hk with hk | ⟨hr, hs, hb⟩
          · rw [hmono k v hk]; rfl
          · have hst' : st'.rb k = none := by
              cases e : st'.rb k with
              | none => rfl
              | some _ =>
                rcases ns.keys k (by rw [e]; simp) with h' | h'
                · exact absurd hr h'
                · exact absurd hs h'
            have hF : stF.rb k = none := by
              cases e : stF.rb k with
              | none => rfl
              | some _ =>
                rcases hkeys k (by rw [e]; simp) with h' | h'
                · exact absurd hst' h'
                · exact absurd hs h'
            rw [hF]; simpa using hb
        · refine .inr ⟨hn, ?_⟩
          show (List.mapM (fun j => if j < st.vals.length + 0 then stF.vals[j]? else none) nd.ins).bind
            (primEvalE P K.toKernelContract base (ksR P K base) nd.prim) = some v
          rw [Nat.add_zero, hvals, ← mapM_prefix nd.ins st.vals (v :: rest)]
          exact hx
      | succ j =>
        have hj' : j < E.length := by simp at hj; omega
        obtain ⟨w, hw, hok⟩ := hnodes j hj'
        have e : st'.vals.length + j = st.vals.length + (j + 1) := by rw [hv]; simp; omega
        rw [e] at hw hok
        exact ⟨w, hw, by simpa using hok⟩
    · rcases hlog c hc with hc' | hc'
      · rcases ns.log c hc' with h' | h'
        · exact .inl h'
        · exact .inr (callOk_mono NE IP net rows tapsN h' ⟨rest, hrest⟩ hmono)
      · exact .inr hc'

/-- **The readbacks are a fixpoint**: from no readback, at the environment holding the run's readbacks at their
keys (`withRb`), the expected graph's evaluation `evalE` is the run's value at every node. -/
theorem aneNodes_evalE (E : List (RNode Int AKey)) (σ : Nat → Surface) (stF : AneSt)
    (h : aneNodes P K NE IP net rows base tapsN E ⟨[], fun _ => none, σ, []⟩ = some stF) :
    stF.vals.length = E.length ∧ ∀ i, i < E.length →
      evalE P K.toKernelContract (withRb base stF.rb) (ksR P K (withRb base stF.rb)) (listGraph E) i = stF.vals[i]? := by
  obtain ⟨⟨rest, hrest, hlen⟩, _, _, hnodes, _, _⟩ := aneNodes_spec P K NE IP net rows base tapsN E _ stF h
  simp only [List.nil_append] at hrest
  refine ⟨by rw [hrest, hlen], fun i => ?_⟩
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  intro hi
  obtain ⟨v, hv, hok⟩ := hnodes i hi
  simp only [List.length_nil, Nat.zero_add] at hv hok
  rw [evalE_eq, hv]
  have hl : listGraph E i = some E[i] := List.getElem?_eq_getElem hi
  rw [hl]
  dsimp only
  rcases hok with ⟨k, hp, hins, hk⟩ | ⟨hn, hx⟩
  · rw [hins, hp, List.mapM_nil, Option.pure_def, Option.bind_some, primEvalE_input]
    exact hk
  · have hm : (E[i].ins.mapM fun j => if _h : j < i then
        evalE P K.toKernelContract (withRb base stF.rb) (ksR P K (withRb base stF.rb)) (listGraph E) j else none) =
        E[i].ins.mapM fun j => if j < i then stF.vals[j]? else none :=
      mapM_congr' _ _ _ fun j _ => by
        by_cases hj : j < i
        · rw [dite_eq_left hj, ite_eq_left hj, ih j hj (by omega)]
        · rw [dite_eq_right hj, ite_eq_right hj]
    rw [hm]
    rw [← hx]
    congr 1
    funext xs
    exact primEvalE_envK P K (withRb base stF.rb) base rfl E[i].prim xs hn

/-- **The calls of a run**: from no readback and no call, the logged calls chain the surfaces from the start to the
end, and each ran on its site's final values with its readback the key's. -/
theorem aneNodes_calls (E : List (RNode Int AKey)) (σ : Nat → Surface) (stF : AneSt)
    (h : aneNodes P K NE IP net rows base tapsN E ⟨[], fun _ => none, σ, []⟩ = some stF) :
    CallsChain σ stF.log stF.surf ∧ ∀ c ∈ stF.log, CallOk NE IP net rows tapsN stF.vals stF.rb c := by
  obtain ⟨_, _, _, _, hchain, hlog⟩ := aneNodes_spec P K NE IP net rows base tapsN E _ stF h
  refine ⟨hchain σ rfl, fun c hc => ?_⟩
  rcases hlog c hc with h' | h'
  · cases h'
  · exact h'

end

/-- **A logged call meets the layer lemmas' call and reader premises** (`mlpLayer_ok`, `affineDeltaLayer_ok`,
`affineAttnLayer_ok`): the route's call with the logged program and fills launching as the logged ones steps
between the logged surfaces, and a reader of the program's output with the split's geometry, whose value is the
key's readback, holds the readback of the surface after the call. -/
theorem callRec_step (NE : NeuralEngine) (IP : InPlace) (net : AneNet) (rows : Nat) (tapsN : List (List (List Nat)))
    {vals : List Value} {rb : AKey → Option Value} {c : CallRec} (h : CallOk NE IP net rows tapsN vals rb c)
    (G : Graph) (call : Call) (hq : G.program call.q = some c.sp.prog) (hf : c.fills.map fillSem = call.fills.map fillSem)
    (r : Reader) (hso : r.so = c.sp.prog.out) (hlen : r.len = c.sp.len) (hM : r.M = c.sp.M) (hD : r.D = c.sp.D)
    (V : Nat → Option Value) (hV : V r.b = rb c.key) :
    call.Step NE IP G c.σ0 c.σ1 ∧ V r.b = readback (c.σ1 r.so) r.len r.M r.D := by
  refine ⟨runCall_step NE IP G call c.sp.prog c.fills c.σ0 c.σ1 hq hf h.run, ?_⟩
  rw [hV, h.key, hso, hlen, hM, hD, h.readback]

end Host.Mlx.SimGraph.Ref
