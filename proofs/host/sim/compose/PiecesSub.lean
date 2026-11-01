import host.sim.compose.Pieces

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-! A piece over some rows is a piece over fewer: how the restricted bundle takes the pieces filled
over the rows of the whole table. -/

variable {F : Ffi} {uses uses' : List Row} {obls : List Obl} {A B : Cls.Inst → ICut F}

def GluePiece.restrict (p : GluePiece F uses A B) (h : ∀ r ∈ uses', r ∈ uses) : GluePiece F uses' A B :=
  ⟨p.m, p.n, p.O, fun r hr => p.chk r (h r hr), fun r hr => p.ok r (h r hr)⟩

def StagePiece.restrict (p : StagePiece F uses obls A B) (h : ∀ r ∈ uses', r ∈ uses) :
    StagePiece F uses' obls A B :=
  ⟨p.m, p.n, p.O, fun r hr => p.chk r (h r hr), fun r hr => p.ok r (h r hr)⟩

def FwdPiece.restrict (p : FwdPiece F uses obls A B) (h : ∀ r ∈ uses', r ∈ uses) :
    FwdPiece F uses' obls A B :=
  ⟨p.m, p.np, p.nb, p.O, fun r hr => p.chk r (h r hr), fun r hr => p.ok r (h r hr)⟩

end Host.Ts.Sim.Compose
