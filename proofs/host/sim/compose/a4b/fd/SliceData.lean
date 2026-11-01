import host.sim.compose.a4b.fd.Nps
import host.sim.compose.a4b.fd.Frames
import host.sim.template.a4pre_fd_vw_r0.Bridge
import host.sim.template.a4pre_fd_vw_r0.K5
import host.sim.dispatch.BridgeSlice

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Route Host.Ts.Sim.Template Host.Load.Run.Tpl

kernel_rfl sliceCtl : PRE_fd_vw_r0.s4.ctl = .call (.obj 59) (.obj 2665) [natV 0, .num (.ref 14)]
kernel_rfl sliceFn : PRE_fd_vw_r0.s4.obj? 59 = some (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 59)
kernel_rfl sliceKind : (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 59).kind = .fn (.native (.arr .slice) [])
kernel_rfl sliceObj : PRE_fd_vw_r0.s4.obj? 2665 = some (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 2665)
kernel_rfl sliceEmpty : (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 2665).kind = .array []
kernel_rfl sliceEnd : nth? PRE_fd_vw_r0.S4.tab 14 = some (.var 12)

theorem slice {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat} {n : Nat}
    (h : RelB FF FR wideP [] M ν K PRE_fd_vw_r0.s4 ⟨PRE_fd_vw_r0.S4.tab, []⟩ t C)
    (hfr : K.fr 2665 = some ([], π.map natV)) (hn : n ≤ π.length)
    (h53 : π.length < 2 ^ 53) (hv : ν 12 = F64.ofNat n) :
    let ys := (lastRows π).map natV
    let t' := (newArray t ys).2.ret (.obj (newArray t ys).1)
    runC FF 1 t C = some (t', C) ∧
      RelB FF FR wideP [] M ν (Disp.Ctx.frameAt K FDFrames.chunk ([], ys))
        PRE_fd_vw_r0.s5 ⟨PRE_fd_vw_r0.S5.tab, []⟩ t' C := by
  have hxe : C.val (M.nv (.ref 14)) = some (F64.ofNat n) := by
    simpa only [Map.nv, SymE.eval, hv] using h.srv.num 14 (.var 12) sliceEnd
  have hs : Disp.sliceL (π.map natV ++ M.vals []) (F64.ofNat 0) (F64.ofNat n) = (lastRows π).map natV := by
    rw [Map.vals, List.map_nil, List.append_nil]
    simpa only [List.drop_zero, Nat.sub_zero] using Disp.sliceL_ofNat (o := 0) (by omega) hn h53
  obtain ⟨ht, hr⟩ := Disp.bridge_slice (pre := []) (pre' := π.map natV) (xs := [])
    (vo := .lit (F64.ofNat 0)) (ve := .ref 14) h sliceCtl sliceFn sliceKind hfr sliceObj sliceEmpty
    rfl rfl rfl hxe (Nat.blt_eq.mp PRE_fd_vw_r0.roomA7_check) PRE_fd_vw_r0.arrA2
    (by rw [PRE_fd_vw_r0.newA2]; rfl)
  rw [hs] at ht hr
  have hp := Option.some.inj PRE_fd_vw_r0.patchB2
  have hr' : RelB FF FR wideP [] M ν
      (Disp.Ctx.frameAt K PRE_fd_vw_r0.s4.next ([], (lastRows π).map natV))
      PRE_fd_vw_r0.s5 ⟨PRE_fd_vw_r0.S5.tab, []⟩
      ((newArray t ((lastRows π).map natV)).2.ret (.obj (newArray t ((lastRows π).map natV)).1)) C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF FR wideP [] M ν
      (Disp.Ctx.frameAt K PRE_fd_vw_r0.s4.next ([], (lastRows π).map natV)) p.1
      ⟨p.2.tab, []⟩ ((newArray t ((lastRows π).map natV)).2.ret
        (.obj (newArray t ((lastRows π).map natV)).1)) C) hp).mp hr
  have hnext : PRE_fd_vw_r0.s4.next = FDFrames.chunk := PRE_fd_vw_r0.newA2
  refine ⟨runC_one (by rw [h.isHalt, sliceCtl]; rfl) ht, ?_⟩
  exact (congrArg (fun a => RelB FF FR wideP [] M ν
    (Disp.Ctx.frameAt K a ([], (lastRows π).map natV)) PRE_fd_vw_r0.s5
    ⟨PRE_fd_vw_r0.S5.tab, []⟩ ((newArray t ((lastRows π).map natV)).2.ret
      (.obj (newArray t ((lastRows π).map natV)).1)) C) hnext).mp hr'

end Host.Ts.Sim.Compose.FDVW
