import host.ts.RenameParametricCallback
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Structural object-literal scheduling. Computed/method/shorthand execution
has separate cases; this certificate covers the original static initializer,
spread-expression descent and final return. -/
inductive ObjectAction where
  | done
  | initial (key : Key) (name : Name) (value : Expr) (rest : List Property)
  | spread (value : Expr) (rest : List Property)
def ObjectAction.properties : ObjectAction → List Property
  | .done => []
  | .initial key _ value rest => .init key value::rest
  | .spread value rest => .spread value::rest
def ObjectAction.valid : ObjectAction → Prop
  | .initial key name _ _ => keyOf key = some (.str name)
  | _ => True
def ObjectAction.frames (owner : Nat) (env : Env) : ObjectAction → List Frame
  | .done => []
  | .initial _ name _ rest => [.l (.objVal owner (.str name) rest env)]
  | .spread _ rest => [.l (.objSpread owner rest env)]
def ObjectAction.control (owner : Nat) (env : Env) : ObjectAction → Ctl
  | .done => .ret (.obj owner)
  | .initial _ _ value _ | .spread value _ => .ev value env
def ObjectAction.advance {S : Type} (action : ObjectAction) (s : St S) (owner : Nat) (env : Env) : St S :=
  {s with stack := action.frames owner env ++ s.stack}.go (action.control owner env)

theorem objNext_action_eq (F : Ffi) (s : St F.S) (owner : Nat) (env : Env) (action : ObjectAction)
    (valid : action.valid) :
    objNext F s owner action.properties env = M.pure (action.advance s owner env) := by
  cases action with
  | done => rfl
  | initial key name value rest =>
    change keyOf key = some (.str name) at valid
    simp only [ObjectAction.properties,objNext,valid,ObjectAction.advance,ObjectAction.frames,ObjectAction.control,
      List.cons_append,List.nil_append,St.push,St.go]
  | spread value rest => rfl

theorem ObjectAction.frames_roles (action : ObjectAction) (NR : NumV → NumV → Prop) (R : Ren)
    (owner : Nat) (env : Env) :
    ListR (FrameR NR R) (action.frames owner env) (action.frames (R.a owner) (R.env env)) := by
  cases action <;> dsimp only [ObjectAction.frames,Encode.frame,Encode.litF,Encode.key,Encode.atom]
  all_goals repeat first | exact env_roles NR R env | constructor
theorem ObjectAction.frames_live (action : ObjectAction) (live : Nat → Prop) (owner : Nat) (env : Env)
    (ownerLive : live owner) (envLive : treeSupport live (Encode.env env)) :
    listSupport (fun frame => treeSupport live (Encode.frame frame)) (action.frames owner env) := by
  cases action <;> dsimp only [ObjectAction.frames,Encode.frame,Encode.litF,Encode.key,Encode.atom,
    listSupport,treeSupport,forestSupport]
  all_goals repeat first | exact ownerLive | exact envLive | constructor
theorem ObjectAction.control_roles (action : ObjectAction) (NR : NumV → NumV → Prop) (R : Ren)
    (owner : Nat) (env : Env) :
    ControlR NR R (action.control owner env) (action.control (R.a owner) (R.env env)) := by
  cases action <;> dsimp only [ObjectAction.control,Encode.ctl,Encode.val,Encode.atom]
  all_goals repeat first | exact env_roles NR R env | constructor
theorem ObjectAction.control_live (action : ObjectAction) (live : Nat → Prop) (owner : Nat) (env : Env)
    (ownerLive : live owner) (envLive : treeSupport live (Encode.env env)) :
    treeSupport live (Encode.ctl (action.control owner env)) := by
  cases action <;> dsimp only [ObjectAction.control,Encode.ctl,Encode.val,Encode.atom,treeSupport,forestSupport,valueSupport]
  all_goals repeat first | exact ownerLive | exact envLive | constructor

theorem ObjectAction.advance_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (action : ObjectAction) (h : StateR NR FR R live framed before after old old' s₀ s)
    (owner : Nat) (env : Env) (ownerLive : live owner) (envLive : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old' (action.advance s₀ owner env) (action.advance s (R.a owner) (R.env env)) :=
  (h.restack ((action.frames_roles NR R owner env).append h.stack)
    (listSupport_append (action.frames_live live owner env ownerLive envLive) h.stackLive)).go
      (action.control_roles NR R owner env) (action.control_live live owner env ownerLive envLive)

theorem step_object_action_eq (F : Ffi) (s : St F.S) (env : Env) (action : ObjectAction)
    (valid : action.valid) (control : s.ctl = .ev (.object action.properties) env) :
    step F s = M.pure (action.advance (s.alloc (.obj ⟨.ordinary,.obj aObjectProto,[],[],true⟩)).2 s.next env) := by
  simp only [step,control,evStep,St.allocObj,St.alloc]
  exact objNext_action_eq F _ s.next env action valid
end Host.Ts.Owned.Parametric
