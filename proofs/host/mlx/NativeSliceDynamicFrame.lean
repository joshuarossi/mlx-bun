import host.mlx.NativeSliceDynamicHost
import host.mlx.NativeWritesFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.SliceDynamicHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

/-- The original dynamic slice exposes the exact output-buffer frame.
Current indexed producer metadata determines both calls before that write. -/
theorem from_source_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out handle start input startInput axisBuffer axisCount sizeBuffer stream : Nat)
    (fo signature₀ outObject axisObject sizeObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (axisRoles : List Host.Ts.Owned.Annotated.FixedByte) (sizeBytes₀ : List Byte)
    (axes : List Nat) (sizeRoles : Shape) (node startNode : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat handle),.big (Int.ofNat start),
      .ptr (.js axisBuffer) 0,.big (Int.ofNat axisCount),.ptr (.js sizeBuffer) 0,
      .big (Int.ofNat sizeRoles.length),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (ha₀ : s₀.heap.get axisBuffer = some (.obj axisObject))
    (hak₀ : axisObject.kind = .buf (axisRoles.map Host.Ts.Owned.Annotated.FixedByte.value))
    (hs₀ : s₀.heap.get sizeBuffer = some (.obj sizeObject)) (hsk₀ : sizeObject.kind = .buf sizeBytes₀)
    (signatureFrame : ¬ framed types) (handleLive : H handle) (startLive : H start)
    (producers : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [handle,start] = some [input,startInput])
    (sourceNode : s₀.ffi.mlx.nodes.get input = some node) (sourceStart : s₀.ffi.mlx.nodes.get startInput = some startNode)
    (sourceAxes : (dimsArg (.jsPtr axisBuffer 0 (axisRoles.map Host.Ts.Owned.Annotated.FixedByte.value))
      (.big (Int.ofNat axisCount))).bind natsOfDims = some axes)
    (sourceSizes : ShapeBuffer.Holds sizeRoles ν₀ C₀ sizeBytes₀) (decodable : sizeRoles.Decodable)
    (rank : len sizeRoles = len (roles input).shape) (integer : isInteger (roles startInput).dtype = true)
    (startRank : Nat.ble (len (roles startInput).shape) 1 = true)
    (bounds : axes.all (Nat.blt · (len (roles input).shape)) = true)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v)
      (arguments out handle start axisBuffer axisCount sizeBuffer sizeRoles.length stream) (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (axisRole : (Host.Ts.Owned.Annotated.fixedBufferRole axisRoles).Holds ν C R (objectKindAt s (R.a axisBuffer)))
    (sizeRole : ShapeBuffer.Holds sizeRoles ν C (ShapeBuffer.bytesAt s (R.a sizeBuffer)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ sizes t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi input startInput axes sizes node.dtype) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out handle start axisBuffer axisCount sizeBuffer sizeRoles.length stream
            (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (axisRoles.map Host.Ts.Owned.Annotated.FixedByte.value) sizeBytes₀),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (nodeWrite roles s₀.ffi.mlx.nnext (sliceDynamicRole roles input startInput axes sizeRoles)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi input startInput axes sizes node.dtype) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out handle start axisBuffer axisCount sizeBuffer sizeRoles.length stream
            (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (axisRoles.map Host.Ts.Owned.Annotated.FixedByte.value) sizeBytes₀)) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s₀ (finishBuffer s₀ (resultWorld s₀.ffi input startInput axes sizes node.dtype) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0)
          symbol (callArgs out handle start axisBuffer axisCount sizeBuffer sizeRoles.length stream
            (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (axisRoles.map Host.Ts.Owned.Annotated.FixedByte.value) sizeBytes₀)) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s t ∧
      (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧ t.ctl = .ret (.num zeroN) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  have axisLive : live axisBuffer := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.1
  have sizeLive : live sizeBuffer := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.2.2.2.2.1
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
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"ptr",chars!"u64",chars!"ptr",chars!"u64",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := h.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀ outputRole
        rw [VectorGetHost.null_bytes] at hok hbo
        obtain ⟨axis',ha,hak,_,_,hba⟩ := h.read_fixed_buffer axisBuffer axisObject _ axisRoles axisLive ha₀ hak₀ axisRole
        obtain ⟨size',hs,hrs,_⟩ := h.heap.readObject sizeBuffer sizeObject sizeLive
          (h.heap.buffer_notFramed sizeBuffer sizeObject sizeBytes₀ sizeLive hs₀ hsk₀) hs₀
        have hsizeKind := hrs.kind
        rw [hsk₀] at hsizeKind
        obtain ⟨sizeBytes,hsk,hbs⟩ := kind_buffer hsizeKind
        have sizeFields : ShapeBuffer.Holds sizeRoles ν C sizeBytes := by
          simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,hs,hsk] using sizeRole
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let axisBytes := axisRoles.map Host.Ts.Owned.Annotated.FixedByte.value
        let args₀ := callArgs out handle start axisBuffer axisCount sizeBuffer sizeRoles.length stream oldBytes axisBytes sizeBytes₀
        let args' := callArgs (R.a out) (R.handle handle) (R.handle start) (R.a axisBuffer) axisCount (R.a sizeBuffer)
          sizeRoles.length (R.handle stream) oldBytes axisBytes sizeBytes
        have native := h.native.2
        obtain ⟨sizes,sizes',node',startNode',hn',hst',sourceCall,targetCall,nativeAfter⟩ := native.sliceDynamic_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 handle start input startInput axisBuffer axisCount sizeBuffer axisBytes sizeBytes₀ sizeBytes axes sizeRoles
          node startNode handleLive startLive producers sourceNode sourceStart rfl rfl sourceAxes sourceSizes sizeFields
          decodable rank integer startRank bounds sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi input startInput axes sizes node.dtype
        let native' := resultWorld s.ffi (R.node input) (R.node startInput) axes sizes' node'.dtype
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (sliceDynamicRole roles input startInput axes sizeRoles)) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) := by
          refine .cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ (.cons ?_ .nil)))))))
          · exact .node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil)))
          · exact .node _ (.cons (.value (.handle handle)) .nil)
          · exact .node _ (.cons (.value (.handle start)) .nil)
          · exact .node _ (.cons (.address axisBuffer) (.cons (.atom _ _) (.cons (bytes_roles hba) .nil)))
          · exact .node _ (.cons (.value (.ordinaryBig (Int.ofNat axisCount))) .nil)
          · exact .node _ (.cons (.address sizeBuffer) (.cons (.atom _ _) (.cons (bytes_roles hbs) .nil)))
          · exact .node _ (.cons (.value (.ordinaryBig (Int.ofNat sizeRoles.length))) .nil)
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
        refine ⟨sizes,t,?_,?_,post,?_,?_,?_,?_,rfl⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          rw [step_sliceDynamic_eq s₀ fn types out handle start axisBuffer axisCount sizeBuffer sizeRoles.length stream
            fo signature₀ outObject returns receiver oldBytes axisBytes sizeBytes₀ native₀ writes₀ hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀
            (bufBytes_of_obj F s₀ axisBuffer axisObject axisBytes (by simp only [Host.Ts.St.obj?,ha₀]) hak₀)
            (bufBytes_of_obj F s₀ sizeBuffer sizeObject sizeBytes₀ (by simp only [Host.Ts.St.obj?,hs₀]) hsk₀) call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          rw [step_sliceDynamic_eq s (R.a fn) (R.a types) (R.a out) (R.handle handle) (R.handle start)
            (R.a axisBuffer) axisCount (R.a sizeBuffer) sizeRoles.length (R.handle stream)
            fo' signature' out' returns this oldBytes axisBytes sizeBytes native' writes' hc hfo hfk hto htKind ho hok
            (bufBytes_of_obj F s (R.a axisBuffer) axis' axisBytes (by simp only [Host.Ts.St.obj?,ha]) hak)
            (bufBytes_of_obj F s (R.a sizeBuffer) size' sizeBytes (by simp only [Host.Ts.St.obj?,hs]) hsk) call]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']
          rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next

        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject oldBytes writes₀
            symbol args₀ ho₀ hok₀ sourceHeap
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' oldBytes writes'
            symbol args' ho hok targetOutBound
        · intro a different
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right different]

end Host.Load.Run.Full.Ordinary.SliceDynamicHost
