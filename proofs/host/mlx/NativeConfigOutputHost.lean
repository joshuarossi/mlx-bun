import host.mlx.NativeConfigDtypeHost
import host.mlx.NativeShapeBuffer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

def configOutputWorld (s : LSt) (a : Nat) (c : Cfg) (shape : List Dim) (dtype : Nat) : LSt :=
  {s with mlx := s.mlx.setObj a (.cfg {c with outs := c.outs ++ [(shape,dtype)]})}

theorem load_config_output (s : LSt) (a b count dtype : Nat) (c : Cfg) (bytes : List Byte)
    (shape : List Dim) (value : F64) (hc : s.mlx.obj? a = some (.cfg c))
    (hs : dimsArg (.jsPtr b 0 bytes) (.big (Int.ofNat count)) = some shape)
    (hd : argNat (.num (.lit value)) = some dtype) :
    Host.Load.call s chars!"mlx_fast_metal_kernel_config_add_output_arg"
      [.big (Int.ofNat a),.jsPtr b 0 bytes,.big (Int.ofNat count),.num (.lit value)] =
      M.pure (some (configOutputWorld s a c shape dtype,status0,[])) := by
  have hm : isMlx chars!"mlx_fast_metal_kernel_config_add_output_arg" = true := by decide +kernel
  have hn := call_config_output_arg s.mlx a (.jsPtr b 0 bytes) (.big (Int.ofNat count)) (.num (.lit value)) shape dtype hs hd
  rw [cfgUpdate_success s.mlx a c {c with outs := c.outs ++ [(shape,dtype)]}
    (fun c => some {c with outs := c.outs ++ [(shape,dtype)]}) hc rfl] at hn
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hn,ok,M.bind,M.pure,configOutputWorld]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.ConfigOutputHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_metal_kernel_config_add_output_arg"
def signature : List Val := [.str chars!"u64",.str chars!"ptr",.str chars!"u64",.str chars!"i32"]

def finishOutput (s : Host.Ts.St LSt) (a b count dtype : Nat) (c : Cfg) (bytes : List Byte)
    (shape : List Dim) (value : F64) : Host.Ts.St LSt :=
  finishStatus s (Host.Load.Owned.configOutputWorld s.ffi a c shape dtype) symbol
    [.big (Int.ofNat a),.jsPtr b 0 bytes,.big (Int.ofNat count),.num (.lit value)]

theorem step_output_eq (s : Host.Ts.St LSt) (fn types a b count dtype : Nat) (value : F64)
    (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (c : Cfg) (bytes : List Byte) (shape : List Dim)
    (hc : s.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.ptr (.js b) 0,.big (Int.ofNat count),.num (.lit value)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : bufBytes F s b = some bytes) (hn : s.ffi.mlx.obj? a = some (.cfg c))
    (hs : dimsArg (.jsPtr b 0 bytes) (.big (Int.ofNat count)) = some shape)
    (same : F64.un .int32 value = value) (hd : argNat (.num (.lit value)) = some dtype) :
    step F s = M.pure (finishOutput s a b count dtype c bytes shape value) := by
  have decode : decodeArgs F s signature [.big (Int.ofNat a),.ptr (.js b) 0,.big (Int.ofNat count),.num (.lit value)] =
      M.pure (some [.big (Int.ofNat a),.jsPtr b 0 bytes,.big (Int.ofNat count),.num (.lit value)]) := by
    funext β k
    simp only [signature,decodeArgs,decode_u64_big,decodeArg_js_pointer F s b 0 bytes hb,
      decode_i32_literal,same,M.bind,M.pure,List.drop_zero,Option.map_some]
  have hcall : F.call s.ffi symbol [.big (Int.ofNat a),.jsPtr b 0 bytes,.big (Int.ofNat count),.num (.lit value)] =
      M.pure (some (Host.Load.Owned.configOutputWorld s.ffi a c shape dtype,status0,[])) := by
    simpa only [F,symbol] using Host.Load.Owned.load_config_output s.ffi a b count dtype c bytes shape value hn hs hd
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _
    (Host.Load.Owned.configOutputWorld s.ffi a c shape dtype) status0 [] hc
    (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk decode hcall]
  rfl

/-- Original output-declaration dispatch. The target shape decoder is proved
from the fixed tagged-buffer annotation, with variable literal dimensions
retaining exact integer recovery and reference dimensions retaining their tag. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types a b dtype : Nat) (value : F64) (fo signature₀ buffer₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (roles : Shape) (sourceShape : List Dim) (decodable : roles.Decodable)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver
      [.big (Int.ofNat a),.ptr (.js b) 0,.big (Int.ofNat roles.length),.num (.lit value)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (hb₀ : s₀.heap.get b = some (.obj buffer₀)) (hbk₀ : buffer₀.kind = .buf (shapeBytes sourceShape))
    (sourceShapeRole : Shape.Holds ν₀ C₀ roles sourceShape)
    (same : F64.un .int32 value = value) (sourceDtype : argNat (.num (.lit value)) = some dtype)
    (signatureFrame : ¬ framed types) (handleLive : H a)
    (role : Config) (source : Cfg) (objectRole : objects a = .config role)
    (sourceConfig : s₀.ffi.mlx.obj? a = some (.cfg source))
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle a).Holds ν C R (callArgument s.ctl 0))
    (countRole : (Host.Ts.Owned.Annotated.Value.ordinaryBig (Int.ofNat roles.length)).Holds ν C R (callArgument s.ctl 2))
    (dtypeRole : (Host.Ts.Owned.Annotated.Value.literal (.lit value)).Holds ν C R (callArgument s.ctl 3))
    (targetShapeRole : ShapeBuffer.Holds roles ν C (ShapeBuffer.bytesAt s (R.a b)))
    (sourceBound : a < 2^64) (targetBound : R.handle a < 2^64) :
    ∃ bytes targetShape target,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishOutput s₀ a b roles.length dtype source (shapeBytes sourceShape) sourceShape value,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some
        (finishOutput s (R.handle a) (R.a b) roles.length dtype target bytes targetShape value,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary
          (objectWrite objects a (.config {role with outs := role.outs ++ [(roles,dtype)]})) H N tail host)
        R live framed before after old old'
        (finishOutput s₀ a b roles.length dtype source (shapeBytes sourceShape) sourceShape value)
        (finishOutput s (R.handle a) (R.a b) roles.length dtype target bytes targetShape value) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have bufferLive : live b := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.2.1
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
        cases ha with | cons hh ha =>
          cases ha with | cons hp ha =>
            cases ha with | cons hcR ha =>
              cases ha with | cons hv ha =>
                cases ha
                cases hp
                have he := fixed_handle_value handleRole
                simp only [hc,callArgument,Host.Ts.arg,nthD] at he
                rw [he] at hc
                have he := fixed_ordinary_big_value countRole
                simp only [hc,callArgument,Host.Ts.arg,nthD] at he
                rw [he] at hc
                have hvalue := Host.Ts.Owned.Annotated.FixedArgument.exact (r := .literal value) dtypeRole
                simp only [hc,callArgument,Host.Ts.arg,nthD,Host.Ts.Owned.Annotated.FixedArgument.value] at hvalue
                rw [hvalue] at hc
                obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
                have htKind := htr.kind
                rw [htk₀] at htKind
                obtain ⟨tys,htKind,htys⟩ := kind_array htKind
                have exactTypes := string_values_exact [chars!"u64",chars!"ptr",chars!"u64",chars!"i32"] htys
                rw [exactTypes] at htKind
                obtain ⟨buffer,hb,hbr,_⟩ := h.heap.readObject b buffer₀ bufferLive
                  (h.heap.buffer_notFramed b buffer₀ _ bufferLive hb₀ hbk₀) hb₀
                have hbKind := hbr.kind
                rw [hbk₀] at hbKind
                obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
                have shapeBuffer : ShapeBuffer.Holds roles ν C bytes := by
                  simpa only [ShapeBuffer.bytesAt,Host.Ts.St.obj?,hb,hbKind] using targetShapeRole
                obtain ⟨targetShape,targetShapeFields,targetDims⟩ := shapeBuffer.decode decodable (R.a b) 0
                have sourceDims := dimsArg_shapeBytes sourceShapeRole decodable b 0
                obtain ⟨target,targetConfig,sourceFields,targetFields⟩ :=
                  h.native.2.config_view_roles a handleLive role source objectRole sourceConfig
                let updated : Config := {role with outs := role.outs ++ [(roles,dtype)]}
                have nativeAfter : VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary
                    (objectWrite objects a (.config updated)) H N tail host R
                    (Host.Load.Owned.configOutputWorld s₀.ffi a source sourceShape dtype)
                    (Host.Load.Owned.configOutputWorld s.ffi (R.handle a) target targetShape dtype) :=
                  ⟨h.native.1,h.native.2.setObjectRoles a handleLive _ _
                    (ObjectRel.write_config objects ν₀ ν C₀ C R a updated _ _
                      (sourceFields.addOutput dtype sourceShapeRole) (targetFields.addOutput dtype targetShapeFields))
                    (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceBound targetBound⟩
                have numberPair : NumberRoles ν₀ ν C₀ C (.lit value) (.lit value) := ⟨.lit value,⟨rfl,rfl⟩⟩
                have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
                have argumentRoles : ForestR (NumberRoles ν₀ ν C₀ C) R
                    ([.big (Int.ofNat a),.jsPtr b 0 (shapeBytes sourceShape),.big (Int.ofNat roles.length),.num (.lit value)].map Parametric.arg)
                    ([.big (Int.ofNat (R.handle a)),.jsPtr (R.a b) 0 bytes,.big (Int.ofNat roles.length),.num (.lit value)].map Parametric.arg) :=
                  .cons (.node _ (.cons (.value (.handle a)) .nil))
                    (.cons (.node _ (.cons (.address b) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
                      (.cons (.node _ (.cons (.value (.ordinaryBig (Int.ofNat roles.length))) .nil))
                        (.cons (.node _ (.cons (.number numberPair) .nil)) .nil)))
                have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R
                    (event ⟨symbol,[.big (Int.ofNat a),.jsPtr b 0 (shapeBytes sourceShape),.big (Int.ofNat roles.length),.num (.lit value)],status0⟩)
                    (event ⟨symbol,[.big (Int.ofNat (R.handle a)),.jsPtr (R.a b) 0 bytes,.big (Int.ofNat roles.length),.num (.lit value)],status0⟩) :=
                  .node _ (.cons (.atom _ _) (.cons (.node _ argumentRoles)
                    (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
                refine ⟨bytes,targetShape,target,?_,?_,h.finishStatus _ _ nativeAfter _ _ _ eventRoles zeroRole⟩
                · change interpC (step F s₀).run C₀ = _
                  rw [step_output_eq s₀ fn types a b roles.length dtype value fo signature₀ returns receiver source _ sourceShape
                    hc₀ hf₀ hk₀ ht₀ htk₀
                    (bufBytes_of_obj F s₀ b buffer₀ _ (by simp only [Host.Ts.St.obj?,hb₀]) hbk₀) sourceConfig sourceDims same sourceDtype]
                  rfl
                · change interpC (step F s).run C = _
                  rw [step_output_eq s (R.a fn) (R.a types) (R.handle a) (R.a b) roles.length dtype value fo' signature' returns this target bytes targetShape
                    hc hfo hfk hto htKind
                    (bufBytes_of_obj F s (R.a b) buffer bytes (by simp only [Host.Ts.St.obj?,hb]) hbKind) targetConfig targetDims same sourceDtype]
                  rfl

end Host.Load.Run.Full.Ordinary.ConfigOutputHost
