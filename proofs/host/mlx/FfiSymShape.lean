import host.mlx.Ffi
namespace Host.Mlx.Ffi.SymShape
open Host.Ts

/-! # Symbolic shapes: a layer over the mlx-c model

Three calls `Ffi.call` leaves stuck when a dimension is a number of the run's
server (`Dim.sym`), which a prompt of symbolic length reaches. `callSym` is
`Ffi.call` where that is defined (`callSym_eq`), and otherwise `symShapeCall`,
which completes only these:

* `mlx_array_size` of a shape with a symbolic dimension: the product (`dProd`),
  as a number (`Ret.num`; `Ret.big` if the product is a literal). The route
  reads it through `Number` (array.ts:238).
* `mlx_conv1d` over a symbolic input length at stride 1: length
  `l + 2·padding − dilation·(k − 1)` (MLX `conv_out_shape`), after a server
  test that it is positive (MLX rejects a non-positive output length).
* `mlx_reshape` with `-1` over a symbolic product: the given dimensions are cut from the
  input's, as its leading dimensions where they equal them (`allEq`: syntactically equal pairs
  need no request, the others a server test), otherwise as a multiset, syntactically
  (`cancelDims`, `reshapeCancel`). After a server test that their product is positive
  (`Reshape::output_shape` divides by it), the inferred dimension is the product of the rest:
  MLX's `ldiv` quotient, exactly. On a syntactic prefix the cut is the multiset cancellation's
  (`inferSym_prefix`); where the leading dimensions differ, the multiset cancellation follows
  (`inferSym_reshape_eq`). -/

def isSym : Dim → Bool
  | .sym _ => true
  | .lit _ => false

/-- `xs` without one occurrence of `d` (syntactic dimension equality). -/
def eraseDim (d : Dim) : List Dim → Option (List Dim)
  | [] => none
  | x :: xs => bif decide (x = d) then some xs else (eraseDim d xs).map (x :: ·)

/-- `xs` without one occurrence of each of `ds`. -/
def cancelDims (xs : List Dim) : List Dim → Option (List Dim)
  | [] => some xs
  | d :: ds => (eraseDim d xs).bind fun ys => cancelDims ys ds

/-- A reshape's output once its given dimensions `gv` were cut to `rs`. -/
def reshapeRest (nw gv rs : List Dim) (d : Nat) : M (Option Out) :=
  .bind (dProd gv) fun p => .bind (dLt (.lit 0) p) fun pos =>
    bif pos then .bind (dProd rs) fun q =>
      .pure (some (.node (nw.map fun x => bif decide (x = .lit (-1)) then q else x) d))
    else .pure none

/-- A reshape's output with its given dimensions `gv` cancelled from `old` as a multiset. -/
def reshapeCancel (nw gv old : List Dim) (d : Nat) : M (Option Out) :=
  match cancelDims old gv with
  | some rest => reshapeRest nw gv rest d
  | none => .pure none

/-- Shape inference where `infer` is stuck on symbolic dimensions. -/
def inferSym : Prim → List (List Dim × Nat) → M (Option Out)
  | .reshape new, [(old, d)] =>
    let given := new.filter (· ≠ .lit (-1))
    bif !(old ++ new).any isSym || !Nat.beq (len (new.filter (· = .lit (-1)))) 1 then .pure none else
    .bind (allEq (old.take given.length) given) fun pre =>
      bif pre then reshapeRest new given (old.drop given.length) d else reshapeCancel new given old d
  | .conv1d stride pad dil groups, [(x, dx), (w, dw)] => match x, w with
    | [n, .sym lx, .lit c], [o, .lit k, .lit ci] =>
      bif decide (stride = 1 ∧ 0 < groups ∧ c = ci * groups) then
        .bind (dSub (.sym lx) (.lit (dil * (k - 1) - 2 * pad))) fun lo =>
        .bind (dLt (.lit 0) lo) fun pos =>
        .pure (bif pos then some (.node [n, lo, o] (promote dx dw)) else none)
      else .pure none
    | _, _ => .pure none
  | _, _ => .pure none

/-- `opOut` with `inferSym`. -/
def opOutSym (s : St) (o : Arg) (p : Prim) (ins : List Nat) : R :=
  match slotOf o, shapesOf s ins with
  | some (b, off, slot), some sh => .bind (inferSym p sh) fun
    | some (.node shape dt) =>
      let (n, s) := s.addNode ⟨p, ins, shape, dt⟩
      let (h, s) := s.setArr slot n
      okW s status0 [u64Write b off h]
    | _ => stuck
  | _, _ => stuck

/-- The layer's calls (stuck except the three above). -/
def symShapeCall (s : St) (name : Name) (args : List Arg) : R :=
  match symOf name, args with
  | some .arraySize, [h] => match (argNat h).bind s.node? with
    | some n => bif n.shape.any isSym then .bind (dProd n.shape) fun
        | .lit i => ok s (.big i)
        | .sym x => ok s (.num x)
      else stuck
    | none => stuck
  | some .reshape, [o, a, sh, n, _] => match arrIns s [a], dimsArg sh n with
    | some ins, some shape => opOutSym s o (.reshape shape) ins
    | _, _ => stuck
  | some .conv1d, [o, x, w, st, pd, dl, gr, _] =>
    match arrIns s [x, w], argNat st, argNat pd, argNat dl, argNat gr with
    | some ins, some st, some pd, some dl, some gr => opOutSym s o (.conv1d st pd dl gr) ins
    | _, _, _, _, _ => stuck
  | _, _ => stuck

/-- The model's call, completed by the layer where the model is stuck. -/
def callSym (s : St) (name : Name) (args : List Arg) : R :=
  .bind (call s name args) fun
    | some r => .pure (some r)
    | none => symShapeCall s name args

/-- **Agreement.** `callSym` runs `Ffi.call`, continuing with its result where it is defined. -/
theorem callSym_eq (s : St) (name : Name) (args : List Arg) (γ : Type)
    (k : Option (St × Ret × List (Nat × Nat × List Byte)) → Free γ) :
    callSym s name args γ k =
      call s name args γ (fun | some r => k (some r) | none => symShapeCall s name args γ k) := by
  unfold callSym M.bind
  congr 1
  funext o
  cases o <;> rfl

theorem dEq_refl (x : Dim) : dEq x x = .pure true := by
  cases x with
  | lit i => show M.pure (decide (i = i)) = _; simp
  | sym v => show (bif decide (Dim.sym v = Dim.sym v) then M.pure true else _) = _; simp

theorem allEq_refl : ∀ xs : List Dim, allEq xs xs = .pure true
  | [] => rfl
  | x :: xs => by
    show M.bind (dEq x x) (fun e => bif e then allEq xs xs else .pure false) = _
    rw [dEq_refl, allEq_refl xs]
    rfl

theorem cancelDims_append : ∀ (ds rs : List Dim), cancelDims (ds ++ rs) ds = some rs
  | [], _ => rfl
  | d :: ds, rs => by
    show (eraseDim d (d :: (ds ++ rs))).bind (fun ys => cancelDims ys ds) = some rs
    have : eraseDim d (d :: (ds ++ rs)) = some (ds ++ rs) := by simp [eraseDim]
    rw [this]; exact cancelDims_append ds rs

/-- The layer's reshape: the leading cut, then the multiset cancellation. -/
theorem inferSym_reshape_eq (new old : List Dim) (d : Nat) :
    inferSym (.reshape new) [(old, d)] =
      bif !(old ++ new).any isSym || !Nat.beq (len (new.filter (· = .lit (-1)))) 1 then .pure none
      else .bind (allEq (old.take (new.filter (· ≠ .lit (-1))).length) (new.filter (· ≠ .lit (-1)))) fun pre =>
        bif pre then reshapeRest new (new.filter (· ≠ .lit (-1))) (old.drop (new.filter (· ≠ .lit (-1))).length) d
        else reshapeCancel new (new.filter (· ≠ .lit (-1))) old d := rfl

/-- **Agreement on a syntactic prefix** (every accepted reshape): the leading cut is the multiset
cancellation's, with no request. -/
theorem inferSym_prefix {new rest : List Dim} {d : Nat} :
    inferSym (.reshape new) [(new.filter (· ≠ .lit (-1)) ++ rest, d)] =
      bif !((new.filter (· ≠ .lit (-1)) ++ rest) ++ new).any isSym ||
          !Nat.beq (len (new.filter (· = .lit (-1)))) 1 then .pure none
      else reshapeCancel new (new.filter (· ≠ .lit (-1))) (new.filter (· ≠ .lit (-1)) ++ rest) d := by
  rw [inferSym_reshape_eq, List.take_left, List.drop_left, allEq_refl]
  unfold reshapeCancel
  rw [cancelDims_append]
  rfl

/-- **Agreement where the leading dimensions differ without a request**: the multiset cancellation,
as before. (With requests, `inferSym_reshape_eq`: a `false` answer continues with it.) -/
theorem inferSym_noPrefix {new old : List Dim} {d : Nat}
    (h : allEq (old.take (new.filter (· ≠ .lit (-1))).length) (new.filter (· ≠ .lit (-1))) = .pure false) :
    inferSym (.reshape new) [(old, d)] =
      bif !(old ++ new).any isSym || !Nat.beq (len (new.filter (· = .lit (-1)))) 1 then .pure none
      else reshapeCancel new (new.filter (· ≠ .lit (-1))) old d := by
  rw [inferSym_reshape_eq, h]
  rfl

end Host.Mlx.Ffi.SymShape
