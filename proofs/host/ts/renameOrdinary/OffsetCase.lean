import host.ts.RenameKernelRfl
import host.ts.renameOrdinary.HostCuts
import host.ts.RenameOffsetBlock
import host.ts.RenameRouteDriver
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def offsetInput : St P.F.S := P.RestStream.micro0.micro66.s89
noncomputable def offsetOutput : St P.F.S := P.RestStream.micro0.micro66.s91
end Host.Load.Run.Full.Ordinary
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro66 89 2672303 as Ordinary.offsetObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
theorem offset_control : offsetInput.ctl = .ret (natV 1) := by host_kernel_rfl
theorem offset_frame : offsetInput.stack =
    .a (.put (some .add) (.prop (.obj 2672303) (.str chars!"offset")) (natV 3)) :: offsetInput.stack.tail := by host_kernel_rfl
theorem offset_heap : offsetInput.heap.get 2672303 = some (.obj offsetObject) := by host_kernel_rfl
theorem offset_kind : offsetObject.kind = .ordinary := by host_kernel_rfl
theorem offset_property : findProp (.str chars!"offset") offsetObject.props = some (.data (natV 3) true true) := by host_kernel_rfl
theorem offset_source_post :
    ({offsetInput with stack := offsetInput.stack.tail}.setObj 2672303
      {offsetObject with props := setPropL (.str chars!"offset") (.data (natV 4) true true) offsetObject.props}).ret (natV 4) = offsetOutput := by host_kernel_rfl
theorem offset_source_run (C : CSrv) : runC P.F 2 offsetInput C = some (offsetOutput,C) := by host_kernel_rfl

/-- The actual first ordinary cache write transports to a different literal
offset. Source control, object kind, writable descriptor and exact endpoint
are checked above; no target interpreter run is a premise. -/
theorem offset_source_transport (FR : Ren → P.F.S → P.F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' offsetInput s)
    (n : Nat) (meaning : SymE) (fs : List Frame)
    (ha : live 2672303) (hn : n+1 < 2^53)
    (number : NumRole ν₀ ν C₀ C meaning (.lit (F64.ofNat 3)) (.lit (F64.ofNat n)))
    (hc : s.ctl = .ret (natV 1))
    (hf : s.stack = .a (.put (some .add) (.prop (.obj (R.a 2672303))
      (.str chars!"offset")) (natV n))::fs)
    (ht : R.a 2672303 < 2^64) :
    ∃ (o : Obj), let t := ({s with stack := fs}.setObj (R.a 2672303)
      {o with props := setPropL (.str chars!"offset") (.data (natV (n+1)) true true) o.props}).ret (natV (n+1))
      runC P.F 2 s C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' offsetOutput t ∧
      NumRole ν₀ ν C₀ C (.bin .add meaning (.lit (F64.ofNat 1)))
        (.lit (F64.ofNat 4)) (.lit (F64.ofNat (n+1))) := by
  obtain ⟨o,_,hr,hpost,hnumber⟩ := offset_block P.F FR R ν₀ ν C₀ C live framed
    before after old old' offsetInput s h 2672303 3 n meaning offsetObject true offsetInput.stack.tail fs
    ha (by decide) hn number offset_control hc offset_frame hf offset_heap offset_kind offset_property (by decide) ht
  refine ⟨o,hr,?_,hnumber⟩
  exact offset_source_post ▸ hpost
end Host.Load.Run.Full.Ordinary
