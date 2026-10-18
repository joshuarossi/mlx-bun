import host.mlx.NativeConfigRoles
import host.mlx.NativeDecodeRoles
import host.mlx.NativeRelationTables
import host.mlx.NativeSymbol
import host.mlx.FixedNativeRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

inductive ConfigTriplet where
  | grid | group

def ConfigTriplet.name : ConfigTriplet → Name
  | .grid => chars!"mlx_fast_metal_kernel_config_set_grid"
  | .group => chars!"mlx_fast_metal_kernel_config_set_thread_group"

def ConfigTriplet.config : ConfigTriplet → Cfg → List NumV → Cfg
  | .grid,c,values => {c with grid := values}
  | .group,c,values => {c with group := values}

def ConfigTriplet.role : ConfigTriplet → Config → List Number → Config
  | .grid,c,values => {c with grid := values}
  | .group,c,values => {c with group := values}

theorem ConfigTriplet.holds (op : ConfigTriplet) {ν : Nat → F64} {C : CSrv} {r : Config} {c : Cfg}
    {roles : List Number} {values : List NumV} (h : r.Holds ν C c) (hv : ListR (Number.Holds ν C) roles values) :
    (op.role r roles).Holds ν C (op.config c values) := by
  cases op with
  | grid => exact h.setGrid hv
  | group => exact h.setGroup hv

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem config_triplet_call (op : ConfigTriplet) (s : St) (a : Nat) (x y z : NumV) :
    Ffi.call s op.name [.big (Int.ofNat a),.num x,.num y,.num z] =
      cfgUpdate s (.big (Int.ofNat a)) (fun c => some (op.config c [x,y,z])) := by
  cases op with
  | grid => exact call_cfgGrid s a x y z
  | group => exact call_cfgGroup s a x y z

end Host.Mlx.Ffi.NativeRoles

namespace Host.Load.Owned
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def configTripletWorld (op : ConfigTriplet) (s : LSt) (a : Nat) (c : Cfg) (x y z : NumV) : LSt :=
  {s with mlx := s.mlx.setObj a (.cfg (op.config c [x,y,z]))}

theorem load_config_triplet (op : ConfigTriplet) (s : LSt) (a : Nat) (c : Cfg) (x y z : NumV)
    (hc : s.mlx.obj? a = some (.cfg c)) :
    Host.Load.call s op.name [.big (Int.ofNat a),.num x,.num y,.num z] =
      M.pure (some (configTripletWorld op s a c x y z,status0,[])) := by
  have hm : isMlx op.name = true := by cases op <;> decide +kernel
  have hn := config_triplet_call op s.mlx a x y z
  rw [cfgUpdate_success s.mlx a c (op.config c [x,y,z]) _ hc rfl] at hn
  funext β k
  simp only [Host.Load.call,hm,Bool.cond_true,hn,ok,M.bind,M.pure,configTripletWorld]

end Host.Load.Owned

namespace Host.Load.Run.Full.Ordinary.ConfigHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.NativeRoles.Arguments Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩

def signature : List Val := [.str chars!"u64",.str chars!"u32",.str chars!"u32",.str chars!"u32"]

def finishTriplet (op : ConfigTriplet) (s : Host.Ts.St LSt) (a : Nat) (c : Cfg) (x y z : NumV) : Host.Ts.St LSt :=
  finishStatus s (Host.Load.Owned.configTripletWorld op s.ffi a c x y z) op.name [.big (Int.ofNat a),.num x,.num y,.num z]

theorem step_triplet_eq (op : ConfigTriplet) (s : Host.Ts.St LSt) (fn types a : Nat) (x y z : NumV)
    (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val) (c : Cfg)
    (hc : s.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.num x,.num y,.num z])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str op.name,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hn : s.ffi.mlx.obj? a = some (.cfg c)) :
    step F s = (NumericDecoder.u32.action x).bind fun x =>
      (NumericDecoder.u32.action y).bind fun y => (NumericDecoder.u32.action z).bind fun z =>
        M.pure (finishTriplet op s a c x y z) := by
  funext β k
  simp only [step,hc,callStep,Host.Ts.St.obj?,hf,hk,callNative,ffiN]
  rw [elemsOf_array F s types signature₀ _ (by simp only [Host.Ts.St.obj?,ht]) htk]
  dsimp only [M.bind,M.pure]
  rw [show decodeArgs F s signature [.big (Int.ofNat a),.num x,.num y,.num z] = _ from
    NumericDecoder.u32.decode_triple F s (Int.ofNat a) x y z]
  dsimp only [M.bind,M.pure]
  apply congrArg (NumericDecoder.u32.action x β)
  funext x'
  apply congrArg (NumericDecoder.u32.action y β)
  funext y'
  apply congrArg (NumericDecoder.u32.action z β)
  funext z'
  have hcall : F.call s.ffi op.name [.big (Int.ofNat a),.num x',.num y',.num z'] =
      M.pure (some (Host.Load.Owned.configTripletWorld op s.ffi a c x' y' z',status0,[])) := by
    simpa only [F] using Host.Load.Owned.load_config_triplet op s.ffi a c x' y' z' hn
  exact congrArg (fun (m : M (Option (LSt × Ret × List (Nat × Nat × List Byte)))) =>
    m β (fun result => ffiDone F s op.name [.big (Int.ofNat a),.num x',.num y',.num z'] result β k)) hcall

/-- Original grid/thread-group dispatch, including all three ABI casts. The
fixed argument occurrences determine both converted configuration payloads;
all other indexed native objects and producers retain their annotations. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (op : ConfigTriplet) (fn types a : Nat) (x₀ y₀ z₀ : NumV)
    (fo signature₀ : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.big (Int.ofNat a),.num x₀,.num y₀,.num z₀])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str op.name,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (signatureFrame : ¬ framed types) (handleLive : H a)
    (role : Config) (source : Cfg) (objectRole : objects a = .config role)
    (sourceConfig : s₀.ffi.mlx.obj? a = some (.cfg source))
    (rx ry rz : Number)
    (sourceX : rx.Holds ν₀ C₀ x₀) (sourceY : ry.Holds ν₀ C₀ y₀) (sourceZ : rz.Holds ν₀ C₀ z₀)
    (handleRole : (Host.Ts.Owned.Annotated.Value.handle a).Holds ν C R (callArgument s.ctl 0))
    (targetX : rx.ValueHolds ν C (callArgument s.ctl 1))
    (targetY : ry.ValueHolds ν C (callArgument s.ctl 2))
    (targetZ : rz.ValueHolds ν C (callArgument s.ctl 3))
    (sourceBound : a < 2^64) (targetBound : R.handle a < 2^64) :
    ∃ x₀' y₀' z₀' x' y' z' target D₀ D,
      interpC (step Host.Load.ffi s₀).run C₀ = some (finishTriplet op s₀ a source x₀' y₀' z₀',D₀) ∧
      interpC (step Host.Load.ffi s).run C = some (finishTriplet op s (R.handle a) target x' y' z',D) ∧
      StateR (NumberRoles ν₀ ν D₀ D)
        (VectorHost.NativeRelation ν₀ ν D₀ D nodes boundary
          (objectWrite objects a (.config (op.role role [rx.decoded .u32,ry.decoded .u32,rz.decoded .u32])))
          H N tail host)
        R live framed before after old old'
        (finishTriplet op s₀ a source x₀' y₀' z₀')
        (finishTriplet op s (R.handle a) target x' y' z') ∧
      TableExtends C₀ D₀ ∧ TableExtends C D := by
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
        cases ha with | cons hh ha =>
          cases ha with | cons hx ha =>
            cases ha with | cons hy ha =>
              cases ha with | cons hz ha =>
                cases ha
                cases hx; cases hy; cases hz
                have he := fixed_handle_value handleRole
                simp only [hc,callArgument,Host.Ts.arg,nthD] at he
                rw [he] at hc
                obtain ⟨x,hex,hx⟩ := targetX
                obtain ⟨y,hey,hy⟩ := targetY
                obtain ⟨z,hez,hz⟩ := targetZ
                simp only [hc,callArgument,Host.Ts.arg,nthD] at hex hey hez
                rw [hex,hey,hez] at hc
                obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
                have htKind := htr.kind
                rw [htk₀] at htKind
                obtain ⟨tys,htKind,htys⟩ := kind_array htKind
                have exactTypes := string_values_exact [chars!"u64",chars!"u32",chars!"u32",chars!"u32"] htys
                rw [exactTypes] at htKind
                obtain ⟨x₀',A₀,y₀',B₀,z₀',D₀,hx₀',hy₀',hz₀',rx₀',ry₀',rz₀',ext₀⟩ :=
                  Number.Holds.triple_decode .u32 sourceX sourceY sourceZ
                obtain ⟨x',A,y',B,z',D,hx',hy',hz',rx',ry',rz',ext⟩ :=
                  Number.Holds.triple_decode .u32 hx hy hz
                have hm := VectorHost.state_mono h ext₀ ext
                obtain ⟨target,targetConfig,sourceFields,targetFields⟩ :=
                  hm.native.2.config_view_roles a handleLive role source objectRole sourceConfig
                let updated := op.role role [rx.decoded .u32,ry.decoded .u32,rz.decoded .u32]
                have sourceUpdated : updated.Holds ν₀ D₀ (op.config source [x₀',y₀',z₀']) :=
                  op.holds sourceFields (.cons rx₀' (.cons ry₀' (.cons rz₀' .nil)))
                have targetUpdated : updated.Holds ν D (op.config target [x',y',z']) :=
                  op.holds targetFields (.cons rx' (.cons ry' (.cons rz' .nil)))
                have nativeAfter : VectorHost.NativeRelation ν₀ ν D₀ D nodes boundary
                    (objectWrite objects a (.config updated)) H N tail host R
                    (Host.Load.Owned.configTripletWorld op s₀.ffi a source x₀' y₀' z₀')
                    (Host.Load.Owned.configTripletWorld op s.ffi (R.handle a) target x' y' z') :=
                  ⟨hm.native.1,hm.native.2.setObjectRoles a handleLive _ _
                    (ObjectRel.write_config objects ν₀ ν D₀ D R a updated _ _ sourceUpdated targetUpdated)
                    (fun _ ne _ _ p => ObjectRel.write_frame ne p) sourceBound targetBound⟩
                have hxRel := Number.paired rx₀' rx'
                have hyRel := Number.paired ry₀' ry'
                have hzRel := Number.paired rz₀' rz'
                have zeroRole : NumberRoles ν₀ ν D₀ D zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
                have eventRoles : TreeR (NumberRoles ν₀ ν D₀ D) R
                    (event ⟨op.name,[.big (Int.ofNat a),.num x₀',.num y₀',.num z₀'],status0⟩)
                    (event ⟨op.name,[.big (Int.ofNat (R.handle a)),.num x',.num y',.num z'],status0⟩) :=
                  .node _ (.cons (.atom _ _) (.cons (.node _
                    (.cons (.node _ (.cons (.value (.handle a)) .nil))
                      (.cons (.node _ (.cons (.number hxRel) .nil))
                        (.cons (.node _ (.cons (.number hyRel) .nil))
                          (.cons (.node _ (.cons (.number hzRel) .nil)) .nil)))))
                    (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
                refine ⟨x₀',y₀',z₀',x',y',z',target,D₀,D,?_,?_,
                  hm.finishStatus _ _ nativeAfter _ _ _ eventRoles zeroRole,ext₀,ext⟩
                · change interpC (step F s₀).run C₀ = _
                  rw [step_triplet_eq op s₀ fn types a x₀ y₀ z₀
                    fo signature₀ returns receiver source hc₀ hf₀ hk₀ ht₀ htk₀ sourceConfig]
                  exact NumericDecoder.u32.triple_run (fun x y z => M.pure (finishTriplet op s₀ a source x y z))
                    x₀ y₀ z₀ x₀' y₀' z₀' C₀ A₀ B₀ D₀ hx₀' hy₀' hz₀'
                · change interpC (step F s).run C = _
                  rw [step_triplet_eq op s (R.a fn) (R.a types) (R.handle a) x y z
                    fo' signature' returns this target hc hfo hfk hto htKind targetConfig]
                  exact NumericDecoder.u32.triple_run (fun x y z => M.pure (finishTriplet op s (R.handle a) target x y z))
                    x y z x' y' z' C A B D hx' hy' hz'

end Host.Load.Run.Full.Ordinary.ConfigHost
