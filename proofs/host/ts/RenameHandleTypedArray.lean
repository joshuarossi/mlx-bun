import host.ts.RenameParametricTypedArray
import host.ts.RenameParametricTypedElements

import host.mlx.NativeVectorObjects

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Word-sized handles survive the actual BigUint64Array element conversion. -/
theorem cellsOf_u64_handles (hs : List Nat) (bound : ∀ h ∈ hs, h < 2^64) :
    cellsOf .u64 (hs.map (fun h => Val.big (Int.ofNat h))) =
      M.pure (some (hs.map (fun h => Cell.big (Int.ofNat h)))) := by
  induction hs with
  | nil => rfl
  | cons h hs ih =>
    have hb := bound h (by simp)
    have tail : ∀ h ∈ hs, h < 2^64 := fun h hh => bound h (by simp [hh])
    have reduced : modInt (Int.ofNat h) (2^64) = h := by
      change h % (2^64) = h
      exact Nat.mod_eq_of_lt hb
    simp only [List.map_cons,cellsOf,toCell,reduced]
    rw [show cellsOf .u64 (hs.map (fun h => Val.big (Int.ofNat h))) =
      M.pure (some (hs.map (fun h => Cell.big (Int.ofNat h)))) from ih tail]
    rfl

theorem cellBytes_u64_handles (hs : List Nat) :
    cellBytes .u64 (hs.map (fun h => Cell.big (Int.ofNat h))) =
      Host.Mlx.Ffi.Annotated.VectorBuffer.bytes hs := by
  induction hs with
  | nil => rfl
  | cons h hs ih =>
    change cellParts .u64 (.big (Int.ofNat h)) 8 0 ++ cellBytes .u64 (hs.map _) = _
    rw [ih]
    rfl

theorem step_construct_u64_handles_eq (F : Ffi) (s : St F.S) (a b proto : Nat) (o bo : Obj)
    (nt : Val) (x y : F64) (hs : List Nat)
    (hc : s.ctl = .construct (.obj a) [.obj b] nt)
    (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (hbo : s.heap.get b = some (.obj bo))
    (hbk : bo.kind = .array (hs.map (fun h => Val.big (Int.ofNat h))))
    (hx : F64.toIndex? x = some 9) (hy : F64.toIndex? y = some proto)
    (bound : ∀ h ∈ hs, h < 2^64) :
    step F s = M.pure ((newTyped F s .u64 proto
      (Host.Mlx.Ffi.Annotated.VectorBuffer.bytes hs) hs.length).2.ret (.obj (s.next+1))) := by
  simp only [step,hc,constructStep,St.obj?,ho,hk,constructNative,bufN,hx,hy]
  obtain ⟨kind,pr,props,priv,ext⟩ := bo
  dsimp only at hbk
  subst kind
  simp only [bufN.typedCtor,Host.Ts.arg,nthD,St.obj?,hbo,elemsOf,retS]
  have pureBind {α β : Type} (v : α) (f : α → M β) : M.bind (M.pure v) f = f v := rfl
  rw [pureBind]
  simp only [eltOfCode]
  rw [cellsOf_u64_handles hs bound]
  rw [pureBind]
  simp only [cellBytes_u64_handles,len_list_length,List.length_map]
  rfl

/-- Iterable construction creates the exact tagged handle bytes used by the
native vector operation. The output annotation follows from the conversion. -/
theorem step_construct_u64_handles_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (ν : Nat → F64)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a b proto : Nat) (o₀ bo₀ : Obj) (nt₀ : Val) (x y : F64) (hs : List Nat)
    (hc₀ : s₀.ctl = .construct (.obj a) [.obj b] nt₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (hbo₀ : s₀.heap.get b = some (.obj bo₀))
    (hbk₀ : bo₀.kind = .array (hs.map (fun h => Val.big (Int.ofNat h))))
    (hx : F64.toIndex? x = some 9) (hy : F64.toIndex? y = some proto)
    (contents : ArrayData s (R.a b) ((hs.map R.handle).map (fun h => Val.big (Int.ofNat h))))
    (codeRole : (Annotated.Value.literal (.lit x)).Holds ν C R (nativeDataArgument s (R.a a) 0))
    (protoRole : (Annotated.Value.literal (.lit y)).Holds ν C R (nativeDataArgument s (R.a a) 1))
    (sourceHandles : ∀ h ∈ hs, h < 2^64) (targetHandles : ∀ h ∈ hs.map R.handle, h < 2^64)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live proto) (protoFixed : R.a proto = proto)
    (sourceBound : s₀.next+1 < 2^64) (targetBound : s.next+1 < 2^64) :
    interpC (step F s₀).run C₀ = some
      ((newTyped F s₀ .u64 proto (Host.Mlx.Ffi.Annotated.VectorBuffer.bytes hs) hs.length).2.ret (.obj (s₀.next+1)),C₀) ∧
    interpC (step F s).run C = some
      ((newTyped F s .u64 proto (Host.Mlx.Ffi.Annotated.VectorBuffer.bytes (hs.map R.handle)) hs.length).2.ret (.obj (s.next+1)),C) ∧
    StateR NR FR R (LiveAfter (LiveAfter live s₀.next) (s₀.next+1)) framed before after old old'
      ((newTyped F s₀ .u64 proto (Host.Mlx.Ffi.Annotated.VectorBuffer.bytes hs) hs.length).2.ret (.obj (s₀.next+1)))
      ((newTyped F s .u64 proto (Host.Mlx.Ffi.Annotated.VectorBuffer.bytes (hs.map R.handle)) hs.length).2.ret (.obj (s.next+1))) := by
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
        refine ⟨?_,?_,StateR.newTyped_roles F NR FR R live framed before after old old' s₀ s h .u64 proto hs.length _ _
          (Host.Mlx.Ffi.Annotated.VectorBuffer.related R hs) bufferProtoLive bufferProtoFixed protoLive protoFixed sourceBound targetBound⟩
        · rw [step_construct_u64_handles_eq F s₀ a b proto o₀ bo₀ nt₀ x y hs hc₀ ho₀ hk₀ hbo₀ hbk₀ hx hy sourceHandles]
          rfl
        · rw [step_construct_u64_handles_eq F s (R.a a) (R.a b) proto o bo nt x y (hs.map R.handle)
            hc ho hk hbo hbk hx hy targetHandles]
          simp only [List.length_map]
          rfl

theorem newTyped_heap_below (F : Ffi) (s : St F.S) (k : EltK) (proto count : Nat) (bs : List Byte)
    (bound : s.next+1 < 2^64) (a : Nat) (ha : a < s.next) :
    ((newTyped F s k proto bs count).2.ret (.obj (s.next+1))).heap.get a = s.heap.get a := by
  simp only [newTyped,St.allocObj,St.alloc,St.ret,PTrie.get_set_u64 _ _ _ bound,
    PTrie.get_set_u64 _ _ _ (show s.next < 2^64 by omega),
    ite_eq_right (show a ≠ s.next+1 by omega),ite_eq_right (Nat.ne_of_lt ha)]

end Host.Ts.Owned.Parametric
