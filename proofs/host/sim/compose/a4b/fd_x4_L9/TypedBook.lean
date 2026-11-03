import host.sim.compose.a4b.fd_x4_L9.Cut
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FDX4L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route Host.Load.Run.Tpl

theorem ForwardBook.prompt {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {cap : Nat}
    (hb : ForwardBook i π K0 x cap) : x.K.fr 2665 = some ([], π.map natV) := by
  rw [hb.frames]
  change (g1Framed K0 π).fr 2665 = _
  exact hb.incomingPrompt

theorem ForwardBook.chunk {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {cap : Nat}
    (hb : ForwardBook i π K0 x cap) : x.K.fr FDX4L9Frames.chunk = some ([], (lastRows π).map natV) := by
  rw [hb.frames]
  rfl

theorem ForwardBook.buffer {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {cap : Nat}
    (hb : ForwardBook i π K0 x cap) : x.K.fr FDX4L9Frames.buffer = some ([], []) := by
  rw [hb.frames]
  rfl

theorem ForwardBook.view {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {cap : Nat}
    (hb : ForwardBook i π K0 x cap) : x.K.fr FDX4L9Frames.view = some ([], []) := by
  rw [hb.frames]
  rfl

end Host.Ts.Sim.Compose.FDX4L9
