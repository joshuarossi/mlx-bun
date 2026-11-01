import host.sim.full.RunFast
import host.sim.template.PostOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # POST's acceptance over the fast table

`PostOk.ok` over `FSrv`, for a row's chunks: `runOkS` at `okN` is `runOk` at `ok` (`runOkS_eq`, `okN_ok`). -/

namespace Host.Load.Run.Tpl.PostOk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route Host.Load.Layers

def refSmallF (c : FSrv) (j : Nat) : Bool :=
  match c.val (.ref j) with
  | some e => match ivlA loopVB (e.subst PostHeadSmall.singleton) with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

theorem refSmallF_eq {c : FSrv} (h : c.Wf) : refSmallF c = PostHeadSmall.refSmall c.toS := by
  funext j
  unfold refSmallF PostHeadSmall.refSmall
  rw [FSrv.val_eq h]
  rfl

noncomputable def smallFXF (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  ((smallRefs (toLoad x).mlx name args).all (refSmallF c) && (G.smallRefsX (toLoad x).mlx name args).all (refSmallF c)) &&
    (!isSymShape name || symRunF c x name args)

theorem smallFXF_eq {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFXF c x name args = PostHeadSmall.smallFX c.toS x name args := by
  unfold smallFXF PostHeadSmall.smallFX PostHeadSmall.smallX PostHeadSmall.smallLoad
  rw [refSmallF_eq h, symRunF_eq h]

noncomputable def smallFSF (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then symShapeSmallF loopVB c (mlxOf x) name args
  else smallFXF c x name args && cloSmallF loopVB c (mlxOf x) name args

theorem smallFSF_eq {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFSF c x name args = PostHeadSmall.smallFS c.toS x name args := by
  unfold smallFSF PostHeadSmall.smallFS
  rw [symShapeSmallF_eq loopVB h, smallFXF_eq h, cloSmallF_eq loopVB h]

noncomputable def smallFX2F (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif (bridgeOf x).active then smallFXF c x name args && (!isSymShape name || aneRunF c x name args) &&
    cloSmallF loopVB c (mlxOf x) name args
  else smallFSF c x name args

theorem smallFX2F_eq {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFX2F c x name args = PostHeadSmall.smallFX2 c.toS x name args := by
  unfold smallFX2F PostHeadSmall.smallFX2
  rw [smallFXF_eq h, aneRunF_eq h, cloSmallF_eq loopVB h, smallFSF_eq h]

noncomputable def okN : St FF.S → FSrv → Bool :=
  Disp.okJSJN J (okBackFXS setupP) 4096 smallFX2F

theorem okN_ok (s : St FF.S) (c : FSrv) (h : c.Wf) : okN s c = ok s c.toS :=
  Disp.okJSJN_eq J (okBackFXS setupP) 4096 (fun _ x name args hw => smallFX2F_eq hw x name args) s h

end Host.Load.Run.Tpl.PostOk
