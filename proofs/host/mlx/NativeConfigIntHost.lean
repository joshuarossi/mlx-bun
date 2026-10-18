import host.mlx.NativeConfigHost
import host.mlx.NativeCStringRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles

def configIntWorld (s : LSt) (a : Nat) (c : Cfg) (name : Name) (value : NumV) : LSt :=
  {s with mlx := s.mlx.setObj a (.cfg {c with ints := c.ints ++ [(name,value)]})}

theorem load_config_int (s : LSt) (a b : Nat) (c : Cfg) (name : Name) (bytes : List Byte) (value : NumV)
    (hc : s.mlx.obj? a = some (.cfg c)) (hn : cstrArg (.jsPtr b 0 bytes) = some name) :
    Host.Load.call s chars!"mlx_fast_metal_kernel_config_add_template_arg_int"
      [.big (Int.ofNat a),.jsPtr b 0 bytes,.num value] =
      M.pure (some (configIntWorld s a c name value,status0,[])) := by
  have hm : isMlx chars!"mlx_fast_metal_kernel_config_add_template_arg_int" = true := by decide +kernel
  have hn' := call_cfgInt s.mlx a (.jsPtr b 0 bytes) name value hn
  rw [cfgUpdate_success s.mlx a c {c with ints := c.ints ++ [(name,value)]}
    (fun c => some {c with ints := c.ints ++ [(name,value)]}) hc rfl] at hn'
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hn',ok,M.bind,M.pure,configIntWorld]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.ConfigIntHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_metal_kernel_config_add_template_arg_int"
def signature : List Val := [.str chars!"u64",.str chars!"cstring",.str chars!"i32"]

def finishInt (s : Host.Ts.St LSt) (a b : Nat) (c : Cfg) (name : Name) (bytes : List Byte) (value : NumV) : Host.Ts.St LSt :=
  finishStatus s (Host.Load.Owned.configIntWorld s.ffi a c name value) symbol
    [.big (Int.ofNat a),.jsPtr b 0 bytes,.num value]

theorem step_int_eq (s : Host.Ts.St LSt) (fn types a b : Nat) (value : NumV)
    (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (c : Cfg) (name : Name) (bytes : List Byte)
    (hc : s.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.ptr (.js b) 0,.num value])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : bufBytes F s b = some bytes) (hn : s.ffi.mlx.obj? a = some (.cfg c))
    (hname : cstrArg (.jsPtr b 0 bytes) = some name) :
    step F s = (NumericDecoder.i32.action value).bind fun v => M.pure (finishInt s a b c name bytes v) := by
  have hd : decodeArgs F s signature [.big (Int.ofNat a),.ptr (.js b) 0,.num value] =
      (NumericDecoder.i32.action value).bind fun v => M.pure (some [.big (Int.ofNat a),.jsPtr b 0 bytes,.num v]) := by
    have hnum := NumericDecoder.i32.decode F s value
    dsimp only [NumericDecoder.name] at hnum
    funext β k
    simp only [signature,decodeArgs,decode_u64_big,decode_cstring_pointer F s b 0 bytes hb,
      hnum,M.bind,M.pure,List.drop_zero,Option.map_some]
  funext β k
  simp only [step,hc,callStep,Host.Ts.St.obj?,hf,hk,callNative,ffiN]
  rw [elemsOf_array F s types signature₀ _ (by simp only [Host.Ts.St.obj?,ht]) htk]
  dsimp only [M.bind,M.pure]
  rw [hd]
  dsimp only [M.bind,M.pure]
  apply congrArg (NumericDecoder.i32.action value β)
  funext v
  have hcall : Host.Load.call s.ffi chars!"mlx_fast_metal_kernel_config_add_template_arg_int" [.big (Int.ofNat a),.jsPtr b 0 bytes,.num v] =
      M.pure (some (Host.Load.Owned.configIntWorld s.ffi a c name v,status0,[])) := by
    exact Host.Load.Owned.load_config_int s.ffi a b c name bytes v hn hname
  change (Host.Load.call s.ffi chars!"mlx_fast_metal_kernel_config_add_template_arg_int"
    [.big (Int.ofNat a),.jsPtr b 0 bytes,.num v] β
    (fun result => ffiDone F s symbol [.big (Int.ofNat a),.jsPtr b 0 bytes,.num v] result β k)) = _
  exact congrArg (fun (m : M (Option (LSt × Ret × List (Nat × Nat × List Byte)))) =>
    m β (fun result => ffiDone F s symbol [.big (Int.ofNat a),.jsPtr b 0 bytes,.num v] result β k)) hcall

/-- The original template-integer setter derives the target C-string from
live bytes and retains a fixed numeric payload across the ABI cast. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types a b : Nat) (value₀ : NumV) (fo signature₀ buffer₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (bytes₀ : List Byte) (name : Name)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.ptr (.js b) 0,.num value₀])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (hb₀ : s₀.heap.get b = some (.obj buffer₀)) (hbk₀ : buffer₀.kind = .buf bytes₀)
    (sourceName : cstrArg (.jsPtr b 0 bytes₀) = some name)
    (signatureFrame : ¬ framed types) (handleLive : H a)
    (role : Config) (source : Cfg) (objectRole : objects a = .config role)
    (sourceConfig : s₀.ffi.mlx.obj? a = some (.cfg source))
    (numberRole : Number) (sourceValue : numberRole.Holds ν₀ C₀ value₀)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle a).Holds ν C R (callArgument s.ctl 0))
    (targetValue : numberRole.ValueHolds ν C (callArgument s.ctl 2))
    (sourceBound : a < 2^64) (targetBound : R.handle a < 2^64) :
    ∃ value₀' value' bytes target D₀ D,
      interpC (step Host.Load.ffi s₀).run C₀ = some (finishInt s₀ a b source name bytes₀ value₀',D₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishInt s (R.handle a) (R.a b) target name bytes value',D) ∧
      StateR (NumberRoles ν₀ ν D₀ D)
        (VectorHost.NativeRelation ν₀ ν D₀ D nodes boundary
          (objectWrite objects a (.config {role with ints := role.ints ++ [(name,numberRole.decoded .i32)]}))
          H N tail host)
        R live framed before after old old'
        (finishInt s₀ a b source name bytes₀ value₀')
        (finishInt s (R.handle a) (R.a b) target name bytes value') ∧
      TableExtends C₀ D₀ ∧ TableExtends C D ∧
      (∀ meaning, numberRole = .literal meaning → D₀ = C₀ ∧ D = C) := by
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
              cases hp; cases hv
              have he := fixed_handle_value handleRole
              simp only [hc,callArgument,Host.Ts.arg,nthD] at he
              rw [he] at hc
              obtain ⟨value,heq,hvalue⟩ := targetValue
              simp only [hc,callArgument,Host.Ts.arg,nthD] at heq
              rw [heq] at hc
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
              obtain ⟨value₀',D₀,run₀,role₀,ext₀⟩ := sourceValue.decode .i32
              obtain ⟨value',D,run',role',ext⟩ := hvalue.decode .i32
              have literalServers (meaning : SymE) (literal : numberRole = .literal meaning) : D₀ = C₀ ∧ D = C := by
                cases literal
                cases sourceValue with | literal _ x _ =>
                  cases hvalue with | literal _ y _ =>
                    have left : some (.lit (F64.un .int32 x),C₀) = some (value₀',D₀) := run₀
                    have right : some (.lit (F64.un .int32 y),C) = some (value',D) := run'
                    exact ⟨(congrArg Prod.snd (Option.some.inj left)).symm,
                      (congrArg Prod.snd (Option.some.inj right)).symm⟩
              have hm := VectorHost.state_mono h ext₀ ext
              obtain ⟨target,targetConfig,sourceFields,targetFields⟩ :=
                hm.native.2.config_view_roles a handleLive role source objectRole sourceConfig
              let updated : Config := {role with ints := role.ints ++ [(name,numberRole.decoded .i32)]}
              have nativeAfter : VectorHost.NativeRelation ν₀ ν D₀ D nodes boundary
                  (objectWrite objects a (.config updated)) H N tail host R
                  (Host.Load.Owned.configIntWorld s₀.ffi a source name value₀')
                  (Host.Load.Owned.configIntWorld s.ffi (R.handle a) target name value') :=
                ⟨hm.native.1,hm.native.2.setObjectRoles a handleLive _ _
                  (ObjectRel.write_config objects ν₀ ν D₀ D R a updated _ _
                    (sourceFields.addInt name role₀) (targetFields.addInt name role'))
                  (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceBound targetBound⟩
              have numberPair := Number.paired role₀ role'
              have zeroRole : NumberRoles ν₀ ν D₀ D zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
              have nameBytes := Parametric.TreeR.mono (NumberRoles.mono ext₀ ext) (bytes_roles hbytes)
              have argumentRoles : ForestR (NumberRoles ν₀ ν D₀ D) R
                  ([.big (Int.ofNat a),.jsPtr b 0 bytes₀,.num value₀'].map Parametric.arg)
                  ([.big (Int.ofNat (R.handle a)),.jsPtr (R.a b) 0 bytes,.num value'].map Parametric.arg) :=
                .cons (.node _ (.cons (.value (.handle a)) .nil))
                  (.cons (.node _ (.cons (.address b) (.cons (.atom _ _) (.cons nameBytes .nil))))
                    (.cons (.node _ (.cons (.number numberPair) .nil)) .nil))
              have eventRoles : TreeR (NumberRoles ν₀ ν D₀ D) R
                  (event ⟨symbol,[.big (Int.ofNat a),.jsPtr b 0 bytes₀,.num value₀'],status0⟩)
                  (event ⟨symbol,[.big (Int.ofNat (R.handle a)),.jsPtr (R.a b) 0 bytes,.num value'],status0⟩) :=
                .node _ (.cons (.atom _ _) (.cons (.node _ argumentRoles)
                  (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
              refine ⟨value₀',value',bytes,target,D₀,D,?_,?_,
                hm.finishStatus _ _ nativeAfter _ _ _ eventRoles zeroRole,ext₀,ext,literalServers⟩
              · change interpC (step F s₀).run C₀ = _
                rw [step_int_eq s₀ fn types a b value₀ fo signature₀ returns receiver source name bytes₀
                  hc₀ hf₀ hk₀ ht₀ htk₀
                  (bufBytes_of_obj F s₀ b buffer₀ bytes₀ (by simp only [Host.Ts.St.obj?,hb₀]) hbk₀) sourceConfig sourceName]
                rw [NumericDecoder.i32.bind_run,run₀]
                rfl
              · change interpC (step F s).run C = _
                rw [step_int_eq s (R.a fn) (R.a types) (R.handle a) (R.a b) value fo' signature' returns this target name bytes
                  hc hfo hfk hto htKind
                  (bufBytes_of_obj F s (R.a b) buffer bytes (by simp only [Host.Ts.St.obj?,hb]) hbKind) targetConfig targetName]
                rw [NumericDecoder.i32.bind_run,run']
                rfl

end Host.Load.Run.Full.Ordinary.ConfigIntHost
