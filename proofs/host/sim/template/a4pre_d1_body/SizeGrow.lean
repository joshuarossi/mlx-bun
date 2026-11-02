import host.sim.template.a4pre_d1_body.SizeLift
import host.sim.full.TargetGrowD
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodySize
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full

/-- B-size's unchanged native call carries any proved target preservation law. -/
theorem callSimQ (P : LoadP) (NB : Nat) {Q : FF.S → Prop}
    (hQ : TargetPres FF (FullRXD P NB) Q) {name : Name}
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FRQ (FullRXD P NB) Q) name A Pre := by
  intro M ν S C x y as hsrv hr hsupp hpre
  refine MSim.mono (MSim.both (callSim P NB hsym hm hp A M ν S C x y as hsrv hr.1 hsupp hpre)
    (fullLawful.call _ _ _) (fullLawful.call _ _ _)) ?_
  intro M' S' C' r r' hx
  obtain ⟨⟨hg, hs⟩, _, ht⟩ := hx
  refine ⟨hg, ?_⟩
  rcases r with _ | ⟨x', ret, ws⟩
  · trivial
  · rcases r' with _ | ⟨y', ret', ws'⟩
    · exact hs.elim
    · exact ⟨⟨hs.1, hQ.call M S.tab.length x y name (as.map M.arg) C y' ret' ws' C' hr.1 hr.2 ht⟩, hs.2⟩

/-- Growth of the actual target native state, including every successful cold size call. -/
theorem callGrow (P : LoadP) (NB : Nat) (y0 : Host.Mlx.Ffi.St) {name : Name}
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FRQ (FullRXD P NB) (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y))) name A Pre :=
  callSimQ P NB (fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0) hsym hm hp A

end Host.Load.Run.Tpl.D1BodySize

-- rechecked: literal chunk length
