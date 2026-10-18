import host.load.Decode
import host.load.Extract

namespace Host.Load.Stop
open Host.Ts

def oneTokenValuation (i : Nat) : F64 := if i = 0 then F64.ofNat 1 else Decode.valuation i

def eosValuation (i : Nat) : F64 := if i = 2 then F64.ofNat 248044 else Decode.valuation i

/-- A candidate numeric-role specialization, never an entry-reachability
theorem. The paired source invariant must supply the generated count. -/
def generatedAt (s : St LSt) (cell count : Nat) : St LSt :=
  s.setCell cell (.num (.lit (F64.ofNat count)))

def afterClear (s : St LSt) : Bool :=
  match s.ctl with
  | .ex (.if_ (.id name) _ _) _ => nameEq name chars!"jumpEmit"
  | _ => false

def atClearTest (s : St LSt) : Bool :=
  match s.ctl with
  | .ex (.if_ (.bin .seq (.bin .mod (.bin .sub (.id name) _) _) _) _ _) _ =>
    nameEq name chars!"generated"
  | _ => false

structure Summary where
  emitted : List SymE
  generated : SymE
  attentionOffset : SymE
  keyShape : List SymE
  recurrentOffset : SymE
  yielded : SymE
  completed : Bool

def summary (s : St LSt) (server : SSrv) (env : Env) : Option Summary := do
  let out ← bindingOf s env chars!"out"
  let emitted ← (elemOf s out 0).bind (symsOf s server)
  let generated ← (elemOf s out 1).bind (symOf server)
  let attentionOffset ← (elemOf s out 2).bind (symOf server)
  let keyShape ← (elemOf s out 3).bind (symsOf s server)
  let recurrentOffset ← (elemOf s out 4).bind (symOf server)
  let yielded ← (bindingOf s env chars!"yieldCount").bind (symOf server)
  let .bool completed ← bindingOf s env chars!"completed" | none
  pure ⟨emitted,generated,attentionOffset,keyShape,recurrentOffset,yielded,completed⟩

end Host.Load.Stop
