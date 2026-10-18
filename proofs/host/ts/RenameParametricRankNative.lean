import host.mlx.NativeSymbol
import host.mlx.NativeShapeRead

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem decodeArgs_one_u64 (F : Ffi) (s : St F.S) (i : Int) :
    decodeArgs F s [.str chars!"u64"] [.big i] = M.pure (some [.big i]) := by
  have hptr : nameEq chars!"u64" chars!"ptr" = false := by decide +kernel
  have hpointer : nameEq chars!"u64" chars!"pointer" = false := by decide +kernel
  have hbuffer : nameEq chars!"u64" chars!"buffer" = false := by decide +kernel
  have hcstring : nameEq chars!"u64" chars!"cstring" = false := by decide +kernel
  have hu64 : nameEq chars!"u64" chars!"u64" = true := Nat.beq_refl _
  funext β k
  simp only [decodeArgs,decodeArg,hptr,hpointer,hbuffer,hcstring,hu64,
    Bool.false_or,Bool.true_or,Bool.cond_false,Bool.cond_true,M.bind,M.pure,Option.map_some]

theorem step_ffi_one_u64 (F : Ffi) (s : St F.S) (fn types : Nat) (i : Int)
    (name returns : Name) (fo to : Obj) (receiver : Val) (native : F.S) (result : Ret)
    (hc : s.ctl = .call (.obj fn) receiver [.big i])
    (hf : s.obj? fn = some fo)
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str name,.obj types,.str returns]))
    (ht : s.obj? types = some to) (htk : to.kind = .array [.str chars!"u64"])
    (hcall : F.call s.ffi name [.big i] = M.pure (some (native,result,[]))) :
    step F s = ffiDone F s name [.big i] (some (native,result,[])) := by
  funext β k
  simp only [step,hc,callStep,hf,hk,callNative,ffiN]
  rw [elemsOf_array F s types to _ ht htk]
  dsimp only [M.bind,M.pure]
  rw [decodeArgs_one_u64 F s i]
  simp only [M.bind,M.pure]
  rw [hcall]
  rfl

theorem event_handle_rank {NR : NumV → NumV → Prop} (R : Ren) (name : Name) (handle rank : Nat) :
    TreeR NR R
      (event ⟨name,[.big (Int.ofNat handle)],.big (Int.ofNat rank)⟩)
      (event ⟨name,[.big (Int.ofNat (R.handle handle))],.big (Int.ofNat rank)⟩) := by
  exact .node _ (.cons (.atom _ _) (.cons
    (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
    (.cons (.node _ (.cons (.value (.ordinaryBig _)) .nil)) .nil)))

/-- Native rank depends on shape-list length, which the indexed native relation
preserves even when the dimensions have different numeric values. -/
theorem native_ndim_pair {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop}
    {ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s₀ s : Host.Load.LSt}
    (h : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail s₀.mlx s.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR NR n.shape n'.shape)
    (handle : Nat) (live : H handle) (node : Host.Mlx.Ffi.Node)
    (source : s₀.mlx.node? handle = some node) :
    Host.Load.call s₀ chars!"mlx_array_ndim" [.big (Int.ofNat handle)] =
      M.pure (some (s₀,.big (Int.ofNat (len node.shape)),[])) ∧
    Host.Load.call s chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] =
      M.pure (some (s,.big (Int.ofNat (len node.shape)),[])) := by
  obtain ⟨i,node',_,hn,hr⟩ := h.node? live source
  refine ⟨Host.Load.Owned.call_ndim s₀ handle node source,?_⟩
  have hc := Host.Load.Owned.call_ndim s (R.handle handle) node' hn
  rw [← (shape i node node' hr).len_eq] at hc
  exact hc

/-- Original symbol dispatch and native rank lookup determine the target rank
return and preserve the full machine relation. The handle occurrence is owned;
the rank return is ordinary integer data. -/
theorem step_ndim_from_source
    (NR : NumV → NumV → Prop) (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St Host.Load.LSt)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR NR n.shape n'.shape)
    (fn types handle : Nat) (fo to : Obj) (returns : Name) (receiver : Val) (node : Host.Mlx.Ffi.Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_ndim",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj to)) (htk₀ : to.kind = .array [.str chars!"u64"])
    (typeFrame : ¬ framed types) (handleLive : H handle)
    (sourceNode : s₀.ffi.mlx.node? handle = some node)
    (handleRole : (Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step Host.Load.ffi s₀).run C₀ =
      some (finishBig s₀ s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] (Int.ofNat (len node.shape)),C₀) ∧
    interpC (step Host.Load.ffi s).run C =
      some (finishBig s s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape)),C) ∧
    StateR NR FR R live framed before after old old'
      (finishBig s₀ s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] (Int.ofNat (len node.shape)))
      (finishBig s s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape))) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by
    have hl := hol.1
    rw [hk₀] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol)
    _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hv ha =>
          cases ha
          have he := fixed_handle_value handleRole
          simp only [hc,callArgument,Host.Ts.arg,nthD] at he
          rw [he] at hc
          obtain ⟨to',hto,htr,_⟩ := h.heap.readObject types to signatureLive typeFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          cases htys with | cons hu htys =>
            cases htys
            cases hu
            obtain ⟨call₀,call'⟩ := native_ndim_pair native shape handle handleLive node sourceNode
            have call₀' : Host.Load.ffi.call s₀.ffi chars!"mlx_array_ndim" [.big (Int.ofNat handle)] =
                M.pure (some (s₀.ffi,.big (Int.ofNat (len node.shape)),[])) := by
              simpa only [Host.Load.ffi] using call₀
            have call'' : Host.Load.ffi.call s.ffi chars!"mlx_array_ndim" [.big (Int.ofNat (R.handle handle))] =
                M.pure (some (s.ffi,.big (Int.ofNat (len node.shape)),[])) := by
              simpa only [Host.Load.ffi] using call'
            refine ⟨?_,?_,h.finishBig s₀.ffi s.ffi h.native _ _ _ _ _
              (event_handle_rank R _ handle _) (.ordinaryBig _)⟩
            · have hs := step_ffi_one_u64 Host.Load.ffi s₀ fn types (Int.ofNat handle) chars!"mlx_array_ndim" returns fo to receiver
                s₀.ffi (.big (Int.ofNat (len node.shape))) hc₀
                (by simp only [St.obj?,hf₀]) hk₀ (by simp only [St.obj?,ht₀]) htk₀ call₀'
              rw [hs,ffiDone_big_empty Host.Load.ffi s₀ s₀.ffi chars!"mlx_array_ndim"
                [.big (Int.ofNat handle)] (Int.ofNat (len node.shape))]; rfl
            · have hs := step_ffi_one_u64 Host.Load.ffi s (R.a fn) (R.a types) (Int.ofNat (R.handle handle))
                chars!"mlx_array_ndim" returns fo' to' this s.ffi (.big (Int.ofNat (len node.shape))) hc
                (by simp only [St.obj?,hfo]) hfk (by simp only [St.obj?,hto]) htKind call''
              rw [hs,ffiDone_big_empty Host.Load.ffi s s.ffi chars!"mlx_array_ndim"
                [.big (Int.ofNat (R.handle handle))] (Int.ofNat (len node.shape))]; rfl


def finishPointer {S : Type} (s : St S) (native : S) (name : Name) (args : List Arg) (region off : Nat) : St S :=
  ((s.setFfi native).setTrace (⟨name,args,.ptr region off⟩::s.trace)).ret (.ptr (.ext region) off)

theorem ffiDone_pointer_empty (F : Ffi) (s : St F.S) (native : F.S)
    (name : Name) (args : List Arg) (region off : Nat) :
    ffiDone F s name args (some (native,.ptr region off,[])) = M.pure (finishPointer s native name args region off) := rfl

theorem finishPointer_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (name : Name) (handle region off : Nat) :
    StateR NR FR R live framed before after old old'
      (finishPointer s₀ s₀.ffi name [.big (Int.ofNat handle)] region off)
      (finishPointer s s.ffi name [.big (Int.ofNat (R.handle handle))] (R.region region) off) := by
  have he : TreeR NR R
      (event ⟨name,[.big (Int.ofNat handle)],.ptr region off⟩)
      (event ⟨name,[.big (Int.ofNat (R.handle handle))],.ptr (R.region region) off⟩) :=
    .node _ (.cons (.atom _ _) (.cons
      (.node _ (.cons (.node _ (.cons (.value (.handle handle)) .nil)) .nil))
      (.cons (.node _ (.cons (.region region) (.cons (.atom _ _) .nil))) .nil)))
  exact ((h.setFfi s₀.ffi s.ffi h.native).traceCons _ _ he).go
    (.node _ (.cons (.value (.ptr (.ext region) off)) .nil)) ⟨True.intro,True.intro⟩

/-- Native shape metadata returns the owned handle's shape-memory region through
original symbol dispatch. The region equation is part of pointer ownership. -/
theorem step_shape_from_source
    (NR : NumV → NumV → Prop) (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (ν : Nat → F64) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St Host.Load.LSt)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live NR R NodeRel ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (fn types handle : Nat) (fo to : Obj) (returns : Name) (receiver : Val) (node : Host.Mlx.Ffi.Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat handle)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_shape",.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj to)) (htk₀ : to.kind = .array [.str chars!"u64"])
    (typeFrame : ¬ framed types) (handleLive : H handle)
    (sourceNode : s₀.ffi.mlx.node? handle = some node)
    (region : R.region (4*handle) = 4*R.handle handle)
    (handleRole : (Annotated.Value.handle handle).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step Host.Load.ffi s₀).run C₀ =
      some (finishPointer s₀ s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] (4*handle) 0,C₀) ∧
    interpC (step Host.Load.ffi s).run C =
      some (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0,C) ∧
    StateR NR FR R live framed before after old old'
      (finishPointer s₀ s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] (4*handle) 0)
      (finishPointer s s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by
    have hl := hol.1
    rw [hk₀] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,ha⟩ := h.native_call_view fn fo (.ffi .symbol)
    _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        cases ha with | cons hv ha =>
          cases ha
          have he := fixed_handle_value handleRole
          simp only [hc,callArgument,Host.Ts.arg,nthD] at he
          rw [he] at hc
          obtain ⟨to',hto,htr,_⟩ := h.heap.readObject types to signatureLive typeFrame ht₀
          have htKind := htr.kind
          rw [htk₀] at htKind
          obtain ⟨tys,htKind,htys⟩ := kind_array htKind
          cases htys with | cons hu htys =>
            cases htys
            cases hu
            obtain ⟨_,node',_,hn,_⟩ := native.node? handleLive sourceNode
            have call₀ := Host.Load.Owned.call_shape s₀.ffi handle node sourceNode
            have call' := Host.Load.Owned.call_shape s.ffi (R.handle handle) node' hn
            rw [← region] at call'
            have call₀' : Host.Load.ffi.call s₀.ffi chars!"mlx_array_shape" [.big (Int.ofNat handle)] =
                M.pure (some (s₀.ffi,.ptr (4*handle) 0,[])) := by
              simpa only [Host.Load.ffi] using call₀
            have call'' : Host.Load.ffi.call s.ffi chars!"mlx_array_shape" [.big (Int.ofNat (R.handle handle))] =
                M.pure (some (s.ffi,.ptr (R.region (4*handle)) 0,[])) := by
              simpa only [Host.Load.ffi] using call'
            refine ⟨?_,?_,finishPointer_roles h chars!"mlx_array_shape" handle (4*handle) 0⟩
            · have hs := step_ffi_one_u64 Host.Load.ffi s₀ fn types (Int.ofNat handle) chars!"mlx_array_shape" returns fo to receiver
                s₀.ffi (.ptr (4*handle) 0) hc₀
                (by simp only [St.obj?,hf₀]) hk₀ (by simp only [St.obj?,ht₀]) htk₀ call₀'
              rw [hs,ffiDone_pointer_empty Host.Load.ffi s₀ s₀.ffi chars!"mlx_array_shape"
                [.big (Int.ofNat handle)] (4*handle) 0]; rfl
            · have hs := step_ffi_one_u64 Host.Load.ffi s (R.a fn) (R.a types) (Int.ofNat (R.handle handle))
                chars!"mlx_array_shape" returns fo' to' this s.ffi (.ptr (R.region (4*handle)) 0) hc
                (by simp only [St.obj?,hfo]) hfk (by simp only [St.obj?,hto]) htKind call''
              rw [hs,ffiDone_pointer_empty Host.Load.ffi s s.ffi chars!"mlx_array_shape"
                [.big (Int.ofNat (R.handle handle))] (R.region (4*handle)) 0]; rfl

/-- `Number` turns ordinary integer data into its actual binary64 literal. In
particular, a native rank return cannot become an unresolved numeric reference. -/
theorem step_number_integer_from_source (F : Ffi)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn : Nat) (fo : Obj) (data : List Val) (receiver : Val) (i : Int)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big i])
    (hf₀ : s₀.heap.get fn = some (.obj fo)) (hk₀ : fo.kind = .fn (.native (.num .number) data))
    (integerRole : (Annotated.Value.ordinaryBig i).Holds ν C R (callArgument s.ctl 0)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (intV i),C₀) ∧
    interpC (step F s).run C = some (s.ret (intV i),C) ∧
    StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (s₀.ret (intV i)) (s.ret (intV i)) := by
  obtain ⟨fo',data',this,args,hc,hfo,hfk,_,_,ha⟩ := h.native_call_view fn fo (.num .number)
    data receiver [.big i] hc₀ hf₀ hk₀
  cases ha with | cons hv ha =>
    cases ha
    have he := fixed_ordinary_big_value integerRole
    simp only [hc,callArgument,Host.Ts.arg,nthD] at he
    rw [he] at hc
    have hv : ValueR (NumberRoles ν₀ ν C₀ C) R (intV i) (intV i) :=
      .num ⟨.lit (F64.ofInt i),NumRole.literal ν₀ ν C₀ C (F64.ofInt i)⟩
    refine ⟨?_,?_,h.go (.node _ (.cons (.value hv) .nil)) ⟨True.intro,True.intro⟩⟩
    · rw [step_native_eq F s₀ fn fo (.num .number) data receiver [.big i] hc₀ hf₀ hk₀]; rfl
    · rw [step_native_eq F s (R.a fn) fo' (.num .number) data' this [.big i] hc hfo hfk]; rfl

end Host.Ts.Owned.Parametric
