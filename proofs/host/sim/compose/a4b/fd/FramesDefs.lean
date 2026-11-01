import host.sim.dispatch.BridgeTyped
import host.sim.template.FullOk
import host.sim.template.EndGen
import host.sim.template.SetupP
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDFrames
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route

def chunk : Nat := 2825053
def buffer : Nat := 2825058
def view : Nat := 2825059

abbrev chunkJ : Disp.JSP FF := fullJSPPXS setupP [2665, chunk] [(4910, .memo [])]

def typedW (bytes : List Byte) (n : Nat) : Nat → Option WFrame :=
  Disp.wAt (Disp.wAt wideP buffer (.buf bytes)) view (.typed .i32 buffer 0 n)

abbrev typedJ (bytes : List Byte) (n : Nat) : Disp.JSP FF :=
  fullJSPPXS setupP [2665, chunk, buffer, view]
    [(buffer, .buf bytes), (view, .typed .i32 buffer 0 n), (4910, .memo [])]

noncomputable def typedOk (bytes : List Byte) (n : Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (typedJ bytes n) (okBackFXS setupP) 4096

def bodyD0 : Nat := 131072
noncomputable def bodyOk (bytes : List Byte) (n : Nat) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (typedJ bytes n) (okBackFXS setupP) bodyD0

end Host.Ts.Sim.Compose.FDFrames
