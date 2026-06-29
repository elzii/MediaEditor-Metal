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

#include "NativeMenuBridge.h"

NativeMenuState g_NativeMenuState;

@interface MenuActionTarget : NSObject
- (void)onAbout:(id)sender;
- (void)onProjectNew:(id)sender;
- (void)onProjectOpen:(id)sender;
- (void)onProjectSave:(id)sender;
- (void)onProjectSaveAs:(id)sender;
@end

@implementation MenuActionTarget
- (void)onAbout:(id)sender {
    g_NativeMenuState.triggerAbout.store(true);
}
- (void)onProjectNew:(id)sender {
    g_NativeMenuState.triggerProjectNew.store(true);
}
- (void)onProjectOpen:(id)sender {
    g_NativeMenuState.triggerProjectOpen.store(true);
}
- (void)onProjectSave:(id)sender {
    g_NativeMenuState.triggerProjectSave.store(true);
}
- (void)onProjectSaveAs:(id)sender {
    g_NativeMenuState.triggerProjectSaveAs.store(true);
}
@end

void SetupNativeMacMenu(NSArray<NSDictionary*>* enabledCameras) {
    dispatch_async(dispatch_get_main_queue(), ^{
        static MenuActionTarget* target = [[MenuActionTarget alloc] init];
        NSMenu* mainMenu = [[NSMenu alloc] init];
        
        NSString* appName = @"mec";
        
        // App Menu
        NSMenuItem* appMenuItem = [[NSMenuItem alloc] init];
        [mainMenu addItem:appMenuItem];
        NSMenu* appMenu = [[NSMenu alloc] init];
        [appMenuItem setSubmenu:appMenu];
        
        // About
        NSMenuItem* aboutItem = [[NSMenuItem alloc] initWithTitle:@"About"
                                                           action:@selector(onAbout:)
                                                    keyEquivalent:@""];
        [aboutItem setTarget:target];
        [appMenu addItem:aboutItem];
        
        [appMenu addItem:[NSMenuItem separatorItem]];
        
        // Quit
        NSMenuItem* quitItem = [[NSMenuItem alloc] initWithTitle:[@"Quit " stringByAppendingString:appName]
                                                          action:@selector(terminate:)
                                                   keyEquivalent:@"q"];
        [quitItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
        [appMenu addItem:quitItem];
        
        // -- MEW TOP LEVEL MENU -----------------
        NSMenuItem* projectItem = [[NSMenuItem alloc] initWithTitle:@"Project"
                                                              action:nil
                                                       keyEquivalent:@""];
        [mainMenu addItem:projectItem];
        NSMenu* projectMenu = [[NSMenu alloc] initWithTitle:@"AI Detection"];
        [projectItem setSubmenu:projectMenu];

        // -- MENU ITEM --------------------------
        NSMenuItem* projectItem_New = [[NSMenuItem alloc] initWithTitle:@"New Project"
                                                          action:@selector(onProjectNew:)
                                                   keyEquivalent:@"n"];
        [projectItem_New setTarget:target];
        [projectMenu addItem:projectItem_New];

        // -- MENU ITEM --------------------------
        NSMenuItem* projectItem_Open = [[NSMenuItem alloc] initWithTitle:@"Open Project"
                                                           action:@selector(onProjectOpen:)
                                                    keyEquivalent:@"o"];
        [projectItem_Open setTarget:target];
        [projectMenu addItem:projectItem_Open];


        // -- MENU ITEM --------------------------
        NSMenuItem* projectItem_Save = [[NSMenuItem alloc] initWithTitle:@"Save Project"
                                                           action:@selector(onProjectSave:)
                                                    keyEquivalent:@"s"];
        [projectItem_Save setTarget:target];
        [projectMenu addItem:projectItem_Save];

        // -- MENU ITEM --------------------------
        NSMenuItem* projectItem_SaveAs = [[NSMenuItem alloc] initWithTitle:@"Save Project As"
                                                           action:@selector(onProjectSaveAs:)
                                                    keyEquivalent:@"S"];
        [projectItem_SaveAs setTarget:target];
        [projectMenu addItem:projectItem_SaveAs];
        
        [NSApp setMainMenu:mainMenu];
    });
}

static NSWindow* g_MainWindow = nil;
static bool g_WindowClosed = false;
static std::vector<std::string> g_DroppedPaths;

@interface MetalAppWindowDelegate : NSObject <NSWindowDelegate, NSDraggingDestination>
@end

@implementation MetalAppWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    g_WindowClosed = true;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        NSArray *urls = [pboard readObjectsForClasses:@[[NSURL class]] options:nil];
        for (NSURL *url in urls) {
            if (url.isFileURL) {
                g_DroppedPaths.push_back(std::string([url.path UTF8String]));
            }
        }
        return YES;
    }
    return NO;
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
            renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
            renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
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
        [window registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
        [window makeKeyAndOrderFront:nil];
        
        MetalAppWindowDelegate* windowDelegate = [[MetalAppWindowDelegate alloc] init];
        [window setDelegate:windowDelegate];
        
        SetupNativeMacMenu(nil);
        
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
                
                if (!g_DroppedPaths.empty()) {
                    if (property.application.Application_DropFromSystem)
                        property.application.Application_DropFromSystem(g_DroppedPaths);
                    g_DroppedPaths.clear();
                }
                
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
                renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
                renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
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
