import host.mlx.NativeSliceUpdateRoles
import host.mlx.NativeSliceDynamicHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.SliceUpdateHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_slice_update"
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"ptr",
  .str chars!"u64",.str chars!"ptr",.str chars!"u64",.str chars!"ptr",.str chars!"u64",.str chars!"u64"]

def arguments (out handle update st sn sp en sr rn stream : Nat) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle handle,.handle update,.pointer st 0,.integer (Int.ofNat sn),
    .pointer sp 0,.integer (Int.ofNat en),.pointer sr 0,.integer (Int.ofNat rn),.handle stream]

def callArgs (out handle update st sn sp en sr rn stream : Nat) (bo bs be br : List Byte) : List Arg :=
  [.jsPtr out 0 bo,.big (Int.ofNat handle),.big (Int.ofNat update),.jsPtr st 0 bs,.big (Int.ofNat sn),
    .jsPtr sp 0 be,.big (Int.ofNat en),.jsPtr sr 0 br,.big (Int.ofNat rn),.big (Int.ofNat stream)]

def resultWorld (s : LSt) (input update : Nat) (st sp sr : List Dim) (node : Node) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (sliceUpdateNode input update st sp sr node)}

theorem decode_sliceUpdate (s : Host.Ts.St LSt) (out st sp sr : Nat)
    (handle update sn en rn stream : Int) (bo bs be br : List Byte)
    (ho : bufBytes F s out = some bo) (hs : bufBytes F s st = some bs)
    (he : bufBytes F s sp = some be) (hr : bufBytes F s sr = some br) :
    decodeArgs F s signature [.ptr (.js out) 0,.big handle,.big update,.ptr (.js st) 0,.big sn,
      .ptr (.js sp) 0,.big en,.ptr (.js sr) 0,.big rn,.big stream] =
      M.pure (some [.jsPtr out 0 bo,.big handle,.big update,.jsPtr st 0 bs,.big sn,
        .jsPtr sp 0 be,.big en,.jsPtr sr 0 br,.big rn,.big stream]) := by
  simpa only [signature,List.drop_zero] using decodeArgs_ptr_u64_tail F s out 0 handle bo _ _ _ ho
    (decodeArgs_u64_tail F s update _ _ _
      (decodeArgs_ptr_u64_tail F s st 0 sn bs _ _ _ hs
        (decodeArgs_ptr_u64_tail F s sp 0 en be _ _ _ he
          (decodeArgs_ptr_u64_tail F s sr 0 rn br _ _ _ hr (decodeArgs_one_u64 F s stream)))))

theorem step_sliceUpdate_eq (s : Host.Ts.St LSt) (fn types out handle update st sn sp en sr rn stream : Nat)
    (fo signature₀ buffer : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (bo bs be br : List Byte) (native : LSt) (writes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat update),
      .ptr (.js st) 0,.big (Int.ofNat sn),.ptr (.js sp) 0,.big (Int.ofNat en),
      .ptr (.js sr) 0,.big (Int.ofNat rn),.big (Int.ofNat stream)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer)) (hbk : buffer.kind = .buf bo)
    (hs : bufBytes F s st = some bs) (he : bufBytes F s sp = some be) (hr : bufBytes F s sr = some br)
    (nativeCall : F.call s.ffi symbol (callArgs out handle update st sn sp en sr rn stream bo bs be br) =
      M.pure (some (native,status0,[(out,0,writes)]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer bo writes symbol
      (callArgs out handle update st sn sp en sr rn stream bo bs be br)) := by
  have ho := bufBytes_of_obj F s out buffer bo (by simp only [Host.Ts.St.obj?,hb]) hbk
  have hd := decode_sliceUpdate s out st sp sr (Int.ofNat handle) (Int.ofNat update)
    (Int.ofNat sn) (Int.ofNat en) (Int.ofNat rn) (Int.ofNat stream) bo bs be br ho hs he hr
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _ native status0 [(out,0,writes)]
    hc (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk hd nativeCall]
  exact ffiDone_status0_buffer F s native out 0 buffer bo writes symbol _ (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- The original ten-argument cache update. Indexed native annotations retain
the input and update roles; literal dimensions may vary with the valuation.
Both decodes and native inference follow from the three annotated buffers and
their bounds, rather than target execution premises. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out handle update input updateInput st sp sr stream : Nat)
    (fo signature₀ outObject startObject stopObject strideObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (startBytes₀ stopBytes₀ strideBytes₀ : List Byte) (starts stops strides : Shape) (node updateNode : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat update),
      .ptr (.js st) 0,.big (Int.ofNat starts.length),.ptr (.js sp) 0,.big (Int.ofNat stops.length),
      .ptr (.js sr) 0,.big (Int.ofNat strides.length),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (hs₀ : s₀.heap.get st = some (.obj startObject)) (hsk₀ : startObject.kind = .buf startBytes₀)
    (he₀ : s₀.heap.get sp = some (.obj stopObject)) (hek₀ : stopObject.kind = .buf stopBytes₀)
    (hr₀ : s₀.heap.get sr = some (.obj strideObject)) (hrk₀ : strideObject.kind = .buf strideBytes₀)
    (signatureFrame : ¬ framed types) (handleLive : H handle) (updateLive : H update)
    (producers : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [handle,update] = some [input,updateInput])
    (sourceNode : s₀.ffi.mlx.nodes.get input = some node) (sourceUpdate : s₀.ffi.mlx.nodes.get updateInput = some updateNode)
    (sourceStarts : ShapeBuffer.Holds starts ν₀ C₀ startBytes₀)
    (sourceStops : ShapeBuffer.Holds stops ν₀ C₀ stopBytes₀)
    (sourceStrides : ShapeBuffer.Holds strides ν₀ C₀ strideBytes₀)
    (startsDecodable : starts.Decodable) (stopsDecodable : stops.Decodable) (stridesDecodable : strides.Decodable)
    (sourceGeometry : SliceUpdateGeometry ν₀ (roles input).shape (roles updateInput).shape starts stops strides)
    (targetGeometry : SliceUpdateGeometry ν (roles input).shape (roles updateInput).shape starts stops strides)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v)
      (arguments out handle update st starts.length sp stops.length sr strides.length stream) (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (startRole : ShapeBuffer.Holds starts ν C (ShapeBuffer.bytesAt s (R.a st)))
    (stopRole : ShapeBuffer.Holds stops ν C (ShapeBuffer.bytesAt s (R.a sp)))
    (strideRole : ShapeBuffer.Holds strides ν C (ShapeBuffer.bytesAt s (R.a sr)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ stDims spDims srDims t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi input updateInput stDims spDims srDims node) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out handle update st starts.length sp stops.length sr strides.length stream
            (cellParts .u64 (.big (Int.ofNat 0)) 8 0) startBytes₀ stopBytes₀ strideBytes₀),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (nodeWrite roles s₀.ffi.mlx.nnext (sliceUpdateRole roles input updateInput starts stops strides)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi input updateInput stDims spDims srDims node) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out handle update st starts.length sp stops.length sr strides.length stream
            (cellParts .u64 (.big (Int.ofNat 0)) 8 0) startBytes₀ stopBytes₀ strideBytes₀)) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  have startLive : live st := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.1
  have stopLive : live sp := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.2.2.1
  have strideLive : live sr := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.2.2.2.2.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by
    have hl := hol.1
    rw [hk₀] at hl
    exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view fn fo (.ffi .symbol) _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        have argsExact := Host.Ts.Owned.Annotated.FixedArgument.list_exact _ argumentRoles
        simp only [hc,callArguments] at argsExact
        rw [argsExact] at hc
        simp only [arguments,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil] at hc
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"ptr",chars!"u64",
          chars!"ptr",chars!"u64",chars!"ptr",chars!"u64",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := h.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀ outputRole
        rw [VectorGetHost.null_bytes] at hok hbo
        obtain ⟨start',hs,hrs,_⟩ := h.heap.readObject st startObject startLive
          (h.heap.buffer_notFramed st startObject startBytes₀ startLive hs₀ hsk₀) hs₀
        have startKind := hrs.kind
        rw [hsk₀] at startKind
        obtain ⟨startBytes,hsk,hbs⟩ := kind_buffer startKind
        have startFields : ShapeBuffer.Holds starts ν C startBytes := by
          simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,hs,hsk] using startRole
        obtain ⟨stop',he,hre,_⟩ := h.heap.readObject sp stopObject stopLive
          (h.heap.buffer_notFramed sp stopObject stopBytes₀ stopLive he₀ hek₀) he₀
        have stopKind := hre.kind
        rw [hek₀] at stopKind
        obtain ⟨stopBytes,hek,hbe⟩ := kind_buffer stopKind
        have stopFields : ShapeBuffer.Holds stops ν C stopBytes := by
          simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,he,hek] using stopRole
        obtain ⟨stride',hr,hrr,_⟩ := h.heap.readObject sr strideObject strideLive
          (h.heap.buffer_notFramed sr strideObject strideBytes₀ strideLive hr₀ hrk₀) hr₀
        have strideKind := hrr.kind
        rw [hrk₀] at strideKind
        obtain ⟨strideBytes,hrk,hbr⟩ := kind_buffer strideKind
        have strideFields : ShapeBuffer.Holds strides ν C strideBytes := by
          simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,hr,hrk] using strideRole
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs out handle update st starts.length sp stops.length sr strides.length stream
          oldBytes startBytes₀ stopBytes₀ strideBytes₀
        let args' := callArgs (R.a out) (R.handle handle) (R.handle update) (R.a st) starts.length (R.a sp) stops.length
          (R.a sr) strides.length (R.handle stream) oldBytes startBytes stopBytes strideBytes
        have native := h.native.2
        obtain ⟨stDims,stDims',spDims,spDims',srDims,srDims',node',sourceCall,targetCall,nativeAfter⟩ := native.sliceUpdate_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 handle update input updateInput st sp sr startBytes₀ startBytes stopBytes₀ stopBytes strideBytes₀ strideBytes
          starts stops strides node updateNode ⟨handleLive,updateLive,True.intro⟩ producers sourceNode sourceUpdate rfl rfl
          sourceStarts startFields sourceStops stopFields sourceStrides strideFields startsDecodable stopsDecodable stridesDecodable
          sourceGeometry targetGeometry sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi input updateInput stDims spDims srDims node
        let native' := resultWorld s.ffi (R.node input) (R.node updateInput) stDims' spDims' srDims' node'
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (sliceUpdateRole roles input updateInput starts stops strides)) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) := by
          refine .cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ .nil)))))))))
          · exact .node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil)))
          · exact .node _ (.cons (.value (.handle handle)) .nil)
          · exact .node _ (.cons (.value (.handle update)) .nil)
          · exact .node _ (.cons (.address st) (.cons (.atom _ _) (.cons (bytes_roles hbs) .nil)))
          · exact .node _ (.cons (.value (.ordinaryBig (Int.ofNat starts.length))) .nil)
          · exact .node _ (.cons (.address sp) (.cons (.atom _ _) (.cons (bytes_roles hbe) .nil)))
          · exact .node _ (.cons (.value (.ordinaryBig (Int.ofNat stops.length))) .nil)
          · exact .node _ (.cons (.address sr) (.cons (.atom _ _) (.cons (bytes_roles hbr) .nil)))
          · exact .node _ (.cons (.value (.ordinaryBig (Int.ofNat strides.length))) .nil)
          · exact .node _ (.cons (.value (.handle stream)) .nil)
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) writes₀ writes' := by
          dsimp only [writes₀,writes']
          rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out outLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨stDims,spDims,srDims,t,?_,?_,post,?_⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          rw [step_sliceUpdate_eq s₀ fn types out handle update st starts.length sp stops.length sr strides.length stream
            fo signature₀ outObject returns receiver oldBytes startBytes₀ stopBytes₀ strideBytes₀ native₀ writes₀ hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀
            (bufBytes_of_obj F s₀ st startObject startBytes₀ (by simp only [Host.Ts.St.obj?,hs₀]) hsk₀)
            (bufBytes_of_obj F s₀ sp stopObject stopBytes₀ (by simp only [Host.Ts.St.obj?,he₀]) hek₀)
            (bufBytes_of_obj F s₀ sr strideObject strideBytes₀ (by simp only [Host.Ts.St.obj?,hr₀]) hrk₀) call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          rw [step_sliceUpdate_eq s (R.a fn) (R.a types) (R.a out) (R.handle handle) (R.handle update)
            (R.a st) starts.length (R.a sp) stops.length (R.a sr) strides.length (R.handle stream)
            fo' signature' out' returns this oldBytes startBytes stopBytes strideBytes native' writes' hc hfo hfk hto htKind ho hok
            (bufBytes_of_obj F s (R.a st) start' startBytes (by simp only [Host.Ts.St.obj?,hs]) hsk)
            (bufBytes_of_obj F s (R.a sp) stop' stopBytes (by simp only [Host.Ts.St.obj?,he]) hek)
            (bufBytes_of_obj F s (R.a sr) stride' strideBytes (by simp only [Host.Ts.St.obj?,hr]) hrk) call]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']
          rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next

end Host.Load.Run.Full.Ordinary.SliceUpdateHost
