import host.mlx.FfiEval

namespace Host.Mlx.FfiEval
open Host.Ts

/-- Resolving a symbolic byte is exactly the existing concrete byte encoder
applied to the materialized cell, with the same kind and byte position. -/
theorem concreteByte_part (ν : NumV → Option F64) (k : EltK) (c d : Cell) (i : Nat)
    (h : concreteCell ν c = some d) :
    concreteByte ν (.part k c i) = concByte (.part k d i) := by
  simp [concreteByte, h, concByte]

/-- Uint32 token feedback uses the four bytes of the resolved numeric value,
including when the original cell held a reference returned by the FFI. -/
theorem concreteByte_u32 (ν : NumV → Option F64) (a : NumV) (f : F64) (h : ν a = some f) :
    (cellParts .u32 (.num a) 4 0).mapM (concreteByte ν) = some (leBytes 4 (F64.toUint32 f)) := by
  simp [cellParts, concreteByte, concreteCell, h, encodeCell, leBytes, nth?, List.mapM, List.mapM.loop]

namespace ByteChecks

private def values : NumV → Option F64
  | .lit x => some x
  | .ref 3 => some (F64.ofNat 9707)
  | _ => none

theorem resolves_reference_bytes :
    (cellParts .u32 (.num (.ref 3)) 4 0).mapM (concreteByte values) = some [235, 37, 0, 0] := by decide +kernel

theorem preserves_literal_bytes :
    [Byte.lit 235, .lit 37, .lit 0, .lit 0].mapM (concreteByte values) = some [235, 37, 0, 0] := rfl

theorem resolves_signed_element :
    (cellParts .i32 (.num (.lit (F64.ofInt (-1)))) 4 0).mapM (concreteByte values) =
      some [255, 255, 255, 255] := by decide +kernel

theorem rejects_missing_reference :
    concreteByte values (.part .u32 (.num (.ref 4)) 0) = none := rfl

theorem rejects_invalid_byte_offset :
    concreteByte values (.part .u32 (.num (.ref 3)) 4) = none := by decide +kernel

end ByteChecks
end Host.Mlx.FfiEval
