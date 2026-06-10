// Safetensors reader: mmap the file (via libc — see mmap.ts for why not
// Bun.mmap), parse the JSON header, expose tensors as raw pointers into
// the mapping. No tensor bytes are ever copied; pages materialize only
// when something (the GPU) touches them.
//
// Format: [u64 LE header_len][header_len bytes of JSON][data...]
// Header: { "<name>": { dtype, shape, data_offsets: [begin, end] }, ... }
// with optional "__metadata__"; offsets are relative to the data section.

import { MmapFile } from "./mmap";

export type SafetensorsDtype =
  | "BOOL" | "U8" | "I8" | "U16" | "I16" | "U32" | "I32" | "U64" | "I64"
  | "F16" | "BF16" | "F32" | "F64";

export const DTYPE_SIZE: Record<SafetensorsDtype, number> = {
  BOOL: 1, U8: 1, I8: 1, U16: 2, I16: 2, U32: 4, I32: 4, U64: 8, I64: 8,
  F16: 2, BF16: 2, F32: 4, F64: 8,
};

export interface TensorInfo {
  name: string;
  dtype: SafetensorsDtype;
  shape: number[];
  /** Byte range relative to the start of the data section. */
  begin: number;
  end: number;
}

export class SafetensorsFile {
  readonly path: string;
  readonly metadata: Record<string, string>;
  readonly tensors: Map<string, TensorInfo>;
  readonly mmap: MmapFile;
  readonly #dataStart: number;

  private constructor(
    path: string,
    mmap: MmapFile,
    tensors: Map<string, TensorInfo>,
    metadata: Record<string, string>,
    dataStart: number,
  ) {
    this.path = path;
    this.mmap = mmap;
    this.tensors = tensors;
    this.metadata = metadata;
    this.#dataStart = dataStart;
  }

  static open(path: string): SafetensorsFile {
    const mmap = MmapFile.open(path);
    if (mmap.size < 8) throw new Error(`${path}: too small for safetensors`);

    const lenBytes = mmap.view(0, 8);
    const headerLen = Number(
      new DataView(lenBytes.buffer, lenBytes.byteOffset, 8).getBigUint64(0, true),
    );
    const dataStart = 8 + headerLen;
    if (dataStart > mmap.size)
      throw new Error(`${path}: header length ${headerLen} exceeds file size`);

    const headerJson = new TextDecoder().decode(mmap.view(8, headerLen));
    const header = JSON.parse(headerJson) as Record<
      string,
      { dtype: SafetensorsDtype; shape: number[]; data_offsets: [number, number] }
    >;

    const tensors = new Map<string, TensorInfo>();
    let metadata: Record<string, string> = {};
    for (const [name, entry] of Object.entries(header)) {
      if (name === "__metadata__") {
        metadata = entry as unknown as Record<string, string>;
        continue;
      }
      const { dtype, shape, data_offsets: [begin, end] } = entry;
      if (!(dtype in DTYPE_SIZE))
        throw new Error(`${path}: tensor ${name} has unsupported dtype ${dtype}`);
      const expected = shape.reduce((a, b) => a * b, 1) * DTYPE_SIZE[dtype];
      if (end - begin !== expected)
        throw new Error(
          `${path}: tensor ${name} byte range ${end - begin} != shape ${JSON.stringify(shape)} × ${dtype}`,
        );
      if (dataStart + end > mmap.size)
        throw new Error(`${path}: tensor ${name} extends past end of file`);
      tensors.set(name, { name, dtype, shape, begin, end });
    }
    return new SafetensorsFile(path, mmap, tensors, metadata, dataStart);
  }

  #info(name: string): TensorInfo {
    const t = this.tensors.get(name);
    if (!t) throw new Error(`${this.path}: no tensor named ${name}`);
    return t;
  }

  /** Raw pointer to the tensor's first byte (for zero-copy FFI handoff). */
  pointer(name: string): number {
    return this.mmap.pointer(this.#dataStart + this.#info(name).begin);
  }

  /** JS view of a tensor's bytes (small tensors / tests only). */
  view(name: string): Uint8Array {
    const t = this.#info(name);
    return this.mmap.view(this.#dataStart + t.begin, t.end - t.begin);
  }
}

/** A sharded model directory: index json + N safetensors files. */
export class ShardedSafetensors {
  readonly files = new Map<string, SafetensorsFile>();
  readonly tensorToFile = new Map<string, SafetensorsFile>();

  static async open(modelDir: string): Promise<ShardedSafetensors> {
    const self = new ShardedSafetensors();
    const indexPath = `${modelDir}/model.safetensors.index.json`;
    if (await Bun.file(indexPath).exists()) {
      const index = (await Bun.file(indexPath).json()) as {
        weight_map: Record<string, string>;
      };
      for (const [tensor, file] of Object.entries(index.weight_map)) {
        let sf = self.files.get(file);
        if (!sf) {
          sf = SafetensorsFile.open(`${modelDir}/${file}`);
          self.files.set(file, sf);
        }
        self.tensorToFile.set(tensor, sf);
      }
    } else {
      const sf = SafetensorsFile.open(`${modelDir}/model.safetensors`);
      self.files.set("model.safetensors", sf);
      for (const name of sf.tensors.keys()) self.tensorToFile.set(name, sf);
    }
    return self;
  }

  get tensorNames(): string[] {
    return [...this.tensorToFile.keys()].sort();
  }

  #file(name: string): SafetensorsFile {
    const sf = this.tensorToFile.get(name);
    if (!sf) throw new Error(`no tensor named ${name}`);
    return sf;
  }

  info(name: string): TensorInfo {
    return this.#file(name).tensors.get(name)!;
  }

  pointer(name: string): number {
    return this.#file(name).pointer(name);
  }

  view(name: string): Uint8Array {
    return this.#file(name).view(name);
  }
}
