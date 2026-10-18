import host.ts.RenameStateRoles
import host.ts.StoreLaws
namespace Host.Ts.Owned

/-- Ordinary JS reference closure. Encoded bigint pointers are followed by the
specific pointer operation's role signature and explicitly selected buffer slot;
arithmetic bigint bits are not interpreted as pointers by this predicate. -/
def valueSupport (live : Nat → Prop) : Val → Prop
  | .obj a => live a
  | .sym a => a < 16 ∨ live (a - 16)
  | .ptr (.js b) _ => live b
  | _ => True

mutual
  def treeSupport (live : Nat → Prop) : Tree → Prop
    | .atom _ _ => True
    | .value v => valueSupport live v
    | .cell _ => True
    | .byte _ => True
    | .address a => live a
    | .symbol a => a < 16 ∨ live (a - 16)
    | .region _ => True
    | .number _ => True
    | .node _ fs => forestSupport live fs
  def forestSupport (live : Nat → Prop) : List Tree → Prop
    | [] => True
    | f :: fs => treeSupport live f ∧ forestSupport live fs
end

def listSupport {α : Type} (support : α → Prop) : List α → Prop
  | [] => True
  | a :: as => support a ∧ listSupport support as

inductive RetR (R : Ren) : Ret → Ret → Prop where
  | void : RetR R .void .void
  | num (n : NumV) : RetR R (.num n) (.num (R.num n))
  | ordinaryBig (i : Int) : RetR R (.big i) (.big i)
  | handle (h : Nat) : RetR R (.big (Int.ofNat h)) (.big (Int.ofNat (R.handle h)))
  | bool (b : Bool) : RetR R (.bool b) (.bool b)
  | ptr (r off : Nat) : RetR R (.ptr r off) (.ptr (R.region r) off)
  | null : RetR R .null .null
  | cstr (s : List Char) : RetR R (.cstr s) (.cstr s)
  | callback (r : Nat) {as bs : List Arg} : ListR (ArgR R) as bs →
      RetR R (.callback r as) (.callback (R.region r) bs)

structure EventR (R : Ren) (e e' : Event) : Prop where
  name : e'.sym = e.sym
  args : ListR (ArgR R) e.args e'.args
  result : RetR R e.ret e'.ret

def Encode.header (o : Obj) : Tree := .node "Obj.header" [Encode.val o.proto,Encode.props o.props,
  Encode.seq (o.priv.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p]),
  Encode.atom o.extensible]

/-- The old array prefix is an output frame; reachability follows only its
header and the newly appended suffix. Every other selected slot is related with
its occurrence roles, including absence. -/
inductive SlotR (R : Ren) (live framed : Nat → Prop) (before after : List Val) (a : Nat) :
    Option HObj → Option HObj → Prop where
  | absent : ¬ framed a → SlotR R live framed before after a none none
  | regular {h h' : HObj} (hf : ¬ framed a) (hr : HeapObjectR R h h') :
      treeSupport live (Encode.hobj h) → SlotR R live framed before after a (some h) (some h')
  | framed {o o' : Obj} {xs ys : List Val} (hf : framed a)
      (hk : o.kind = .array (before ++ xs)) (hk' : o'.kind = .array (after ++ ys))
      (hv : ListR (ValueR R) xs ys) (hh : TreeR R (Encode.header o) (Encode.header o')) :
      listSupport (valueSupport live) xs → treeSupport live (Encode.header o) →
      SlotR R live framed before after a (some (.obj o)) (some (.obj o'))

structure HeapR {S : Type} (R : Ren) (live framed : Nat → Prop) (before after : List Val)
    (s s' : St S) : Prop where
  lookup : ∀ a, live a → SlotR R live framed before after a (s.heap.get a) (s'.heap.get (R.a a))
  sourceBound : ∀ a, live a → a < s.next
  targetBound : ∀ a, live a → R.a a < s'.next
  prefixLive : ∀ a, framed a → live a
  inj : ∀ a b, live a → live b → R.a a = R.a b → a = b
  fresh : ∀ k, R.a (s.next + k) = s'.next + k

/-- A complete runtime boundary relation. Operation rules still discharge the
role signatures of the encountered source operation; this definition does not
assert a universal interpreter equivariance theorem. -/
structure StateR {S : Type} (FR : Ren → S → S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (oldTrace oldTrace' : List Event) (s s' : St S) : Prop where
  heap : HeapR R live framed before after s s'
  control : ControlR R s.ctl s'.ctl
  controlLive : treeSupport live (Encode.ctl s.ctl)
  stack : ListR (FrameR R) s.stack s'.stack
  stackLive : listSupport (fun f => treeSupport live (Encode.frame f)) s.stack
  jobs : ListR (fun j j' => TreeR R (Encode.job j) (Encode.job j')) s.jobs s'.jobs
  jobsLive : listSupport (fun j => treeSupport live (Encode.job j)) s.jobs
  stores : TreeR R (Encode.stores s.stores) (Encode.stores s'.stores)
  storesLive : treeSupport live (Encode.stores s.stores)
  native : FR R s.ffi s'.ffi
  trace : ∃ fresh fresh', s.trace = fresh ++ oldTrace ∧ s'.trace = fresh' ++ oldTrace' ∧
    ListR (EventR R) fresh fresh'

namespace StateR
variable {S : Type} {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
  {before after : List Val} {old old' : List Event} {s s' : St S}

theorem go (h : StateR FR R live framed before after old old' s s')
    {c c' : Ctl} (hc : ControlR R c c') (hs : treeSupport live (Encode.ctl c)) :
    StateR FR R live framed before after old old' (s.go c) (s'.go c') :=
  ⟨⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,
    hc,hs,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

theorem restack (h : StateR FR R live framed before after old old' s s')
    {fs fs' : List Frame} (hf : ListR (FrameR R) fs fs') (hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs) :
    StateR FR R live framed before after old old' {s with stack := fs} {s' with stack := fs'} :=
  ⟨⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,
    h.control,h.controlLive,hf,hl,h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

end StateR

/-- Ordinary bigint shift is a complete source and target machine step preserving
all runtime components and role-sensitive reachability. Native handle renaming
is independent of the large intermediate result. -/
theorem step_bigShl_state (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s s' : St F.S) (h : StateR FR R live framed before after old old' s s')
    (a : Int) (b : Nat) (fs fs' : List Frame)
    (hc : s.ctl = .ret (.big (Int.ofNat b))) (hc' : s'.ctl = .ret (.big (Int.ofNat b)))
    (hf : s.stack = .e (.binR .shl (.big a)) :: fs)
    (hf' : s'.stack = .e (.binR .shl (.big a)) :: fs') :
    let t := ({s with stack := fs}.ret (.big (a * (2 ^ b : Nat))))
    let t' := ({s' with stack := fs'}.ret (.big (a * (2 ^ b : Nat))))
    step F s = M.pure t ∧ step F s' = M.pure t' ∧
      StateR FR R live framed before after old old' t t' := by
  dsimp only
  obtain ⟨hs,hs',hv⟩ := step_bigShl F R s s' a b fs fs' hc hc' hf hf'
  refine ⟨hs,hs',?_⟩
  have hfs := h.stack
  have hfl := h.stackLive
  rw [hf,hf'] at hfs
  cases hfs with
  | cons hhead htail =>
    have hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs := by
      rw [hf] at hfl
      exact hfl.2
    exact (h.restack htail hl).go (.node _ (.cons (.value (.ordinaryBig _)) .nil)) ⟨True.intro,True.intro⟩

namespace HeapR
variable {S : Type} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s s' : St S}

/-- A write to a selected ordinary object preserves every other live heap slot. -/
theorem setObj (h : HeapR R live framed before after s s') (a : Nat) (o o' : Obj)
    (ha : live a) (hf : ¬ framed a) (hr : ObjectR R o o')
    (hl : treeSupport live (Encode.obj o))
    (hs : a < 2 ^ 64) (ht : R.a a < 2 ^ 64) :
    HeapR R live framed before after (s.setObj a o) (s'.setObj (R.a a) o') := by
  constructor
  · intro b hb
    by_cases he : b = a
    · subst b
      simp only [St.setObj, PTrie.get_set_u64 _ _ _ hs, PTrie.get_set_u64 _ _ _ ht]
      exact .regular hf (.obj hr) ⟨hl,True.intro⟩
    · have hne : R.a b ≠ R.a a := fun heq => he (h.inj b a hb ha heq)
      simpa only [St.setObj, PTrie.get_set_u64 _ _ _ hs, PTrie.get_set_u64 _ _ _ ht,
        ite_eq_right he,ite_eq_right hne] using h.lookup b hb
  · exact h.sourceBound
  · exact h.targetBound
  · exact h.prefixLive
  · exact h.inj
  · exact h.fresh

end HeapR

namespace StateR
variable {S : Type} {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
  {before after : List Val} {old old' : List Event} {s s' : St S}

theorem setObj (h : StateR FR R live framed before after old old' s s') (a : Nat) (o o' : Obj)
    (ha : live a) (hf : ¬ framed a) (hr : ObjectR R o o')
    (hl : treeSupport live (Encode.obj o))
    (hs : a < 2 ^ 64) (ht : R.a a < 2 ^ 64) :
    StateR FR R live framed before after old old' (s.setObj a o) (s'.setObj (R.a a) o') :=
  ⟨h.heap.setObj a o o' ha hf hr hl hs ht,h.control,h.controlLive,h.stack,h.stackLive,
    h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

end StateR

private theorem cellVal_support (live : Nat → Prop) (c : Cell) : valueSupport live (cellVal c) := by
  cases c <;> exact True.intro

/-- The source typed-view read preserves the complete runtime relation. This
uses the actual coherent buffer contents, including symbolic token numbers or
owned uint64 handles; it does not replace the buffer by a canonical token. -/
theorem step_indexTyped0_state (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s s' : St F.S) (h : StateR FR R live framed before after old old' s s')
    (a b : Nat) (o o' : Obj) (k : EltK) (c c' : Cell) (fs fs' : List Frame)
    (hcells : CellR R c c')
    (hc : s.ctl = .ret (.num zeroN)) (hc' : s'.ctl = .ret (.num zeroN))
    (hf : s.stack = .e (.indexR (.obj a)) :: fs)
    (hf' : s'.stack = .e (.indexR (.obj (R.a a))) :: fs')
    (ho : s.obj? a = some o) (hk : o.kind = .typed k b 0 1)
    (ho' : s'.obj? (R.a a) = some o') (hk' : o'.kind = .typed k (R.a b) 0 1)
    (hb : bufBytes F s b = some (cellParts k c k.size 0))
    (hb' : bufBytes F s' (R.a b) = some (cellParts k c' k.size 0)) :
    let t := ({s with stack := fs}.ret (cellVal c))
    let t' := ({s' with stack := fs'}.ret (cellVal c'))
    step F s = M.pure t ∧ step F s' = M.pure t' ∧
      StateR FR R live framed before after old old' t t' := by
  dsimp only
  obtain ⟨hs,hs',hv⟩ := step_indexTyped0_roles F R s s' a b o o' k c c' fs fs'
    hcells hc hc' hf hf' ho hk ho' hk' hb hb'
  refine ⟨hs,hs',?_⟩
  have hfs := h.stack
  have hfl := h.stackLive
  rw [hf,hf'] at hfs
  cases hfs with
  | cons hhead htail =>
    have hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs := by
      rw [hf] at hfl
      exact hfl.2
    exact (h.restack htail hl).go (.node _ (.cons (.value hv) .nil)) ⟨cellVal_support live c,True.intro⟩

private theorem byteForest {R : Ren} {xs ys : List Byte} (h : ListR (ByteR R) xs ys) :
    ForestR R (xs.map Encode.byte) (ys.map Encode.byte) := by
  induction h with
  | nil => exact .nil
  | cons h _ ih => exact .cons (.byte h) ih

private theorem bytesSupport (live : Nat → Prop) (xs : List Byte) :
    forestSupport live (xs.map Encode.byte) := by
  induction xs with
  | nil => exact True.intro
  | cons x xs ih => exact ⟨True.intro,ih⟩

/-- Replacing a buffer's bytes preserves all descriptor and private-field roles. -/
theorem ObjectR.replaceBuffer {R : Ren} {o o' : Obj} (h : ObjectR R o o')
    {xs ys : List Byte} (hb : ListR (ByteR R) xs ys) :
    ObjectR R {o with kind := .buf xs} {o' with kind := .buf ys} := by
  change TreeR R (.node "Obj" _) (.node "Obj" _) at h
  cases h with
  | node _ hs =>
    cases hs with
    | cons hkind hrest =>
      exact .node _ (.cons (.node _ (.cons (.node _ (byteForest hb)) .nil)) hrest)

theorem objectBufferSupport (live : Nat → Prop) (o : Obj)
    (h : treeSupport live (Encode.obj o)) (xs : List Byte) :
    treeSupport live (Encode.obj {o with kind := .buf xs}) :=
  ⟨⟨bytesSupport live xs,True.intro⟩,h.2⟩

/-- Actual JS-buffer patching preserves the complete boundary relation, with
all unaffected live slots and all nonheap runtime components framed. -/
theorem applyWrites_buffer_state (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s s' : St F.S) (h : StateR FR R live framed before after old old' s s')
    (b off : Nat) (o o' : Obj) (bs bs' bytes bytes' : List Byte)
    (ho : s.obj? b = some o) (hk : o.kind = .buf bs)
    (ho' : s'.obj? (R.a b) = some o') (hk' : o'.kind = .buf bs')
    (hr : ObjectR R o o') (hl : treeSupport live (Encode.obj o))
    (hbuf : live b) (hframe : ¬ framed b)
    (hb : ListR (ByteR R) bs bs') (hw : ListR (ByteR R) bytes bytes')
    (hs : b < 2 ^ 64) (ht : R.a b < 2 ^ 64) :
    let data := bs.take off ++ bytes ++ bs.drop (off + len bytes)
    let data' := bs'.take off ++ bytes' ++ bs'.drop (off + len bytes')
    let u := s.setObj b {o with kind := .buf data}
    let u' := s'.setObj (R.a b) {o' with kind := .buf data'}
    applyWrites F s [(b,off,bytes)] = some u ∧
      applyWrites F s' [(R.a b,off,bytes')] = some u' ∧
      StateR FR R live framed before after old old' u u' := by
  dsimp only
  have hp := patch_related hb hw off
  exact ⟨applyWrites_one_buffer F s b off bytes bs o ho hk,
    applyWrites_one_buffer F s' (R.a b) off bytes' bs' o' ho' hk',
    h.setObj b _ _ hbuf hframe (hr.replaceBuffer hp) (objectBufferSupport live o hl _) hs ht⟩

end Host.Ts.Owned
