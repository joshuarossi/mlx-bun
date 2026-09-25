# @mlx-bun/mlx

Low-level Bun bindings for MLX on Apple Silicon Macs. This package owns native
library loading, arrays, tensor operations, graph compilation, and custom Metal
kernel execution. It uses the existing mlx-bun implementation and MLX 0.32.2.

See the runnable [array example](examples/arrays.ts):
`bun packages/mlx/examples/arrays.ts` prints `[2, 4, 6]`.

Arrays own native handles. Release them with `using` or `.dispose()`. Operations
are lazy; reading the result evaluates it. Zero-copy constructors have additional
buffer lifetime contracts documented on their methods.

## Source ownership

| File | Responsibility |
| --- | --- |
| `src/native.ts` | Native artifact locations and pinned MLX version |
| `src/ffi.ts` | C ABI declarations, errors, device and memory controls |
| `src/array.ts` | Array handles, metadata, host access, and ownership |
| `src/host-buffer.ts` | Aligned native host allocations |
| `src/ops.ts` | Tensor operations exposed by the existing bindings |
| `src/compile.ts` | Compile and replay a TypeScript graph builder |
| `src/metal-kernel.ts` | Compile and call custom Metal source through MLX |
| `src/autograd.ts` | Value-and-gradient and vector-Jacobian transforms |
| `src/custom-vjp.ts` | Custom gradient definitions |
| `src/checkpoint.ts` | Recomputation for automatic differentiation |
| `src/materialize.ts` | Independent tensor storage copies |
| `src/index.ts` | Convenient public imports |

Each source module except `native.ts` also has an explicit package subpath, such
as `@mlx-bun/mlx/ops` or `@mlx-bun/mlx/autograd`. `@mlx-bun/mlx/ffi` exposes raw
bindings for code that needs them. Model graphs, artifact loading, tokenizers, and generation belong to
[`@mlx-bun/inference`](../inference/README.md).

## Development

Use Bun 1.4.2 or newer on an Apple Silicon Mac running macOS 14 or newer. From
the repository root, run `bun install`. Then build the pinned native runtime
using the existing recipe (requires CMake and Xcode command-line tools):

```sh
bun run --cwd packages/mlx build:native /tmp/mlx-native-build
bun run --cwd packages/mlx stage:native /tmp/mlx-native-build/lib
bun run typecheck
bun run test
```

The build output directory must not already exist. If you already have the
matching native runtime, pass its directory directly to `stage:native`.

Native artifacts live in ignored `dist/native/` and ship inside the npm archive:
`libmlxc.dylib`, `libmlx.dylib`, `libjaccl.dylib`, and `mlx.metallib`.
Consumers do not download them on first use. For local native development,
`MLX_BUN_LIBMLXC` can point to a compatible `libmlxc.dylib` explicitly.

From this package directory, `bun pm pack --destination /tmp` validates the
native files and creates an archive. This package has not been published yet.

Standalone Bun executables resolve `MLX_BUN_LIBMLXC` first, then `libmlxc.dylib`
beside the executable, then this package's `dist/native`. Source/package execution
never searches beside the Bun executable. Keep the native companion libraries
and Metal library together; the app's bundle builder copies the staged files.
