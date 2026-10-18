import host.ts.RenameRuntimeArguments
import host.ts.RenameRuntimeBinding
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def parameterFrameNote (fn : Func) (params : List Pat) (roles : List Value) (env : Env) : Tree :=
  .node "Frame.k" [.node "FnF.params" [.atom Func fn,.atom (List Pat) params,valuesNote roles,environmentNote env]]
def parameterDefaultFrameNote (fn : Func) (pattern : Pat) (params : List Pat) (roles : List Value) (env : Env) : Tree :=
  .node "Frame.k" [.node "FnF.paramDflt" [.atom Func fn,.atom Pat pattern,.atom (List Pat) params,valuesNote roles,environmentNote env]]
def callBoundaryNote : Tree := .node "Frame.k" [.node "FnF.fn" [.node "Boundary.call" []]]

theorem parameterFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} (fn : Func) (params : List Pat)
    (roles : List Value) (env : Env) (args : List Val)
    (h : ListR (fun role value => role.Holds ν C R value) roles args) :
    (parameterFrameNote fn params roles env).Holds ν C R
      (Encode.frame (.k (.params fn params args (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.atom Func fn) (.cons (.atom (List Pat) params)
    (.cons (valuesNote_holds h) (.cons (environmentNote_holds ν C R env) .nil))))) .nil)
theorem parameterFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} (fn : Func) (params : List Pat)
    (roles : List Value) (env : Env) (args : List Val)
    (h : (parameterFrameNote fn params roles env).Holds ν C R
      (Encode.frame (.k (.params fn params args (R.env env))))) :
    ListR (fun role value => role.Holds ν C R value) roles args := by
  cases h with | node _ outer => cases outer with | cons inner _ =>
    cases inner with | node _ fields => cases fields with | cons _ fields =>
      cases fields with | cons _ fields => cases fields with | cons values _ => exact valuesNote_view values
theorem parameterDefaultFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} (fn : Func) (pattern : Pat)
    (params : List Pat) (roles : List Value) (env : Env) (args : List Val)
    (h : ListR (fun role value => role.Holds ν C R value) roles args) :
    (parameterDefaultFrameNote fn pattern params roles env).Holds ν C R
      (Encode.frame (.k (.paramDflt fn pattern params args (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.atom Func fn) (.cons (.atom Pat pattern) (.cons (.atom (List Pat) params)
    (.cons (valuesNote_holds h) (.cons (environmentNote_holds ν C R env) .nil)))))) .nil)
theorem parameterDefaultFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} (fn : Func) (pattern : Pat)
    (params : List Pat) (roles : List Value) (env : Env) (args : List Val)
    (h : (parameterDefaultFrameNote fn pattern params roles env).Holds ν C R
      (Encode.frame (.k (.paramDflt fn pattern params args (R.env env))))) :
    ListR (fun role value => role.Holds ν C R value) roles args := by
  cases h with | node _ outer => cases outer with | cons inner _ =>
    cases inner with | node _ fields => cases fields with | cons _ fields =>
      cases fields with | cons _ fields => cases fields with | cons _ fields =>
        cases fields with | cons values _ => exact valuesNote_view values
theorem callBoundaryNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) :
    callBoundaryNote.Holds ν C R (Encode.frame (.k (.fn .call))) :=
  .node _ (.cons (.node _ (.cons (.node _ .nil) .nil)) .nil)

end Host.Ts.Owned.Annotated
