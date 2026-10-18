import host.mlx.NativeRopeHost
import host.mlx.NativeWritesFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RopeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

private theorem literal_number_view {ν : Nat → F64} {C : CSrv} {e : SymE} {value : NumV}
    (held : (Number.literal e).Holds ν C value) : ∃ x, value = .lit x ∧ NumDenote ν C e (.lit x) := by
  cases held with | literal _ x meaning => exact ⟨x,rfl,meaning⟩

/-- Literal offset occurrences keep their varying expression while both
original i32 decoders leave their independent numeric servers unchanged. -/
theorem from_literal_source_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out handle input stream dims : Nat) (dimValue : F64) (traditional : Bool) (base : Int) (scale : F64)
    (offset : SymE) (offset₀ : F64) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver (rawArgs out handle stream dimValue traditional base scale (.lit offset₀)))
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject)) (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [handle] = some [input]) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceOffset : (Number.literal offset).Holds ν₀ C₀ (.lit offset₀))
    (argumentRoles : ListR (ArgumentPattern.Holds ν C R)
      ((beforeArguments out handle dimValue traditional base scale).map .fixed ++ [.numeric (.literal offset)] ++ (afterArguments stream).map .fixed)
      (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (dimension : F64.toInt? dimValue = some (Int.ofNat dims)) (dimFixed : F64.un .int32 dimValue = dimValue) (positive : 0 < dims)
    (rank : Nat.ble 3 (len (roles input).shape) = true)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finish s₀ out handle input stream dims dimValue traditional base scale (.lit (F64.un .int32 offset₀)) node outObject,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (nodeWrite roles s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) ((Number.literal offset).decoded .i32)))
          boundary objects (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finish s₀ out handle input stream dims dimValue traditional base scale (.lit (F64.un .int32 offset₀)) node outObject) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν C R (objectKindAt t (R.a out)) ∧ TableExtends C₀ C₀ ∧ TableExtends C C ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s₀ (finish s₀ out handle input stream dims dimValue traditional base scale (.lit (F64.un .int32 offset₀)) node outObject) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s t ∧ (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧ t.ctl = .ret (.num zeroN) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have outLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by have hl := hol.1; rw [hk₀] at hl; exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view fn fo (.ffi .symbol) _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        obtain ⟨value,argsExact,targetOffset⟩ := ArgumentPattern.one_numeric_exact _ _ (Number.literal offset) argumentRoles
        simp only [hc,callArguments] at argsExact
        rw [argsExact] at hc
        simp only [beforeArguments,afterArguments,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil,List.cons_append,List.nil_append] at hc
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"i32",chars!"bool",chars!"u64",chars!"f32",chars!"i32",chars!"u64",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨targetValue,targetEqual,targetMeaning⟩ := literal_number_view targetOffset
        subst value
        let value₀' : NumV := .lit (F64.un .int32 offset₀)
        let value' : NumV := .lit (F64.un .int32 targetValue)
        have run₀ : interpC (NumericDecoder.i32.action (.lit offset₀)).run C₀ = some (value₀',C₀) := rfl
        have run' : interpC (NumericDecoder.i32.action (.lit targetValue)).run C = some (value',C) := rfl
        have sourceMeaning : NumDenote ν₀ C₀ offset (.lit offset₀) := by cases sourceOffset with | literal _ _ held => exact held
        have role₀ : ((Number.literal offset).decoded .i32).Holds ν₀ C₀ value₀' := by
          refine .literal _ _ ?_
          change some (F64.un .int32 offset₀) = some (F64.un .int32 (offset.eval ν₀))
          exact congrArg (fun x => some (F64.un .int32 x)) (Option.some.inj sourceMeaning)
        have role' : ((Number.literal offset).decoded .i32).Holds ν C value' := by
          refine .literal _ _ ?_
          change some (F64.un .int32 targetValue) = some (F64.un .int32 (offset.eval ν))
          exact congrArg (fun x => some (F64.un .int32 x)) (Option.some.inj targetMeaning)
        have ext₀ := TableExtends.refl C₀
        have ext := TableExtends.refl C
        have hm := h
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := hm.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀
          (Host.Ts.Owned.Annotated.Tree.Holds.mono ext outputRole)
        rw [VectorGetHost.null_bytes] at hok hbo
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs out handle stream dimValue traditional base scale value₀' oldBytes
        let args' := callArgs (R.a out) (R.handle handle) (R.handle stream) dimValue traditional base scale value' oldBytes
        have native := hm.native.2
        obtain ⟨node',hn',sourceCall,targetCall,nativeAfter⟩ := native.rope_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 handle input dims dimValue traditional (baseRole base) (.big base) (.big base) (scaleRole scale) ((Number.literal offset).decoded .i32)
          (.lit (F64.un .f32 scale)) (.lit (F64.un .f32 scale)) value₀' value' node
          (base_holds ν₀ C₀ Host.Ts.Owned.Annotated.identity base) (base_holds ν C R base) (scale_holds ν₀ C₀ scale) (scale_holds ν C scale)
          role₀ role' handleLive producer sourceNode rfl rfl dimension positive rank sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi input dims traditional base scale value₀' node
        let native' := resultWorld s.ffi (R.node input) dims traditional base scale value' node'
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite roles s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) ((Number.literal offset).decoded .i32)))
            boundary objects (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨hm.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have dimRole : NumberRoles ν₀ ν C₀ C (.lit dimValue) (.lit dimValue) := ⟨.lit dimValue,⟨rfl,rfl⟩⟩
        have scalePair := Number.paired (scale_holds ν₀ C₀ scale) (scale_holds ν C scale)
        have offsetPair := Number.paired role₀ role'
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) := by
          refine .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil)))) ?_
          refine .cons (.node _ (.cons (.value (.handle handle)) .nil)) ?_
          refine .cons (.node _ (.cons (.number dimRole) .nil)) ?_
          refine .cons (.node _ (.cons (.atom _ _) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig base)) .nil)) ?_
          refine .cons (.node _ (.cons (.number scalePair) .nil)) ?_
          refine .cons (.node _ (.cons (.number offsetPair) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) ?_
          exact .cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) writes₀ writes' := by
          dsimp only [writes₀,writes']; rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (hm.heap.targetBound out outLive) targetHeap
        have post := hm.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨t,?_,?_,post,?_,ext₀,ext,?_,?_,?_,rfl⟩
        · change interpC (step F s₀).run C₀ = _
          rw [step_abi s₀ fn types out handle stream dimValue traditional base scale (.lit offset₀) fo signature₀ returns receiver oldBytes hc₀ hf₀ hk₀ ht₀ htk₀
            (bufBytes_of_obj F s₀ out outObject oldBytes (by simp only [Host.Ts.St.obj?,ho₀]) hok₀) dimFixed]
          rw [NumericDecoder.i32.bind_run,run₀]
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          change interpC (complete s₀ out handle stream dimValue traditional base scale value₀' oldBytes).run C₀ = _
          unfold complete
          rw [call]
          change interpC (ffiDone F s₀ symbol args₀ (some (native₀,status0,[(out,0,writes₀)]))).run C₀ = _
          rw [ffiDone_status0_buffer F s₀ native₀ out 0 outObject oldBytes writes₀ symbol args₀ (by simp only [Host.Ts.St.obj?,ho₀]) hok₀]
          rfl
        · change interpC (step F s).run C = _
          rw [step_abi s (R.a fn) (R.a types) (R.a out) (R.handle handle) (R.handle stream) dimValue traditional base scale (.lit targetValue)
            fo' signature' returns this oldBytes hc hfo hfk hto htKind
            (bufBytes_of_obj F s (R.a out) out' oldBytes (by simp only [Host.Ts.St.obj?,ho]) hok) dimFixed]
          rw [NumericDecoder.i32.bind_run,run']
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          change interpC (complete s (R.a out) (R.handle handle) (R.handle stream) dimValue traditional base scale value' oldBytes).run C = _
          unfold complete
          rw [call]
          change interpC (ffiDone F s symbol args' (some (native',status0,[(R.a out,0,writes')]))).run C = _
          rw [ffiDone_status0_buffer F s native' (R.a out) 0 out' oldBytes writes' symbol args' (by simp only [Host.Ts.St.obj?,ho]) hok]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']; rw [← native.handleMap.head]
          exact slot_role ν C R s₀.ffi.mlx.next

        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject oldBytes writes₀
            symbol args₀ ho₀ hok₀ sourceHeap
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' oldBytes writes'
            symbol args' ho hok targetOutBound
        · intro a different
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right different]

end Host.Load.Run.Full.Ordinary.RopeHost
