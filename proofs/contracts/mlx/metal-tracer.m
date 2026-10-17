// Metal dispatch tracer: loaded into the bun process (bun:ffi dlopen) BEFORE MLX
// creates its device. Swizzles every ObjC class that implements the relevant
// Metal selectors and records libraries, functions, pipelines (with their
// maxTotalThreadsPerThreadgroup and threadExecutionWidth) and dispatches.
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>
#include <pthread.h>
#include <stdio.h>

static pthread_mutex_t mu = PTHREAD_MUTEX_INITIALIZER;
static __thread int depth = 0;
static int enabled = 0;
static NSMutableDictionary *libs;      // libptr -> desc dict
static NSMutableDictionary *funcs;     // funcptr -> {name, specialized, lib}
static NSMutableDictionary *pipes;     // pipeptr -> {name, specialized, origin, maxTotal, width}
static NSMutableArray *events;         // strings
static NSMutableDictionary *curPipe;   // encoderptr -> pipeptr
static NSString *outDir;

static NSString *key(id o) { return [NSString stringWithFormat:@"%p", (__bridge void *)o]; }
static NSString *sha(NSString *s) {
  NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
  unsigned char h[32]; CC_SHA256(d.bytes, (CC_LONG)d.length, h);
  NSMutableString *r = [NSMutableString string];
  for (int i = 0; i < 32; i++) [r appendFormat:@"%02x", h[i]];
  return r;
}

static NSString *desc(NSDictionary *p) {
  if (!p) return @"?\t?\tunknown";
  return [NSString stringWithFormat:@"%@\t%@\t%@", p[@"name"], p[@"specialized"], p[@"origin"]];
}
static NSString *origin(id lib) {
  NSDictionary *ld = libs[key(lib)];
  if (!ld) return @"unknown";
  return [ld[@"kind"] isEqual:@"source"] ? [@"source:" stringByAppendingString:ld[@"sha256"]] : [@"file:" stringByAppendingString:ld[@"path"]];
}
// Records the function a pipeline was made from with the pipeline's own limits.
static void recPipe(id p, id fn) {
  id<MTLComputePipelineState> ps = p;
  NSMutableDictionary *d = [(funcs[key(fn)] ?: @{@"name": @"?fn", @"specialized": @"?fn", @"origin": @"unknown"}) mutableCopy];
  d[@"maxTotal"] = @((unsigned long)ps.maxTotalThreadsPerThreadgroup);
  d[@"width"] = @((unsigned long)ps.threadExecutionWidth);
  d[@"staticThreadgroupMemory"] = @((unsigned long)ps.staticThreadgroupMemoryLength);
  pipes[key(p)] = d;
}
static void recLib(id lib, NSDictionary *desc) {
  if (!lib) return;
  pthread_mutex_lock(&mu); libs[key(lib)] = desc; pthread_mutex_unlock(&mu);
}

// ---- swizzle helper: replace IMP in every class that defines `sel`.
typedef id (^Maker)(IMP orig);
static void swz(SEL sel, Maker make) {
  unsigned int n = 0; Class *cls = objc_copyClassList(&n);
  for (unsigned int i = 0; i < n; i++) {
    unsigned int m = 0; Method *ms = class_copyMethodList(cls[i], &m);
    for (unsigned int j = 0; j < m; j++) {
      if (method_getName(ms[j]) == sel) {
        IMP orig = method_getImplementation(ms[j]);
        method_setImplementation(ms[j], imp_implementationWithBlock(make(orig)));
        fprintf(stderr, "kt: swizzled %s %s\n", class_getName(cls[i]), sel_getName(sel));
      }
    }
    free(ms);
  }
  free(cls);
}

static void install(void) {
  libs = [NSMutableDictionary new]; funcs = [NSMutableDictionary new]; pipes = [NSMutableDictionary new];
  events = [NSMutableArray new]; curPipe = [NSMutableDictionary new];
  // Load the driver bundle and realize encoder classes.
  id<MTLDevice> dev = MTLCreateSystemDefaultDevice();
  id<MTLCommandQueue> q = [dev newCommandQueue];
  id<MTLCommandBuffer> cb = [q commandBuffer];
  id<MTLComputeCommandEncoder> e1 = [cb computeCommandEncoderWithDispatchType:MTLDispatchTypeConcurrent];
  [e1 endEncoding];
  id<MTLComputeCommandEncoder> e2 = [cb computeCommandEncoder];
  [e2 endEncoding];
  fprintf(stderr, "kt: device %s class %s encoder %s\n", dev.name.UTF8String, object_getClassName(dev), object_getClassName(e1));

  swz(@selector(newLibraryWithSource:options:error:), ^id(IMP o) {
    return ^id(id self, NSString *src, MTLCompileOptions *opt, NSError **err) {
      depth++;
      id lib = ((id (*)(id, SEL, NSString *, MTLCompileOptions *, NSError **))o)(self, @selector(newLibraryWithSource:options:error:), src, opt, err);
      depth--;
      if (depth == 0 && lib) {
        NSString *h = sha(src);
        NSString *p = [outDir stringByAppendingFormat:@"/src-%@.metal", h];
        [src writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *lp = [outDir stringByAppendingFormat:@"/src-%@.metallib", h];
        BOOL ser = ((BOOL (*)(id, SEL, NSURL *, NSError **))objc_msgSend)(lib, @selector(serializeToURL:error:), [NSURL fileURLWithPath:lp], nil);
        long mm = -1; if (@available(macOS 15.0, *)) mm = (long)opt.mathMode;
        long fp = -1; if (@available(macOS 15.0, *)) fp = (long)opt.mathFloatingPointFunctions;
        recLib(lib, @{@"kind": @"source", @"sha256": h, @"path": p, @"serialized": ser ? lp : @"",
                      @"mathMode": @(mm), @"mathFloatingPointFunctions": @(fp),
                      @"fastMathEnabled": @(opt.fastMathEnabled),
                      @"languageVersion": [NSString stringWithFormat:@"0x%lx", (long)opt.languageVersion],
                      @"preserveInvariance": @(opt.preserveInvariance),
                      @"optimizationLevel": @((long)opt.optimizationLevel),
                      @"preprocessorMacros": opt.preprocessorMacros ? [opt.preprocessorMacros description] : @"",
                      @"libraryType": @((long)opt.libraryType)});
      }
      return lib;
    };
  });
  swz(@selector(newLibraryWithFile:error:), ^id(IMP o) {
    return ^id(id self, NSString *path, NSError **err) {
      depth++;
      id lib = ((id (*)(id, SEL, NSString *, NSError **))o)(self, @selector(newLibraryWithFile:error:), path, err);
      depth--;
      if (depth == 0) recLib(lib, @{@"kind": @"file", @"path": path ?: @""});
      return lib;
    };
  });
  swz(@selector(newLibraryWithURL:error:), ^id(IMP o) {
    return ^id(id self, NSURL *url, NSError **err) {
      depth++;
      id lib = ((id (*)(id, SEL, NSURL *, NSError **))o)(self, @selector(newLibraryWithURL:error:), url, err);
      depth--;
      if (depth == 0) recLib(lib, @{@"kind": @"url", @"path": url.path ?: @""});
      return lib;
    };
  });
  swz(@selector(newFunctionWithName:), ^id(IMP o) {
    return ^id(id self, NSString *name) {
      depth++;
      id f = ((id (*)(id, SEL, NSString *))o)(self, @selector(newFunctionWithName:), name);
      depth--;
      if (depth == 0 && f) { pthread_mutex_lock(&mu); funcs[key(f)] = @{@"name": name, @"specialized": name, @"lib": key(self), @"origin": origin(self)}; pthread_mutex_unlock(&mu); }
      return f;
    };
  });
  swz(@selector(newFunctionWithDescriptor:error:), ^id(IMP o) {
    return ^id(id self, MTLFunctionDescriptor *d, NSError **err) {
      depth++;
      id f = ((id (*)(id, SEL, MTLFunctionDescriptor *, NSError **))o)(self, @selector(newFunctionWithDescriptor:error:), d, err);
      depth--;
      if (depth == 0 && f) { pthread_mutex_lock(&mu); funcs[key(f)] = @{@"name": d.name ?: @"", @"specialized": d.specializedName ?: d.name ?: @"", @"lib": key(self), @"origin": origin(self)}; pthread_mutex_unlock(&mu); }
      return f;
    };
  });
  swz(@selector(newComputePipelineStateWithFunction:error:), ^id(IMP o) {
    return ^id(id self, id fn, NSError **err) {
      depth++;
      id p = ((id (*)(id, SEL, id, NSError **))o)(self, @selector(newComputePipelineStateWithFunction:error:), fn, err);
      depth--;
      if (depth == 0 && p) { pthread_mutex_lock(&mu); recPipe(p, fn); pthread_mutex_unlock(&mu); }
      return p;
    };
  });
  swz(@selector(newComputePipelineStateWithDescriptor:options:reflection:error:), ^id(IMP o) {
    return ^id(id self, MTLComputePipelineDescriptor *d, MTLPipelineOption op, id *refl, NSError **err) {
      depth++;
      id p = ((id (*)(id, SEL, id, MTLPipelineOption, id *, NSError **))o)(self, @selector(newComputePipelineStateWithDescriptor:options:reflection:error:), d, op, refl, err);
      depth--;
      if (depth == 0 && p) { pthread_mutex_lock(&mu); recPipe(p, d.computeFunction); pthread_mutex_unlock(&mu); }
      return p;
    };
  });
  swz(@selector(setComputePipelineState:), ^id(IMP o) {
    return ^void(id self, id p) {
      depth++;
      ((void (*)(id, SEL, id))o)(self, @selector(setComputePipelineState:), p);
      depth--;
      if (depth == 0) { pthread_mutex_lock(&mu); curPipe[key(self)] = pipes[key(p)] ?: @{@"name": @"?pipe", @"specialized": @"?pipe", @"origin": @"unknown"}; pthread_mutex_unlock(&mu); }
    };
  });
  swz(@selector(dispatchThreadgroups:threadsPerThreadgroup:), ^id(IMP o) {
    return ^void(id self, MTLSize g, MTLSize t) {
      depth++;
      ((void (*)(id, SEL, MTLSize, MTLSize))o)(self, @selector(dispatchThreadgroups:threadsPerThreadgroup:), g, t);
      depth--;
      if (depth == 0 && enabled) { pthread_mutex_lock(&mu);
        [events addObject:[NSString stringWithFormat:@"D\t%@\tgroups\t%lu,%lu,%lu\t%lu,%lu,%lu\t%@", desc(curPipe[key(self)]), g.width, g.height, g.depth, t.width, t.height, t.depth, curPipe[key(self)][@"maxTotal"] ?: @"?"]];
        pthread_mutex_unlock(&mu); }
    };
  });
  swz(@selector(dispatchThreads:threadsPerThreadgroup:), ^id(IMP o) {
    return ^void(id self, MTLSize g, MTLSize t) {
      depth++;
      ((void (*)(id, SEL, MTLSize, MTLSize))o)(self, @selector(dispatchThreads:threadsPerThreadgroup:), g, t);
      depth--;
      if (depth == 0 && enabled) { pthread_mutex_lock(&mu);
        [events addObject:[NSString stringWithFormat:@"D\t%@\tthreads\t%lu,%lu,%lu\t%lu,%lu,%lu\t%@", desc(curPipe[key(self)]), g.width, g.height, g.depth, t.width, t.height, t.depth, curPipe[key(self)][@"maxTotal"] ?: @"?"]];
        pthread_mutex_unlock(&mu); }
    };
  });
}

void kt_init(const char *dir) {
  @autoreleasepool {
    outDir = [NSString stringWithUTF8String:dir];
    [[NSFileManager defaultManager] createDirectoryAtPath:outDir withIntermediateDirectories:YES attributes:nil error:nil];
    install();
  }
}
void kt_enable(int on) { pthread_mutex_lock(&mu); enabled = on; pthread_mutex_unlock(&mu); }
void kt_mark(const char *s) {
  pthread_mutex_lock(&mu); [events addObject:[NSString stringWithFormat:@"M\t%s", s]]; pthread_mutex_unlock(&mu);
}
// Writes events with pipeline -> function -> library resolved, plus the library table.
void kt_dump(const char *path) {
  @autoreleasepool {
    pthread_mutex_lock(&mu);
    NSMutableString *out = [NSMutableString string];
    for (NSString *ev in events) [out appendFormat:@"%@\n", ev];
    [out writeToFile:[NSString stringWithUTF8String:path] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSMutableString *lt = [NSMutableString string];
    for (NSString *k in libs) [lt appendFormat:@"%@\t%@\n", k, libs[k]];
    [lt writeToFile:[[NSString stringWithUTF8String:path] stringByAppendingString:@".libs"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    pthread_mutex_unlock(&mu);
  }
}
// One line per compute pipeline created since kt_init:
// name, specialized name, origin, maxTotalThreadsPerThreadgroup, threadExecutionWidth, static threadgroup bytes.
void kt_dump_pipelines(const char *path) {
  @autoreleasepool {
    pthread_mutex_lock(&mu);
    NSMutableString *out = [NSMutableString string];
    for (NSString *k in pipes) { NSDictionary *d = pipes[k];
      [out appendFormat:@"%@\t%@\t%@\t%@\t%@\t%@\n", d[@"name"], d[@"specialized"], d[@"origin"], d[@"maxTotal"], d[@"width"], d[@"staticThreadgroupMemory"]]; }
    [out writeToFile:[NSString stringWithUTF8String:path] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    pthread_mutex_unlock(&mu);
  }
}
void kt_clear(void) { pthread_mutex_lock(&mu); [events removeAllObjects]; pthread_mutex_unlock(&mu); }
