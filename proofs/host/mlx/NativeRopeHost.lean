import host.mlx.NativeRopeRoles
import host.mlx.NativeArgumentPattern
import host.mlx.NativeQuantizedHost
import host.mlx.NativeRelationTables

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RopeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_rope"
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"i32",.str chars!"bool",.str chars!"u64",
  .str chars!"f32",.str chars!"i32",.str chars!"u64",.str chars!"u64"]
def beforeArguments (out handle : Nat) (dims : F64) (traditional : Bool) (base : Int) (scale : F64) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle handle,.literal dims,.boolean traditional,.integer base,.literal scale]
def afterArguments (stream : Nat) : List Host.Ts.Owned.Annotated.FixedArgument := [.integer 0,.handle stream]
def rawArgs (out handle stream : Nat) (dims : F64) (traditional : Bool) (base : Int) (scale : F64) (offset : NumV) : List Val :=
  [.ptr (.js out) 0,.big (Int.ofNat handle),.num (.lit dims),.bool traditional,.big base,.num (.lit scale),.num offset,.big 0,.big (Int.ofNat stream)]
def callArgs (out handle stream : Nat) (dims : F64) (traditional : Bool) (base : Int) (scale : F64) (offset : NumV) (bytes : List Byte) : List Arg :=
  [.jsPtr out 0 bytes,.big (Int.ofNat handle),.num (.lit dims),.bool traditional,.big base,.num (.lit (F64.un .f32 scale)),
    .num offset,.big 0,.big (Int.ofNat stream)]
def baseRole (base : Int) : Host.Ts.Owned.Annotated.Tree := .node "Arg.big" [.value (.ordinaryBig base)]
def scaleRole (scale : F64) : Number := .literal (.lit (F64.un .f32 scale))
def resultWorld (s : LSt) (input dims : Nat) (traditional : Bool) (base : Int) (scale : F64) (offset : NumV) (node : Node) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (ropeNode input dims traditional (.big base) (.lit (F64.un .f32 scale)) offset node)}
def finish (s : Host.Ts.St LSt) (out handle input stream dims : Nat) (dimValue : F64) (traditional : Bool)
    (base : Int) (scale : F64) (offset : NumV) (node : Node) (buffer : Host.Ts.Obj) : Host.Ts.St LSt :=
  finishBuffer s (resultWorld s.ffi input dims traditional base scale offset node) out 0 buffer
    (cellParts .u64 (.big (Int.ofNat 0)) 8 0) (cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0)
    symbol (callArgs out handle stream dimValue traditional base scale offset (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
def complete (s : Host.Ts.St LSt) (out handle stream : Nat) (dims : F64) (traditional : Bool) (base : Int)
    (scale : F64) (offset : NumV) (bytes : List Byte) : M (Host.Ts.St LSt) :=
  (F.call s.ffi symbol (callArgs out handle stream dims traditional base scale offset bytes)).bind
    (ffiDone F s symbol (callArgs out handle stream dims traditional base scale offset bytes))

theorem base_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (base : Int) :
    (baseRole base).Holds ν C R (Parametric.arg (.big base)) := .node _ (.cons (.value (.ordinaryBig base)) .nil)
theorem scale_holds (ν : Nat → F64) (C : CSrv) (scale : F64) :
    (scaleRole scale).Holds ν C (.lit (F64.un .f32 scale)) := .literal _ _ rfl

theorem step_abi (s : Host.Ts.St LSt) (fn types out handle stream : Nat) (dims : F64) (traditional : Bool)
    (base : Int) (scale : F64) (offset : NumV) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (bytes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver (rawArgs out handle stream dims traditional base scale offset))
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : bufBytes F s out = some bytes) (dimFixed : F64.un .int32 dims = dims) :
    step F s = (NumericDecoder.i32.action offset).bind (fun value => complete s out handle stream dims traditional base scale value bytes) := by
  have decode : decodeArgs F s signature (rawArgs out handle stream dims traditional base scale offset) =
      (NumericDecoder.i32.action offset).bind (fun value => M.pure (some (callArgs out handle stream dims traditional base scale value bytes))) := by
    have offsetDecode := NumericDecoder.i32.decode F s offset
    dsimp only [NumericDecoder.name] at offsetDecode
    funext β k
    simp only [signature,rawArgs,callArgs,decodeArgs,decodeArg_js_pointer F s out 0 bytes hb,decode_u64_big,
      decode_i32_literal,dimFixed,QuantizedHost.decode_boolean,decode_f32_literal,offsetDecode,
      List.drop_zero,M.bind,M.pure,Option.map_some]
  funext β k
  simp only [step,hc,callStep,Host.Ts.St.obj?,hf,hk,callNative,ffiN]
  rw [elemsOf_array F s types signature₀ signature (by simp only [Host.Ts.St.obj?,ht]) htk]
  dsimp only [M.bind,M.pure]
  rw [decode]
  dsimp only [M.bind,M.pure]
  apply congrArg (NumericDecoder.i32.action offset β)
  funext value
  unfold complete
  dsimp only [M.bind]

/-- The offset is cast by the actual i32 decoder on each side. Independent
table extensions preserve all fixed native occurrences before allocation. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out handle input stream dims : Nat) (dimValue : F64) (traditional : Bool) (base : Int) (scale : F64)
    (offset : Number) (offset₀ : NumV) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val) (node : Node)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver (rawArgs out handle stream dimValue traditional base scale offset₀))
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject)) (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0))
    (signatureFrame : ¬ framed types) (handleLive : H handle)
    (producer : Host.Mlx.Ffi.nodesOf s₀.ffi.mlx [handle] = some [input]) (sourceNode : s₀.ffi.mlx.nodes.get input = some node)
    (sourceOffset : offset.Holds ν₀ C₀ offset₀)
    (argumentRoles : ListR (ArgumentPattern.Holds ν C R)
      ((beforeArguments out handle dimValue traditional base scale).map .fixed ++ [.numeric offset] ++ (afterArguments stream).map .fixed)
      (callArguments s.ctl))
    (outputRole : (Host.Ts.Owned.Annotated.fixedBufferRole VectorGetHost.nullRole).Holds ν C R (objectKindAt s (R.a out)))
    (dimension : F64.toInt? dimValue = some (Int.ofNat dims)) (dimFixed : F64.un .int32 dimValue = dimValue) (positive : 0 < dims)
    (rank : Nat.ble 3 (len (roles input).shape) = true)
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ value₀ D₀ t D,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finish s₀ out handle input stream dims dimValue traditional base scale value₀ node outObject,D₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,D) ∧
      StateR (NumberRoles ν₀ ν D₀ D)
        (VectorHost.NativeRelation ν₀ ν D₀ D
          (nodeWrite roles s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) (offset.decoded .i32)))
          boundary objects (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finish s₀ out handle input stream dims dimValue traditional base scale value₀ node outObject) t ∧
      (slotKindRole s₀.ffi.mlx.next).Holds ν D R (objectKindAt t (R.a out)) ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
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
        obtain ⟨value,argsExact,targetOffset⟩ := ArgumentPattern.one_numeric_exact _ _ offset argumentRoles
        simp only [hc,callArguments] at argsExact
        rw [argsExact] at hc
        simp only [beforeArguments,afterArguments,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil,List.cons_append,List.nil_append] at hc
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"i32",chars!"bool",chars!"u64",chars!"f32",chars!"i32",chars!"u64",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨value₀',D₀,run₀,role₀,ext₀⟩ := sourceOffset.decode .i32
        obtain ⟨value',D,run',role',ext⟩ := targetOffset.decode .i32
        have hm := VectorHost.state_mono h ext₀ ext
        obtain ⟨out',ho,hok,hro,hlo,hbo⟩ := hm.read_fixed_buffer out outObject _ VectorGetHost.nullRole outLive ho₀ hok₀
          (Host.Ts.Owned.Annotated.Tree.Holds.mono ext outputRole)
        rw [VectorGetHost.null_bytes] at hok hbo
        let oldBytes := cellParts .u64 (.big (Int.ofNat 0)) 8 0
        let args₀ := callArgs out handle stream dimValue traditional base scale value₀' oldBytes
        let args' := callArgs (R.a out) (R.handle handle) (R.handle stream) dimValue traditional base scale value' oldBytes
        have native := hm.native.2
        obtain ⟨node',hn',sourceCall,targetCall,nativeAfter⟩ := native.rope_null
          (.jsPtr out 0 oldBytes) (.jsPtr (R.a out) 0 oldBytes) (.big (Int.ofNat stream)) (.big (Int.ofNat (R.handle stream)))
          out 0 handle input dims dimValue traditional (baseRole base) (.big base) (.big base) (scaleRole scale) (offset.decoded .i32)
          (.lit (F64.un .f32 scale)) (.lit (F64.un .f32 scale)) value₀' value' node
          (base_holds ν₀ D₀ Host.Ts.Owned.Annotated.identity base) (base_holds ν D R base) (scale_holds ν₀ D₀ scale) (scale_holds ν D scale)
          role₀ role' handleLive producer sourceNode rfl rfl dimension positive rank sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi input dims traditional base scale value₀' node
        let native' := resultWorld s.ffi (R.node input) dims traditional base scale value' node'
        have nativeRelated : VectorHost.NativeRelation ν₀ ν D₀ D
            (nodeWrite roles s₀.ffi.mlx.nnext (ropeRole roles input dims traditional (baseRole base) (scaleRole scale) (offset.decoded .i32)))
            boundary objects (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨hm.native.1,nativeAfter⟩
        let writes₀ := cellParts .u64 (.big (Int.ofNat s₀.ffi.mlx.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat s.ffi.mlx.next)) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' oldBytes writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν D₀ D zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have dimRole : NumberRoles ν₀ ν D₀ D (.lit dimValue) (.lit dimValue) := ⟨.lit dimValue,⟨rfl,rfl⟩⟩
        have scalePair := Number.paired (scale_holds ν₀ D₀ scale) (scale_holds ν D scale)
        have offsetPair := Number.paired role₀ role'
        have argsRelated : ForestR (NumberRoles ν₀ ν D₀ D) R (args₀.map Parametric.arg) (args'.map Parametric.arg) := by
          refine .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbo) .nil)))) ?_
          refine .cons (.node _ (.cons (.value (.handle handle)) .nil)) ?_
          refine .cons (.node _ (.cons (.number dimRole) .nil)) ?_
          refine .cons (.node _ (.cons (.atom _ _) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig base)) .nil)) ?_
          refine .cons (.node _ (.cons (.number scalePair) .nil)) ?_
          refine .cons (.node _ (.cons (.number offsetPair) .nil)) ?_
          refine .cons (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) ?_
          exact .cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil
        have eventRoles : TreeR (NumberRoles ν₀ ν D₀ D) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have writesRelated : ListR (ByteR (NumberRoles ν₀ ν D₀ D) R) writes₀ writes' := by
          dsimp only [writes₀,writes']; rw [← native.handleMap.head]
          exact Host.Mlx.Ffi.Parametric.cellParts_roles (.handle _) .u64 8 0
        have targetOutBound := Nat.lt_trans (hm.heap.targetBound out outLive) targetHeap
        have post := hm.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' oldBytes oldBytes writes₀ writes'
          symbol args₀ args' outLive ho₀ hok₀ hro hlo hbo writesRelated sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨value₀',D₀,t,D,?_,?_,post,?_,ext₀,ext⟩
        · change interpC (step F s₀).run C₀ = _
          rw [step_abi s₀ fn types out handle stream dimValue traditional base scale offset₀ fo signature₀ returns receiver oldBytes hc₀ hf₀ hk₀ ht₀ htk₀
            (bufBytes_of_obj F s₀ out outObject oldBytes (by simp only [Host.Ts.St.obj?,ho₀]) hok₀) dimFixed]
          rw [NumericDecoder.i32.bind_run,run₀]
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[(out,0,writes₀)])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld,writes₀,u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s₀.ffi symbol _ _ _ (by decide +kernel) sourceCall
          change interpC (complete s₀ out handle stream dimValue traditional base scale value₀' oldBytes).run D₀ = _
          unfold complete
          rw [call]
          change interpC (ffiDone F s₀ symbol args₀ (some (native₀,status0,[(out,0,writes₀)]))).run D₀ = _
          rw [ffiDone_status0_buffer F s₀ native₀ out 0 outObject oldBytes writes₀ symbol args₀ (by simp only [Host.Ts.St.obj?,ho₀]) hok₀]
          rfl
        · change interpC (step F s).run C = _
          rw [step_abi s (R.a fn) (R.a types) (R.a out) (R.handle handle) (R.handle stream) dimValue traditional base scale value
            fo' signature' returns this oldBytes hc hfo hfk hto htKind
            (bufBytes_of_obj F s (R.a out) out' oldBytes (by simp only [Host.Ts.St.obj?,ho]) hok) dimFixed]
          rw [NumericDecoder.i32.bind_run,run']
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[(R.a out,0,writes')])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld,writes',u64Write,Int.ofNat_eq_natCast] using
              Host.Load.Owned.load_unary_call s.ffi symbol _ _ _ (by decide +kernel) targetCall
          change interpC (complete s (R.a out) (R.handle handle) (R.handle stream) dimValue traditional base scale value' oldBytes).run D = _
          unfold complete
          rw [call]
          change interpC (ffiDone F s symbol args' (some (native',status0,[(R.a out,0,writes')]))).run D = _
          rw [ffiDone_status0_buffer F s native' (R.a out) 0 out' oldBytes writes' symbol args' (by simp only [Host.Ts.St.obj?,ho]) hok]
          rfl
        · have patch : oldBytes.take 0 ++ writes' ++ oldBytes.drop (0 + len writes') = writes' := rfl
          simp only [objectKindAt,t,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']; rw [← native.handleMap.head]
          exact slot_role ν D R s₀.ffi.mlx.next

end Host.Load.Run.Full.Ordinary.RopeHost
