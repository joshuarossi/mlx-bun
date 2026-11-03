import host.sim.compose.a4b.fd.Nps
import host.sim.compose.a4b.fd.Frames
import host.sim.template.a4pre_fd_vw_r0.Bridge
import host.sim.template.a4pre_fd_vw_r0.K0
import host.sim.template.a4pre_fd_vw_r0.K1
import host.sim.template.a4pre_fd_vw_r0.K2
import host.sim.template.a4pre_fd_vw_r0.K3
import host.sim.template.a4pre_fd_vw_r0.K4
import host.sim.template.a4pre_fd_vw_r0.K5
import host.sim.dispatch.BridgeSlice

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Route Host.Ts.Sim.Template Host.Load.Run.Tpl

abbrev lastRows (π : List Nat) : List Nat := π.drop (π.length - 1)

theorem lastRows_length {π : List Nat} (h : 1 ≤ π.length) : (lastRows π).length = 1 := by
  simp only [lastRows, List.length_drop]
  omega

kernel_rfl sliceCtl : PRE_fd_vw_r0.s4.ctl = .call (.obj 59) (.obj 2665) [.num (.ref 14), .num (.ref 8226)]
kernel_rfl sliceFn : PRE_fd_vw_r0.s4.obj? 59 = some (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 59)
kernel_rfl sliceKind : (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 59).kind = .fn (.native (.arr .slice) [])
kernel_rfl sliceObj : PRE_fd_vw_r0.s4.obj? 2665 = some (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 2665)
kernel_rfl sliceEmpty : (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s4 2665).kind = .array []
kernel_rfl sliceStart : nth? PRE_fd_vw_r0.S4.tab 14 = some (.var 10)
kernel_rfl sliceEnd : nth? PRE_fd_vw_r0.S4.tab 8226 = some (.var 9)

theorem slice {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (h : RelB FF FR wideGPf [] M ν K PRE_fd_vw_r0.s4 ⟨PRE_fd_vw_r0.S4.tab, []⟩ t C)
    (hfr : K.fr 2665 = some ([], π.map natV)) (h1 : 1 ≤ π.length)
    (h53 : π.length < 2 ^ 53) (hv9 : ν 9 = F64.ofNat π.length) (hv10 : ν 10 = F64.ofNat (π.length - 1)) :
    let ys := (lastRows π).map natV
    let t' := (newArray t ys).2.ret (.obj (newArray t ys).1)
    runC FF 1 t C = some (t', C) ∧
      RelB FF FR wideGPf [] M ν (Disp.Ctx.frameAt K FDFrames.chunk ([], ys))
        PRE_fd_vw_r0.s5 ⟨PRE_fd_vw_r0.S5.tab, []⟩ t' C := by
  have hxo : C.val (M.nv (.ref 14)) = some (F64.ofNat (π.length - 1)) := by
    simpa only [Map.nv, SymE.eval, hv10] using h.srv.num 14 (.var 10) sliceStart
  have hxe : C.val (M.nv (.ref 8226)) = some (F64.ofNat π.length) := by
    simpa only [Map.nv, SymE.eval, hv9] using h.srv.num 8226 (.var 9) sliceEnd
  have hs : Disp.sliceL (π.map natV ++ M.vals []) (F64.ofNat (π.length - 1)) (F64.ofNat π.length) = (lastRows π).map natV := by
    rw [Map.vals, List.map_nil, List.append_nil, Disp.sliceL_ofNat (by omega) (Nat.le_refl _) h53]
    have hl : π.length - (π.length - 1) = 1 := by omega
    rw [hl]
    congr 1
    exact List.take_of_length_le (by simp only [List.length_drop]; omega)
  obtain ⟨ht, hr⟩ := Disp.bridge_slice (pre := []) (pre' := π.map natV) (xs := [])
    (vo := .ref 14) (ve := .ref 8226) h sliceCtl sliceFn sliceKind hfr sliceObj sliceEmpty
    rfl rfl hxo hxe (Nat.blt_eq.mp PRE_fd_vw_r0.roomA2_check) PRE_fd_vw_r0.arrA2
    (by rw [PRE_fd_vw_r0.newA2]; rfl)
  rw [hs] at ht hr
  have hp := Option.some.inj PRE_fd_vw_r0.patchB2
  have hr' : RelB FF FR wideGPf [] M ν
      (Disp.Ctx.frameAt K PRE_fd_vw_r0.s4.next ([], (lastRows π).map natV))
      PRE_fd_vw_r0.s5 ⟨PRE_fd_vw_r0.S5.tab, []⟩
      ((newArray t ((lastRows π).map natV)).2.ret (.obj (newArray t ((lastRows π).map natV)).1)) C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF FR wideGPf [] M ν
      (Disp.Ctx.frameAt K PRE_fd_vw_r0.s4.next ([], (lastRows π).map natV)) p.1
      ⟨p.2.tab, []⟩ ((newArray t ((lastRows π).map natV)).2.ret
        (.obj (newArray t ((lastRows π).map natV)).1)) C) hp).mp hr
  have hnext : PRE_fd_vw_r0.s4.next = FDFrames.chunk := PRE_fd_vw_r0.newA2
  intro ys t'
  refine ⟨runC_one (by rw [h.isHalt, sliceCtl]; rfl) ht, ?_⟩
  exact (congrArg (fun a => RelB FF FR wideGPf [] M ν
    (Disp.Ctx.frameAt K a ([], (lastRows π).map natV)) PRE_fd_vw_r0.s5
    ⟨PRE_fd_vw_r0.S5.tab, []⟩ ((newArray t ((lastRows π).map natV)).2.ret
      (.obj (newArray t ((lastRows π).map natV)).1)) C) hnext).mp hr'

end Host.Ts.Sim.Compose.FDVW
