import host.sim.compose.a4b.SetupD1Dispatch
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodySource
open Host.Ts Host.Ts.Sim.Template

noncomputable def codeAt (a : Nat) : Option Func :=
  match (objOf D1Call.s1 a).kind with
  | .fn (.closure f _ _ _) => some f
  | _ => none

noncomputable def envAt (a : Nat) : Env :=
  match (objOf D1Call.s1 a).kind with
  | .fn (.closure _ e _ _) => e
  | _ => []

def address : Option Val → Nat
  | some (.obj a) => a
  | _ => 0

noncomputable def captured (n : Name) : Option Val :=
  (lookupEnv n (envAt 2671709)).bind fun a => (D1Call.s1.cell? a).join

noncomputable def receiver : Nat := address (captured nThis)

noncomputable def privateAddr (n : Name) : Nat :=
  address (D1Endpoint.privateVal (objOf D1Call.s1 receiver) n)

-- The function reached by the original caller is the constructor's D1 arrow.
kernel_rfl originalCode : codeAt 2671709 =
  some Host.Ts.Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast_n156

kernel_rfl capturedLayers : captured (chars!"one") = some (.obj 388693)
kernel_rfl capturedReceiver : receiver = 80731
kernel_rfl submittedAddress : privateAddr (chars!"submitted") = 7948
kernel_rfl runAddress : privateAddr (chars!"run") = 7955
kernel_rfl submittedCode : codeAt 7948 =
  some Host.Ts.Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast_n291
kernel_rfl runCode : codeAt 7955 =
  some Host.Ts.Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast_n372
kernel_rfl layerCount : (arrOf D1Call.s1 388693).length = 64

def num (i : Nat) : Expr := .lit (.num (toString i).toList)
def indexed (n : Name) (i : Nat) : Expr := .index (.id n) (num i) false

def layerStmt (i : Nat) : Stmt :=
  .expr (.call (.member (.id (chars!"scope")) (chars!"accept") false)
    [.expr (num i), .expr (.call (.member (indexed (chars!"layers") i) (chars!"forward") false)
      ([.expr (.member (.id (chars!"scope")) (chars!"hidden") false),
        .expr (indexed (chars!"state") i), .expr (.id (chars!"phase"))] ++
        if i % 4 == 3 then [.expr (.id (chars!"positions"))] else []) false)] false)

def finishStmt : Stmt :=
  .ret (some (.call (.member (.id (chars!"scope")) (chars!"finish") false)
    [.expr (num 64), .expr (.call (.member (.member .this (chars!"finalNorm") false)
      (chars!"forward") false) [.expr (.member (.id (chars!"scope")) (chars!"hidden") false)] false)] false))

noncomputable def runBody : List Stmt :=
  match codeAt 7955 with
  | some (.mk _ _ _ (.block ss) _ _ _) => ss
  | _ => []

-- Exact source syntax: every layer index 0..63 occurs in order, followed by final norm.
kernel_rfl full64Source : runBody = (List.range 64).map layerStmt ++ [finishStmt]

end Host.Load.Run.Tpl.D1BodySource

-- rechecked: literal chunk length
