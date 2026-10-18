import host.mlx.NativeDataRoles
import host.mlx.NativeSliceDynamicHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi

theorem load_data_call (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St) (handle : Nat)
    (hc : Host.Mlx.Ffi.call s.mlx chars!"mlx_array_new_data" args = ok native (.big (Int.ofNat handle))) :
    Host.Load.call s chars!"mlx_array_new_data" args = M.pure (some ({s with mlx := native},.big (Int.ofNat handle),[])) := by
  have hm : isMlx chars!"mlx_array_new_data" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hc,ok,M.bind,M.pure]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.DataHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_array_new_data"
def signature : List Val := [.str chars!"ptr",.str chars!"ptr",.str chars!"i32",.str chars!"i32"]

def arguments (dataBuffer shapeBuffer : Nat) (count dtype : F64) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer dataBuffer 0,.pointer shapeBuffer 0,.literal count,.literal dtype]

def callArgs (dataBuffer shapeBuffer : Nat) (bytes shapeBytes : List Byte) (count dtype : F64) : List Arg :=
  [.jsPtr dataBuffer 0 bytes,.jsPtr shapeBuffer 0 shapeBytes,.num (.lit count),.num (.lit dtype)]

def resultWorld (s : LSt) (shape : List Dim) (dtype : Nat) (bytes : List Byte) : LSt :=
  {s with mlx := NativeRoles.createZero s.mlx (dataNode shape dtype bytes)}

theorem step_data_eq (s : Host.Ts.St LSt) (fn types dataBuffer shapeBuffer : Nat)
    (count dtypeArg : F64) (bytes shapeBytes : List Byte) (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (native : LSt) (handle : Nat)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js dataBuffer) 0,.ptr (.js shapeBuffer) 0,.num (.lit count),.num (.lit dtypeArg)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hd : bufBytes F s dataBuffer = some bytes) (hs : bufBytes F s shapeBuffer = some shapeBytes)
    (countSame : F64.un .int32 count = count) (dtypeSame : F64.un .int32 dtypeArg = dtypeArg)
    (nativeCall : F.call s.ffi symbol (callArgs dataBuffer shapeBuffer bytes shapeBytes count dtypeArg) =
      M.pure (some (native,.big (Int.ofNat handle),[]))) :
    step F s = M.pure (finishBig s native symbol (callArgs dataBuffer shapeBuffer bytes shapeBytes count dtypeArg) (Int.ofNat handle)) := by
  have decode : decodeArgs F s signature [.ptr (.js dataBuffer) 0,.ptr (.js shapeBuffer) 0,.num (.lit count),.num (.lit dtypeArg)] =
      M.pure (some (callArgs dataBuffer shapeBuffer bytes shapeBytes count dtypeArg)) := by
    funext β k
    simp only [signature,decodeArgs,decodeArg_js_pointer F s dataBuffer 0 bytes hd,
      decodeArg_js_pointer F s shapeBuffer 0 shapeBytes hs,decode_i32_literal,countSame,dtypeSame,
      M.bind,M.pure,List.drop_zero,Option.map_some,callArgs]
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _ native (.big (Int.ofNat handle)) []
    hc (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk decode nativeCall]
  rfl

/-- The original copied-data constructor retains varying numeric payload
meanings, original shape-dependent truncation and the fresh owned return
handle throughout the complete host/native relation. Shared fixed geometry
and scalar ABI occurrences are mathematical annotations, not target runs. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C base boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types dataBuffer shapeBuffer dtype : Nat) (countArg dtypeArg : F64)
    (fo signature₀ dataObject shapeObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (bytes₀ : List Byte) (shapeBytesRoles : List Host.Ts.Owned.Annotated.FixedByte)
    (shape : List Dim) (shapeRoles : Shape) (byteRoles : List Host.Ts.Owned.Annotated.Byte)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver
      [.ptr (.js dataBuffer) 0,.ptr (.js shapeBuffer) 0,.num (.lit countArg),.num (.lit dtypeArg)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (hd₀ : s₀.heap.get dataBuffer = some (.obj dataObject)) (hdk₀ : dataObject.kind = .buf bytes₀)
    (hs₀ : s₀.heap.get shapeBuffer = some (.obj shapeObject))
    (hsk₀ : shapeObject.kind = .buf (shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value))
    (signatureFrame : ¬ framed types)
    (sourceShape : dimsArg (.jsPtr shapeBuffer 0 (shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value))
      (.num (.lit countArg)) = some shape)
    (sourceDtype : argNat (.num (.lit dtypeArg)) = some dtype)
    (countSame : F64.un .int32 countArg = countArg) (dtypeSame : F64.un .int32 dtypeArg = dtypeArg)
    (shapeSource : Shape.Holds ν₀ C₀ shapeRoles shape) (shapeTarget : Shape.Holds ν C shapeRoles shape)
    (sourceBytes : ListR (Host.Ts.Owned.Annotated.Byte.Holds ν₀ C₀ Host.Ts.Owned.Annotated.identity) byteRoles bytes₀)
    (targetBytes : ListR (Host.Ts.Owned.Annotated.Byte.Holds ν C R) byteRoles (ShapeBuffer.bytesAt s (R.a dataBuffer)))
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v) (arguments dataBuffer shapeBuffer countArg dtypeArg) (callArguments s.ctl))
    (shapeBufferRole : (Host.Ts.Owned.Annotated.fixedBufferRole shapeBytesRoles).Holds ν C R (objectKindAt s (R.a shapeBuffer)))
    (sourceNodes : s₀.ffi.mlx.nnext < 2^64) (targetNodes : s.ffi.mlx.nnext < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) :
    ∃ bytes,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBig s₀ (resultWorld s₀.ffi shape dtype bytes₀) symbol
          (callArgs dataBuffer shapeBuffer bytes₀ (shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value) countArg dtypeArg)
          (Int.ofNat s₀.ffi.mlx.next),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some
        (finishBig s (resultWorld s.ffi shape dtype bytes) symbol
          (callArgs (R.a dataBuffer) (R.a shapeBuffer) bytes (shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value) countArg dtypeArg)
          (Int.ofNat s.ffi.mlx.next),C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (nodeWrite base s₀.ffi.mlx.nnext (dataRole shape dtype shapeRoles byteRoles)) boundary objects
          (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host)
        R live framed before after old old'
        (finishBig s₀ (resultWorld s₀.ffi shape dtype bytes₀) symbol
          (callArgs dataBuffer shapeBuffer bytes₀ (shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value) countArg dtypeArg)
          (Int.ofNat s₀.ffi.mlx.next))
        (finishBig s (resultWorld s.ffi shape dtype bytes) symbol
          (callArgs (R.a dataBuffer) (R.a shapeBuffer) bytes (shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value) countArg dtypeArg)
          (Int.ofNat s.ffi.mlx.next)) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have dataLive : live dataBuffer := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  have shapeLive : live shapeBuffer := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.1
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
        have exactTypes := string_values_exact [chars!"ptr",chars!"ptr",chars!"i32",chars!"i32"] htys
        rw [exactTypes] at htKind
        obtain ⟨data',hdata,hdr,_⟩ := h.heap.readObject dataBuffer dataObject dataLive
          (h.heap.buffer_notFramed dataBuffer dataObject bytes₀ dataLive hd₀ hdk₀) hd₀
        have dataKind := hdr.kind
        rw [hdk₀] at dataKind
        obtain ⟨bytes,dataKind,dataBytesRelated⟩ := kind_buffer dataKind
        have byteFields : ListR (Host.Ts.Owned.Annotated.Byte.Holds ν C R) byteRoles bytes := by
          simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,hdata,dataKind] using targetBytes
        obtain ⟨shape',hshape,shapeKind,_,_,shapeBytesRelated⟩ := h.read_fixed_buffer shapeBuffer shapeObject _ shapeBytesRoles
          shapeLive hs₀ hsk₀ shapeBufferRole
        let shapeBytes := shapeBytesRoles.map Host.Ts.Owned.Annotated.FixedByte.value
        let args₀ := callArgs dataBuffer shapeBuffer bytes₀ shapeBytes countArg dtypeArg
        let args' := callArgs (R.a dataBuffer) (R.a shapeBuffer) bytes shapeBytes countArg dtypeArg
        have native := h.native.2
        obtain ⟨sourceCall,targetCall,nativeAfter⟩ := native.array_new_data dataBuffer shapeBuffer bytes₀ bytes shapeBytes
          (.num (.lit countArg)) (.num (.lit dtypeArg)) shape dtype shapeRoles byteRoles sourceShape sourceDtype
          shapeSource shapeTarget sourceBytes byteFields sourceNodes targetNodes sourceHandles targetHandles
        let native₀ := resultWorld s₀.ffi shape dtype bytes₀
        let native' := resultWorld s.ffi shape dtype bytes
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (nodeWrite base s₀.ffi.mlx.nnext (dataRole shape dtype shapeRoles byteRoles)) boundary objects
            (fun a => a = s₀.ffi.mlx.next ∨ H a) (fun i => i = s₀.ffi.mlx.nnext ∨ N i) tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        have valueRole : ValueR (NumberRoles ν₀ ν C₀ C) R
            (.big (Int.ofNat s₀.ffi.mlx.next)) (.big (Int.ofNat s.ffi.mlx.next)) := by
          rw [← native.handleMap.head]
          exact .handle _
        have countRole : NumberRoles ν₀ ν C₀ C (.lit countArg) (.lit countArg) := ⟨.lit countArg,⟨rfl,rfl⟩⟩
        have dtypeRole : NumberRoles ν₀ ν C₀ C (.lit dtypeArg) (.lit dtypeArg) := ⟨.lit dtypeArg,⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
          .cons (.node _ (.cons (.address dataBuffer) (.cons (.atom _ _) (.cons (bytes_roles dataBytesRelated) .nil))))
            (.cons (.node _ (.cons (.address shapeBuffer) (.cons (.atom _ _) (.cons (bytes_roles shapeBytesRelated) .nil))))
              (.cons (.node _ (.cons (.number countRole) .nil)) (.cons (.node _ (.cons (.number dtypeRole) .nil)) .nil)))
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R
            (event ⟨symbol,args₀,.big (Int.ofNat s₀.ffi.mlx.next)⟩) (event ⟨symbol,args',.big (Int.ofNat s.ffi.mlx.next)⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.value valueRole) .nil)) .nil)))
        refine ⟨bytes,?_,?_,h.finishBig _ _ nativeRelated _ _ _ _ _ eventRoles valueRole⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,.big (Int.ofNat s₀.ffi.mlx.next),[])) := by
            simpa only [F,symbol,args₀,callArgs,native₀,resultWorld] using Host.Load.Owned.load_data_call s₀.ffi _ _ _ sourceCall
          rw [step_data_eq s₀ fn types dataBuffer shapeBuffer countArg dtypeArg bytes₀ shapeBytes fo signature₀ returns receiver
            native₀ s₀.ffi.mlx.next hc₀ hf₀ hk₀ ht₀ htk₀
            (bufBytes_of_obj F s₀ dataBuffer dataObject bytes₀ (by simp only [Host.Ts.St.obj?,hd₀]) hdk₀)
            (bufBytes_of_obj F s₀ shapeBuffer shapeObject shapeBytes (by simp only [Host.Ts.St.obj?,hs₀]) hsk₀)
            countSame dtypeSame call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',.big (Int.ofNat s.ffi.mlx.next),[])) := by
            simpa only [F,symbol,args',callArgs,native',resultWorld] using Host.Load.Owned.load_data_call s.ffi _ _ _ targetCall
          rw [step_data_eq s (R.a fn) (R.a types) (R.a dataBuffer) (R.a shapeBuffer) countArg dtypeArg bytes shapeBytes fo' signature' returns this
            native' s.ffi.mlx.next hc hfo hfk hto htKind
            (bufBytes_of_obj F s (R.a dataBuffer) data' bytes (by simp only [Host.Ts.St.obj?,hdata]) dataKind)
            (bufBytes_of_obj F s (R.a shapeBuffer) shape' shapeBytes (by simp only [Host.Ts.St.obj?,hshape]) shapeKind)
            countSame dtypeSame call]
          rfl

end Host.Load.Run.Full.Ordinary.DataHost
