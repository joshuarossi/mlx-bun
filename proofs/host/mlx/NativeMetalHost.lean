import host.mlx.OrdinaryMetalHost
import host.mlx.NativeWritesFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_fast_metal_kernel_apply"
abbrev signature := MetalHost.signature
def arguments (out kernel inputs config stream : Nat) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle kernel,.handle inputs,.handle config,.handle stream]
def callArgs (out kernel inputs config stream slot : Nat) : List Arg :=
  [.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat slot)) 8 0),.big (Int.ofNat kernel),.big (Int.ofNat inputs),
    .big (Int.ofNat config),.big (Int.ofNat stream)]
def result (s : LSt) (kernel : Nat) (inputs : List Nat) (config : Cfg) : Host.Mlx.Ffi.St × List Nat :=
  kernelApply.outs kernel inputs config s.mlx 0 config.outs
def resultWorld (s : LSt) (kernel : Nat) (inputs : List Nat) (config : Cfg) (slot : Nat) : LSt :=
  {s with mlx := (result s kernel inputs config).1.setObj slot (.vec (result s kernel inputs config).2)}

theorem step_metal_eq (s : Host.Ts.St LSt) (fn types out kernel inputs config stream slot : Nat)
    (fo signature₀ buffer : Host.Ts.Obj) (returns : Name) (receiver : Val) (native : LSt)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat kernel),.big (Int.ofNat inputs),
      .big (Int.ofNat config),.big (Int.ofNat stream)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer)) (hbk : buffer.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (nativeCall : F.call s.ffi symbol (callArgs out kernel inputs config stream slot) =
      M.pure (some (native,status0,[u64Write out 0 slot]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
      (cellParts .u64 (.big (Int.ofNat slot)) 8 0) symbol (callArgs out kernel inputs config stream slot)) := by
  have hb' := bufBytes_of_obj F s out buffer _ (by simp only [Host.Ts.St.obj?,hb]) hbk
  rw [step_ffi_decoded F s fn types symbol returns fo signature₀ receiver signature _ _ native status0 [u64Write out 0 slot]
    hc (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk
    (MetalHost.decode_metal F s out (Int.ofNat kernel) (Int.ofNat inputs) (Int.ofNat config) (Int.ofNat stream) _ hb') nativeCall]
  exact ffiDone_status0_buffer F s native out 0 buffer _ _ symbol _ (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- Any actual Metal apply to an existing owned output vector. The source
kernel, input vector and indexed configuration determine all target objects
and fresh output annotations. All other object/configuration/payload roles are
framed, while producer support is returned for later vector-element reads. -/
theorem from_source_framed (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out kernel inv cfg stream slot : Nat) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (name source header : Name) (nIn nOut : Nat) (inputs oldOutputs : List Nat) (config : Config) (c : Cfg)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat kernel),.big (Int.ofNat inv),
      .big (Int.ofNat cfg),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (signatureFrame : ¬ framed types) (kernelLive : H kernel) (inputsLive : H inv) (configLive : H cfg) (slotLive : H slot)
    (sourceKernel : s₀.ffi.mlx.obj? kernel = some (.kernel name source header nIn nOut))
    (sourceInputs : s₀.ffi.mlx.obj? inv = some (.vec inputs))
    (sourceOutput : s₀.ffi.mlx.obj? slot = some (.vec oldOutputs))
    (sourceConfig : s₀.ffi.mlx.obj? cfg = some (.cfg c)) (configRole : objects cfg = .config config)
    (inputSupport : listSupport N inputs)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v)
      (arguments out kernel inv cfg stream) (callArguments s.ctl))
    (outputRole : (slotKindRole slot).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext + config.outs.length < 2^64)
    (targetNodes : s.ffi.mlx.nnext + config.outs.length < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ K t, interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs) boundary
          (objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)) H K tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      (slotKindRole slot).Holds ν C R (objectKindAt t (R.a out)) ∧
      (∀ i, N i → K i) ∧ listSupport K (result s₀.ffi kernel inputs c).2 ∧ listSupport K inputs ∧
      t.next = s.next ∧ t.stack = s.stack ∧ (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s₀ (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) ∧
      Host.Ts.Owned.Annotated.NativeHeapFrame s t ∧ t.ctl = .ret (.num zeroN) := by
  have calleeLive : live fn := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have bufferLive : live out := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.2.1.1
  obtain ⟨_,_,_,hol⟩ := h.heap.readObject fn fo calleeLive
    (h.heap.function_notFramed fn fo _ calleeLive hf₀ hk₀) hf₀
  have signatureLive : live types := by have hl := hol.1; rw [hk₀] at hl; exact hl.1.2.1.2.1
  obtain ⟨fo',data,this,args,hc,hfo,hfk,hd,_,_⟩ := h.native_call_view fn fo (.ffi .symbol) _ receiver _ hc₀ hf₀ hk₀
  cases hd with | cons hn hd =>
    cases hd with | cons ht hd =>
      cases hd with | cons hr hd =>
        cases hd
        cases hn; cases ht; cases hr
        have exactArgs := Host.Ts.Owned.Annotated.FixedArgument.list_exact _ argumentRoles
        simp only [hc,callArguments] at exactArgs
        rw [exactArgs] at hc
        simp only [arguments,Host.Ts.Owned.Annotated.FixedArgument.value,List.map_cons,List.map_nil] at hc
        obtain ⟨signature',hto,htr,_⟩ := h.heap.readObject types signature₀ signatureLive signatureFrame ht₀
        have htKind := htr.kind
        rw [htk₀] at htKind
        obtain ⟨tys,htKind,htys⟩ := kind_array htKind
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64",chars!"u64",chars!"u64"] htys
        rw [exactTypes] at htKind
        obtain ⟨out',ho,hro,hlo⟩ := h.heap.readObject out outObject bufferLive
          (h.heap.buffer_notFramed out outObject _ bufferLive ho₀ hok₀) ho₀
        have outKind := hro.kind
        rw [hok₀] at outKind
        obtain ⟨bytes,hbk,hbytes⟩ := kind_buffer outKind
        have slotAnnotation : (slotKindRole slot).Holds ν C R (Encode.kind out'.kind) := by
          simpa only [objectKindAt,Host.Ts.St.obj?,ho] using outputRole
        have exactBytes := Kind.buf.inj (hbk.symm.trans (slot_kind_exact slotAnnotation))
        subst bytes
        have native := h.native.2
        have sourceSlotBound := Nat.lt_trans (native.liveHandleBound slot slotLive) sourceHandles
        have targetSlotBound := Nat.lt_trans (native.handleMap.bound slot (native.liveHandleBound slot slotLive)) targetHandles
        obtain ⟨c',K,hcfg',sourceCall,targetCall,nativeAfter,mapped,inclusion,support,slotBytes⟩ := native.kernelApply_existing_roles
          (.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
          (.jsPtr (R.a out) 0 (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0)) out 0 slot kernel inv cfg
          name source header nIn nOut inputs oldOutputs config c slotLive kernelLive inputsLive configLive rfl rfl
          sourceKernel sourceInputs sourceOutput sourceConfig configRole sourceNodes targetNodes sourceSlotBound targetSlotBound
        let native₀ := resultWorld s₀.ffi kernel inputs c slot
        let native' := resultWorld s.ffi (R.handle kernel) (inputs.map R.node) c' (R.handle slot)
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C
            (kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs) boundary
            (objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)) H K tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let args₀ := callArgs out kernel inv cfg stream slot
        let args' := callArgs (R.a out) (R.handle kernel) (R.handle inv) (R.handle cfg) (R.handle stream) (R.handle slot)
        let bytes₀ := cellParts .u64 (.big (Int.ofNat slot)) 8 0
        let bytes' := cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' bytes' bytes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
          .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
            (.cons (.node _ (.cons (.value (.handle kernel)) .nil))
              (.cons (.node _ (.cons (.value (.handle inv)) .nil))
                (.cons (.node _ (.cons (.value (.handle cfg)) .nil)) (.cons (.node _ (.cons (.value (.handle stream)) .nil)) .nil))))
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out bufferLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' bytes₀ bytes' bytes₀ bytes'
          symbol args₀ args' bufferLive ho₀ hok₀ hro hlo hbytes hbytes sourceHeap targetOutBound zeroRole eventRoles
        have inputSupport' : listSupport K inputs := by
          have liftSupport : ∀ xs : List Nat, listSupport N xs → listSupport K xs := by
            intro xs
            induction xs with
            | nil => intro _; trivial
            | cons i ins ih => intro hs; exact ⟨inclusion i hs.1,ih hs.2⟩
          exact liftSupport inputs inputSupport
        refine ⟨K,t,?_,?_,post,finishBuffer_slot_role ν C R s native' out slot out' symbol args' targetOutBound,
          inclusion,support,inputSupport',rfl,rfl,?_,?_,?_,rfl⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[u64Write out 0 slot])) := by
            have call₀ : Host.Mlx.Ffi.call s₀.ffi.mlx symbol args₀ =
                okW native₀.mlx status0 [u64Write out 0 slot] := by
              simpa only [symbol,args₀,callArgs,native₀,resultWorld,result,call_kernelApply] using sourceCall
            simpa only [F,symbol,native₀,resultWorld] using MetalHost.load_metal_call s₀.ffi _ _ _ call₀
          rw [step_metal_eq s₀ fn types out kernel inv cfg stream slot fo signature₀ outObject returns receiver native₀
            hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[u64Write (R.a out) 0 (R.handle slot)])) := by
            have call' : Host.Mlx.Ffi.call s.ffi.mlx symbol args' =
                okW native'.mlx status0 [u64Write (R.a out) 0 (R.handle slot)] := by
              simpa only [symbol,args',callArgs,native',resultWorld,result,call_kernelApply] using targetCall
            simpa only [F,symbol,native',resultWorld] using MetalHost.load_metal_call s.ffi _ _ _ call'
          rw [step_metal_eq s (R.a fn) (R.a types) (R.a out) (R.handle kernel) (R.handle inv) (R.handle cfg)
            (R.handle stream) (R.handle slot) fo' signature' out' returns this native' hc hfo hfk hto htKind ho hbk call]
          rfl
        · intro a ne
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right ne]

        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject bytes₀ bytes₀
            symbol args₀ ho₀ hok₀ sourceHeap
        · exact Host.Ts.Owned.Annotated.NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' bytes' bytes'
            symbol args' ho hbk targetOutBound

theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out kernel inv cfg stream slot : Nat) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (name source header : Name) (nIn nOut : Nat) (inputs oldOutputs : List Nat) (config : Config) (c : Cfg)
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat kernel),.big (Int.ofNat inv),
      .big (Int.ofNat cfg),.big (Int.ofNat stream)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (signatureFrame : ¬ framed types) (kernelLive : H kernel) (inputsLive : H inv) (configLive : H cfg) (slotLive : H slot)
    (sourceKernel : s₀.ffi.mlx.obj? kernel = some (.kernel name source header nIn nOut))
    (sourceInputs : s₀.ffi.mlx.obj? inv = some (.vec inputs))
    (sourceOutput : s₀.ffi.mlx.obj? slot = some (.vec oldOutputs))
    (sourceConfig : s₀.ffi.mlx.obj? cfg = some (.cfg c)) (configRole : objects cfg = .config config)
    (inputSupport : listSupport N inputs)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v)
      (arguments out kernel inv cfg stream) (callArguments s.ctl))
    (outputRole : (slotKindRole slot).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext + config.outs.length < 2^64)
    (targetNodes : s.ffi.mlx.nnext + config.outs.length < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ K t, interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C
          (kernelOutputRoles roles kernel inputs config s₀.ffi.mlx.nnext 0 config.outs) boundary
          (objectWrite objects slot (.vec (result s₀.ffi kernel inputs c).2)) H K tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi kernel inputs c slot) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out kernel inv cfg stream slot)) t ∧
      (slotKindRole slot).Holds ν C R (objectKindAt t (R.a out)) ∧
      (∀ i, N i → K i) ∧ listSupport K (result s₀.ffi kernel inputs c).2 ∧ listSupport K inputs ∧
      t.next = s.next ∧ t.stack = s.stack ∧ (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) := by
  obtain ⟨K,t,sourceRun,targetRun,post,slotRole,inclusion,outputs,ins,next,stack,heap,_,_,_⟩ :=
    from_source_framed ν₀ ν C₀ C R roles boundary objects H N tail host live framed before after old old' s₀ s h
    fn types out kernel inv cfg stream slot fo signature₀ outObject returns receiver name source header nIn nOut
    inputs oldOutputs config c hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ signatureFrame kernelLive inputsLive configLive slotLive
    sourceKernel sourceInputs sourceOutput sourceConfig configRole inputSupport argumentRoles outputRole
    sourceNodes targetNodes sourceHandles targetHandles sourceHeap targetHeap
  exact ⟨K,t,sourceRun,targetRun,post,slotRole,inclusion,outputs,ins,next,stack,heap⟩

end Host.Load.Run.Full.Ordinary.MetalFamilyHost
