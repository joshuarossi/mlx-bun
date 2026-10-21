import host.simgraph.Classify
import host.load.Inputs
import host.mlx.GraphStability
namespace Host.Mlx.SimGraph
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load.Extract
open Host.Mlx.Ffi (Prim)

/-! # The template's domain and inputs, and graph growth

* `tplDom NL N0 fixed s`: the template nodes whose carriers the certificate
  may use: created before the loop (`< NL`) or in the template iteration
  (`≥ N0`), with rope arguments a literal or a bigint of `fixed` (which the
  iteration map must keep). The native relation corresponds such nodes fully.
* `loadedT`: `Extract.loaded` for a symbolic state (cache offsets are
  symbolic there; they are not part of the carriers).
* `evalR_extend`: a later native state that keeps the nodes up to `i` and the
  route kernels evaluates node `i` as the earlier one does. -/

/-- A rope argument the iteration map is required to keep. -/
def okArg (fixed : List Int) : Arg → Bool
  | .big i => fixed.contains i
  | .num (.lit _) => true
  | _ => false

def primArgsOk (fixed : List Int) : Prim → Bool
  | .rope _ _ b _ _ => okArg fixed b
  | .replayed _ p => primArgsOk fixed p
  | _ => true

/-- The template's domain. -/
def tplDom (NL N0 : Nat) (fixed : List Int) (s : Ffi.St) (i : Nat) : Bool :=
  (decide (i < NL) || decide (N0 ≤ i)) && match s.nodes.get i with
    | some nd => primArgsOk fixed nd.prim
    | none => true

theorem primArgsOk_sound (fixed : List Int) :
    ∀ p : Prim, primArgsOk fixed p = true → PrimArgs (fun a => okArg fixed a = true) p := by
  intro p
  induction p <;> simp_all [primArgsOk, PrimArgs]

theorem tplDom_args {NL N0 : Nat} {fixed : List Int} {s : Ffi.St} {i : Nat} {nd : Ffi.Node}
    (h : tplDom NL N0 fixed s i = true) (hn : s.nodes.get i = some nd) :
    PrimArgs (fun a => okArg fixed a = true) nd.prim := by
  simp only [tplDom, hn, Bool.and_eq_true] at h
  exact primArgsOk_sound fixed _ h.2

theorem tplDom_band {NL N0 : Nat} {fixed : List Int} {s : Ffi.St} {i : Nat}
    (h : tplDom NL N0 fixed s i = true) : i < NL ∨ N0 ≤ i := by
  simp only [tplDom, Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq] at h
  exact h.1

/-- Rope arguments the iteration map keeps: it fixes the bigints of `fixed` and
literal numbers (as `M.arg` does when `M.big` fixes them). -/
theorem okArg_kept (fixed : List Int) (α : Arg → Arg) (hbig : ∀ i ∈ fixed, α (.big i) = .big i)
    (hlit : ∀ f, α (.num (.lit f)) = .num (.lit f)) :
    ∀ a v, okArg fixed a = true → Ffi.argNat a = some v → Ffi.argNat (α a) = some v := by
  intro a v ha hv
  cases a with
  | big i =>
    rw [hbig i (by simpa [okArg] using ha)]
    exact hv
  | num x =>
    cases x with
    | lit f => rw [hlit]; exact hv
    | ref _ => simp [okArg] at ha
  | _ => simp [okArg] at ha

/-! ## The template's inputs -/

def cacheT (s : St Host.Load.LSt) (v : Val) : Option Cache := do
  let cls ← className s v
  let first ← ((privateField s v chars!"conv").orElse fun _ => own s v chars!"keys").bind (optionalTensor s)
  let second ← ((privateField s v chars!"recurrent").orElse fun _ => own s v chars!"values").bind (optionalTensor s)
  pure ⟨cls, 0, first, second⟩

/-- The loaded model and caches of a symbolic state. -/
def loadedT (s : St Host.Load.LSt) (env : Env) : Option Loaded := do
  let m ← (bindingOf s env chars!"model").bind (model s)
  let cs ← ((bindingOf s env chars!"cache").bind (elements s)).bind (List.mapM (cacheT s))
  pure ⟨m, cs⟩

/-! ## Graph growth -/

section
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  {κ : Type} [DecidableEq κ] (env : Env κ)

omit [DecidableEq κ] in
theorem renameN_self {δ : Type} (r : RNode δ κ) : renameN (fun i => i) (fun h => h) r = r := by
  obtain ⟨p, ins⟩ := r
  have : ∀ q : RPrim δ κ, renameCls (fun h => h) q = q := by
    intro q; induction q <;> simp_all [renameCls]
  simp [renameN, this]

/-- **Graph growth.** A later native state `s'` that keeps every node up to `i`
and every route kernel object of `s` evaluates node `i` as `s` does. -/
theorem evalR_extend (N : Nums Int) (Ks : KernelSources) (s s' : Ffi.St) (i : Nat)
    (nodes : ∀ j ≤ i, s'.nodes.get j = s.nodes.get j)
    (kernels : ∀ k name, kernelName? Ks s k = some name → kernelName? Ks s' k = some name)
    (v : Value) (hv : evalR M K env (ffiGraph N Ks s) i = some v) :
    evalR M K env (ffiGraph N Ks s') i = some v := by
  let G := ffiGraph (κ := κ) N Ks s
  let B : Nat → Option (RNode Int κ) := fun j => if j ≤ i then G j else none
  have hB : evalR M K env B i = evalR M K env G i :=
    evalR_prefix M K env B G i fun j hj => by simp only [B, hj, ↓reduceIte]
  have ha : Agree N N (fun i => i) SynImg.id (kernelName? Ks s) (kernelName? Ks s') (fun _ => True) :=
    ⟨fun _ _ h => h, fun _ _ h => h, fun _ _ h => h, fun _ _ h => h, fun _ _ _ h => h, kernels⟩
  have hA : ∀ p, PrimArgs (fun _ => True) p := by
    intro p; induction p <;> simp_all [PrimArgs]
  have emb : Embeds (fun i => i) (fun h => h) B (ffiGraph N Ks s') := by
    refine ⟨fun j r hr => ?_, fun _ _ _ h => h⟩
    have hj : j ≤ i := by
      by_contra hj; simp [B, hj] at hr
    simp only [B, hj, ↓reduceIte] at hr
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp hr
    show (s'.nodes.get j).bind _ = _
    rw [nodes j hj, hnd, Option.bind_some, renameN_self]
    have h := resolveNode_img ha (fun i => i) nd r (hA _) hres
    have hnd' : nodeI (fun i => i) SynImg.id nd = nd := by rw [nodeI, primI_id]; simp [SynImg.id]
    rw [hnd', mapN_id] at h
    exact h.trans (congrArg some (renameN_self r))
  exact evalR_embed M K env B _ emb i v (hB.trans hv)

end

end Host.Mlx.SimGraph
