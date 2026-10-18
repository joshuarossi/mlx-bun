import host.ts.RenameParametricNativeCall
import host.ts.RenameAnnotations
import host.mlx.OwnedFfi

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

/-- A fresh allocation leaves every older heap address unchanged. The machine
word bound is explicit because the indexed store uses bounded address writes. -/
theorem alloc_ret_heap_below {S : Type} (s : St S) (o : HObj) (v : Val)
    (bound : s.next < 2^64) (a : Nat) (old : a < s.next) :
    ((s.alloc o).2.ret v).heap.get a = s.heap.get a := by
  simp only [St.alloc,St.ret,PTrie.get_set_u64 _ _ _ bound,ite_eq_right (Nat.ne_of_lt old)]

/-- An occurrence selector for a call's arguments. Its fixed literal roles
must be established by the preceding source execution. -/
def callArgument (c : Ctl) (i : Nat) : Val :=
  match c with
  | .call _ _ args => Host.Ts.arg args i
  | _ => .undef

theorem fixed_literal_value {ν : Nat → F64} {C : CSrv} {R : Ren} {x : F64} {v : Val}
    (h : (Annotated.Value.literal (.lit x)).Holds ν C R v) : v = .num (.lit x) := by
  cases h with
  | literal e y hy =>
    have he : y = x := Option.some.inj hy
    exact he ▸ rfl

def externalBuffer (r off count : Nat) : HObj :=
  .obj ⟨.extBuf r off count,.obj aArrayBufferProto,[],[],true⟩

theorem StateR.alloc_externalBuffer {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (r off count : Nat) (hp : live aArrayBufferProto) (hpr : R.a aArrayBufferProto = aArrayBufferProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (externalBuffer r off count)).2.ret (.obj s₀.next))
      ((s.alloc (externalBuffer (R.region r) off count)).2.ret (.obj s.next)) := by
  have hproto : ValueR NR R (.obj aArrayBufferProto) (.obj aArrayBufferProto) := by
    simpa only [hpr] using (ValueR.obj (NR := NR) (R := R) aArrayBufferProto)
  have ho : HeapObjectR NR R (externalBuffer r off count) (externalBuffer (R.region r) off count) :=
    .obj (.node _ (.cons (.node _ (.cons (.region r) (.cons (.atom _ _) (.cons (.atom _ _) .nil))))
      (.cons (.value hproto) (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have hol : treeSupport (LiveAfter live s₀.next) (Encode.hobj (externalBuffer r off count)) :=
    ⟨⟨⟨True.intro,True.intro,True.intro,True.intro⟩,
      Or.inl hp,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have hh := h.alloc _ _ ho hol hs ht
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have hv : ValueR NR R (.obj s₀.next) (.obj s.next) := by
    simpa only [hn] using (ValueR.obj (NR := NR) (R := R) s₀.next)
  exact hh.go (.node _ (.cons (.value hv) .nil)) ⟨Or.inr rfl,True.intro⟩

theorem step_toArrayBuffer_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj)
    (data : List Val) (this : Val) (r origin off count : Nat) (x y : F64)
    (hc : s.ctl = .call (.obj a) this [.ptr (.ext r) origin,.num (.lit x),.num (.lit y)])
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .fn (.native (.ffi .toArrayBuffer) data))
    (hx : F64.toIndex? x = some off) (hy : F64.toIndex? y = some count) :
    step F s = M.pure ((s.alloc (externalBuffer r (origin+off) count)).2.ret (.obj s.next)) := by
  rw [step_native_eq F s a o (.ffi .toArrayBuffer) data this _ hc ho hk]
  simp only [callNative]
  rw [ffiN_toArrayBuffer_ext F s this data r origin off count (.num (.lit x)) (.num (.lit y))
    (by simp only [offsetArg,hx]) (by simp only [offsetArg,hy])]
  rfl

/-- The actual Bun builtin's callee, pointer and fresh allocation are derived
from the source state. Only the offset/count occurrence annotations need to
be retained by the preceding expression proof; plain numeric-role existence
does not suffice because the interpreter requires literal offsets. -/
theorem step_toArrayBuffer_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (ν : Nat → F64)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (data₀ : List Val) (this₀ : Val)
    (r origin off count : Nat) (x y : F64)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ [.ptr (.ext r) origin,.num (.lit x),.num (.lit y)])
    (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.native (.ffi .toArrayBuffer) data₀))
    (hx : F64.toIndex? x = some off) (hy : F64.toIndex? y = some count)
    (offsetRole : (Annotated.Value.literal (.lit x)).Holds ν C R (callArgument s.ctl 1))
    (countRole : (Annotated.Value.literal (.lit y)).Holds ν C R (callArgument s.ctl 2))
    (hp : live aArrayBufferProto) (hpr : R.a aArrayBufferProto = aArrayBufferProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    interpC (step F s₀).run C₀ =
      some ((s₀.alloc (externalBuffer r (origin+off) count)).2.ret (.obj s₀.next),C₀) ∧
    interpC (step F s).run C =
      some ((s.alloc (externalBuffer (R.region r) (origin+off) count)).2.ret (.obj s.next),C) ∧
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (externalBuffer r (origin+off) count)).2.ret (.obj s₀.next))
      ((s.alloc (externalBuffer (R.region r) (origin+off) count)).2.ret (.obj s.next)) := by
  obtain ⟨o,data,this,args,hc,ho,hk,_,_,hargs⟩ := h.native_call_view a o₀
    (.ffi .toArrayBuffer) data₀ this₀ _ hc₀ ho₀ hk₀
  cases hargs with | cons hpointer hargs =>
    cases hargs with | cons hoffset hargs =>
      cases hargs with | cons hcount hargs =>
        cases hargs
        cases hpointer
        have heoff := fixed_literal_value offsetRole
        have hecount := fixed_literal_value countRole
        simp only [hc,callArgument,Host.Ts.arg,nthD] at heoff hecount
        rw [heoff,hecount] at hc
        refine ⟨?_,?_,h.alloc_externalBuffer r (origin+off) count hp hpr hs ht⟩
        · rw [step_toArrayBuffer_eq F s₀ a o₀ data₀ this₀ r origin off count x y hc₀ ho₀ hk₀ hx hy]; rfl
        · rw [step_toArrayBuffer_eq F s (R.a a) o data this (R.region r) origin off count x y hc ho hk hx hy]; rfl

end Host.Ts.Owned.Parametric
