import host.sim.dispatch.BridgeTyped
import host.sim.template.FullOk
import host.sim.template.EndGen
import host.sim.template.SetupP
import host.sim.template.Ghosts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX0Frames
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route Host.Load.Run.Tpl

def chunk : Nat := 2826777
def buffer : Nat := 2826782
def view : Nat := 2826783

/-- The pre-final cut's frames: the prompt, the memo and the ghosts. -/
abbrev startJ : Disp.JSP FF := fullJSPPXS setupP (2665 :: 4910 :: ghostPf) wideListPf

abbrev chunkJ : Disp.JSP FF := fullJSPPXS setupP (2665 :: 4910 :: (ghostPf ++ [chunk])) wideListPf

def typedW (bytes : List Byte) (n : Nat) : Nat → Option WFrame :=
  Disp.wAt (Disp.wAt wideGPf buffer (.buf bytes)) view (.typed .i32 buffer 0 n)

abbrev typedJ (bytes : List Byte) (n : Nat) : Disp.JSP FF :=
  fullJSPPXS setupP (2665 :: 4910 :: (ghostPf ++ [chunk, buffer, view]))
    ((buffer, .buf bytes) :: (view, .typed .i32 buffer 0 n) :: wideListPf)

noncomputable def typedOk (bytes : List Byte) (n : Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (typedJ bytes n) (okBackFXS setupP) 131072

end Host.Ts.Sim.Compose.FDX0Frames
