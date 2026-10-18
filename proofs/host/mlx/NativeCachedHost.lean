import host.mlx.NativeCachedRoles
import host.mlx.NativeReshapeHost

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev F : Host.Ts.Ffi := ⟨LSt,Host.Load.call,Host.Load.read,fun _ => 4096,Host.Load.back⟩
def symbol : Name := chars!"mlx_closure_apply"
def signature : List Val := [.str chars!"ptr",.str chars!"u64",.str chars!"u64"]
def arguments (out closure inputs : Nat) : List Host.Ts.Owned.Annotated.FixedArgument :=
  [.pointer out 0,.handle closure,.handle inputs]
def callArgs (out closure inputs slot : Nat) : List Arg :=
  [.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat slot)) 8 0),.big (Int.ofNat closure),.big (Int.ofNat inputs)]
def resultWorld (s : LSt) (final : Host.Mlx.Ffi.St) (slot : Nat) (outputs : List Nat) : LSt :=
  {s with mlx := final.setObj slot (.vec outputs)}

theorem load_call (s : LSt) (args : List Arg) (native : Host.Mlx.Ffi.St)
    (ws : List (Nat × Nat × List Byte))
    (hc : Host.Mlx.Ffi.call s.mlx symbol args = okW native status0 ws) :
    F.call s symbol args = M.pure (some ({s with mlx := native},status0,ws)) := by
  have hm : isMlx symbol = true := by decide +kernel
  funext β k
  simp only [F,Host.Load.call,hm,Bool.cond_true,hc,okW,M.bind,M.pure]

theorem step_cached_eq (s : Host.Ts.St LSt) (fn types out closure inputs slot : Nat)
    (fo signature₀ buffer : Host.Ts.Obj) (returns : Name) (receiver : Val) (native : LSt)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat closure),.big (Int.ofNat inputs)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer))
    (hbk : buffer.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (nativeCall : F.call s.ffi symbol (callArgs out closure inputs slot) =
      M.pure (some (native,status0,[u64Write out 0 slot]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
      (cellParts .u64 (.big (Int.ofNat slot)) 8 0) symbol (callArgs out closure inputs slot)) := by
  have hb' := bufBytes_of_obj F s out buffer _ (by simp only [Host.Ts.St.obj?,hb]) hbk
  have call : F.call s.ffi symbol
      [.jsPtr out 0 ((cellParts .u64 (.big (Int.ofNat slot)) 8 0).drop 0),.big (Int.ofNat closure),.big (Int.ofNat inputs)] =
      M.pure (some (native,status0,[u64Write out 0 slot])) := by
    simpa only [callArgs,List.drop_zero] using nativeCall
  rw [step_ffi_ptr_u64_u64 F s fn types out 0 (Int.ofNat closure) (Int.ofNat inputs)
    symbol returns fo signature₀ _ native status0 [u64Write out 0 slot] hc
    (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk hb' call]
  exact ffiDone_status0_buffer F s native out 0 buffer _ _ symbol _ (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- A fixed signature and a checked source replay plan close an actual cached
closure host call. The target argument decoding, trace selection, replay,
native output write and host heap update are all conclusions. Captured object
annotations outside the result vector retain their original meanings. -/
theorem from_source (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N K : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (fn types out cls inv slot callback : Nat) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (payload : Arg) (shapeless : Bool) (trace : Host.Mlx.Ffi.Trace) (inputs oldOutputs : List Nat)
    (final : Host.Mlx.Ffi.St) (substitutions : List (Nat × Nat))
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat cls),.big (Int.ofNat inv)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (signatureFrame : ¬ framed types) (closureLive : H cls) (inputsLive : H inv) (slotLive : H slot)
    (sourceClosure : s₀.ffi.mlx.obj? cls = some (.clo (.compiled callback payload shapeless [trace])))
    (sourceInputs : s₀.ffi.mlx.obj? inv = some (.vec inputs))
    (sourceOutput : s₀.ffi.mlx.obj? slot = some (.vec oldOutputs))
    (traceSupport : listSupport N trace.ins) (inputSupport : listSupport N inputs)
    (traceSignature : TraceSignature shapeless (inputRoles roles trace.ins) (inputRoles roles inputs))
    (traceMeta inputsMeta : List (List Dim × Nat))
    (sourceTraceMeta : Host.Mlx.Ffi.shapesOf s₀.ffi.mlx trace.ins = some traceMeta)
    (sourceInputsMeta : Host.Mlx.Ffi.shapesOf s₀.ffi.mlx inputs = some inputsMeta)
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary cls (NodeRel roles ν₀ ν C₀ C R boundary)
      N s₀.ffi.mlx (trace.ins.zip inputs) trace.order K final substitutions)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (traceOutputsSupport : listSupport N trace.outs)
    (argumentRoles : ListR (fun r v => r.role.Holds ν C R v) (arguments out cls inv) (callArguments s.ctl))
    (outputRole : (slotKindRole slot).Holds ν C R (objectKindAt s (R.a out)))
    (sourceNodes : s₀.ffi.mlx.nnext + trace.order.length < 2^64)
    (targetNodes : s.ffi.mlx.nnext + trace.order.length < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64) :
    ∃ final' : Host.Mlx.Ffi.St, ∃ t,
      interpC (step Host.Load.ffi s₀).run C₀ = some
        (finishBuffer s₀ (resultWorld s₀.ffi final slot (trace.outs.map (substOf substitutions))) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out cls inv slot),C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
          (objectWrite objects slot (.vec (trace.outs.map (substOf substitutions)))) H K tail host)
        R live framed before after old old'
        (finishBuffer s₀ (resultWorld s₀.ffi final slot (trace.outs.map (substOf substitutions))) out 0 outObject
          (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat slot)) 8 0)
          symbol (callArgs out cls inv slot)) t ∧
      (slotKindRole slot).Holds ν C R (objectKindAt t (R.a out)) ∧
      (∀ i, N i → K i) ∧
      listSupport K (trace.outs.map (substOf substitutions)) ∧
      final'.objs = s.ffi.mlx.objs ∧ final'.next = s.ffi.mlx.next ∧
      t.ffi = resultWorld s.ffi final' (R.handle slot) ((trace.outs.map (substOf substitutions)).map R.node) ∧
      t.next = s.next ∧ t.stack = s.stack ∧ (∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a) := by
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
        have exactTypes := string_values_exact [chars!"ptr",chars!"u64",chars!"u64"] htys
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
        obtain ⟨final',sourceCall,targetCall,nativeAfter,slotBytes,objectsFrame,nextFrame,inclusion,support⟩ :=
          native.cached_existing_signature cls inv callback out 0 slot payload shapeless trace inputs oldOutputs substitutions
            (.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
            (.jsPtr (R.a out) 0 (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0))
            closureLive inputsLive slotLive sourceClosure sourceInputs sourceOutput rfl rfl traceSupport inputSupport
            traceSignature traceMeta inputsMeta sourceTraceMeta sourceInputsMeta plan keys outputs traceOutputsSupport
            sourceNodes targetNodes sourceSlotBound targetSlotBound
        let native₀ := resultWorld s₀.ffi final slot (trace.outs.map (substOf substitutions))
        let native' := resultWorld s.ffi final' (R.handle slot) ((trace.outs.map (substOf substitutions)).map R.node)
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
            (objectWrite objects slot (.vec (trace.outs.map (substOf substitutions)))) H K tail host R native₀ native' :=
          ⟨h.native.1,nativeAfter⟩
        let args₀ := callArgs out cls inv slot
        let args' := callArgs (R.a out) (R.handle cls) (R.handle inv) (R.handle slot)
        let bytes₀ := cellParts .u64 (.big (Int.ofNat slot)) 8 0
        let bytes' := cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0
        let t := finishBuffer s native' (R.a out) 0 out' bytes' bytes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
          .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
            (.cons (.node _ (.cons (.value (.handle cls)) .nil)) (.cons (.node _ (.cons (.value (.handle inv)) .nil)) .nil))
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out bufferLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' bytes₀ bytes' bytes₀ bytes'
          symbol args₀ args' bufferLive ho₀ hok₀ hro hlo hbytes hbytes sourceHeap targetOutBound zeroRole eventRoles
        refine ⟨final',t,?_,?_,post,finishBuffer_slot_role ν C R s native' out slot out' symbol args' targetOutBound,
          inclusion,support,objectsFrame,nextFrame,rfl,rfl,rfl,?_⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[u64Write out 0 slot])) := by
            simpa only [native₀,resultWorld] using load_call s₀.ffi args₀ _ _ sourceCall
          rw [step_cached_eq s₀ fn types out cls inv slot fo signature₀ outObject returns receiver native₀
            hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[u64Write (R.a out) 0 (R.handle slot)])) := by
            simpa only [native',resultWorld] using load_call s.ffi args' _ _ targetCall
          rw [step_cached_eq s (R.a fn) (R.a types) (R.a out) (R.handle cls) (R.handle inv) (R.handle slot)
            fo' signature' out' returns this native' hc hfo hfk hto htKind ho hbk call]
          rfl
        · intro a ne
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right ne]

end Host.Load.Run.Full.Ordinary.CachedFamilyHost
