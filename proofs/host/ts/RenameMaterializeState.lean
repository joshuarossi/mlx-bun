import host.ts.RenameLive
import host.ts.RenameMaterialize
import host.ts.StoreLaws
namespace Host.Ts

namespace Trie
variable {α β : Type}

def map (f : α → β) : Trie α → Trie β
  | .nil => .nil
  | .node v a b c d => .node (v.map f) (map f a) (map f b) (map f c) (map f d)

private theorem pick_get (n : Nat) (a b c d : Trie α) (i : Nat) :
    (pick n a b c d).get i = pick n (a.get i) (b.get i) (c.get i) (d.get i) := by
  unfold pick brec
  cases Nat.blt n 2 <;> cases Nat.beq n 0 <;> cases Nat.beq n 2 <;> rfl

private theorem pick_map {γ δ : Type} (f : γ → δ) (n : Nat) (a b c d : γ) :
    f (pick n a b c d) = pick n (f a) (f b) (f c) (f d) := by
  unfold pick brec
  cases Nat.blt n 2 <;> cases Nat.beq n 0 <;> cases Nat.beq n 2 <;> rfl

theorem get_map (f : α → β) (t : Trie α) : ∀ i, (t.map f).get i = (t.get i).map f := by
  induction t with
  | nil => intro i; rfl
  | node v a b c d ia ib ic id =>
    intro i
    simp only [map, get_node]
    by_cases hi : i = 0
    · simp only [ite_eq_left hi]
    · simp only [ite_eq_right hi, pick_get, ia, ib, ic, id]
      exact (pick_map (Option.map f) (i % 4) (a.get (i / 4)) (b.get (i / 4))
        (c.get (i / 4)) (d.get (i / 4))).symm

end Trie

namespace PTrie
variable {α β : Type}

def map (f : α → β) (t : PTrie α) : PTrie β := ⟨t.root.map (Trie.map (Trie.map f))⟩

theorem get_map (f : α → β) (t : PTrie α) (i : Nat) : (t.map f).get i = (t.get i).map f := by
  rw [get_eq, get_eq]
  dsimp only [map]
  rw [Trie.get_map]
  cases hg : t.root.get (i / 4096) with
  | none => rfl
  | some g =>
    simp only [Option.map_some, orNil_some]
    rw [Trie.get_map]
    cases hp : g.get ((i / 64) % 64) with
    | none => rfl
    | some p =>
      simp only [Option.map_some, orNil_some]
      exact Trie.get_map f p (i % 64)

end PTrie

/-- Materialization keeps all resource identities and replaces numeric references by
their concrete table values. Invalid references become NaN; specialization lemmas require
successful input lookups or numeric-closure witnesses, so that fallback is never used. -/
def materializer (C : CSrv) : NameMap (.concrete C) := { a := id, n := id }

namespace NameMap

def nativeNode {mode : NumMode} (M : NameMap mode) (n : Host.Mlx.Ffi.Node) : Host.Mlx.Ffi.Node :=
  ⟨M.prim n.prim, n.ins.map M.node, n.shape.map M.dim, n.dtype⟩

end NameMap

def materializeNative (C : CSrv) (s : Host.Mlx.Ffi.St) : Host.Mlx.Ffi.St :=
  let M := materializer C
  ⟨s.next, s.nodes.map M.nativeNode, s.nnext, s.arrs, s.objs.map M.nativeObj,
    s.tokens.map M.num, s.files, s.pending.map M.nativePending, s.errh.map M.arg,
    s.arch, s.deviceSizes, s.wired, s.items.map M.num⟩

def materializeStateWith {S : Type} (ffiMap : CSrv → S → S) (C : CSrv) (s : St S) : St S :=
  let M := materializer C
  ⟨s.heap.map M.hobj, s.next, M.ctl s.ctl, s.stack.map M.frame,
    ⟨s.jobs.map M.job, ffiMap C s.ffi, s.trace.map M.event, M.stores s.stores⟩⟩

abbrev materializeState := materializeStateWith materializeNative

theorem materializeStateWith_control {S : Type} (ffiMap : CSrv → S → S)
    (C : CSrv) (s : St S) (c : Ctl) (fs : List Frame) :
    materializeStateWith ffiMap C { s with ctl := c, stack := fs } =
      { materializeStateWith ffiMap C s with
        ctl := (materializer C).ctl c
        stack := fs.map (materializer C).frame } := rfl

theorem materializeState_control (C : CSrv) (s : St Host.Mlx.Ffi.St) (c : Ctl) (fs : List Frame) :
    materializeState C { s with ctl := c, stack := fs } =
      { materializeState C s with ctl := (materializer C).ctl c, stack := fs.map (materializer C).frame } := rfl

/-- Numeric closure states that table extension cannot change the meaning of any number
already stored in this state, including dormant frames, heap objects and native graph metadata.
This property is checked at a template cut; it is not a machine-step simulation premise. -/
def NumericClosedWith {S : Type} (ffiMap : CSrv → S → S) (C : CSrv) (s : St S) : Prop :=
  ∀ D, TableExtends C D → materializeStateWith ffiMap D s = materializeStateWith ffiMap C s

abbrev NumericClosed := NumericClosedWith materializeNative

theorem materialize_num (C : CSrv) (a : NumV) (x : F64) (ha : C.val a = some x) :
    (materializer C).num a = .lit x := by
  cases a with
  | lit y =>
    have hxy : y = x := Option.some.inj ha
    subst x
    rfl
  | ref i => simp only [NameMap.num, ha, Option.getD_some]

theorem NumericClosedWith.mono {S : Type} {ffiMap : CSrv → S → S} {C D : CSrv} {s : St S}
    (h : NumericClosedWith ffiMap C s) (hd : TableExtends C D) : NumericClosedWith ffiMap D s := by
  intro E he
  exact (h E (hd.trans he)).trans (h D hd).symm

/-- Returning a defined number and removing the top frame preserves numeric closure.
All untouched heap, native-state, and dormant-frame data are framed by the prior invariant. -/
theorem NumericClosedWith.ret_number {S : Type} {ffiMap : CSrv → S → S} {C : CSrv} {s : St S}
    (h : NumericClosedWith ffiMap C s) (a : NumV) (x : F64) (ha : C.val a = some x)
    (f : Frame) (fs : List Frame) (hf : s.stack = f :: fs) :
    NumericClosedWith ffiMap C { s with ctl := .ret (.num a), stack := fs } := by
  intro D hd
  have hs := h D hd
  have hstack : fs.map (materializer D).frame = fs.map (materializer C).frame := by
    have hh := congrArg (fun u : St S => u.stack) hs
    change s.stack.map (materializer D).frame = s.stack.map (materializer C).frame at hh
    rw [hf] at hh
    exact (List.cons.inj hh).2
  rw [materializeStateWith_control, materializeStateWith_control, hs, hstack]
  change { materializeStateWith ffiMap C s with
      ctl := .ret (.num ((materializer D).num a))
      stack := fs.map (materializer C).frame } =
    { materializeStateWith ffiMap C s with
      ctl := .ret (.num ((materializer C).num a))
      stack := fs.map (materializer C).frame }
  rw [materialize_num D a x (hd.val ha), materialize_num C a x ha]

theorem materialize_heap (C : CSrv) (s : St Host.Mlx.Ffi.St) (a : Nat) :
    (materializeState C s).heap.get a = (s.heap.get a).map (materializer C).hobj :=
  PTrie.get_map _ s.heap a

/-- The interpreter's numeric `<` comparison has the same branch answer after
materialization. No number-table extension or numeric closure assumption is needed. -/
theorem step_numLt_materializeWith (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv) (a b : NumV) (fs : List Frame) (x y : F64)
    (hc : s.ctl = .ret (.num b)) (hf : s.stack = .e (.binR .lt (.num a)) :: fs)
    (ha : C.val a = some x) (hb : C.val b = some y) :
    let t := { s with ctl := .ret (.bool (F64.test .lt x y)), stack := fs }
    interpC (step F s).run C = some (t, C) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap C t, E) := by
  dsimp only
  have hma := materialize_num C a x ha
  have hmb := materialize_num C b y hb
  have hcs : (materializeStateWith ffiMap C s).ctl = .ret (.num (.lit y)) := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
    change Ctl.ret (.num ((materializer C).num b)) = _
    rw [hmb]
  have hfs : (materializeStateWith ffiMap C s).stack =
      .e (.binR .lt (.num (.lit x))) :: fs.map (materializer C).frame := by
    change s.stack.map (materializer C).frame = _
    rw [hf]
    change Frame.e (.binR .lt (.num ((materializer C).num a))) :: _ = _
    rw [hma]
  constructor
  · cases a with
    | lit u =>
      have hx : u = x := Option.some.inj ha
      subst x
      cases b with
      | lit v =>
        have hy : v = y := Option.some.inj hb
        subst y
        simp only [step, hc, stepRet, hf, retStep, retE, binOp, compare, toNum, M.bind, M.pure,
          numTest, M.run, retS, St.ret, interpC_pure, Bool.cond_false]
      | ref j =>
        have hb' : nth? C.tab j = some y := hb
        simp only [step, hc, stepRet, hf, retStep, retE, binOp, compare, toNum, M.bind, M.pure,
          numTest, M.test, M.run, retS, St.ret, interpC_test, CSrv.val, hb', interpC_pure,
          Bool.cond_false]
    | ref i =>
      cases b <;>
        simp only [step, hc, stepRet, hf, retStep, retE, binOp, compare, toNum, M.bind, M.pure,
          numTest, M.test, M.run, retS, St.ret, interpC_test, ha, hb, interpC_pure]
        <;> rfl
  · have ht := materializeStateWith_control ffiMap C s (.ret (.bool (F64.test .lt x y))) fs
    rw [ht]
    simp only [step, hcs, stepRet, hfs, retStep, retE, binOp, compare, toNum, M.bind, M.pure,
      numTest, M.run, retS, St.ret, interpC_pure]
    rfl

/-- An actual numeric machine step specializes to the same complete successor state,
even though only the reference-valued execution allocates a number-table entry. -/
theorem step_numNeg_materializeWith (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv)
    (i : Nat) (fs : List Frame) (x : F64)
    (hc : s.ctl = .ret (.num (.ref i))) (hf : s.stack = .e (.unary .neg) :: fs)
    (hx : C.val (.ref i) = some x) (closed : NumericClosedWith ffiMap C s) :
    let D : CSrv := ⟨C.tab ++ [F64.un .neg x]⟩
    let t := { s with ctl := .ret (.num (.ref C.tab.length)), stack := fs }
    interpC (step F s).run C = some (t, D) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap D t, E) := by
  dsimp only
  let D : CSrv := ⟨C.tab ++ [F64.un .neg x]⟩
  have hm : (materializer C).num (.ref i) = .lit x := materialize_num C _ _ hx
  have hcs : (materializeStateWith ffiMap C s).ctl = .ret (.num (.lit x)) := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
    change Ctl.ret (.num ((materializer C).num (.ref i))) = _
    rw [hm]
  have hfs : (materializeStateWith ffiMap C s).stack =
      .e (.unary .neg) :: fs.map (materializer C).frame := by
    change s.stack.map (materializer C).frame = _
    rw [hf]
    rfl
  have hst : materializeStateWith ffiMap D s = materializeStateWith ffiMap C s :=
    closed D (TableExtends.append C _)
  have hstack : fs.map (materializer D).frame = fs.map (materializer C).frame := by
    have hh := congrArg (fun u : St F.S => u.stack) hst
    change s.stack.map (materializer D).frame = s.stack.map (materializer C).frame at hh
    rw [hf] at hh
    exact (List.cons.inj hh).2
  have hnew : (materializer D).num (.ref C.tab.length) = .lit (F64.un .neg x) := by
    apply materialize_num
    exact nth?_append_length C.tab _
  have ht : materializeStateWith ffiMap D { s with ctl := .ret (.num (.ref C.tab.length)), stack := fs } =
      { materializeStateWith ffiMap C s with
        ctl := .ret (.num (.lit (F64.un .neg x)))
        stack := fs.map (materializer C).frame } := by
    rw [materializeStateWith_control, hst, hstack]
    change { materializeStateWith ffiMap C s with
      ctl := .ret (.num ((materializer D).num (.ref C.tab.length)))
      stack := fs.map (materializer C).frame } = _
    rw [hnew]
  constructor
  · simp only [step, hc, stepRet, hf, retStep, retE, unaryOp, toNum, M.bind, M.pure,
      numUn, M.un, M.run, retS, St.ret, interpC_un, hx, interpC_pure]
  · change interpC (step F (materializeStateWith ffiMap C s)).run E =
      some (materializeStateWith ffiMap D { s with ctl := .ret (.num (.ref C.tab.length)), stack := fs }, E)
    rw [ht]
    simp only [step, hcs, stepRet, hfs, retStep, retE, unaryOp, toNum, M.bind, M.pure,
      numUn, M.run, retS, St.ret, interpC_pure]

/-- The numeric-closure obligation is preserved by the reference-allocating step;
the freshly returned reference is already defined in its successor server. -/
theorem step_numNeg_numericClosed (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C : CSrv) (fs : List Frame) (x : F64)
    (hf : s.stack = .e (.unary .neg) :: fs) (closed : NumericClosedWith ffiMap C s) :
    NumericClosedWith ffiMap ⟨C.tab ++ [F64.un .neg x]⟩
      { s with ctl := .ret (.num (.ref C.tab.length)), stack := fs } := by
  exact (closed.mono (TableExtends.append C _)).ret_number (.ref C.tab.length)
    (F64.un .neg x) (nth?_append_length C.tab _) (.e (.unary .neg)) fs hf

end Host.Ts
