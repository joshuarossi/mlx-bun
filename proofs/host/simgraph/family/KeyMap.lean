import host.simgraph.family.Eval
import host.simgraph.Match
import host.mlx.FfiAneEval
namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval Inference.Contracts.Mlx
open Host.Mlx.FfiAneEval (Mem pureVal noInput)

/-! # Renaming a graph's input keys

The Neural Engine semantics (`FfiAneEval`) evaluates the FFI graph with its
readers and writers as leaves keyed by their node ids (`Graph.pure`, keys
`Nat`); a family's expected graph names its inputs by its own keys. `keyG f`
renames every input key by `f`; nothing else depends on keys:

* `cgLeaves_keyG`, `closureLeaves_keyG`: the compute_g and closure patterns
  are unchanged;
* `evalRR_keyG`: the route evaluation of the renamed graph at `env` is the
  original's at `env₀` when `env` holds at `f k` what `env₀` holds at `k`
  (`KeyAgree`) and the weights agree;
* `pureVal_keyG`: a node's pure value in the Neural Engine semantics is the
  route evaluation of the pure graph with its readers' and writers' leaves
  renamed by `rk`, at an environment holding each one's fixed value at its
  key. -/

section
variable {δ κ κ' : Type} (f : κ → κ')

/-- Rename an input key. -/
def keyP : RPrim δ κ → RPrim δ κ'
  | .input k => .input (f k)
  | .computeG => .computeG
  | .data b s d => .data b s d
  | .load a b => .load a b
  | .zeros s d => .zeros s d
  | .unsupported => .unsupported
  | .reshape s => .reshape s
  | .transpose ax => .transpose ax
  | .slice a b c => .slice a b c
  | .sliceUpdate a b c => .sliceUpdate a b c
  | .sliceDynamic ax sz => .sliceDynamic ax sz
  | .concat a => .concat a
  | .unary op => .unary op
  | .binary op => .binary op
  | .astype d => .astype d
  | .contiguous => .contiguous
  | .rmsNorm e => .rmsNorm e
  | .rope d t b s off => .rope d t b s off
  | .sdpa s m => .sdpa s m
  | .qmm t g b m => .qmm t g b m
  | .dequantize g b m d => .dequantize g b m d
  | .take a => .take a
  | .conv1d a b c d => .conv1d a b c d
  | .logsumexp a k => .logsumexp a k
  | .kernel n c o => .kernel n c o
  | .replayed c p => .replayed c (keyP p)

def keyN (r : RNode δ κ) : RNode δ κ' := ⟨keyP f r.prim, r.ins⟩

/-- A graph with its input keys renamed. -/
def keyG (g : Nat → Option (RNode δ κ)) (i : Nat) : Option (RNode δ κ') := (g i).map (keyN f)

theorem keyP_replayed {p : RPrim δ κ} {c : Nat} {q : RPrim δ κ'} {q' : RPrim δ κ}
    (hq : ∀ r : RPrim δ κ, keyP f r = q ↔ r = q') : keyP f p = .replayed c q ↔ p = .replayed c q' := by
  cases p <;> simp [keyP, hq]

theorem keyP_binary {p : RPrim δ κ} {op : List Char} : keyP f p = .binary op ↔ p = .binary op := by
  cases p <;> simp [keyP]

theorem keyP_unary {p : RPrim δ κ} {op : List Char} : keyP f p = .unary op ↔ p = .unary op := by
  cases p <;> simp [keyP]

theorem keyP_astype {p : RPrim δ κ} {d : Nat} : keyP f p = .astype d ↔ p = .astype d := by
  cases p <;> simp [keyP]

theorem keyP_data_nil {p : RPrim δ κ} {bs : List Nat} {d : Nat} : keyP f p = .data bs [] d ↔ p = .data bs [] d := by
  cases p <;> simp [keyP]

theorem replayedExp_keyP (p : RPrim δ κ) : replayedExp? (keyP f p) = replayedExp? p := by
  cases p with
  | replayed c q => cases q <;> simp [keyP, replayedExp?]
  | _ => rfl

theorem elementwise_keyP (p : RPrim δ κ) : elementwise (keyP f p) = elementwise p := by
  induction p <;> simp_all [keyP, elementwise]

theorem cgAux_key [DecidableEq δ] [DecidableEq κ] [DecidableEq κ'] (r : RNode δ κ) (b : Nat → Option (RNode δ κ)) :
    cgAux (keyN f r) (fun j => (b j).map (keyN f)) = cgAux r b := by
  have hm : ∀ {c : Nat} {op : List Char} (p : RPrim δ κ),
      keyP f p = .replayed c (.binary op) ↔ p = .replayed c (.binary op) :=
    fun _ => keyP_replayed f (fun _ => keyP_binary f)
  have hu : ∀ {c : Nat} {op : List Char} (p : RPrim δ κ),
      keyP f p = .replayed c (.unary op) ↔ p = .replayed c (.unary op) :=
    fun _ => keyP_replayed f (fun _ => keyP_unary f)
  have ha : ∀ {c d : Nat} (p : RPrim δ κ), keyP f p = .replayed c (.astype d) ↔ p = .replayed c (.astype d) :=
    fun _ => keyP_replayed f (fun _ => keyP_astype f)
  simp only [cgAux, keyN, replayedExp_keyP, Option.bind_eq_bind, Option.bind_map, Function.comp_def, hm, hu, ha,
    keyP_data_nil, rnode_eq_mk]

theorem cgLeaves_keyG [DecidableEq δ] [DecidableEq κ] [DecidableEq κ'] (G : Nat → Option (RNode δ κ)) (i : Nat) :
    cgLeaves (keyG f G) i = cgLeaves G i := by
  unfold cgLeaves keyG
  cases hg : G i with
  | none => rfl
  | some r =>
    simp only [Option.map_some, Option.bind_some]
    have hb : (fun j => if j < i then (G j).map (keyN f) else none) =
        (fun j => ((fun j => if j < i then G j else none) j).map (keyN f)) := by
      funext j; by_cases h : j < i <;> simp [h]
    rw [hb, cgAux_key]

end

section
variable {κ κ' : Type} [DecidableEq κ] [DecidableEq κ'] (f : κ → κ')

theorem closureLeaves_keyG (kind : Nat → Option Compiled) (G : Nat → Option (RNode Int κ)) (i : Nat) :
    closureLeaves kind (keyG f G) i = closureLeaves kind G i := by
  have hrb : ∀ (q : RPrim Int κ) (c : Nat) (op : List Char), keyP f q = .replayed c (.binary op) ↔
      q = .replayed c (.binary op) := fun _ _ _ => keyP_replayed f (fun _ => keyP_binary f)
  have hru : ∀ (q : RPrim Int κ) (c : Nat) (op : List Char), keyP f q = .replayed c (.unary op) ↔
      q = .replayed c (.unary op) := fun _ _ _ => keyP_replayed f (fun _ => keyP_unary f)
  have hra : ∀ (q : RPrim Int κ) (c d : Nat), keyP f q = .replayed c (.astype d) ↔
      q = .replayed c (.astype d) := fun _ _ _ => keyP_replayed f (fun _ => keyP_astype f)
  have hb2 : ∀ (q : RPrim Int κ) (op : List Char), keyP f q = .binary op ↔ q = .binary op :=
    fun _ _ => keyP_binary f
  have hast : ∀ (q : RPrim Int κ) (d : Nat), keyP f q = .astype d ↔ q = .astype d := fun _ _ => keyP_astype f
  have hb : (fun j => if j < i then keyG f G j else none) =
      (fun j => ((fun j => if j < i then G j else none) j).map (keyN f)) := by
    funext j; by_cases hj : j < i <;> simp [hj, keyG]
  unfold closureLeaves
  rw [hb]
  unfold keyG
  cases hG : G i with
  | none => rfl
  | some r =>
    simp only [Option.map_some, Option.bind_some]
    unfold closureAux
    simp only [keyN]
    cases hp : r.prim with
    | replayed cls p =>
      simp only [keyP, elementwise_keyP]
      split
      · simp only [closureBody, Option.bind_eq_bind, Option.bind_map, Function.comp_def, keyN, hb2, hast, hrb, hru,
          hra, rnode_eq_mk]
      · rfl
    | _ => simp [keyP]

end

/-! ## Values -/

section
variable {κ κ' : Type} (f : κ → κ')

/-- `env` holds at `f k` what `env₀` holds at `k`, for the primitive's key. -/
def KeyAgree (env : Env κ') (env₀ : Env κ) : RPrim Int κ → Prop
  | .input k => env.inputs (f k) = env₀.inputs k
  | .replayed _ p => KeyAgree env env₀ p
  | _ => True

theorem keyAgree_noInput (g : Nat → κ') (env : Env κ') (env₀ : Env Nat) :
    ∀ p : RPrim Int Nat, noInput p = true → KeyAgree g env env₀ p
  | .input _, h => by simp [noInput] at h
  | .replayed _ q, h => keyAgree_noInput g env env₀ q h
  | .computeG, _ | .data .., _ | .load .., _ | .zeros .., _ | .unsupported, _ | .reshape _, _ | .transpose _, _
  | .slice .., _ | .sliceUpdate .., _ | .sliceDynamic .., _ | .concat _, _ | .unary _, _ | .binary _, _
  | .astype _, _ | .contiguous, _ | .rmsNorm _, _ | .rope .., _ | .sdpa .., _ | .qmm .., _ | .dequantize .., _
  | .take _, _ | .conv1d .., _ | .logsumexp .., _ | .kernel .., _ => trivial

variable {C : M1Max.Contract} (P : MlxPrefillContract C)

theorem primEval_keyP (K : KernelContract C) (env : Env κ') (env₀ : Env κ) (hw : env.weights = env₀.weights) :
    ∀ (p : RPrim Int κ) (xs : List Value), KeyAgree f env env₀ p →
      primEval P.toMlxContract K env (keyP f p) xs = primEval P.toMlxContract K env₀ p xs := by
  intro p
  induction p with
  | input k =>
    intro xs h
    rcases xs with _ | ⟨_, _⟩
    · exact h
    · rfl
  | replayed c q ih =>
    intro xs h
    show (if elementwise (keyP f q) then none else primEval P.toMlxContract K env (keyP f q) xs) =
      (if elementwise q then none else primEval P.toMlxContract K env₀ q xs)
    rw [elementwise_keyP, ih xs h]
  | load a b =>
    intro xs _
    rcases xs with _ | ⟨_, _⟩
    · show env.weights a b = env₀.weights a b
      rw [hw]
    · rfl
  | _ => intro xs _; rcases xs with _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _⟩⟩⟩⟩⟩ <;> rfl

theorem rowsEval_keyP : ∀ (p : RPrim Int κ) (xs : List Value), rowsEval P (keyP f p) xs = rowsEval P p xs := by
  intro p
  induction p with
  | replayed c q ih =>
    intro xs
    show (if elementwise (keyP f q) then none else rowsEval P (keyP f q) xs) =
      (if elementwise q then none else rowsEval P q xs)
    rw [elementwise_keyP, ih xs]
  | _ => intro xs; rcases xs with _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _⟩⟩⟩⟩⟩ <;> rfl

theorem computeGP_keyP (xs : List Value) : computeGP P (κ := κ') xs = computeGP P (κ := κ) xs := by
  simp only [computeGP]
  congr 1
  funext _
  rcases xs with _ | ⟨_, _ | ⟨_, _ | ⟨_, _ | ⟨_, _⟩⟩⟩⟩ <;> rfl

theorem primEvalP_keyP (K : KernelContract C) (env : Env κ') (env₀ : Env κ) (hw : env.weights = env₀.weights)
    (p : RPrim Int κ) (xs : List Value) (h : KeyAgree f env env₀ p) :
    primEvalP P K env (keyP f p) xs = primEvalP P K env₀ p xs := by
  simp only [primEvalP, primEval_keyP f P K env env₀ hw p xs h, rowsEval_keyP f P p xs]

theorem prefillEval_keyP (K : RouteKernelContract C) (p : RPrim Int κ) (xs : List Value) :
    prefillEval K (keyP f p) xs = prefillEval K p xs := by
  cases p <;> rfl

theorem primEvalR_keyP (K : RouteKernelContract C) (env : Env κ') (env₀ : Env κ) (hw : env.weights = env₀.weights)
    (p : RPrim Int κ) (xs : List Value) (h : KeyAgree f env env₀ p) :
    primEvalR P K env (keyP f p) xs = primEvalR P K env₀ p xs := by
  simp only [primEvalR, primEvalP_keyP f P K.toKernelContract env env₀ hw p xs h, prefillEval_keyP f K p xs]

variable [DecidableEq κ] [DecidableEq κ']

/-- **Renaming the input keys**: the route evaluation of the renamed graph is the original's. -/
theorem evalRR_keyG (K : RouteKernelContract C) (env : Env κ') (env₀ : Env κ) (kind : Nat → Option Compiled)
    (g : Nat → Option (RNode Int κ)) (hw : env.weights = env₀.weights)
    (hk : ∀ j nd, g j = some nd → KeyAgree f env env₀ nd.prim) :
    ∀ i, evalRR P K env kind (keyG f g) i = evalRR P K env₀ kind g i := by
  intro i
  induction i using Nat.strong_induction_on with
  | _ i ih =>
  have hargs : ∀ l : List Nat, (l.mapM fun j => if _h : j < i then evalRR P K env kind (keyG f g) j else none) =
      (l.mapM fun j => if _h : j < i then evalRR P K env₀ kind g j else none) := fun l =>
    mapM_congr' l _ _ fun j _ => by
      by_cases hj : j < i
      · simp only [hj, ↓reduceDIte]; exact ih j hj
      · simp only [hj, ↓reduceDIte]
  rw [evalRR_eq, evalRR_eq, cgLeaves_keyG, closureLeaves_keyG]
  cases hgi : g i with
  | none => simp [keyG, hgi]
  | some nd =>
    simp only [keyG, hgi, Option.map_some]
    cases cgLeaves g i with
    | some leaves =>
      (try dsimp only); rw [hargs]
      congr 1; funext xs; exact computeGP_keyP P xs
    | none =>
      (try dsimp only)
      cases closureLeaves kind g i with
      | some x => (try dsimp only); rw [hargs]
      | none =>
        (try dsimp only)
        rw [hargs]
        simp only [keyN]
        congr 1
        funext xs
        exact primEvalR_keyP f P K env env₀ hw nd.prim xs (hk i nd hgi)

end

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (K : RouteKernelContract C)
  (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled) {κ : Type} [DecidableEq κ]

/-- **Pure values as a keyed evaluation**: with the readers' and writers'
leaves renamed by `rk` and an environment holding each one's fixed value at
its key (and the run's weights), a node's pure value is the route
evaluation. -/
theorem pureVal_keyG (G : FfiAneEval.Graph) (m : Mem) (rk : Nat → κ) (env : Env κ) (hw : env.weights = weights)
    (hr : ∀ j, (G.touch j).isSome = true → env.inputs (rk j) = m.vals j)
    (hn : ∀ j nd, G.node j = some nd → noInput nd.prim = true) (i : Nat) :
    pureVal P K weights kind G m i = evalRR P K env kind (keyG rk G.pure) i := by
  unfold pureVal
  refine (evalRR_keyG rk P K env (m.env weights) kind G.pure hw ?_ i).symm
  intro j nd hj
  unfold FfiAneEval.Graph.pure at hj
  split at hj
  · rename_i ht
    cases hj
    exact hr j ht
  · exact keyAgree_noInput rk env _ nd.prim (hn j nd hj)

end

end Host.Mlx.SimGraph
