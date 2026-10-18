import host.mlx.ReplayInference
import host.mlx.QuantizedInference

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def signatureMatch : List (List Dim × Nat) → List (List Dim × Nat) → Bool
  | [], [] => true
  | (sa,da)::ra, (sb,db)::rb =>
      bif !(Nat.beq da db) || !(Nat.beq (len sa) (len sb)) then false else signatureMatch ra rb
  | _, _ => false

theorem signatureMatch_roles {NR : NumV → NumV → Prop}
    {as as' bs bs' : List (List Dim × Nat)}
    (ha : ListR (fun a b : List Dim × Nat => Parametric.ShapeR NR a.1 b.1 ∧ b.2 = a.2) as as')
    (hb : ListR (fun a b : List Dim × Nat => Parametric.ShapeR NR a.1 b.1 ∧ b.2 = a.2) bs bs') :
    signatureMatch as' bs' = signatureMatch as bs := by
  induction ha generalizing bs bs' with
  | nil => cases hb <;> rfl
  | @cons a a' as as' hmeta hrest ih =>
    cases hb with
    | nil => rfl
    | @cons b b' bs bs' hbmeta hbrest =>
      rcases a with ⟨sa,da⟩
      rcases a' with ⟨sa',da'⟩
      rcases b with ⟨sb,db⟩
      rcases b' with ⟨sb',db'⟩
      rcases hmeta with ⟨hsa,hda⟩
      rcases hbmeta with ⟨hsb,hdb⟩
      dsimp only at hda hdb
      subst da'; subst db'
      simp only [signatureMatch]
      rw [← hsa.len_eq,← hsb.len_eq,ih hbrest]

theorem traceFits_go_shapeless : ∀ as bs : List (List Dim × Nat),
    traceFits.go true as bs = M.pure (signatureMatch as bs) := by
  intro as
  induction as with
  | nil => intro bs; cases bs <;> rfl
  | cons a as ih =>
    intro bs
    rcases a with ⟨sa,da⟩
    cases bs with
    | nil => rfl
    | cons b bs =>
      rcases b with ⟨sb,db⟩
      cases hg : (!(Nat.beq da db) || !(Nat.beq (len sa) (len sb)))
      · simpa only [traceFits.go,signatureMatch,hg,Bool.cond_false,Bool.cond_true] using ih bs
      · simp only [traceFits.go,signatureMatch,hg]; rfl

theorem traceFits_shapeless (s : St) (t : Trace) (xs : List Nat)
    (as bs : List (List Dim × Nat))
    (ha : shapesOf s t.ins = some as) (hb : shapesOf s xs = some bs) :
    traceFits s true t xs = M.pure (signatureMatch as bs) := by
  unfold traceFits
  rw [ha,hb]
  exact traceFits_go_shapeless as bs

/-- Shapeless trace selection compares only dtype and rank. Numeric dimensions
may have different meanings or literal capacities in the two executions. -/
theorem Live.traceFits_shapeless {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (t t' : Trace) (ht : TraceR R t t') (xs : List Nat) (as bs : List (List Dim × Nat))
    (ha : Ffi.shapesOf s t.ins = some as) (hb : Ffi.shapesOf s xs = some bs)
    (ta : listSupport N t.ins) (tb : listSupport N xs) :
    traceFits s true t xs = M.pure (signatureMatch as bs) ∧
      traceFits s' true t' (xs.map R.node) = M.pure (signatureMatch as bs) := by
  have nodeMetadata : ∀ i n n', NodeR NR R (PrimR NR R) boundary i n n' →
      Parametric.ShapeR NR n.shape n'.shape ∧ n'.dtype = n.dtype := by
    intro i n n' hr; exact ⟨hr.shape,hr.dtype⟩
  obtain ⟨as',ha',hra⟩ := h.shapesOf nodeMetadata t.ins as ta ha
  obtain ⟨bs',hb',hrb⟩ := h.shapesOf nodeMetadata xs bs tb hb
  have target : Ffi.shapesOf s' t'.ins = some as' := by rw [ht.ins]; exact ha'
  refine ⟨NativeRoles.traceFits_shapeless s t xs as bs ha hb,?_⟩
  rw [NativeRoles.traceFits_shapeless s' t' (xs.map R.node) as' bs' target hb',signatureMatch_roles hra hrb]

theorem traceFits_go_fixed_self : ∀ as : List (List Dim × Nat), traceFits.go false as as = M.pure true := by
  intro as
  induction as with
  | nil => rfl
  | cons a as ih =>
    rcases a with ⟨shape,dt⟩
    have hd : Nat.beq dt dt = true := by simp only [Nat.beq_refl]
    have hs : Nat.beq (len shape) (len shape) = true := by simp only [Nat.beq_refl]
    simp only [traceFits.go,hd,hs,InferenceRoles.allEq_self]
    exact ih

theorem traceFits_fixed_self (s : St) (t : Trace) (xs : List Nat) (as : List (List Dim × Nat))
    (ha : shapesOf s t.ins = some as) (hb : shapesOf s xs = some as) :
    traceFits s false t xs = M.pure true := by
  unfold traceFits
  rw [ha,hb]
  exact traceFits_go_fixed_self as

/-- First-match trace selection agrees for shapeless compiled closures. All
trace input nodes are explicit live resources with defined source metadata. -/
theorem Live.findTrace_shapeless {NR : NumV → NumV → Prop} {R : Ren} {boundary : Nat → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R (NodeR NR R (PrimR NR R) boundary) (fun _ => ObjectR NR R) H N tail s s')
    (xs : List Nat) (inputs : List (List Dim × Nat))
    (hx : listSupport N xs) (hi : Ffi.shapesOf s xs = some inputs)
    {ts ts' : List Trace} (traces : ListR (TraceR R) ts ts')
    (valid : listSupport (fun t : Trace => listSupport N t.ins ∧
      ∃ metadata, Ffi.shapesOf s t.ins = some metadata) ts) :
    ∃ result result', findTrace s true xs ts = M.pure result ∧
      findTrace s' true (xs.map R.node) ts' = M.pure result' ∧ OptionR (TraceR R) result result' := by
  induction traces with
  | nil => exact ⟨none,none,rfl,rfl,.none⟩
  | @cons t t' ts ts' ht hrest ih =>
    obtain ⟨metadata,hm⟩ := valid.1.2
    have fits := h.traceFits_shapeless t t' ht xs metadata inputs hm hi valid.1.1 hx
    obtain ⟨r,r',hr,hr',hrole⟩ := ih valid.2
    cases hg : signatureMatch metadata inputs
    · refine ⟨r,r',?_,?_,hrole⟩
      · simp only [findTrace,fits.1,hg]
        exact hr
      · simp only [findTrace,fits.2,hg]
        exact hr'
    · refine ⟨some t,some t',?_,?_,.some ht⟩
      · simp only [findTrace,fits.1,hg]; rfl
      · simp only [findTrace,fits.2,hg]; rfl

/-- The cached path of the actual compiled-closure dispatcher. The trace choice
is supplied by `findTrace`'s checked result; replay remains the original call. -/
theorem closureApply_cached (s : St) (out : Arg) (b off slot cls inv cb : Nat)
    (payload : Arg) (shapeless : Bool) (traces : List Trace) (xs : List Nat) (t : Trace)
    (ho : slotOf out = some (b,off,slot))
    (hc : s.obj? cls = some (.clo (.compiled cb payload shapeless traces)))
    (hi : s.obj? inv = some (.vec xs))
    (ht : findTrace s shapeless xs traces = M.pure (some t)) :
    closureApply s out (.big (Int.ofNat cls)) (.big (Int.ofNat inv)) =
      applyDone s cls b off slot t xs := by
  unfold closureApply
  simp only [ho,argNat_big_nat,Option.bind_some,hc,hi,ht]
  rfl

end Host.Mlx.Ffi.NativeRoles
