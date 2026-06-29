#import <Metal/Metal.h>
#import <Foundation/Foundation.h>

static id<MTLDevice> g_MetalDevice = nil;

extern "C" {
    void ImGui_ImplMetal_SetDevice(void* device) {
        g_MetalDevice = (__bridge id<MTLDevice>)device;
    }
    
    void* ImGui_ImplMetal_CreateTexture(const void* data, int width, int height, int channels, int bit_depth) {
        if (!g_MetalDevice) return nil;
        
        MTLPixelFormat pixelFormat = MTLPixelFormatRGBA8Unorm;
        int bytesPerPixel = 4;
        if (channels == 1) {
            pixelFormat = MTLPixelFormatR8Unorm;
            bytesPerPixel = 1;
        } else if (channels == 2) {
            pixelFormat = MTLPixelFormatRG8Unorm;
            bytesPerPixel = 2;
        }
        
        unsigned char* rgbaData = NULL;
        if (channels == 3) {
            pixelFormat = MTLPixelFormatRGBA8Unorm;
            bytesPerPixel = 4;
            rgbaData = (unsigned char*)malloc(width * height * 4);
            const unsigned char* src = (const unsigned char*)data;
            for (int i = 0; i < width * height; i++) {
                rgbaData[i*4 + 0] = src[i*3 + 0];
                rgbaData[i*4 + 1] = src[i*3 + 1];
                rgbaData[i*4 + 2] = src[i*3 + 2];
                rgbaData[i*4 + 3] = 255;
            }
            data = rgbaData;
        }
        
        MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:pixelFormat
                                                                                               width:width
                                                                                              height:height
                                                                                           mipmapped:NO];
        descriptor.usage = MTLTextureUsageShaderRead;
        descriptor.storageMode = MTLStorageModeShared;
        
        id<MTLTexture> texture = [g_MetalDevice newTextureWithDescriptor:descriptor];
        if (texture && data) {
            MTLRegion region = MTLRegionMake2D(0, 0, width, height);
            [texture replaceRegion:region
                       mipmapLevel:0
                         withBytes:data
                       bytesPerRow:width * bytesPerPixel];
        }
        
        if (rgbaData) {
            free(rgbaData);
        }
        
        return (__bridge_retained void*)texture;
    }
    
    void ImGui_ImplMetal_UpdateTexture(void* textureId, const void* data, int width, int height, int channels, int bit_depth) {
        id<MTLTexture> texture = (__bridge id<MTLTexture>)textureId;
        if (!texture || !data) return;
        
        int bytesPerPixel = 4;
        if (channels == 1) {
            bytesPerPixel = 1;
        } else if (channels == 2) {
            bytesPerPixel = 2;
        }
        
        unsigned char* rgbaData = NULL;
        if (channels == 3) {
            bytesPerPixel = 4;
            rgbaData = (unsigned char*)malloc(width * height * 4);
            const unsigned char* src = (const unsigned char*)data;
            for (int i = 0; i < width * height; i++) {
                rgbaData[i*4 + 0] = src[i*3 + 0];
                rgbaData[i*4 + 1] = src[i*3 + 1];
                rgbaData[i*4 + 2] = src[i*3 + 2];
                rgbaData[i*4 + 3] = 255;
            }
            data = rgbaData;
        }
        
        MTLRegion region = MTLRegionMake2D(0, 0, width, height);
        [texture replaceRegion:region
                   mipmapLevel:0
                     withBytes:data
                   bytesPerRow:width * bytesPerPixel];
                   
        if (rgbaData) {
            free(rgbaData);
        }
    }
    
    void ImGui_ImplMetal_DestroyTexture(void* textureId) {
        if (!textureId) return;
        id<MTLTexture> texture = (__bridge_transfer id<MTLTexture>)textureId;
        texture = nil;
    }
}
