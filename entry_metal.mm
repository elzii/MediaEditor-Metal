#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "imgui.h"
#include "imgui_impl_metal.h"
#include "imgui_impl_osx.h"
#include "imgui_helper.h"
#include "application.h"
#include <algorithm>
#include <vector>
#include <string>

static NSWindow* g_MainWindow = nil;
static bool g_WindowClosed = false;

@interface MetalAppWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation MetalAppWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    g_WindowClosed = true;
}
@end

extern "C" {
    void ImGui_ImplMetal_SetDevice(void* device);
}

void Application_FullScreen(bool on) {
    if (!g_MainWindow) return;
    bool isFullScreen = (g_MainWindow.styleMask & NSWindowStyleMaskFullScreen) != 0;
    if (isFullScreen != on) {
        [g_MainWindow toggleFullScreen:nil];
    }
}

static bool Show_Splash_Window(ApplicationWindowProperty& property, ImGuiContext* ctx, id<MTLDevice> device, id<MTLCommandQueue> commandQueue) {
    NSRect contentRect = NSMakeRect(0, 0, property.splash_screen_width, property.splash_screen_height);
    NSWindowStyleMask styleMask = NSWindowStyleMaskBorderless;
    NSWindow* window = [[NSWindow alloc] initWithContentRect:contentRect
                                                   styleMask:styleMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    [window setAlphaValue:property.splash_screen_alpha];
    [window setLevel:NSStatusWindowLevel]; // Show above normal windows
    [window center];
    
    MTKView* mtkView = [[MTKView alloc] initWithFrame:contentRect device:device];
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    [window setContentView:mtkView];
    [window orderFront:nil];
    [window makeKeyWindow];
    
    ImGui_ImplOSX_Init(mtkView);
    ImGui_ImplMetal_Init(device);
    
    ImGuiIO& io = ImGui::GetIO();
    if (property.application.Application_SetupContext)
        property.application.Application_SetupContext(ctx, property.handle, true);
        
    bool done = false;
    bool splash_done = false;
    int frame_count = 0;
    
    while (!splash_done && !done) {
        @autoreleasepool {
            NSEvent* event;
            do {
                event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                           untilDate:[NSDate distantPast]
                                              inMode:NSDefaultRunLoopMode
                                             dequeue:YES];
                if (event != nil) {
                    [NSApp sendEvent:event];
                    [NSApp updateWindows];
                }
            } while (event != nil);
            
            if (![window isVisible]) {
                done = true;
                break;
            }
            
            ImGui::ImUpdateTextures();
            
            MTLRenderPassDescriptor* renderPassDescriptor = mtkView.currentRenderPassDescriptor;
            if (renderPassDescriptor == nil) continue;
            
            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui_ImplOSX_NewFrame(mtkView);
            ImGui::NewFrame();
            
            io.DisplaySize.x = mtkView.bounds.size.width;
            io.DisplaySize.y = mtkView.bounds.size.height;
            CGFloat framebufferScale = window.screen.backingScaleFactor ?: NSScreen.mainScreen.backingScaleFactor;
            io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
            
            auto _splash_done = property.application.Application_SplashScreen(property.handle, done);
            frame_count++;
            if (frame_count > 1) {
                splash_done = _splash_done;
            }
            
            ImGui::EndFrame();
            
            if (splash_done || done) break;
            
            ImGui::Render();
            
            id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
            id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui Splash Rendering"];
            ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];
            
            [commandBuffer presentDrawable:mtkView.currentDrawable];
            [commandBuffer commit];
        }
    }
    
    if (property.application.Application_SplashFinalize)
        property.application.Application_SplashFinalize(&property.handle);
        
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplOSX_Shutdown();
    [window orderOut:nil];
    [window close];
    
    return done;
}

int main(int argc, char** argv) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        [NSApp finishLaunching];
        
        ApplicationWindowProperty property(argc, argv);
        Application_Setup(property);
        
        IMGUI_CHECKVERSION();
        auto ctx = ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO(); (void)io;
        ImGuiContext& g = *GImGui;
        io.ApplicationName = property.name.c_str();
        io.Fonts->AddFontDefault(property.font_scale);
        io.FontGlobalScale = 1.0f / property.font_scale;
        
        if (property.power_save) io.ConfigFlags |= ImGuiConfigFlags_EnablePowerSavingMode;
        if (property.low_reflash) io.ConfigFlags |= ImGuiConfigFlags_EnableLowRefreshMode;
        ImGui::SetCustomFrameRate(property.max_fps, property.min_fps);
        
        auto setting_path = property.using_setting_path ? ImGuiHelper::settings_path(property.name) : "";
        auto ini_name = property.name;
        std::replace(ini_name.begin(), ini_name.end(), ' ', '_');
        setting_path += ini_name + ".ini";
        io.IniFilename = setting_path.c_str();
        if (property.internationalize && !property.language_path.empty()) {
            io.LanguagePath = property.language_path.c_str();
            g.Style.TextInternationalize = 1;
            g.LanguageName = "Default";
        }
        
        ImGui::StyleColorsDark();
        
        if (property.application.Application_Initialize)
            property.application.Application_Initialize(&property.handle);
            
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        id<MTLCommandQueue> commandQueue = [device newCommandQueue];
        
        ImGui_ImplMetal_SetDevice((__bridge void*)device);
        
        bool splash_done = false;
        if (property.application.Application_SplashScreen &&
            property.splash_screen_width > 0 &&
            property.splash_screen_height > 0) {
            auto app_will_quit = Show_Splash_Window(property, ctx, device, commandQueue);
            splash_done = true;
            if (app_will_quit) {
                ImGui::ImDestroyTextures();
                ImGui::DestroyContext();
                return 0;
            }
        }
        
        NSRect contentRect;
        NSWindowStyleMask styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
        if (property.resizable) styleMask |= NSWindowStyleMaskResizable;
        if (!property.window_border) styleMask = NSWindowStyleMaskBorderless;
        
        if (property.full_size) {
            NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
            contentRect = screenRect;
        } else {
            contentRect = NSMakeRect(property.pos_x, property.pos_y, property.width, property.height);
        }
        
        NSWindow* window = [[NSWindow alloc] initWithContentRect:contentRect
                                                       styleMask:styleMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO];
        g_MainWindow = window;
        NSString* nsTitle = [NSString stringWithUTF8String:property.name.c_str()];
        [window setTitle:nsTitle];
        
        if (property.center) {
            [window center];
        }
        
        MTKView* mtkView = [[MTKView alloc] initWithFrame:contentRect device:device];
        mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 1);
        [window setContentView:mtkView];
        [window makeKeyAndOrderFront:nil];
        
        MetalAppWindowDelegate* windowDelegate = [[MetalAppWindowDelegate alloc] init];
        [window setDelegate:windowDelegate];
        
        if (!splash_done && property.application.Application_SetupContext)
            property.application.Application_SetupContext(ctx, property.handle, false);
            
        ImGui_ImplOSX_Init(mtkView);
        ImGui_ImplMetal_Init(device);
        
        bool done = false;
        bool app_done = false;
        
        while (!app_done && !done && !g_WindowClosed) {
            @autoreleasepool {
                NSEvent* event;
                do {
                    event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                               untilDate:[NSDate distantPast]
                                                  inMode:NSDefaultRunLoopMode
                                                 dequeue:YES];
                    if (event != nil) {
                        [NSApp sendEvent:event];
                        [NSApp updateWindows];
                    }
                } while (event != nil);
                
                if (![window isVisible] || g_WindowClosed) {
                    done = true;
                }
                
                ImGui::ImUpdateTextures();
                
                MTLRenderPassDescriptor* renderPassDescriptor = mtkView.currentRenderPassDescriptor;
                if (renderPassDescriptor == nil) continue;
                
                ImGui_ImplMetal_NewFrame(renderPassDescriptor);
                ImGui_ImplOSX_NewFrame(mtkView);
                ImGui::NewFrame();
                
                io.DisplaySize.x = mtkView.bounds.size.width;
                io.DisplaySize.y = mtkView.bounds.size.height;
                CGFloat framebufferScale = window.screen.backingScaleFactor ?: NSScreen.mainScreen.backingScaleFactor;
                io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
                
                if (property.application.Application_Frame)
                    app_done = property.application.Application_Frame(property.handle, done);
                else
                    app_done = done;
                    
                ImGui::EndFrame();
                if (app_done) break;
                
                ImGui::Render();
                
                id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
                renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
                id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
                [renderEncoder pushDebugGroup:@"ImGui Rendering"];
                ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
                [renderEncoder popDebugGroup];
                [renderEncoder endEncoding];
                
                [commandBuffer presentDrawable:mtkView.currentDrawable];
                [commandBuffer commit];
            }
        }
        
        if (property.application.Application_Finalize)
            property.application.Application_Finalize(&property.handle);
            
        ImGui_ImplMetal_Shutdown();
        ImGui_ImplOSX_Shutdown();
        ImGui::ImDestroyTextures();
        ImGui::DestroyContext();
        
        return 0;
    }
}
