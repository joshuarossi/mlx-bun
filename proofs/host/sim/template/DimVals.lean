namespace Host.Load.Run.Tpl

/-! # The values of the abstracted dims

The D1 traces and the convolution caches hold, in the classes whose rows are symbolic, numbers the row counts cancel out of. The shared
templates hold them as variables, whose values are these. -/

/-- From POST's shared cut: the convolution caches' lengths `v201`–`v248`, the D1 traces' dims `v249`–`v256`. -/
def tailVal : Nat → Option Nat := fun v =>
  bif Nat.ble 201 v && Nat.ble v 248 then some 3
  else bif Nat.ble 249 v && Nat.ble v 255 then some 1
  else bif Nat.beq v 256 then some 1536
  else none

/-- In the decode template: the convolution caches' lengths `v114`–`v161`, the D1 traces' dims `v102`–`v109`. -/
def decVal : Nat → Option Nat := fun v =>
  bif Nat.ble 114 v && Nat.ble v 161 then some 3
  else bif Nat.ble 102 v && Nat.ble v 108 then some 1
  else bif Nat.beq v 109 then some 1536
  else none

end Host.Load.Run.Tpl
