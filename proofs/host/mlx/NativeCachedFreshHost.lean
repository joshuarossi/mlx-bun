import host.mlx.NativeCachedHost
import host.mlx.NativeCachedFreshRoles
import host.mlx.NativeBufferResultFrame

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedFamilyHost
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def freshWorld (world : LSt) (final : Host.Mlx.Ffi.St) (outputs : List Nat) : LSt :=
  {world with mlx := (final.newObj (.vec outputs)).2}

theorem step_cached_fresh_eq (s : Host.Ts.St LSt) (fn types out closure inputs oldSlot newSlot : Nat)
    (fo signature₀ buffer : Host.Ts.Obj) (returns : Name) (receiver : Val) (native : LSt)
    (hc : s.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat closure),.big (Int.ofNat inputs)])
    (hf : s.heap.get fn = some (.obj fo))
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht : s.heap.get types = some (.obj signature₀)) (htk : signature₀.kind = .array signature)
    (hb : s.heap.get out = some (.obj buffer))
    (hbk : buffer.kind = .buf (cellParts .u64 (.big (Int.ofNat oldSlot)) 8 0))
    (nativeCall : F.call s.ffi symbol (callArgs out closure inputs oldSlot) =
      M.pure (some (native,status0,[u64Write out 0 newSlot]))) :
    step F s = M.pure (finishBuffer s native out 0 buffer (cellParts .u64 (.big (Int.ofNat oldSlot)) 8 0)
      (cellParts .u64 (.big (Int.ofNat newSlot)) 8 0) symbol (callArgs out closure inputs oldSlot)) := by
  have bytes := bufBytes_of_obj F s out buffer _ (by simp only [Host.Ts.St.obj?,hb]) hbk
  have call : F.call s.ffi symbol
      [.jsPtr out 0 ((cellParts .u64 (.big (Int.ofNat oldSlot)) 8 0).drop 0),.big (Int.ofNat closure),.big (Int.ofNat inputs)] =
      M.pure (some (native,status0,[u64Write out 0 newSlot])) := by simpa only [callArgs,List.drop_zero] using nativeCall
  rw [step_ffi_ptr_u64_u64 F s fn types out 0 (Int.ofNat closure) (Int.ofNat inputs) symbol returns
    fo signature₀ _ native status0 [u64Write out 0 newSlot] hc
    (by simp only [Host.Ts.St.obj?,hf]) hk (by simp only [Host.Ts.St.obj?,ht]) htk bytes call]
  exact ffiDone_status0_buffer F s native out 0 buffer _ _ symbol _ (by simp only [Host.Ts.St.obj?,hb]) hbk

/-- The original host dispatcher and applyWrites close the fresh cached branch
from current call/slot notes and producer policy. All six retained families
and strong indexed native annotations survive; the written slot is updated
to the actual fresh native handle. No target role or run is assumed. -/
theorem retained_fresh_from_source {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N K roots : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (policy : ProducerAnnotations roots H N roles objects)
    (fn types out cls inv slot callback : Nat) (fo signature₀ outObject : Host.Ts.Obj) (returns : Name) (receiver : Val)
    (payload : Arg) (shapeless : Bool) (trace : Host.Mlx.Ffi.Trace) (inputs : List Nat)
    (final : Host.Mlx.Ffi.St) (substitutions : List (Nat × Nat))
    (hc₀ : s₀.ctl = .call (.obj fn) receiver [.ptr (.js out) 0,.big (Int.ofNat cls),.big (Int.ofNat inv)])
    (hf₀ : s₀.heap.get fn = some (.obj fo))
    (hk₀ : fo.kind = .fn (.native (.ffi .symbol) [.str symbol,.obj types,.str returns]))
    (ht₀ : s₀.heap.get types = some (.obj signature₀)) (htk₀ : signature₀.kind = .array signature)
    (ho₀ : s₀.heap.get out = some (.obj outObject))
    (hok₀ : outObject.kind = .buf (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
    (signatureFrame : ¬ framed types) (closureLive : H cls) (inputsLive : H inv) (slotLive : H slot)
    (sourceClosure : s₀.ffi.mlx.obj? cls = some (.clo (.compiled callback payload shapeless [trace])))
    (sourceInputs : s₀.ffi.mlx.obj? inv = some (.vec inputs)) (sourceOutput : s₀.ffi.mlx.obj? slot = none)
    (traceSignature : TraceSignature shapeless (inputRoles roles trace.ins) (inputRoles roles inputs))
    (traceMeta inputsMeta : List (List Dim × Nat))
    (sourceTraceMeta : Host.Mlx.Ffi.shapesOf s₀.ffi.mlx trace.ins = some traceMeta)
    (sourceInputsMeta : Host.Mlx.Ffi.shapesOf s₀.ffi.mlx inputs = some inputsMeta)
    (plan : ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary cls (NodeRel roles ν₀ ν C₀ C R boundary)
      N s₀.ffi.mlx (trace.ins.zip inputs) trace.order K final substitutions)
    (keys : listSupport (fun p : Nat × Nat => p.1 < final.nnext) substitutions)
    (outputs : listSupport (· < final.nnext) trace.outs)
    (sourceNodes : s₀.ffi.mlx.nnext + trace.order.length < 2^64) (targetNodes : s.ffi.mlx.nnext + trace.order.length < 2^64)
    (sourceHandles : s₀.ffi.mlx.next < 2^64) (targetHandles : s.ffi.mlx.next < 2^64)
    (sourceHeap : out < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Value) (note : notes.runtime.control = callNote fnRole thisRole ((arguments out cls inv).map FixedArgument.role))
    (selected : notes.buffers.owners out = some (handleSlotNotes slot)) :
    let sourcePost := finishBuffer s₀ (freshWorld s₀.ffi final (trace.outs.map (substOf substitutions))) out 0 outObject
      (cellParts .u64 (.big (Int.ofNat slot)) 8 0) (cellParts .u64 (.big (Int.ofNat final.next)) 8 0) symbol (callArgs out cls inv slot)
    let newObjects := objectWrite objects final.next (.vec (trace.outs.map (substOf substitutions)))
    let newH := fun i => i = final.next ∨ H i
    ∃ t, interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary newObjects newH K tail host)
        R live framed before after old old' sourcePost t ∧
      RetainedInventory (notes.nativeHandleResult out final.next) ν₀ ν C₀ C R live sourcePost t ∧
      ProducerAnnotations roots newH K roles newObjects ∧ ProducerSupport roots newH K sourcePost.ffi.mlx := by
  dsimp only
  have argumentRoles := (inventory.runtime.native_arguments fnRole thisRole (arguments out cls inv) (.obj fn) receiver _ hc₀ note).2
  have outputRole := (inventory.buffers.slot_roles out slot selected).2
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
        obtain ⟨final',sourceCall,targetCall,nativeAfter,policyPost,supportPost,slotBytes⟩ := native.cached_fresh_signature policy
          cls inv callback out 0 slot payload shapeless trace inputs substitutions
          (.jsPtr out 0 (cellParts .u64 (.big (Int.ofNat slot)) 8 0))
          (.jsPtr (R.a out) 0 (cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0))
          closureLive inputsLive slotLive sourceClosure sourceInputs sourceOutput rfl rfl traceSignature
          traceMeta inputsMeta sourceTraceMeta sourceInputsMeta plan keys outputs sourceNodes targetNodes sourceHandles targetHandles
        have counter := nativeAfter.handleMap.head
        change R.handle (final.next+1) = final'.next+1 at counter
        rw [plan.frames.2,native.handleMap.fresh 1] at counter
        have targetCounter : final'.next = s.ffi.mlx.next := by omega
        have freshMap : R.handle final.next = final'.next := by rw [plan.frames.2,targetCounter,native.handleMap.head]
        let native₀ := freshWorld s₀.ffi final (trace.outs.map (substOf substitutions))
        let native' := freshWorld s.ffi final' ((trace.outs.map (substOf substitutions)).map R.node)
        have nativeRelated : VectorHost.NativeRelation ν₀ ν C₀ C roles boundary
            (objectWrite objects final.next (.vec (trace.outs.map (substOf substitutions))))
            (fun i => i = final.next ∨ H i) K tail host R native₀ native' := ⟨h.native.1,nativeAfter⟩
        let args₀ := callArgs out cls inv slot
        let args' := callArgs (R.a out) (R.handle cls) (R.handle inv) (R.handle slot)
        let bytes₀ := cellParts .u64 (.big (Int.ofNat slot)) 8 0
        let bytes' := cellParts .u64 (.big (Int.ofNat (R.handle slot))) 8 0
        let writes₀ := cellParts .u64 (.big (Int.ofNat final.next)) 8 0
        let writes' := cellParts .u64 (.big (Int.ofNat final'.next)) 8 0
        let sourcePost := finishBuffer s₀ native₀ out 0 outObject bytes₀ writes₀ symbol args₀
        let t := finishBuffer s native' (R.a out) 0 out' bytes' writes' symbol args'
        have zeroRole : NumberRoles ν₀ ν C₀ C zeroN zeroN := ⟨.lit (F64.zero false),⟨rfl,rfl⟩⟩
        have argsRelated : ForestR (NumberRoles ν₀ ν C₀ C) R (args₀.map Parametric.arg) (args'.map Parametric.arg) :=
          .cons (.node _ (.cons (.address out) (.cons (.atom _ _) (.cons (bytes_roles hbytes) .nil))))
            (.cons (.node _ (.cons (.value (.handle cls)) .nil)) (.cons (.node _ (.cons (.value (.handle inv)) .nil)) .nil))
        have eventRoles : TreeR (NumberRoles ν₀ ν C₀ C) R (event ⟨symbol,args₀,status0⟩) (event ⟨symbol,args',status0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ argsRelated) (.cons (.node _ (.cons (.number zeroRole) .nil)) .nil)))
        have targetOutBound := Nat.lt_trans (h.heap.targetBound out bufferLive) targetHeap
        have post := h.finishBuffer_event native₀ native' nativeRelated out 0 outObject out' bytes₀ bytes' writes₀ writes'
          symbol args₀ args' bufferLive ho₀ hok₀ hro hlo hbytes slotBytes sourceHeap targetOutBound zeroRole eventRoles
        have sourceFrame := NativeHeapFrame.finishBuffer s₀ native₀ out 0 outObject bytes₀ writes₀ symbol args₀ ho₀ hok₀ sourceHeap
        have targetFrame := NativeHeapFrame.finishBuffer s native' (R.a out) 0 out' bytes' writes' symbol args' ho hbk targetOutBound
        have sourceOutside : ∀ a, a ≠ out → sourcePost.heap.get a = s₀.heap.get a := by
          intro a different
          change (s₀.heap.set out _).get a = s₀.heap.get a
          rw [PTrie.get_set_u64 _ _ _ sourceHeap,ite_eq_right different]
        have targetOutside : ∀ a, a ≠ R.a out → t.heap.get a = s.heap.get a := by
          intro a different
          change (s.heap.set (R.a out) _).get a = s.heap.get a
          rw [PTrie.get_set_u64 _ _ _ targetOutBound,ite_eq_right different]
        have sourceSlotRole : (slotKindRole final.next).Holds ν₀ C₀ identity (objectKindAt sourcePost out) := by
          have patch : bytes₀.take 0 ++ writes₀ ++ bytes₀.drop (0 + len writes₀) = writes₀ := rfl
          simp only [sourcePost,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ sourceHeap,patch]
          exact slot_role_source ν₀ C₀ final.next
        have targetSlotRole : (slotKindRole final.next).Holds ν C R (objectKindAt t (R.a out)) := by
          have patch : bytes'.take 0 ++ writes' ++ bytes'.drop (0 + len writes') = writes' := rfl
          simp only [t,objectKindAt,finishBuffer,Host.Ts.St.ret,Host.Ts.St.setTrace,Host.Ts.St.setFfi,Host.Ts.St.setObj,
            Host.Ts.St.obj?,PTrie.get_set_u64 _ _ _ targetOutBound,patch]
          dsimp only [writes']
          rw [←freshMap]
          exact slot_role ν C R final.next
        have retained := inventory.native_handle_result h.heap out final.next (handleSlotNotes slot) selected
          sourceFrame targetFrame sourceSlotRole targetSlotRole sourceOutside targetOutside rfl rfl
        refine ⟨t,?_,?_,post,retained,policyPost,supportPost⟩
        · change interpC (step F s₀).run C₀ = _
          have call : F.call s₀.ffi symbol args₀ = M.pure (some (native₀,status0,[u64Write out 0 final.next])) := by
            simpa only [native₀,freshWorld] using load_call s₀.ffi args₀ _ _ sourceCall
          rw [step_cached_fresh_eq s₀ fn types out cls inv slot final.next fo signature₀ outObject returns receiver native₀
            hc₀ hf₀ hk₀ ht₀ htk₀ ho₀ hok₀ call]
          rfl
        · change interpC (step F s).run C = _
          have call : F.call s.ffi symbol args' = M.pure (some (native',status0,[u64Write (R.a out) 0 final'.next])) := by
            simpa only [native',freshWorld] using load_call s.ffi args' _ _ targetCall
          rw [step_cached_fresh_eq s (R.a fn) (R.a types) (R.a out) (R.handle cls) (R.handle inv) (R.handle slot) final'.next
            fo' signature' out' returns this native' hc hfo hfk hto htKind ho hbk call]
          rfl

end Host.Load.Run.Full.Ordinary.CachedFamilyHost
