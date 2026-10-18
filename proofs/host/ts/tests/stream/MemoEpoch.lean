import host.ts.Memo
open Lean Host.Ts.Memo

unsafe def epochTest : IO Unit := do
  reset
  let x := [1,2,3,4,5,6,7,8,9,10]
  let key := (987654321, ptrAddrUnsafe x)
  let first := memoImpl key.1 x (fun _ => mkNatLit 17)
  unless first == mkNatLit 17 do throw (IO.userError "first expression")
  beginEpoch
  let second := memoImpl key.1 x (fun _ => mkNatLit 99)
  unless second == first do throw (IO.userError "previous hit not promoted")
  unless ((← memoRef.get).find? key).isSome do throw (IO.userError "current table lost promotion")
  beginEpoch
  unless ((← previousRef.get).find? key).isSome do throw (IO.userError "promoted expression did not survive")
  beginEpoch
  unless ((← previousRef.get).find? key).isNone do throw (IO.userError "stale expression retained")
  reset

#eval epochTest
