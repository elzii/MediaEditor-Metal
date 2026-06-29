#pragma once
#include <atomic>
#include <string>
#include <vector>

// Thread-safe flags that the native macOS menu sets when clicked,
// and your main ImGui render loop reads and resets.
struct NativeMenuState {
    std::atomic<bool> triggerAbout{false};
    std::atomic<bool> triggerProjectNew{false};
    std::atomic<bool> triggerProjectOpen{false};
    std::atomic<bool> triggerProjectSave{false};
    std::atomic<bool> triggerProjectSaveAs{false};
};

// Global or shared reference accessible across both layers
extern NativeMenuState g_NativeMenuState;

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

// Objective-C++ initialization function signature
void SetupNativeMacMenu(NSArray<NSDictionary*>* enabledCameras);
#endif
