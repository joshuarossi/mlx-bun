import type { AppModule, CliInvocation, CliVerbHandler, ModuleRuntime } from "@mlx-bun/app-core";
import { parseImageArgs, runImage, type ImageVerbDependencies } from "./image";
import { manifest } from "./manifest";
import { createImageHandlers } from "./routes";
import { ImageService } from "./service";

export { manifest } from "./manifest";
export { encodePng } from "./png";
export { createImageHandlers, generationResponse, parseGenerationBody } from "./routes";
export type { GenerationService } from "./routes";
export { ImageRequestError, ImageService, NO_IMAGE_MODEL, validateImageRequest } from "./service";
export type { ImageGeneration, ImageOutcome, ImageServiceOptions, ImageServices } from "./service";
export { imageSummary, parseImageArgs, progressLine, runImage } from "./image";
export type { ImageArgs, ImageVerbDependencies } from "./image";

/** Test seams: the verb's file writing. */
export interface ImagesModuleOptions {
  verb?: Partial<Pick<ImageVerbDependencies, "writeFile">>;
}

/** The images module. The host implements `modelHost` (the `image` lease, its residency policy and the execution lock) and `catalog`. */
export function createImagesModule(options: ImagesModuleOptions = {}): AppModule<"modelHost" | "catalog"> {
  return {
    ...manifest,
    activate({ services, signal }): ModuleRuntime {
      // The route and the verb share one service; stopping the module cancels its generations and `dispose` joins them.
      const service = new ImageService(services, { signal });
      const image: CliVerbHandler = async (invocation: CliInvocation) => {
        try { await runImage(service, parseImageArgs(invocation), { stdout: invocation.stdout, stderr: invocation.stderr, ...options.verb }, invocation.signal); }
        catch (error) { if (invocation.signal.aborted) throw new Error("image generation cancelled"); throw error; }
        return 0;
      };
      return { routes: createImageHandlers(service), verbs: { image }, dispose: () => service.close() };
    },
  };
}

export default createImagesModule();
