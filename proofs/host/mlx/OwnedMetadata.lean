import host.mlx.OwnedFfi
import host.ts.RenameParametricState

set_option maxRecDepth 1000000
set_option Elab.async false

namespace Host.Mlx.Ffi.Parametric
open Host.Ts Host.Ts.Owned
open Host.Ts.Owned.Parametric

/-- Dimensions are related by their numeric meaning, independently of native
handle renaming. Literal capacities may differ between the two executions. -/
abbrev ShapeR (NR : NumV → NumV → Prop) :=
  ListR (fun d d' : Dim => NR d.num d'.num)

theorem cellParts_roles {NR : NumV → NumV → Prop} {R : Ren} {c c' : Cell}
    (hc : Host.Ts.Owned.Parametric.CellR NR R c c') (k : EltK) : ∀ n i,
    ListR (Host.Ts.Owned.Parametric.ByteR NR R) (cellParts k c n i) (cellParts k c' n i)
  | 0, _ => .nil
  | n+1, i => .cons (.part k i hc) (cellParts_roles hc k n (i+1))

theorem shapeBytes_roles {NR : NumV → NumV → Prop} (R : Ren) {shape shape' : List Dim}
    (h : ShapeR NR shape shape') :
    ListR (Host.Ts.Owned.Parametric.ByteR NR R) (shapeBytes shape) (shapeBytes shape') := by
  induction h with
  | nil => exact .nil
  | cons hd _ ih =>
    exact (cellParts_roles (.num hd) .i32 4 0).append ih

/-- Native metadata reads preserve a potentially noninjective numeric relation.
Both pointer regions are derived from the actual owned handle. -/
theorem read_shape_roles {NR : NumV → NumV → Prop} (R : Ren) (s s' : St) (h : Nat)
    (n n' : Node) (hn : s.node? h = some n) (hn' : s'.node? (R.handle h) = some n')
    (hshape : ShapeR NR n.shape n'.shape) (off count : Nat) :
    ∃ bs bs', read s (4*h) off count = some bs ∧
      read s' (4 * R.handle h) off count = some bs' ∧
      ListR (Host.Ts.Owned.Parametric.ByteR NR R) bs bs' := by
  refine ⟨_, _, Owned.read_shape s h n hn off count,
    Owned.read_shape s' _ n' hn' off count, ?_⟩
  exact ((shapeBytes_roles R hshape).drop off).take count

theorem call_size (s : St) (h : Nat) (n : Node) (ds : List Nat)
    (hn : s.node? h = some n) (hd : natsOfDims n.shape = some ds) :
    call s chars!"mlx_array_size" [.big (Int.ofNat h)] =
      M.pure (some (s, Ret.big (Int.ofNat (ds.foldr (·*·) 1)), [])) := by
  have hs : symOf chars!"mlx_array_size" = some .arraySize := by decide +kernel
  unfold call
  rw [hs]
  simp only [argNat_big_nat, Option.bind_some, hn, hd, ok]
  rfl

/-- The size result is integer data subsequently converted by `Number`,
independently of any equal-valued native handle. Its numeric relation records
the actual rounded binary64 conversion of each integer product. -/
theorem call_size_roles {NR : NumV → NumV → Prop} (R : Ren) (s s' : St) (h : Nat)
    (n n' : Node) (ds ds' : List Nat)
    (hn : s.node? h = some n) (hn' : s'.node? (R.handle h) = some n')
    (hd : natsOfDims n.shape = some ds) (hd' : natsOfDims n'.shape = some ds')
    (size : NR (.lit (F64.ofInt (Int.ofNat (ds.foldr (·*·) 1))))
      (.lit (F64.ofInt (Int.ofNat (ds'.foldr (·*·) 1))))) :
    call s chars!"mlx_array_size" [.big (Int.ofNat h)] =
        M.pure (some (s, Ret.big (Int.ofNat (ds.foldr (·*·) 1)), [])) ∧
      call s' chars!"mlx_array_size" [.big (Int.ofNat (R.handle h))] =
        M.pure (some (s', Ret.big (Int.ofNat (ds'.foldr (·*·) 1)), [])) ∧
      Host.Ts.Owned.Parametric.TreeR NR R
        (Host.Ts.Owned.Parametric.ret (.big (Int.ofNat (ds.foldr (·*·) 1))))
        (Host.Ts.Owned.Parametric.ret (.big (Int.ofNat (ds'.foldr (·*·) 1)))) := by
  refine ⟨call_size s h n ds hn hd, call_size s' _ n' ds' hn' hd', ?_⟩
  exact .node _ (.cons (.value (.numericInteger size)) .nil)

end Host.Mlx.Ffi.Parametric

namespace Host.Load.Parametric
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi

/-- Exact paired source getters followed by the dimension's numeric relation.
The relation may pair a symbolic number with a literal, or distinct literals. -/
theorem typedGet_shape_roles {NR : NumV → NumV → Prop} (R : Ren)
    (s s' : Host.Ts.St LSt) (b h i : Nat) (bo bo' : Host.Ts.Obj) (n n' : Node) (d d' : Dim)
    (ho : s.obj? b = some bo) (ho' : s'.obj? (R.a b) = some bo')
    (hk : bo.kind = .extBuf (4*h) 0 (len n.shape * 4))
    (hk' : bo'.kind = .extBuf (4 * R.handle h) 0 (len n'.shape * 4))
    (hn : s.ffi.mlx.node? h = some n) (hn' : s'.ffi.mlx.node? (R.handle h) = some n')
    (hi : nth? n.shape i = some d) (hi' : nth? n'.shape i = some d')
    (hb : Nat.blt i (len n.shape) = true) (hb' : Nat.blt i (len n'.shape) = true)
    (hd : NR d.num d'.num) :
    typedGet ffi s .i32 b 0 (len n.shape) i = M.pure (some (.data (.num d.num) true true)) ∧
      typedGet ffi s' .i32 (R.a b) 0 (len n'.shape) i = M.pure (some (.data (.num d'.num) true true)) ∧
      Host.Ts.Owned.Parametric.ValueR NR R (.num d.num) (.num d'.num) :=
  ⟨Owned.typedGet_shape_dimension s b h i bo n d ho hk hn hi hb,
    Owned.typedGet_shape_dimension s' (R.a b) (R.handle h) i bo' n' d' ho' hk' hn' hi' hb', .num hd⟩

end Host.Load.Parametric
