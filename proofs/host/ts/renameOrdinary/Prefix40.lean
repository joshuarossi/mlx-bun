import host.ts.renameOrdinary.Prefix39
import host.ts.renameOrdinary.DriverCall
import host.ts.renameOrdinary.ParameterRoles

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.Prefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def plainEntry {S : Type} (s : St S) (f : Func) (env : Env) (this : Val) (args : List Val) : St S :=
  let a := (s.alloc (.cell (some this))).2
  let p := allocCells a (paramNames f) ((nThis,s.next)::env)
  parameterContinuation p.2 f .call args p.1

theorem plainEntry_run (F : Ffi) (s : St F.S) (f : Func) (env : Env) (this : Val) (args : List Val) :
    enterClosure F s f env false .undef this args .call = M.pure (plainEntry s f env this args) := rfl

theorem plainEntry_arguments {S : Type} (s : St S) (f : Func) (env : Env) (this : Val) (args : List Val) :
    parameterArguments (plainEntry s f env this args) = args := rfl

/-- At the real closure entry, the checked argument values become the saved
parameter arguments without changing their occurrence meanings. -/
theorem call_arguments_preserved (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C D : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s result : St P.F.S)
    (h : StateR NR FR R live framed before after old old' callInput s)
    (run : interpC (step P.F s).run C = some (result,D)) :
    ∀ i, nthD .undef (parameterArguments result) i = callArgument s.ctl i := by
  obtain ⟨callee,this,args,hctl,hcallee,_,_⟩ := (h.control_view call_control).call_view
  cases hcallee
  have hl := h.controlLive
  change treeSupport live (Encode.ctl callInput.ctl) at hl
  rw [call_control] at hl
  have ha : live 2790 := hl.1
  have hn := h.heap.function_notFramed 2790 callObject _ ha call_heap call_kind
  obtain ⟨o,ho,hr,_⟩ := h.heap.readObject 2790 callObject ha hn call_heap
  have hk := hr.kind
  rw [call_kind] at hk
  obtain ⟨home,hk,hhome⟩ := kind_closure hk
  have hh : home = .undef := hhome.undef_iff.mp rfl
  subst home
  rw [step_closure_eq P.F s (R.a 2790) o Host.Ts.Sources.Mlx.Ops.ast_n172 (R.env callEnv)
    false .undef this args hctl ho hk,plainEntry_run] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  change plainEntry s Host.Ts.Sources.Mlx.Ops.ast_n172 (R.env callEnv) this args = result at he
  intro i
  rw [← he,plainEntry_arguments]
  simp only [hctl,callArgument,Host.Ts.arg]

/-- Source-only closure dispatch retains any annotation on the axis argument
at the actual parameter-entry cut. -/
theorem call_axis_transport (NR : NumV → NumV → Prop) (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St P.F.S)
    (h : StateR NR FR R live framed before after old old' callInput s)
    (bound : s.next + 2 + (paramNames Host.Ts.Sources.Mlx.Ops.ast_n172).length ≤ 2^64)
    (Q : Val → Prop) (axis : Q (callArgument s.ctl 1)) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R (ClosureLive live callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172)
        framed before after old old' callOutput result ∧ Q (nthD .undef (parameterArguments result) 1) := by
  obtain ⟨result,hr,hs⟩ := FirstCall.transport NR FR R C₀ C live framed before after old old' s h bound
  exact ⟨result,hr,hs,(call_arguments_preserved NR FR R C C live framed before after old old' s result h hr 1).symm ▸ axis⟩

theorem first_forty_transport
    (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Ren → Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail)
      R live framed before after old old' input s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (code : (Annotated.Value.literal (.lit (F64.ofNat 4))).Holds ν C R (nativeDataArgument s (R.a 90) 0))
    (proto : (Annotated.Value.literal (.lit (F64.ofNat 21))).Holds ν C R (nativeDataArgument s (R.a 90) 1))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedProtoLive : live 21) (typedProtoFixed : R.a 21 = 21)
    (arrayProtoLive : live aArrayProto) (arrayProtoFixed : R.a aArrayProto = aArrayProto)
    (nativeHandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (bound : s.next + 9 ≤ 2^64) :
    ∃ result, runC P.F 40 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) (NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail) R
        (ClosureLive (LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
          TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next)
          callInput.next false .undef Host.Ts.Sources.Mlx.Ops.ast_n172)
        framed before after old old' callOutput result ∧
      nthD .undef (parameterArguments result) 1 = natV 1 := by
  let fr := NativeFrame FR ν₀ ν C₀ C roles ObjRel boundary H N tail
  let live39 := LiveAfter (LiveAfter (LiveAfter (LiveAfter live NativeBuffer.input.next)
    TypedBuffer.input.next) ShapeSpread.input.next) P.RestStream.micro0.micro0.s35.next
  obtain ⟨s39,hr39,h39,axis39⟩ := transport_axis FR R ν₀ ν C₀ C roles ObjRel boundary H N tail
    live framed before after old old' s h rank code proto bufferProtoLive bufferProtoFixed
    typedProtoLive typedProtoFixed arrayProtoLive arrayProtoFixed nativeHandle region (by omega)
  have hn39 : s39.next = s.next+4 := counter_add h h39 4 (by host_kernel_rfl)
  have hl : (paramNames Host.Ts.Sources.Mlx.Ops.ast_n172).length = 3 := by decide +kernel
  have hb39 : s39.next + 2 + (paramNames Host.Ts.Sources.Mlx.Ops.ast_n172).length ≤ 2^64 := by
    rw [hl,hn39]; omega
  obtain ⟨result,hr40,h40,axis40⟩ := call_axis_transport (NumberRoles ν₀ ν C₀ C) fr R C₀ C live39
    framed before after old old' s39 h39 hb39 (fun v => v = natV 1) axis39
  have hh39 : isHalt s39.ctl = false := h39.control.isHalt_eq.trans (by host_kernel_rfl)
  have one : runC P.F 1 s39 C = some (result,C) := runC_cons P.F 0 s39 result result C C C hh39 hr40 rfl
  exact ⟨result,runC_join P.F hr39 one,h40,axis40⟩

end Host.Load.Run.Full.Ordinary.Prefix
