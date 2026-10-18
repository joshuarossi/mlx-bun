import host.mlx.NativeAnnotations
import host.mlx.CachedInference

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

abbrev Metadata := List (Shape × Nat)
abbrev Metadata.Holds (ν : Nat → F64) (C : CSrv) :=
  ListR (fun (a : Shape × Nat) (b : List Dim × Nat) => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2)

/-- Geometry inferred by the original primitive and justified by one fixed
output annotation. The numeric table is not extended by these pure cases. -/
def PureInference (ν : Nat → F64) (C : CSrv) (output : Shape × Nat)
    (p : Prim) (inputs : List (List Dim × Nat)) : Prop :=
  ∃ shape, infer p inputs = M.pure (some (.node shape output.2)) ∧ Shape.Holds ν C output.1 shape

def Shape.Literal (roles : Shape) : Prop := listSupport (fun r => ∃ e, r = .literal e) roles

theorem Dimension.literal_unique {ν : Nat → F64} {C : CSrv} {e : SymE} {a b : Dim}
    (ha : Dimension.Holds ν C (.literal e) a) (hb : Dimension.Holds ν C (.literal e) b) : a = b := by
  cases ha with
  | literal _ i _ hi => cases hb with
    | literal _ j _ hj =>
      have he : i = j := Option.some.inj (hi.symm.trans hj)
      rw [he]

theorem Shape.literal_unique {ν : Nat → F64} {C : CSrv} {roles : Shape} {a b : List Dim}
    (literal : roles.Literal) (ha : Shape.Holds ν C roles a) (hb : Shape.Holds ν C roles b) : a = b := by
  induction ha generalizing b with
  | nil => cases hb; rfl
  | cons hh ht ih =>
    cases hb with
    | cons hh' ht' =>
      obtain ⟨e,he⟩ := literal.1
      subst he
      rw [Dimension.literal_unique hh hh',ih literal.2 ht']

theorem Shape.split {ν : Nat → F64} {C : CSrv} (a b : Shape) (shape : List Dim)
    (h : Shape.Holds ν C (a++b) shape) :
    ∃ as bs, shape = as++bs ∧ Shape.Holds ν C a as ∧ Shape.Holds ν C b bs := by
  induction a generalizing shape with
  | nil => exact ⟨[],shape,rfl,.nil,h⟩
  | cons r rs ih =>
    cases h with
    | cons hh ht =>
      obtain ⟨as,bs,he,ha,hb⟩ := ih _ ht
      exact ⟨_::as,bs,congrArg (_ :: ·) he,.cons hh ha,hb⟩

theorem Metadata.single {ν : Nat → F64} {C : CSrv} {roles : Shape} {dt : Nat}
    {inputs : List (List Dim × Nat)}
    (h : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(roles,dt)] inputs) :
    ∃ shape, inputs = [(shape,dt)] ∧ Shape.Holds ν C roles shape := by
  cases h with
  | @cons a b as bs hh ht =>
    cases ht
    rcases b with ⟨shape,d⟩
    rcases hh with ⟨hs,hd⟩
    dsimp only at hd hs
    subst d
    exact ⟨shape,rfl,hs⟩

theorem Metadata.pair {ν : Nat → F64} {C : CSrv} {a b : Shape} {da db : Nat}
    {inputs : List (List Dim × Nat)}
    (h : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(a,da),(b,db)] inputs) :
    ∃ sa sb, inputs = [(sa,da),(sb,db)] ∧ Shape.Holds ν C a sa ∧ Shape.Holds ν C b sb := by
  cases h with
  | @cons x y xs ys hh ht =>
    obtain ⟨sb,he,hb⟩ := Metadata.single ht
    rcases y with ⟨sa,d⟩
    rcases hh with ⟨ha,hd⟩
    dsimp only at hd ha
    subst d
    exact ⟨sa,sb,congrArg ((sa,da) :: ·) he,ha,hb⟩

theorem unary {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : Shape} {dt : Nat}
    (op : List Char) {p : Prim} {inputs : List (List Dim × Nat)}
    (hp : Primitive.Holds ν C R (.unary op) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(roles,dt)] inputs) :
    PureInference ν C (roles,unaryDtype op dt) p inputs := by
  cases hp
  obtain ⟨shape,he,hs⟩ := Metadata.single hi
  subst inputs
  exact ⟨shape,rfl,hs⟩

theorem astype {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : Shape} {dt : Nat}
    (dtype : Nat) {p : Prim} {inputs : List (List Dim × Nat)}
    (hp : Primitive.Holds ν C R (.astype dtype) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(roles,dt)] inputs) :
    PureInference ν C (roles,dtype) p inputs := by
  cases hp
  obtain ⟨shape,he,hs⟩ := Metadata.single hi
  subst inputs
  exact ⟨shape,rfl,hs⟩

theorem binary_same {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : Shape} {da db : Nat}
    (op : List Char) {p : Prim} {inputs : List (List Dim × Nat)}
    (literal : roles.Literal) (hp : Primitive.Holds ν C R (.binary op) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(roles,da),(roles,db)] inputs) :
    PureInference ν C (roles,binaryDtype op da db) p inputs := by
  cases hp
  obtain ⟨a,b,he,ha,hb⟩ := Metadata.pair hi
  subst inputs
  have eq := Shape.literal_unique literal ha hb
  subst b
  refine ⟨a,?_,ha⟩
  simp only [infer,InferenceRoles.broadcast_same]
  rfl

theorem binary_scalar {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : Shape} {da db : Nat}
    (op : List Char) {p : Prim} {inputs : List (List Dim × Nat)}
    (hp : Primitive.Holds ν C R (.binary op) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(roles,da),([],db)] inputs) :
    PureInference ν C (roles,binaryDtype op da db) p inputs := by
  cases hp
  obtain ⟨a,b,he,ha,hb⟩ := Metadata.pair hi
  cases hb
  subst inputs
  refine ⟨a,?_,ha⟩
  simp only [infer,InferenceRoles.broadcast_scalar]
  rfl

theorem binary_suffix {ν : Nat → F64} {C : CSrv} {R : Ren} {roles leading : Shape} {da db : Nat}
    (op : List Char) {p : Prim} {inputs : List (List Dim × Nat)}
    (literal : roles.Literal) (hp : Primitive.Holds ν C R (.binary op) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2)
      [(roles,da),(leading++roles,db)] inputs) :
    PureInference ν C (leading++roles,binaryDtype op da db) p inputs := by
  cases hp
  obtain ⟨a,b,he,ha,hb⟩ := Metadata.pair hi
  obtain ⟨bs,as,hsplit,hbs,has⟩ := Shape.split leading roles b hb
  have eq := Shape.literal_unique literal ha has
  subst as
  subst inputs
  rw [hsplit]
  refine ⟨bs++a,?_,hbs.append ha⟩
  simp only [infer,InferenceRoles.broadcast_suffix]
  rfl

def one : Dimension := .literal (.lit (F64.ofInt 1))

theorem one_holds (ν : Nat → F64) (C : CSrv) : one.Holds ν C (.lit 1) :=
  .literal _ 1 rfl rfl

theorem logsumexp_keep {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : Shape} {dt : Nat}
    (axis : Nat) {p : Prim} {inputs : List (List Dim × Nat)}
    (bound : axis < len roles) (hp : Primitive.Holds ν C R (.logsumexp axis true) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [(roles,dt)] inputs) :
    PureInference ν C (setAt roles axis one,atLeastFloat dt) p inputs := by
  cases hp
  obtain ⟨shape,he,hs⟩ := Metadata.single hi
  subst inputs
  have hb : Nat.blt axis (len shape) = true := by rw [← hs.len_eq,Nat.blt_eq]; exact bound
  refine ⟨setAt shape axis (.lit 1),?_,InferenceRoles.setAt_roles hs (one_holds ν C) axis⟩
  simp only [infer,hb]
  rfl

theorem reshape_one {ν : Nat → F64} {C : CSrv} {R : Ren} {dt : Nat}
    {p : Prim} {inputs : List (List Dim × Nat)}
    (hp : Primitive.Holds ν C R (.reshape [one]) p)
    (hi : ListR (fun a b => Shape.Holds ν C a.1 b.1 ∧ b.2 = a.2) [([one],dt)] inputs) :
    PureInference ν C ([one],dt) p inputs := by
  have lit : Shape.Literal [one] := ⟨⟨_,rfl⟩,True.intro⟩
  have ones : Shape.Holds ν C [one] [.lit 1] := .cons (one_holds ν C) .nil
  cases hp with
  | reshape hn =>
    have he := Shape.literal_unique lit hn ones
    subst he
    obtain ⟨shape,hi',hs⟩ := Metadata.single hi
    have hs' := Shape.literal_unique lit hs ones
    subst shape
    subst inputs
    exact ⟨[.lit 1],InferenceRoles.reshape_singleton_one dt,ones⟩

end Host.Mlx.Ffi.Annotated
