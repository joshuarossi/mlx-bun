import host.ts.RenameKernelRfl
set_option Elab.async false

example : (1 : Nat) + 2 = 3 := by host_kernel_rfl

/--
error: (kernel) declaration type mismatch, '_example' has type
  0 = 0
but it is expected to have type
  0 = 1
-/
#guard_msgs in
example : (0 : Nat) = 1 := by host_kernel_rfl
