import host.ts.RenameIncrement
namespace Host.Ts

def branchCtl (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) : Ctl :=
  bif b then .ex yes env else match no with
    | some no => .ex no env
    | none => .ret .undef

theorem materializer_branchCtl (C : CSrv) (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) :
    (materializer C).ctl (branchCtl b yes no env) = branchCtl b yes no env := by
  cases b <;> cases no <;>
    simp only [branchCtl, Bool.cond_true, Bool.cond_false, NameMap.ctl, materializer_env]

/-- The actual source `if` frame takes the same arm after numeric materialization.
The boolean was established by the preceding comparison; this step asks no oracle. -/
theorem step_if_bool_materialize (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv) (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env)
    (fs : List Frame) (hc : s.ctl = .ret (.bool b))
    (hf : s.stack = .s (.if_ yes no env) :: fs) :
    let t := { s with ctl := branchCtl b yes no env, stack := fs }
    interpC (step F s).run C = some (t, C) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap C t, E) := by
  dsimp only
  have hcs : (materializeStateWith ffiMap C s).ctl = .ret (.bool b) := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
  have hfs : (materializeStateWith ffiMap C s).stack =
      .s (.if_ yes no env) :: fs.map (materializer C).frame := by
    change s.stack.map (materializer C).frame = _
    rw [hf]
    change Frame.s (.if_ yes no ((materializer C).env env)) :: _ = _
    rw [materializer_env]
  have ht := materializeStateWith_control ffiMap C s (branchCtl b yes no env) fs
  rw [materializer_branchCtl] at ht
  constructor
  · cases b <;> cases no <;>
      simp only [step, hc, stepRet, hf, retStep, retSt, truthy, M.bind, M.pure, M.run,
        Bool.cond_true, Bool.cond_false, interpC_pure, St.go, retS, St.ret, branchCtl]
  · rw [ht]
    cases b <;> cases no <;>
      simp only [step, hcs, stepRet, hfs, retStep, retSt, truthy, M.bind, M.pure, M.run,
        Bool.cond_true, Bool.cond_false, interpC_pure, St.go, retS, St.ret, branchCtl]

theorem if_bool_numericClosed (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C : CSrv) (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env)
    (fs : List Frame) (hf : s.stack = .s (.if_ yes no env) :: fs)
    (closed : NumericClosedWith ffiMap C s) :
    NumericClosedWith ffiMap C { s with ctl := branchCtl b yes no env, stack := fs } := by
  intro D hd
  have hs := closed D hd
  have htail : fs.map (materializer D).frame = fs.map (materializer C).frame := by
    have hh := congrArg (fun u : St F.S => u.stack) hs
    change s.stack.map (materializer D).frame = s.stack.map (materializer C).frame at hh
    rw [hf] at hh
    exact (List.cons.inj hh).2
  calc
    materializeStateWith ffiMap D { s with ctl := branchCtl b yes no env, stack := fs } =
        { materializeStateWith ffiMap D s with
          ctl := branchCtl b yes no env
          stack := fs.map (materializer D).frame } := by
      simpa only [materializer_branchCtl] using
        materializeStateWith_control ffiMap D s (branchCtl b yes no env) fs
    _ = { materializeStateWith ffiMap C s with
          ctl := branchCtl b yes no env
          stack := fs.map (materializer C).frame } := by rw [hs, htail]
    _ = materializeStateWith ffiMap C { s with ctl := branchCtl b yes no env, stack := fs } := by
      symm
      simpa only [materializer_branchCtl] using
        materializeStateWith_control ffiMap C s (branchCtl b yes no env) fs

end Host.Ts
