import host.ts.RenameOwnedState
namespace Host.Ts.Owned.Parametric

/-- Numeric positions carry a relation independently of address and handle maps.
This permits a symbolic expression to have different literal values at two cuts,
and permits an interpreted number reference to specialize to a literal. -/
inductive ValueR (NR : NumV → NumV → Prop) (R : Ren) : Val → Val → Prop where
  | undef : ValueR NR R .undef .undef
  | null : ValueR NR R .null .null
  | bool (b : Bool) : ValueR NR R (.bool b) (.bool b)
  | str (s : Name) : ValueR NR R (.str s) (.str s)
  | num {n n' : NumV} : NR n n' → ValueR NR R (.num n) (.num n')
  | ordinaryBig (i : Int) : ValueR NR R (.big i) (.big i)
  | handle (h : Nat) : ValueR NR R (.big (Int.ofNat h)) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      ValueR NR R (.big (ptrInt m off)) (.big (ptrInt (R.mem m) off))
  | obj (a : Nat) : ValueR NR R (.obj a) (.obj (R.a a))
  | sym (a : Nat) : ValueR NR R (.sym a) (.sym (R.sym a))
  | ptr (m : Mem) (off : Nat) : ValueR NR R (.ptr m off) (.ptr (R.mem m) off)

inductive CellR (NR : NumV → NumV → Prop) (R : Ren) : Cell → Cell → Prop where
  | num {n n' : NumV} : NR n n' → CellR NR R (.num n) (.num n')
  | ordinaryBig (i : Int) : CellR NR R (.big i) (.big i)
  | handle (h : Nat) : CellR NR R (.big (Int.ofNat h)) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      CellR NR R (.big (ptrInt m off)) (.big (ptrInt (R.mem m) off))

inductive ByteR (NR : NumV → NumV → Prop) (R : Ren) : Byte → Byte → Prop where
  | lit (b : Nat) : ByteR NR R (.lit b) (.lit b)
  | part {c c' : Cell} (k : EltK) (i : Nat) : CellR NR R c c' →
      ByteR NR R (.part k c i) (.part k c' i)

mutual
  inductive TreeR (NR : NumV → NumV → Prop) (R : Ren) : Tree → Tree → Prop where
    | atom (α : Type) (x : α) : TreeR NR R (.atom α x) (.atom α x)
    | value {v v' : Val} : ValueR NR R v v' → TreeR NR R (.value v) (.value v')
    | cell {c c' : Cell} : CellR NR R c c' → TreeR NR R (.cell c) (.cell c')
    | byte {b b' : Byte} : ByteR NR R b b' → TreeR NR R (.byte b) (.byte b')
    | address (a : Nat) : TreeR NR R (.address a) (.address (R.a a))
    | symbol (a : Nat) : TreeR NR R (.symbol a) (.symbol (R.sym a))
    | region (a : Nat) : TreeR NR R (.region a) (.region (R.region a))
    | number {n n' : NumV} : NR n n' → TreeR NR R (.number n) (.number n')
    | node (tag : String) {xs ys : List Tree} : ForestR NR R xs ys →
        TreeR NR R (.node tag xs) (.node tag ys)
  inductive ForestR (NR : NumV → NumV → Prop) (R : Ren) : List Tree → List Tree → Prop where
    | nil : ForestR NR R [] []
    | cons {x y : Tree} {xs ys : List Tree} : TreeR NR R x y → ForestR NR R xs ys →
        ForestR NR R (x :: xs) (y :: ys)
end

abbrev FrameR (NR : NumV → NumV → Prop) (R : Ren) (f f' : Frame) := TreeR NR R (Encode.frame f) (Encode.frame f')
abbrev ControlR (NR : NumV → NumV → Prop) (R : Ren) (c c' : Ctl) := TreeR NR R (Encode.ctl c) (Encode.ctl c')
abbrev ObjectR (NR : NumV → NumV → Prop) (R : Ren) (o o' : Obj) := TreeR NR R (Encode.obj o) (Encode.obj o')

inductive HeapObjectR (NR : NumV → NumV → Prop) (R : Ren) : HObj → HObj → Prop where
  | uninitialized : HeapObjectR NR R (.cell none) (.cell none)
  | cell {v v' : Val} : ValueR NR R v v' → HeapObjectR NR R (.cell (some v)) (.cell (some v'))
  | obj {o o' : Obj} : ObjectR NR R o o' → HeapObjectR NR R (.obj o) (.obj o')

def arg : Arg → Tree
  | .null => .node "Arg.null" []
  | .num n => .node "Arg.num" [.number n]
  | .big i => .node "Arg.big" [.value (.big i)]
  | .bool b => .node "Arg.bool" [Encode.atom b]
  | .jsPtr b off bytes => .node "Arg.jsPtr" [.address b,Encode.atom off,Encode.seq (bytes.map Encode.byte)]
  | .extPtr r off => .node "Arg.extPtr" [.region r,Encode.atom off]
  | .other v => .node "Arg.other" [.value v]

def ret : Ret → Tree
  | .void => .node "Ret.void" []
  | .num n => .node "Ret.num" [.number n]
  | .big i => .node "Ret.big" [.value (.big i)]
  | .bool b => .node "Ret.bool" [Encode.atom b]
  | .ptr r off => .node "Ret.ptr" [.region r,Encode.atom off]
  | .null => .node "Ret.null" []
  | .cstr s => .node "Ret.cstr" [Encode.atom s]
  | .callback r as => .node "Ret.callback" [.region r,Encode.seq (as.map arg)]

def event (e : Event) : Tree := .node "Event" [Encode.atom e.sym,Encode.seq (e.args.map arg),ret e.ret]

inductive SlotR (NR : NumV → NumV → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (a : Nat) : Option HObj → Option HObj → Prop where
  | absent : ¬ framed a → SlotR NR R live framed before after a none none
  | regular {h h' : HObj} (hf : ¬ framed a) (hr : HeapObjectR NR R h h') :
      treeSupport live (Encode.hobj h) → SlotR NR R live framed before after a (some h) (some h')
  | framed {o o' : Obj} {xs ys : List Val} (hf : framed a)
      (hk : o.kind = .array (before ++ xs)) (hk' : o'.kind = .array (after ++ ys))
      (hv : ListR (ValueR NR R) xs ys) (hh : TreeR NR R (Encode.header o) (Encode.header o')) :
      listSupport (valueSupport live) xs → treeSupport live (Encode.header o) →
      SlotR NR R live framed before after a (some (.obj o)) (some (.obj o'))

structure HeapR {S : Type} (NR : NumV → NumV → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (s s' : St S) : Prop where
  lookup : ∀ a, live a → SlotR NR R live framed before after a (s.heap.get a) (s'.heap.get (R.a a))
  sourceBound : ∀ a, live a → a < s.next
  targetBound : ∀ a, live a → R.a a < s'.next
  prefixLive : ∀ a, framed a → live a
  inj : ∀ a b, live a → live b → R.a a = R.a b → a = b
  fresh : ∀ k, R.a (s.next + k) = s'.next + k

/-- Full runtime relation with an explicit, potentially noninjective numeric
relation. Source AST and ordinary bigint roles retain their previous meanings.
No literal-index substitution or machine-step simulation is postulated here. -/
structure StateR {S : Type} (NR : NumV → NumV → Prop) (FR : Ren → S → S → Prop) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (oldTrace oldTrace' : List Event)
    (s s' : St S) : Prop where
  heap : HeapR NR R live framed before after s s'
  control : ControlR NR R s.ctl s'.ctl
  controlLive : treeSupport live (Encode.ctl s.ctl)
  stack : ListR (FrameR NR R) s.stack s'.stack
  stackLive : listSupport (fun f => treeSupport live (Encode.frame f)) s.stack
  jobs : ListR (fun j j' => TreeR NR R (Encode.job j) (Encode.job j')) s.jobs s'.jobs
  jobsLive : listSupport (fun j => treeSupport live (Encode.job j)) s.jobs
  stores : TreeR NR R (Encode.stores s.stores) (Encode.stores s'.stores)
  storesLive : treeSupport live (Encode.stores s.stores)
  native : FR R s.ffi s'.ffi
  trace : ∃ fresh fresh', s.trace = fresh ++ oldTrace ∧ s'.trace = fresh' ++ oldTrace' ∧
    ListR (fun e e' => TreeR NR R (event e) (event e')) fresh fresh'

section Monotonicity
variable {NR NR' : NumV → NumV → Prop} {R : Ren} (m : ∀ a b, NR a b → NR' a b)
include m

theorem ValueR.mono {v v' : Val} (h : ValueR NR R v v') : ValueR NR' R v v' := by
  cases h with
  | num h => exact .num (m _ _ h)
  | undef => exact .undef
  | null => exact .null
  | bool b => exact .bool b
  | str s => exact .str s
  | ordinaryBig i => exact .ordinaryBig i
  | handle h => exact .handle h
  | pointerInteger p o => exact .pointerInteger p o
  | obj a => exact .obj a
  | sym a => exact .sym a
  | ptr p o => exact .ptr p o

theorem CellR.mono {c c' : Cell} (h : CellR NR R c c') : CellR NR' R c c' := by
  cases h with
  | num h => exact .num (m _ _ h)
  | ordinaryBig i => exact .ordinaryBig i
  | handle h => exact .handle h
  | pointerInteger p o => exact .pointerInteger p o

theorem ByteR.mono {b b' : Byte} (h : ByteR NR R b b') : ByteR NR' R b b' := by
  cases h with
  | lit b => exact .lit b
  | part k i h => exact .part k i (h.mono m)

omit m in
mutual
  theorem TreeR.mono (m : ∀ a b, NR a b → NR' a b)
      {t t' : Tree} (h : TreeR NR R t t') : TreeR NR' R t t' :=
    match h with
    | .atom α x => .atom α x
    | .value h => .value (h.mono m)
    | .cell h => .cell (h.mono m)
    | .byte h => .byte (h.mono m)
    | .address a => .address a
    | .symbol a => .symbol a
    | .region a => .region a
    | .number h => .number (m _ _ h)
    | .node tag h => .node tag (ForestR.mono m h)
  theorem ForestR.mono (m : ∀ a b, NR a b → NR' a b)
      {ts ts' : List Tree} (h : ForestR NR R ts ts') : ForestR NR' R ts ts' :=
    match h with
    | .nil => .nil
    | .cons h hs => .cons (TreeR.mono m h) (ForestR.mono m hs)
end

theorem HeapObjectR.mono {h h' : HObj} (hr : HeapObjectR NR R h h') : HeapObjectR NR' R h h' := by
  cases hr with
  | uninitialized => exact .uninitialized
  | cell h => exact .cell (h.mono m)
  | obj h => exact .obj (h.mono m)

omit m in
private theorem mapListRel {α β : Type} {p q : α → β → Prop}
    (h : ∀ a b, p a b → q a b) {xs : List α} {ys : List β} (hr : ListR p xs ys) : ListR q xs ys := by
  induction hr with
  | nil => exact .nil
  | cons hp _ ih => exact .cons (h _ _ hp) ih

theorem SlotR.mono {live framed : Nat → Prop} {before after : List Val} {a : Nat} {h h' : Option HObj}
    (hr : SlotR NR R live framed before after a h h') : SlotR NR' R live framed before after a h h' := by
  cases hr with
  | absent hf => exact .absent hf
  | regular hf hr hl => exact .regular hf (hr.mono m) hl
  | framed hf hk hk' hv hh hl hhLive =>
    exact .framed hf hk hk' (mapListRel (fun _ _ h => h.mono m) hv) (hh.mono m) hl hhLive

theorem StateR.mono {S : Type} {FR FR' : Ren → S → S → Prop} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s')
    (hn : FR R s.ffi s'.ffi → FR' R s.ffi s'.ffi) :
    StateR NR' FR' R live framed before after old old' s s' := by
  refine ⟨⟨fun a ha => (h.heap.lookup a ha).mono m,h.heap.sourceBound,h.heap.targetBound,
    h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,h.control.mono m,h.controlLive,
    mapListRel (fun _ _ h => h.mono m) h.stack,h.stackLive,
    mapListRel (fun _ _ h => h.mono m) h.jobs,h.jobsLive,h.stores.mono m,h.storesLive,hn h.native,?_⟩
  obtain ⟨xs,ys,hx,hy,hr⟩ := h.trace
  exact ⟨xs,ys,hx,hy,mapListRel (fun _ _ h => h.mono m) hr⟩

end Monotonicity

namespace StateR
variable {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
  {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s s' : St S}

theorem go (h : StateR NR FR R live framed before after old old' s s')
    {c c' : Ctl} (hc : ControlR NR R c c') (hs : treeSupport live (Encode.ctl c)) :
    StateR NR FR R live framed before after old old' (s.go c) (s'.go c') :=
  ⟨⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,
    hc,hs,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

theorem restack (h : StateR NR FR R live framed before after old old' s s')
    {fs fs' : List Frame} (hf : ListR (FrameR NR R) fs fs')
    (hl : listSupport (fun f => treeSupport live (Encode.frame f)) fs) :
    StateR NR FR R live framed before after old old' {s with stack := fs} {s' with stack := fs'} :=
  ⟨⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,
    h.control,h.controlLive,hf,hl,h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

end StateR
end Host.Ts.Owned.Parametric
