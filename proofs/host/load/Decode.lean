import host.load.Route
namespace Host.Load.Decode
open Host.Ts

/-- External inputs of the continuous real loader and generation harness: the
first number is the token budget; remaining numbers are uint32 token readbacks. -/
def tab : List SymE := (List.range 9).map SymE.var

def reads : List NumV := (List.range 8).map fun i => .ref (i + 1)

/-- The original load environment with explicit symbolic native readbacks.
The generation driver consumes the caches returned by the actual binding. -/
def world : LSt :=
  { Route.world with mlx := { Route.world.mlx with tokens := reads } }

/-- A discovery valuation; it chooses branch answers only. Every resulting chunk
is checked against the symbolic server by the kernel. -/
def valuation (i : Nat) : F64 :=
  F64.ofNat ([5, 100, 101, 102, 103, 104, 105, 106, 107].getD i 0)

/-- The driver's exported load marker, using the entry environment retained at
boot. The first true state is the explicit load/decode boundary. -/
def loadDone (env : Env) (s : St LSt) : Bool :=
  match bindingOf s env chars!"loadDone" with
  | some (.bool b) => b
  | _ => false

def yielded (env : Env) (s : St LSt) : Option NumV :=
  match bindingOf s env chars!"yieldCount" with
  | some (.num n) => some n
  | _ => none

end Host.Load.Decode
