import host.ts.RenameParametricTypedBuffer
import host.mlx.NativeHostState
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem cellParts_roles {NR : NumV → NumV → Prop} {R : Ren} {c c' : Cell}
    (hc : CellR NR R c c') (k : EltK) :
    ∀ n i, ListR (ByteR NR R) (cellParts k c n i) (cellParts k c' n i)
  | 0,_ => .nil
  | n+1,i => .cons (.part k i hc) (cellParts_roles hc k n (i+1))

def bytesObject (bytes : List Byte) : HObj :=
  .obj ⟨.buf bytes,.obj aArrayBufferProto,[],[],true⟩

theorem bytes_support (live : Nat → Prop) (bs : List Byte) : treeSupport live (Encode.seq (bs.map Encode.byte)) := by
  induction bs with
  | nil => exact True.intro
  | cons b bs ih => exact ⟨True.intro,ih⟩

theorem StateR.newTyped_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (k : EltK) (proto count : Nat) (bs₀ bs : List Byte) (bytes : ListR (ByteR NR R) bs₀ bs)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    StateR NR FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) framed before after old old'
      ((newTyped F s₀ k proto bs₀ count).2.ret (.obj (s₀.next+1)))
      ((newTyped F s k proto bs count).2.ret (.obj (s.next+1))) := by
  have hp : ValueR NR R (.obj aArrayBufferProto) (.obj aArrayBufferProto) := by
    simpa only [bufferProtoFixed] using ValueR.obj (NR:=NR) (R:=R) aArrayBufferProto
  have ho : HeapObjectR NR R (bytesObject bs₀) (bytesObject bs) :=
    .obj (.node _ (.cons (.node _ (.cons (bytes_roles bytes) .nil))
      (.cons (.value hp) (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have support : treeSupport (LiveAfter live s₀.next) (Encode.hobj (bytesObject bs₀)) :=
    ⟨⟨⟨bytes_support _ bs₀,True.intro⟩,Or.inl bufferProtoLive,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have hb := h.alloc _ _ ho support (by omega) (by omega)
  have ht := hb.alloc_typedBuffer k s₀.next 0 count proto (Or.inr rfl) (Or.inl protoLive) protoFixed
    sourceBound targetBound
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  simpa only [newTyped,St.allocObj,bytesObject,typedBuffer,hn,St.alloc] using ht

def ArrayData {S : Type} (s : St S) (a : Nat) (values : List Val) : Prop :=
  ∃ o, s.heap.get a = some (.obj o) ∧ o.kind = .array values

theorem ArrayData.heap_eq {S : Type} {s t : St S} {a : Nat} {values : List Val}
    (h : ArrayData s a values) (hh : t.heap = s.heap) : ArrayData t a values := by
  obtain ⟨o,ho,hk⟩ := h
  refine ⟨o,?_,hk⟩
  rw [hh]
  exact ho

theorem newTyped_buffer_object (F : Ffi) (s : St F.S) (k : EltK) (proto count : Nat) (bs : List Byte)
    (bound : s.next+1 < 2^64) :
    ((newTyped F s k proto bs count).2.ret (.obj (s.next+1))).obj? s.next =
      some ⟨.buf bs,.obj aArrayBufferProto,[],[],true⟩ := by
  have hb : s.next < 2^64 := by omega
  simp only [newTyped,St.allocObj,St.alloc,St.obj?,St.ret,
    PTrie.get_set_u64 _ _ _ bound,PTrie.get_set_u64 _ _ _ hb,
    ite_eq_right (show s.next ≠ s.next+1 by omega),ite_true]

theorem cellsOf_u64_zero : cellsOf .u64 [.big 0] = M.pure (some [.big 0]) := rfl

theorem step_construct_u64_zero_eq (F : Ffi) (s : St F.S) (a b proto : Nat) (o bo : Obj)
    (nt : Val) (x y : F64) (hc : s.ctl = .construct (.obj a) [.obj b] nt)
    (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (hbo : s.heap.get b = some (.obj bo)) (hbk : bo.kind = .array [.big 0])
    (hx : F64.toIndex? x = some 9) (hy : F64.toIndex? y = some proto) :
    step F s = M.pure ((newTyped F s .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s.next+1))) := by
  simp only [step,hc,constructStep,St.obj?,ho,hk,constructNative,bufN,hx,hy]
  obtain ⟨kind,pr,props,priv,ext⟩ := bo
  dsimp only at hbk
  subst kind
  simp only [bufN.typedCtor,Host.Ts.arg,nthD,St.obj?,hbo,elemsOf,retS]
  rfl

/-- BigUint64Array([0n]) runs the original iterable conversion and two fresh
allocations. Its zero is ordinary integer data; no handle renaming is applied. -/
theorem step_construct_u64_zero_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (ν : Nat → F64)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a b proto : Nat) (o₀ bo₀ : Obj) (nt₀ : Val) (x y : F64)
    (hc₀ : s₀.ctl = .construct (.obj a) [.obj b] nt₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (hbo₀ : s₀.heap.get b = some (.obj bo₀)) (hbk₀ : bo₀.kind = .array [.big 0])
    (hx : F64.toIndex? x = some 9) (hy : F64.toIndex? y = some proto)
    (contents : ArrayData s (R.a b) [.big 0])
    (codeRole : (Annotated.Value.literal (.lit x)).Holds ν C R (nativeDataArgument s (R.a a) 0))
    (protoRole : (Annotated.Value.literal (.lit y)).Holds ν C R (nativeDataArgument s (R.a a) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    interpC (step F s₀).run C₀ = some
        ((newTyped F s₀ .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s₀.next+1)),C₀) ∧
      interpC (step F s).run C = some
        ((newTyped F s .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s.next+1)),C) ∧
      StateR NR FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) framed before after old old'
        ((newTyped F s₀ .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s₀.next+1)))
        ((newTyped F s .u64 proto (cellParts .u64 (.big 0) 8 0) 1).2.ret (.obj (s.next+1))) := by
  obtain ⟨o,data,nt,args,hc,ho,hk,hdata,_,hargs⟩ := h.native_construct_view a o₀
    (.buf .typedCtor) [.num (.lit x),.num (.lit y)] nt₀ _ hc₀ ho₀ hk₀
  cases hargs with | cons harg hargs =>
    cases hargs
    cases harg
    obtain ⟨bo,hbo,hbk⟩ := contents
    cases hdata with | cons hcode hdata =>
      cases hdata with | cons hproto hdata =>
        cases hdata
        have hecode := fixed_literal_value codeRole
        have heproto := fixed_literal_value protoRole
        simp only [nativeDataArgument,St.obj?,ho,hk,Host.Ts.arg,nthD] at hecode heproto
        rw [hecode,heproto] at hk
        refine ⟨?_,?_,StateR.newTyped_roles F NR FR R live framed before after old old' s₀ s h .u64 proto 1 _ _
          (cellParts_roles (.ordinaryBig 0) .u64 8 0) bufferProtoLive bufferProtoFixed protoLive protoFixed sourceBound targetBound⟩
        · rw [step_construct_u64_zero_eq F s₀ a b proto o₀ bo₀ nt₀ x y hc₀ ho₀ hk₀ hbo₀ hbk₀ hx hy]; rfl
        · rw [step_construct_u64_zero_eq F s (R.a a) (R.a b) proto o bo nt x y hc ho hk hbo hbk hx hy]; rfl
end Host.Ts.Owned.Parametric
