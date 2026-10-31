import host.sim.compose.Shape

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-- A generated glue owns the variable map of its actual template. -/
structure GluePiece (F : Ffi) (uses : List Row) (A B : Cls.Inst → ICut F) where
  m : List (Nat × Q)
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : PieceOk F uses [⟨m, O⟩] (fun X Y => CutStep X Y n) A B

/-- A generated stage owns its site's oracle, even when it also uses standalone
stage oracles.  The latter remain separate obligations in their original variables. -/
structure StagePiece (F : Ffi) (uses : List Row) (obls : List Obl) (A B : Cls.Inst → ICut F) where
  m : List (Nat × Q)
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : PieceOk F uses (⟨m, O⟩ :: obls) (fun X Y => StageCall X Y n) A B

/-- A generated forward owns the variable map and oracle shared by all its rows. -/
structure FwdPiece (F : Ffi) (uses : List Row) (obls : List Obl) (A B : Cls.Inst → ICut F) where
  m : List (Nat × Q)
  np : Nat
  nb : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : PieceOk F uses (⟨m, O⟩ :: obls) (fun X Y => FwdCall X Y np nb) A B

def GlueP.piece {F : Ffi} {uses : List Row} {m : List (Nat × Q)} {A B : Cls.Inst → ICut F}
    (p : GlueP F uses m A B) : GluePiece F uses A B := ⟨m, p.n, p.O, p.chk, p.ok⟩

def StageP.piece {F : Ffi} {uses : List Row} {m : List (Nat × Q)} {A B : Cls.Inst → ICut F}
    (p : StageP F uses m A B) : StagePiece F uses [] A B := ⟨m, p.n, p.O, p.chk, p.ok⟩

def FwdP.piece {F : Ffi} {uses : List Row} {m : List (Nat × Q)} {obls : List Obl}
    {A B : Cls.Inst → ICut F} (p : FwdP F uses m obls A B) : FwdPiece F uses obls A B :=
  ⟨m, p.np, p.nb, p.O, p.chk, p.ok⟩

end Host.Ts.Sim.Compose
