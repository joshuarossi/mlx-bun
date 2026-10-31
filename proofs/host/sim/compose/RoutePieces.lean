import host.sim.compose.Shape
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

structure RGluePiece (F : Ffi) (Adm : Cls.Inst → Prop) (uses : List Row)
    (A B : Cls.Inst → ICut F) where
  m : List (Nat × Q)
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : RPieceOk F Adm uses [⟨m, O⟩] (fun X Y => CutStep X Y n) A B

structure RStagePiece (F : Ffi) (Adm : Cls.Inst → Prop) (uses : List Row) (obls : List Obl)
    (A B : Cls.Inst → ICut F) where
  m : List (Nat × Q)
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : RPieceOk F Adm uses (⟨m, O⟩ :: obls) (fun X Y => StageCall X Y n) A B

structure RFwdPiece (F : Ffi) (Adm : Cls.Inst → Prop) (uses : List Row) (obls : List Obl)
    (A B : Cls.Inst → ICut F) where
  m : List (Nat × Q)
  np : Nat
  nb : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : RPieceOk F Adm uses (⟨m, O⟩ :: obls) (fun X Y => FwdCall X Y np nb) A B

end Host.Ts.Sim.Compose
