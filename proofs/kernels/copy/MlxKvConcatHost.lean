import kernels.copy.KvRowDispatchGeometry
import kernels.copy.MlxKvConcatSource

namespace Inference.Kernels.Copy.MlxKvConcatHost
open Contracts.Mlx State KvRowDispatchGeometry
set_option maxRecDepth 10000

-- Reviewed concatenate_gpu/copy_gpu_inplace host arithmetic. Original native
-- array flags, offsets, BF16 dtype, ownership and compiler attachment remain
-- outside this translation. Concatenation here requires an existing cache.
def axes (length capacity : Nat) : List Axis :=
  [⟨1,4*length*256,4*(capacity+256)*256⟩,
   ⟨4,length*256,(capacity+256)*256⟩,
   ⟨length,256,256⟩,⟨256,1,1⟩]

theorem collapsed (length capacity : Nat) (nontrivial : 1<length)
    (shorter : length<capacity+256) (supported : length≤262144) :
    collapse (axes length capacity) (2^31-1)=
      [⟨4,length*256,(capacity+256)*256⟩,⟨length*256,1,1⟩] := by
  have first : contiguous ⟨1,4*length*256,4*(capacity+256)*256⟩
      ⟨4,length*256,(capacity+256)*256⟩ 4 (2^31-1) := by
    constructor
    · dsimp; ring
    constructor
    · dsimp; ring
    · decide
  have second (size : Nat) : ¬contiguous ⟨4,length*256,(capacity+256)*256⟩
      ⟨length,256,256⟩ size (2^31-1) := by
    intro equal
    have same := equal.2.1
    dsimp at same
    omega
  have third : contiguous ⟨length,256,256⟩ ⟨256,1,1⟩ (length*256) (2^31-1) := by
    exact ⟨rfl,rfl,by omega⟩
  have ne : length≠1 := by omega
  simp only [collapse,axes,markers,mark,Nat.one_mul,first,second,third,ne,
    show (4:Nat)≠1 by decide,show (256:Nat)≠1 by decide,ite_true,ite_false]
  simp [collect]

theorem old_selected (capacity : Nat) (positive : 0<capacity) (multiple : capacity%256=0)
    (supported : capacity≤262144) :
    collapse (axes capacity capacity) (2^31-1)=
      [⟨4,capacity*256,(capacity+256)*256⟩,⟨capacity*256,1,1⟩] ∧
    grid (collapse (axes capacity capacity) (2^31-1))=⟨capacity*256,4,1⟩ := by
  have nontrivial : 1<capacity := by omega
  have equal := collapsed capacity capacity nontrivial (by omega) supported
  refine ⟨equal,?_⟩
  rw [equal]
  simp [grid,Nat.mul_comm]
  exact Nat.div_self (by omega)

theorem new_selected (capacity : Nat) (positive : 0<capacity) :
    collapse (axes 256 capacity) (2^31-1)=
      [⟨4,65536,(capacity+256)*256⟩,⟨65536,1,1⟩] ∧
    grid (collapse (axes 256 capacity) (2^31-1))=⟨65536,4,1⟩ := by
  have equal := collapsed 256 capacity (by decide) (by omega) (by decide)
  refine ⟨equal,?_⟩
  rw [equal]
  simp [grid]

def sliceOffsets (capacity : Nat) : List Nat := [0,256*capacity]

theorem input_offsets (capacity : Nat) :
    sliceOffsets capacity=[0,256*capacity] := rfl

theorem block_selected (width : Nat) (wide : 256≤width) :
    blockDimensions ⟨width,4,1⟩=some ⟨256,4,1⟩ := by
  have h2 : 2≤width := by omega
  have h4 : 4≤width := by omega
  have h8 : 8≤width := by omega
  have h16 : 16≤width := by omega
  have h32 : 32≤width := by omega
  have h64 : 64≤width := by omega
  have h128 : 128≤width := by omega
  norm_num [blockDimensions,blockLoop,Powers.sum,Powers.dimensions,h2,h4,h8,h16,h32,h64,h128,wide]

def hostSource : String := r#"void concatenate_gpu(
    const std::vector<array>& inputs,
    array& out,
    int axis,
    const Stream& s) {
  std::vector<int> sizes;
  sizes.push_back(0);
  for (auto& p : inputs) {
    sizes.push_back(p.shape(axis));
  }
  std::partial_sum(sizes.cbegin(), sizes.cend(), sizes.begin());

  out.set_data(allocator::malloc(out.nbytes()));

  auto strides = out.strides();
  auto flags = out.flags();
  flags.row_contiguous = false;
  flags.col_contiguous = false;
  flags.contiguous = false;
  auto& d = metal::device(s.device);
  auto& compute_encoder = metal::get_command_encoder(s);
  auto concurrent_ctx = compute_encoder.start_concurrent();
  for (int i = 0; i < inputs.size(); i++) {
    array out_slice(inputs[i].shape(), out.dtype(), nullptr, {});
    size_t data_offset = strides[axis] * sizes[i];
    out_slice.copy_shared_buffer(
        out, strides, flags, out_slice.size(), data_offset);
    copy_gpu_inplace(inputs[i], out_slice, CopyType::GeneralGeneral, s);
  }
}"#

end Inference.Kernels.Copy.MlxKvConcatHost
