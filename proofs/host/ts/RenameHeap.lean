import host.ts.RenameMachine
import host.ts.StoreLaws
set_option maxRecDepth 1000000
namespace Host.Ts

/-- An output array has an opaque old prefix. Only values appended after the cut
are renamed; prototype, descriptors and private fields retain ordinary meaning. -/
def FramedArray (R : Ren) (before after : List Val) (o o' : Obj) : Prop :=
  ∃ suffix, o.kind = .array (before ++ suffix) ∧
    o' = { R.obj o with kind := .array (after ++ suffix.map R.val) }

def LiveSlot (R : Ren) (framed : Nat → Prop) (before after : List Val)
    (a : Nat) (source target : Option HObj) : Prop :=
  (framed a ∧ ∃ o o', source = some (.obj o) ∧ target = some (.obj o') ∧ FramedArray R before after o o') ∨
    (¬ framed a ∧ target = source.map R.hobj)

/-- Heap observations needed by the live cut. Unselected garbage is unrestricted.
Prefix slots compare headers and appended suffixes without following their opaque
old elements. This is a heap relation; control and native-state obligations remain
separate and are not implied by it. -/
structure LiveHeap {S : Type} (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (s s' : St S) : Prop where
  lookup : ∀ a, live a → LiveSlot R framed before after a (s.heap.get a) (s'.heap.get (R.a a))
  sourceBound : ∀ a, live a → a < s.next
  targetBound : ∀ a, live a → R.a a < s'.next
  prefixLive : ∀ a, framed a → live a
  inj : ∀ a b, live a → live b → R.a a = R.a b → a = b
  fresh : ∀ k, R.a (s.next + k) = s'.next + k

namespace LiveHeap
variable {S : Type} {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s s' : St S}

theorem fresh_addr (h : LiveHeap R live framed before after s s') : R.a s.next = s'.next := by
  simpa using h.fresh 0

theorem alloc (h : LiveHeap R live framed before after s s') (v : HObj)
    (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    LiveHeap R (fun a => live a ∨ a = s.next) framed before after
      (s.alloc v).2 (s'.alloc (R.hobj v)).2 := by
  have hn : ¬ framed s.next := by
    intro hp
    have := h.sourceBound s.next (h.prefixLive s.next hp)
    omega
  have ha := h.fresh_addr
  constructor
  · intro a hl
    by_cases he : a = s.next
    · subst a
      simp [St.alloc, PTrie.get_set_u64 _ _ _ hs, PTrie.get_set_u64 _ _ _ ht,
        ha, LiveSlot, hn]
    · have hl : live a := hl.resolve_right he
      have hsne : a ≠ s.next := by have := h.sourceBound a hl; omega
      have htne : R.a a ≠ s'.next := by have := h.targetBound a hl; omega
      simpa only [St.alloc, PTrie.get_set_u64 _ _ _ hs, PTrie.get_set_u64 _ _ _ ht,
        ite_eq_right hsne, ite_eq_right htne] using h.lookup a hl
  · intro a hl
    dsimp only [St.alloc]
    rcases hl with hl | rfl
    · have := h.sourceBound a hl; omega
    · omega
  · intro a hl
    dsimp only [St.alloc]
    rcases hl with hl | rfl
    · have := h.targetBound a hl; omega
    · rw [ha]; omega
  · intro a hp
    exact .inl (h.prefixLive a hp)
  · intro a b hl hr he
    rcases hl with hl | rfl <;> rcases hr with hr | rfl
    · exact h.inj a b hl hr he
    · have := h.targetBound a hl
      rw [ha] at he
      omega
    · have := h.targetBound b hr
      rw [ha] at he
      omega
    · rfl
  · intro k
    dsimp only [St.alloc]
    have hf := h.fresh (k + 1)
    simpa only [Nat.add_assoc, Nat.add_comm 1 k, Nat.succ_eq_add_one] using hf

theorem control (h : LiveHeap R live framed before after s s') (c c' : Ctl) :
    LiveHeap R live framed before after (s.go c) (s'.go c') :=
  ⟨h.lookup, h.sourceBound, h.targetBound, h.prefixLive, h.inj, h.fresh⟩

theorem stack (h : LiveHeap R live framed before after s s') (fs fs' : List Frame) :
    LiveHeap R live framed before after { s with stack := fs } { s' with stack := fs' } :=
  ⟨h.lookup, h.sourceBound, h.targetBound, h.prefixLive, h.inj, h.fresh⟩

theorem allocObj (h : LiveHeap R live framed before after s s') (kind : Kind) (proto : Val) (props : Props)
    (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    LiveHeap R (fun a => live a ∨ a = s.next) framed before after
      (s.allocObj kind proto props).2 (s'.allocObj (R.kind kind) (R.val proto) (R.props props)).2 := by
  exact h.alloc (.obj ⟨kind, proto, props, [], true⟩) hs ht

theorem newArray (h : LiveHeap R live framed before after s s') (vs : List Val)
    (hp : R.a aArrayProto = aArrayProto) (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    LiveHeap R (fun a => live a ∨ a = s.next) framed before after
      (Host.Ts.newArray s vs).2 (Host.Ts.newArray s' (vs.map R.val)).2 := by
  have hh := h.allocObj (.array vs) (.obj aArrayProto) [] hs ht
  have hp' : R.val (.obj aArrayProto) = .obj aArrayProto := by
    change Val.obj (R.a aArrayProto) = _
    rw [hp]
  simpa only [Host.Ts.newArray, Ren.kind, NameMap.kind, NameMap.vals, Ren.props, NameMap.props,
    List.map_nil, hp', Ren.val] using hh

end LiveHeap

/-- Actual evaluation of an empty array allocates the corresponding fresh object.
The heap relation permits unrelated old garbage and arbitrary framed output prefixes. -/
theorem step_emptyArray_live (F : Ffi) (R : Ren) (live framed : Nat → Prop) (before after : List Val)
    (s s' : St F.S) (env : Env) (h : LiveHeap R live framed before after s s')
    (hc : s.ctl = .ev (.array []) env) (hc' : s'.ctl = .ev (.array []) (R.env env))
    (hp : R.a aArrayProto = aArrayProto) (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    let t := (newArray s []).2.ret (.obj s.next)
    let t' := (newArray s' []).2.ret (.obj s'.next)
    step F s = M.pure t ∧ step F s' = M.pure t' ∧
      LiveHeap R (fun a => live a ∨ a = s.next) framed before after t t' ∧ t'.ctl = R.ctl t.ctl := by
  dsimp only
  have hh := h.allocObj (.array []) (.obj aArrayProto) [] hs ht
  have hp' : R.val (.obj aArrayProto) = .obj aArrayProto := by
    change Val.obj (R.a aArrayProto) = _
    rw [hp]
  simp only [Ren.kind, NameMap.kind, List.map_nil, hp'] at hh
  refine ⟨?_, ?_, hh.control _ _, ?_⟩
  · simp only [step, hc, evStep, arrayNext, newArray, St.allocObj, St.alloc, retS, List.reverse_nil]
  · simp only [step, hc', evStep, arrayNext, newArray, St.allocObj, St.alloc, retS, List.reverse_nil]
  · change Ctl.ret (.obj s'.next) = .ret (.obj (R.a s.next))
    rw [h.fresh_addr]

/-- Completing an array literal is an actual allocating machine transition. The
new elements and fresh address commute with renaming, even when old heap garbage
and framed output prefixes differ. -/
theorem step_arrayEnd_live (F : Ffi) (R : Ren) (live framed : Nat → Prop) (before after : List Val)
    (s s' : St F.S) (v : Val) (acc : List Val) (env : Env) (fs : List Frame)
    (h : LiveHeap R live framed before after s s')
    (hc : s.ctl = .ret v) (hc' : s'.ctl = .ret (R.val v))
    (hf : s.stack = .l (.array acc [] env) :: fs)
    (hf' : s'.stack = .l (.array (acc.map R.val) [] (R.env env)) :: fs.map R.frame)
    (hp : R.a aArrayProto = aArrayProto) (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    let t := (newArray { s with stack := fs } (v :: acc).reverse).2.ret (.obj s.next)
    let t' := (newArray { s' with stack := fs.map R.frame } ((v :: acc).reverse.map R.val)).2.ret (.obj s'.next)
    step F s = M.pure t ∧ step F s' = M.pure t' ∧
      LiveHeap R (fun a => live a ∨ a = s.next) framed before after t t' ∧
      t'.ctl = R.ctl t.ctl ∧ t'.stack = t.stack.map R.frame := by
  dsimp only
  have hh := (h.stack fs (fs.map R.frame)).newArray (v :: acc).reverse hp hs ht
  refine ⟨?_, ?_, hh.control _ _, ?_, ?_⟩
  · simp only [step, hc, stepRet, hf, retStep, retL, arrayNext, retS, newArray, St.allocObj, St.alloc]
  · simp only [step, hc', stepRet, hf', retStep, retL, arrayNext, retS, newArray, St.allocObj, St.alloc,
      List.map_reverse, List.map_cons]
  · change Ctl.ret (.obj s'.next) = .ret (.obj (R.a s.next))
    rw [h.fresh_addr]
  · rfl

/-- Creating a callback closure is an actual fresh allocation. Its environment
is renamed with the captured addresses; no equality of unreachable heap slots is
required. -/
theorem step_arrow_live (F : Ffi) (R : Ren) (live framed : Nat → Prop) (before after : List Val)
    (s s' : St F.S) (f : Func) (env : Env) (h : LiveHeap R live framed before after s s')
    (hc : s.ctl = .ev (.arrow f) env) (hc' : s'.ctl = .ev (.arrow f) (R.env env))
    (hp : R.a aFunctionProto = aFunctionProto) (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    let t := (closureObj s f env true .undef).2.ret (.obj s.next)
    let t' := (closureObj s' f (R.env env) true .undef).2.ret (.obj s'.next)
    step F s = M.pure t ∧ step F s' = M.pure t' ∧
      LiveHeap R (fun a => live a ∨ a = s.next) framed before after t t' ∧ t'.ctl = R.ctl t.ctl := by
  dsimp only
  have hh := h.allocObj (.fn (.closure f env true .undef)) (.obj aFunctionProto) [] hs ht
  have hp' : R.val (.obj aFunctionProto) = .obj aFunctionProto := by
    change Val.obj (R.a aFunctionProto) = _
    rw [hp]
  simp only [Ren.kind, NameMap.kind, NameMap.code, NameMap.val, hp'] at hh
  refine ⟨?_, ?_, hh.control _ _, ?_⟩
  · simp only [step, hc, evStep, retS, closureObj, St.allocObj, St.alloc]
  · simp only [step, hc', evStep, retS, closureObj, St.allocObj, St.alloc]
  · change Ctl.ret (.obj s'.next) = .ret (.obj (R.a s.next))
    rw [h.fresh_addr]

/-- The first static property of an object literal allocates the object and
enters its initializer, with corresponding fresh target and waiting frame. -/
theorem step_objectStart_live (F : Ffi) (R : Ren) (live framed : Nat → Prop) (before after : List Val)
    (s s' : St F.S) (name : Name) (e : Expr) (rest : List Property) (env : Env)
    (h : LiveHeap R live framed before after s s')
    (hc : s.ctl = .ev (.object (.init (.id name) e :: rest)) env)
    (hc' : s'.ctl = .ev (.object (.init (.id name) e :: rest)) (R.env env))
    (hf : s'.stack = s.stack.map R.frame)
    (hp : R.a aObjectProto = aObjectProto) (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    let u := (s.allocObj .ordinary (.obj aObjectProto) []).2
    let u' := (s'.allocObj .ordinary (.obj aObjectProto) []).2
    let t := (u.push (.l (.objVal s.next (.str name) rest env))).go (.ev e env)
    let t' := (u'.push (.l (.objVal s'.next (.str name) rest (R.env env)))).go (.ev e (R.env env))
    step F s = M.pure t ∧ step F s' = M.pure t' ∧
      LiveHeap R (fun a => live a ∨ a = s.next) framed before after t t' ∧
      t'.ctl = R.ctl t.ctl ∧ t'.stack = t.stack.map R.frame := by
  dsimp only
  have hh := h.allocObj .ordinary (.obj aObjectProto) [] hs ht
  have hp' : R.val (.obj aObjectProto) = .obj aObjectProto := by
    change Val.obj (R.a aObjectProto) = _
    rw [hp]
  simp only [Ren.kind, NameMap.kind, hp'] at hh
  refine ⟨?_, ?_, (hh.stack _ _).control _ _, rfl, ?_⟩
  · simp only [step, hc, evStep, objNext, keyOf, St.allocObj, St.alloc]
  · simp only [step, hc', evStep, objNext, keyOf, St.allocObj, St.alloc]
  · change .l (.objVal s'.next (.str name) rest (R.env env)) :: s'.stack =
      (Frame.l (.objVal s.next (.str name) rest env) :: s.stack).map R.frame
    simp only [List.map_cons, Ren.frame, NameMap.frame, NameMap.litF, NameMap.key, hf, h.fresh_addr]

end Host.Ts
