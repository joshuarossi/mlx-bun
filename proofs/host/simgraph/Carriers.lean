namespace Host.Mlx.SimGraph.Iter

/-- The template start's cache input nodes (64 pairs) and its two token nodes. -/
structure TplInputs where
  caches : List (Option Nat × Option Nat)
  read : Nat
  fed : Nat

end Host.Mlx.SimGraph.Iter
