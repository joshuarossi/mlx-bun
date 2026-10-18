import host.mlx.FfiEval
import host.load.Expr
namespace Host.Load.Program
open Host.Mlx Host.Mlx.FfiEval

/-- Exactly the operations in the ancestor closure of the loaded parameters.
Data bytes are materialized by the host numeric valuation before matching. -/
inductive Op where
  | load (file key : List Char)
  | data (bytes : List Nat)
  | add
  | transpose (axes : List Nat)
  | contiguous
  deriving DecidableEq, Lean.ToExpr

structure Node where
  op : Op
  ins : List Nat
  shape : List Nat
  dtype : Nat
  deriving DecidableEq, Lean.ToExpr

def Node.erase (n : Node) : RNode Int InKey :=
  ⟨match n.op with
    | .load f k => .load f k
    | .data bs => .data bs (n.shape.map Int.ofNat) n.dtype
    | .add => .binary chars!"add"
    | .transpose axes => .transpose axes
    | .contiguous => .contiguous, n.ins⟩

abbrev Code := List Node

def graph (p : Code) : Nat → Option (RNode Int InKey) :=
  listGraph (p.map Node.erase)

def Header (v : Value) (n : Node) : Prop := v.dtype.code = n.dtype ∧ v.shape = n.shape

def validAt (p : Code) (i : Nat) (n : Node) : Bool :=
  n.ins.all (· < i) && match n.op, n.ins with
  | .load _ _, [] => true
  | .data _, [] => (Dtype.ofCode n.dtype).isSome
  | .add, [a, b] => match p[a]?, p[b]? with
    | some x, some y => decide (x.dtype = 12 ∧ y.dtype = 12 ∧ y.shape = [] ∧ n.dtype = 12 ∧ n.shape = x.shape)
    | _, _ => false
  | .transpose axes, [a] => match p[a]? with
    | some x => decide (axes.length = x.shape.length ∧ (List.range x.shape.length).all (fun a => axes.contains a) = true ∧
        n.dtype = x.dtype ∧ n.shape = axes.map (fun a => x.shape.getD a 0))
    | _ => false
  | .contiguous, [a] => match p[a]? with
    | some x => decide (n.dtype = x.dtype ∧ n.shape = x.shape)
    | _ => false
  | _, _ => false


def allAt (f : Nat → α → Bool) : Nat → List α → Bool
  | _, [] => true
  | i, n :: ns => f i n && allAt f (i + 1) ns

theorem allAt_cons (f : Nat → α → Bool) (i : Nat) (n : α) (ns : List α)
    (hh : f i n = true) (ht : allAt f (i + 1) ns = true) :
    allAt f i (n :: ns) = true := by simp only [allAt, hh, ht, Bool.and_self]

theorem allAt_get (f : Nat → α → Bool) (xs : List α) (offset : Nat)
    (h : allAt f offset xs = true) (hn : xs[i]? = some n) : f (offset + i) n = true := by
  induction xs generalizing offset i with
  | nil => simp at hn
  | cons a xs ih =>
    simp only [allAt, Bool.and_eq_true] at h
    cases i with
    | zero =>
      have he : a = n := by simpa using hn
      simpa [he] using h.1
    | succ i =>
      have := ih (offset + 1) h.2 (by simpa using hn)
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this

theorem allAt_ignore (f : α → Bool) (xs : List α) (offset : Nat) :
    allAt (fun _ a => f a) offset xs = xs.all f := by
  induction xs generalizing offset with
  | nil => rfl
  | cons a xs ih => simp only [allAt, List.all_cons, ih]

def valid (p : Code) : Bool := allAt (validAt p) 0 p

def Valid (p : Code) : Prop := valid p = true

/-- The external checkpoint assumption is indexed by actual file/key leaves.
No intermediate-node contents are accepted as external parameters. -/
def Leaves (p : Code) (weights : List Char → List Char → Option Value) : Prop :=
  ∀ (i : Nat) (n : Node) (file key : List Char), p[i]? = some n → n.op = .load file key →
    ∃ v, weights file key = some v ∧ Header v n

theorem graph_get (p : Code) (h : p[i]? = some n) : graph p i = some n.erase := by
  simp [graph, listGraph, h]

theorem no_compute (p : Code) (h : p[i]? = some n) : cgLeaves (graph p) i = none := by
  apply cgLeaves_none (graph p) i n.erase (graph_get p h)
  cases n with
  | mk op ins shape dtype => cases op <;> rfl

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (weights : List Char → List Char → Option Value) (inputs : InKey → Option Value)

noncomputable def value (p : Code) (i : Nat) : Option Value :=
  evalR M K ⟨weights, inputs⟩ (graph p) i

theorem value_step (p : Code) (h : p[i]? = some n) : value M K weights inputs p i =
    (n.ins.mapM fun j => if _h : j < i then value M K weights inputs p j else none).bind
      (primEval M K ⟨weights, inputs⟩ n.erase.prim) := by
  rw [value, evalR_eq, graph_get p h, no_compute p h]
  rfl

theorem load_value (p : Code) (h : p[i]? = some ⟨.load file key, [], shape, dt⟩) :
    value M K weights inputs p i = weights file key := by
  rw [value_step M K weights inputs p h]
  rfl

theorem data_value (p : Code) (h : p[i]? = some ⟨.data bs, [], shape, dt⟩) :
    value M K weights inputs p i = dataValue bs (shape.map Int.ofNat) dt := by
  rw [value_step M K weights inputs p h]
  rfl

theorem add_value (p : Code) (h : p[i]? = some ⟨.add, [a,b], shape, dt⟩)
    (ha : a < i) (hb : b < i) (va vb : Value)
    (hva : value M K weights inputs p a = some va) (hvb : value M K weights inputs p b = some vb) :
    value M K weights inputs p i = add va vb := by
  rw [value_step M K weights inputs p h]
  simp only [List.mapM_cons, List.mapM_nil, dite_eq_left ha, dite_eq_left hb, hva, hvb,
    Option.pure_def, Node.erase]
  rfl

theorem transpose_value (p : Code) (h : p[i]? = some ⟨.transpose axes, [a], shape, dt⟩)
    (ha : a < i) (va : Value) (hva : value M K weights inputs p a = some va) :
    value M K weights inputs p i = transpose va axes := by
  rw [value_step M K weights inputs p h]
  simp only [List.mapM_cons, List.mapM_nil, dite_eq_left ha, hva, Option.pure_def, Node.erase]
  rfl

theorem contiguous_value (p : Code) (h : p[i]? = some ⟨.contiguous, [a], shape, dt⟩)
    (ha : a < i) (va : Value) (hva : value M K weights inputs p a = some va) :
    value M K weights inputs p i = some va := by
  rw [value_step M K weights inputs p h]
  simp only [List.mapM_cons, List.mapM_nil, dite_eq_left ha, hva, Option.pure_def, Node.erase]
  rfl

theorem dtype_of_code {d : Dtype} (h : d.code = 12) : d = .bfloat16 := by
  cases d <;> simp_all [Dtype.code]

theorem ofCode_some_code (h : Dtype.ofCode n = some d) : d.code = n := by
  unfold Dtype.ofCode at h
  split at h <;> cases h <;> rfl

theorem data_header (bs shape : List Nat) (h : (Dtype.ofCode dt).isSome = true) :
    ∃ v, dataValue bs (shape.map Int.ofNat) dt = some v ∧ v.dtype.code = dt ∧ v.shape = shape := by
  obtain ⟨d, hd⟩ := Option.isSome_iff_exists.mp h
  refine ⟨⟨d, shape, fun i => leWord bs d.bytes (i % extent shape)⟩, ?_, ofCode_some_code hd, rfl⟩
  have hs : ∀ shape : List Nat, natShape (shape.map Int.ofNat) = some shape := by
    intro sh
    induction sh with
    | nil => rfl
    | cons a l ih =>
      show natShape ((a : Int) :: l.map Int.ofNat) = some (a :: l)
      rw [natShape, ite_eq_left (Int.natCast_nonneg a), ih]
      simp
  simp [dataValue, hd, hs shape]

theorem valid_get (p : Code) (hp : Valid p) (h : p[i]? = some n) : validAt p i n = true := by
  simpa using allAt_get (validAt p) p 0 hp h

theorem evaluated (p : Code) (hp : Valid p) (hl : Leaves p weights) :
    ∀ (i : Nat) (n : Node), p[i]? = some n → ∃ v, value M K weights inputs p i = some v ∧ Header v n := by
  intro i
  induction i using Nat.strong_induction_on with
  | h i ih =>
    intro n hn
    have hv := valid_get p hp hn
    rcases n with ⟨op, ins, shape, dt⟩
    cases op with
    | load file key =>
      cases ins with
      | nil =>
        obtain ⟨v, hw, hh⟩ := hl i _ file key hn rfl
        exact ⟨v, (load_value M K weights inputs p hn).trans hw, hh⟩
      | cons a rest => simp [validAt] at hv
    | data bs =>
      cases ins with
      | nil =>
        obtain ⟨v, he, hd, hs⟩ := data_header bs shape (by simpa [validAt] using hv)
        exact ⟨v, (data_value M K weights inputs p hn).trans he, hd, hs⟩
      | cons a rest => simp [validAt] at hv
    | add =>
      cases ins with
      | nil => simp [validAt] at hv
      | cons a rest =>
        cases rest with
        | nil => simp [validAt] at hv
        | cons b tail =>
          cases tail with
          | cons c rest => simp [validAt] at hv
          | nil =>
            simp only [validAt, List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true, decide_eq_true_eq] at hv
            rcases hv with ⟨⟨ha, hb⟩, hv⟩
            cases hx : p[a]? with
            | none => simp [hx] at hv
            | some x =>
              cases hy : p[b]? with
              | none => simp [hx, hy] at hv
              | some y =>
                simp only [hx, hy, decide_eq_true_eq] at hv
                rcases hv with ⟨hxd, hyd, hys, hdt, hshape⟩
                obtain ⟨va, hva, hda, hsa⟩ := ih a ha x hx
                obtain ⟨vb, hvb, hdb, hsb⟩ := ih b hb y hy
                obtain ⟨w, hw, hwd, hws⟩ := add_exists va vb
                  (dtype_of_code (hda.trans hxd)) (dtype_of_code (hdb.trans hyd)) (Or.inr (hsb.trans hys))
                exact ⟨w, (add_value M K weights inputs p hn ha hb va vb hva hvb).trans hw,
                  by simpa [hwd, Dtype.code] using hdt.symm, hws.trans (hsa.trans hshape.symm)⟩
    | transpose axes =>
      cases ins with
      | nil => simp [validAt] at hv
      | cons a rest =>
        cases rest with
        | cons b tail => simp [validAt] at hv
        | nil =>
          simp only [validAt, List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true, decide_eq_true_eq] at hv
          rcases hv with ⟨ha, hv⟩
          cases hx : p[a]? with
          | none => simp [hx] at hv
          | some x =>
            simp only [hx, decide_eq_true_eq] at hv
            rcases hv with ⟨hlen, hperm, hdt, hshape⟩
            obtain ⟨va, hva, hda, hsa⟩ := ih a ha x hx
            have he : axes.length = va.shape.length ∧ (List.range va.shape.length).all (fun a => axes.contains a) = true := by simpa [hsa] using And.intro hlen hperm
            let sh := axes.map (fun a => va.shape.getD a 0)
            let w : Value := { va with shape := sh, elems := (fun i =>
              let out := unflat sh i
              let src := (List.range va.shape.length).map (fun a => out.getD (axes.idxOf a) 0)
              va.elems (flat va.shape src)) }
            refine ⟨w, (transpose_value M K weights inputs p hn ha va hva).trans ?_, hda.trans hdt.symm, ?_⟩
            · simp only [transpose, he, and_self, ↓reduceIte]; rfl
            · show axes.map (fun a => va.shape.getD a 0) = shape
              simpa [hsa] using hshape.symm
    | contiguous =>
      cases ins with
      | nil => simp [validAt] at hv
      | cons a rest =>
        cases rest with
        | cons b tail => simp [validAt] at hv
        | nil =>
          simp only [validAt, List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true, decide_eq_true_eq] at hv
          rcases hv with ⟨ha, hv⟩
          cases hx : p[a]? with
          | none => simp [hx] at hv
          | some x =>
            simp only [hx, decide_eq_true_eq] at hv
            obtain ⟨va, hva, hda, hsa⟩ := ih a ha x hx
            exact ⟨va, contiguous_value M K weights inputs p hn ha va hva, hda.trans hv.1.symm, hsa.trans hv.2.symm⟩

theorem no_inputs (p : Code) (G : Nat → Option (RNode Int InKey)) (cert : List Nat) :
    InputsHeld M K ⟨weights, inputs⟩ G (p.map Node.erase) cert := by
  intro k e key he hk
  cases hn : p[k]? with
  | none => simp [List.getElem?_map, hn] at he
  | some n =>
    have hem : n.erase = e := by simpa [List.getElem?_map, hn] using he
    subst e
    cases n with
    | mk op ins sh dt => cases op <;> cases hk

/-- Matching a checked load program transports its successful evaluation to
its actual graph carriers. All external assumptions are the named leaf loads. -/
theorem evaluated_actual (p : Code) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (hp : Valid p) (hl : Leaves p weights) (hm : Matches G (p.map Node.erase) cert = true)
    (hn : p[i]? = some n) :
    ∃ v, evalR M K ⟨weights, inputs⟩ G (certAt cert i) = some v ∧ Header v n := by
  have hi : i < p.length := by
    by_contra hn'
    simp [List.getElem?_eq_none (by omega : p.length ≤ i)] at hn
  obtain ⟨v, hv, hh⟩ := evaluated M K weights inputs p hp hl i n hn
  refine ⟨v, ?_, hh⟩
  exact (matches_eval M K ⟨weights, inputs⟩ G (p.map Node.erase) cert hm
    (no_inputs M K weights inputs p G cert) i (by simpa using hi)).trans hv

theorem matches_of_allAt (p : Code) (G : Nat → Option (RNode Int InKey)) (cert : List Nat)
    (h : allAt (fun i n => nodeOk G cert i n.erase) 0 p = true) :
    Matches G (p.map Node.erase) cert = true := by
  apply List.all_eq_true.mpr
  intro i hi
  have hil : i < p.length := by simpa using List.mem_range.mp hi
  have hn : p[i]? = some p[i] := List.getElem?_eq_getElem hil
  simp only [List.getElem?_map, hn, Option.map_some]
  simpa using allAt_get (fun i n => nodeOk G cert i n.erase) p 0 h hn

end Host.Load.Program
