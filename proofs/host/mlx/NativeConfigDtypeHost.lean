import host.mlx.NativeConfigIntHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

def configDtypeWorld (s : LSt) (a : Nat) (c : Cfg) (name : Name) (dtype : Nat) : LSt :=
  {s with mlx := s.mlx.setObj a (.cfg {c with dtypes := c.dtypes ++ [(name,dtype)]})}

theorem load_config_dtype (s : LSt) (a b dtype : Nat) (c : Cfg) (name : Name) (bytes : List Byte) (value : F64)
    (hc : s.mlx.obj? a = some (.cfg c)) (hn : cstrArg (.jsPtr b 0 bytes) = some name)
    (hd : argNat (.num (.lit value)) = some dtype) :
    Host.Load.call s chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype"
      [.big (Int.ofNat a),.jsPtr b 0 bytes,.num (.lit value)] =
      M.pure (some (configDtypeWorld s a c name dtype,status0,[])) := by
  have hm : isMlx chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype" = true := by decide +kernel
  have hn' := call_config_dtype_arg s.mlx a (.jsPtr b 0 bytes) (.num (.lit value)) name dtype hn hd
  rw [cfgUpdate_success s.mlx a c {c with dtypes := c.dtypes ++ [(name,dtype)]}
    (fun c => some {c with dtypes := c.dtypes ++ [(name,dtype)]}) hc rfl] at hn'
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hn',ok,M.bind,M.pure,configDtypeWorld]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.ConfigDtypeHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_metal_kernel_config_add_template_arg_dtype"
def signature : List Val := [.str chars!"u64",.str chars!"cstring",.str chars!"i32"]

def finishDtype (s : Host.Ts.St LSt) (a b dtype : Nat) (c : Cfg) (name : Name) (bytes : List Byte) (value : F64) : Host.Ts.St LSt :=
  finishStatus s (Host.Load.Owned.configDtypeWorld s.ffi a c name dtype) symbol
    [.big (Int.ofNat a),.jsPtr b 0 bytes,.num (.lit value)]

theorem step_dtype_eq (s : Host.Ts.St LSt) (fn types a b dtype : Nat) (value : F64)
    (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (c : Cfg) (name : Name) (bytes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.ptr (.js b) 0,.num (.lit value)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : bufBytes F s b = some bytes) (hn : s.ffi.mlx.obj? a = some (.cfg c))
    (hname : cstrArg (.jsPtr b 0 bytes) = some name)
    (same : F64.un .int32 value = value) (hd : argNat (.num (.lit value)) = some dtype) :
    step F s = M.pure (finishDtype s a b dtype c name bytes value) := by
  have decode : decodeArgs F s signature [.big (Int.ofNat a),.ptr (.js b) 0,.num (.lit value)] =
      M.pure (some [.big (Int.ofNat a),.jsPtr b 0 bytes,.num (.lit value)]) := by
    funext β k
    simp only [signature,decodeArgs,decode_u64_big,decode_cstring_pointer F s b 0 bytes hb,
      decode_i32_literal,same,M.bind,M.pure,List.drop_zero,Option.map_some]
  have hcall : F.call s.ffi symbol [.big (Int.ofNat a),.jsPtr b 0 bytes,.num (.lit value)] =
      M.pure (some (Host.Load.Owned.configDtypeWorld s.ffi a c name dtype,status0,[])) := by
    simpa only [F,symbol] using Host.Load.Owned.load_config_dtype s.ffi a b dtype c name bytes value hn hname hd
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _
    (Host.Load.Owned.configDtypeWorld s.ffi a c name dtype) status0 [] hc
    (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk decode hcall]
  rfl

/-- A fixed dtype enum follows the original literal ABI conversion. The
target name and native configuration are recovered from the source heap and
the indexed live relation, without target decoding or native-call premises. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types a b dtype : Nat) (value : F64) (fo signature₀ buffer₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (bytes₀ : List Byte) (name : Name)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.ptr (.js b) 0,.num (.lit value)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (hb₀ : s₀.heap.get b = some (.obj buffer₀)) (hbk₀ : buffer₀.kind = .buf bytes₀)
    (sourceName : cstrArg (.jsPtr b 0 bytes₀) = some name)
    (same : F64.un .int32 value = value) (sourceDtype : argNat (.num (.lit value)) = some dtype)
    (signatureFrame : ¬ framed types) (handleLive : H a)
    (role : Config) (source : Cfg) (objectRole : objects a = .config role)
    (sourceConfig : s₀.ffi.mlx.obj? a = some (.cfg source))
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle a).Holds ν C R (callArgument s.ctl 0))
    (dtypeRole : (Host.Ts.Owned.Annotated.Value.literal (.lit value)).Holds ν C R (callArgument s.ctl 2))
    (sourceBound : a < 2^64) (targetBound : R.handle a < 2^64) :
    ∃ bytes target,
      interpC (step Host.Load.ffi s₀).run C₀ = some (finishDtype s₀ a b dtype source name bytes₀ value,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishDtype s (R.handle a) (R.a b) dtype target name bytes value,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary
          (objectWrite objects a (.config {role with dtypes := role.dtypes ++ [(name,dtype)]})) H N tail host)
        R live framed before after old old'
        (finishDtype s₀ a b dtype source name bytes₀ value)
        (finishDtype s (R.handle a) (R.a b) dtype target name bytes value) := by
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
            cases ha with | cons hv ha =>
              cases ha
              cases hp
              have he := fixed_handle_value handleRole
              simp only [hc,callArgument,Host.Ts.arg,nthD] at he
              rw [he] at hc
              have hvalue := Host.Ts.Owned.Annotated.FixedArgument.exact (r := .literal value) dtypeRole
              simp only [hc,callArgument,Host.Ts.arg,nthD,Host.Ts.Owned.Annotated.FixedArgument.value] at hvalue
              rw [hvalue] at hc
              obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
              have htKind := htr.kind
              rw [htk₀] at htKind
              obtain ⟨tys,htKind,htys⟩ := kind_array htKind
              have exactTypes := string_values_exact [chars!"u64",chars!"cstring",chars!"i32"] htys
              rw [exactTypes] at htKind
              obtain ⟨buffer,hb,hbr,_⟩ := h.heap.readObject b buffer₀ bufferLive
                (h.heap.buffer_notFramed b buffer₀ bytes₀ bufferLive hb₀ hbk₀) hb₀
              have hbKind := hbr.kind
              rw [hbk₀] at hbKind
              obtain ⟨bytes,hbKind,hbytes⟩ := kind_buffer hbKind
              have targetName : cstrArg (.jsPtr (R.a b) 0 bytes) = some name :=
                (cstrArg_roles b 0 hbytes).symm.trans sourceName
              obtain ⟨target,targetConfig,sourceFields,targetFields⟩ :=
                h.native.2.config_view_roles a handleLive role source objectRole sourceConfig
              let updated : Config := {role with dtypes := role.dtypes ++ [(name,dtype)]}
              have nativeAfter : VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary
                  (objectWrite objects a (.config updated)) H N tail host R
                  (Host.Load.Owned.configDtypeWorld s₀.ffi a source name dtype)
                  (Host.Load.Owned.configDtypeWorld s.ffi (R.handle a) target name dtype) :=
                ⟨h.native.1,h.native.2.setObjectRoles a handleLive _ _
                  (ObjectRel.write_config objects ν₀ ν C₀ C R a updated _ _
                    (sourceFields.addDtype name dtype) (targetFields.addDtype name dtype))
                  (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceBound targetBound⟩
              have numberPair : NumberRoles ν₀ ν C₀ C (.lit value) (.lit value) := ⟨.lit value,⟨rfl,rfl⟩⟩
              have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
              have argumentRoles : ForestR (NumberRoles ν₀ ν C₀ C) R
                  ([.big (Int.ofNat a),.jsPtr b 0 bytes₀,.num (.lit value)].map Parametric.arg)
                  ([.big (Int.ofNat (R.handle a)),.jsPtr (R.a b) 0 bytes,.num (.lit value)].map Parametric.arg) :=
                .cons (.node _ (.cons (.value (.handle a)) .nil))
                  (.cons (.node _ (.cons (.address b) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
                    (.cons (.node _ (.cons (.number numberPair) .nil)) .nil))
              have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R
                  (event ⟨symbol,[.big (Int.ofNat a),.jsPtr b 0 bytes₀,.num (.lit value)],status0⟩)
                  (event ⟨symbol,[.big (Int.ofNat (R.handle a)),.jsPtr (R.a b) 0 bytes,.num (.lit value)],status0⟩) :=
                .node _ (.cons (.atom _ _) (.cons (.node _ argumentRoles)
                  (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
              refine ⟨bytes,target,?_,?_,h.finishStatus _ _ nativeAfter _ _ _ eventRoles zeroRole⟩
              · change interpC (step F s₀).run C₀ = _
                rw [step_dtype_eq s₀ fn types a b dtype value fo signature₀ returns receiver source name bytes₀
                  hc₀ hf₀ hk₀ ht₀ htk₀
                  (bufBytes_of_obj F s₀ b buffer₀ bytes₀ (by simp only [Host.Ts.St.obj?,hb₀]) hbk₀) sourceConfig sourceName same sourceDtype]
                rfl
              · change interpC (step F s).run C = _
                rw [step_dtype_eq s (R.a fn) (R.a types) (R.handle a) (R.a b) dtype value fo' signature' returns this target name bytes
                  hc hfo hfk hto htKind
                  (bufBytes_of_obj F s (R.a b) buffer bytes (by simp only [Host.Ts.St.obj?,hb]) hbKind) targetConfig targetName same sourceDtype]
                rfl

end Host.Load.Run.Full.Ordinary.ConfigDtypeHost
