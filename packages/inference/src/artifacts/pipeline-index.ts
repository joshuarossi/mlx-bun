// A diffusers pipeline snapshot: a root `model_index.json` naming the pipeline
// class and its components, each component in a subdirectory with its own
// config and weights. This reader spells the layout; which family runs a
// pipeline class is the family registry's decision.

/** The file that marks a pipeline snapshot. */
export const PIPELINE_INDEX_FILE = "model_index.json";

/** One component entry: the library and class the reference implementation loads. */
export interface PipelineComponent {
  readonly library: string;
  readonly className: string;
}

export interface PipelineIndex {
  readonly className: string;
  /** Component name (also its subdirectory) to its declared implementation. */
  readonly components: ReadonlyMap<string, PipelineComponent>;
}

/** Parse a `model_index.json` object. Underscore keys are metadata; a
 * `[library, class]` pair is a component; `[null, null]` declares an absent
 * optional component and is skipped. Throws for a missing class name or a
 * malformed entry. */
export function parsePipelineIndex(raw: unknown): PipelineIndex {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) throw new Error(`${PIPELINE_INDEX_FILE} must be a JSON object`);
  const record = raw as Record<string, unknown>;
  const className = record._class_name;
  if (typeof className !== "string" || !className) throw new Error(`${PIPELINE_INDEX_FILE} has no _class_name`);
  const components = new Map<string, PipelineComponent>();
  for (const [name, value] of Object.entries(record)) {
    if (name.startsWith("_")) continue;
    if (!Array.isArray(value) || value.length !== 2) throw new Error(`${PIPELINE_INDEX_FILE}: component ${name} must be [library, class]`);
    const [library, componentClass] = value;
    if (library === null && componentClass === null) continue;
    if (typeof library !== "string" || typeof componentClass !== "string")
      throw new Error(`${PIPELINE_INDEX_FILE}: component ${name} must name a library and a class`);
    components.set(name, { library, className: componentClass });
  }
  return { className, components };
}

/** Read and parse `<modelDir>/model_index.json`. */
export async function readPipelineIndex(modelDir: string): Promise<PipelineIndex> {
  return parsePipelineIndex(await Bun.file(`${modelDir}/${PIPELINE_INDEX_FILE}`).json());
}

/** The subdirectory of a component the index declares; throws naming the
 * component when the index lacks it or the directory has no config. */
export async function pipelineComponentDir(modelDir: string, index: PipelineIndex, name: string, configFile = "config.json"): Promise<string> {
  if (!index.components.has(name)) throw new Error(`${modelDir}: pipeline ${index.className} declares no ${name} component`);
  const dir = `${modelDir}/${name}`;
  if (!(await Bun.file(`${dir}/${configFile}`).exists())) throw new Error(`${modelDir}: component ${name} has no ${configFile}`);
  return dir;
}
