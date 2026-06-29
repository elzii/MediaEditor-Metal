#pragma once

#define IMGUI_SHARED_LIBRARY 0
#define IMGUI_EMSCRIPTEN 0
#define IMGUI_BUILD_EXAMPLE 0
#define IMGUI_OPENGL 0
#define IMGUI_GLM 0
#define IMGUI_ENABLE_FREETYPE 0
#define IMGUI_GLEW 0
#define IMGUI_SDL2 0
#define IMGUI_TIFF 0
#define IMGUI_RENDERING_VULKAN 0
#define IMGUI_RENDERING_GL3 0
#define IMGUI_RENDERING_GL2 0
#define IMGUI_RENDERING_DX12 0
#define IMGUI_RENDERING_DX11 0
#define IMGUI_RENDERING_DX10 0
#define IMGUI_RENDERING_DX9 0
#define IMGUI_RENDERING_MATAL 1
#define IMGUI_PLATFORM_SDL2 0
#define IMGUI_PLATFORM_GLFW 0
#define IMGUI_PLATFORM_GLUT 0
#define IMGUI_PLATFORM_WIN32 0

#define IMGUI_FONT_NO_UTF8 0
#define IMGUI_FONT_NO_LATIN 0
#define IMGUI_FONT_HEI 0
#define IMGUI_FONT_KAI 0
#define IMGUI_FONT_SONG 0
#define IMGUI_FONT_YUAN 0
#define IMGUI_FONT_SARASA 0
#define IMGUI_FONT_WEIHEI 1
#define IMGUI_FONT_SANS 0
#define IMGUI_FONT_ZPIX 0
#define IMGUI_FONT_MONONARROW 1
#define IMGUI_FONT_INCONSOLATA 0
#define IMGUI_FONT_TAHOMA 0
#define IMGUI_FONT_COUSINE 0
#define IMGUI_FONT_DROIDSANS 0
#define IMGUI_FONT_KARLA 0
#define IMGUI_FONT_MONACO 0
#define IMGUI_FONT_PROGGYTINY 0
#define IMGUI_FONT_ROBOTO 0
#define IMGUI_FONT_SOURCECODEPRO 0

#define IMGUI_ICONS 1
#define IMGUI_VULKAN_SHADER 0
#define IMGUI_APPLICATION_RENDERING_VULKAN 0
#define IMGUI_APPLICATION_RENDERING_GL3 0
#define IMGUI_APPLICATION_RENDERING_GL2 0
#define IMGUI_APPLICATION_RENDERING_DX11 0
#define IMGUI_APPLICATION_RENDERING_DX9 0
#define IMGUI_APPLICATION_PLATFORM_SDL2 0
#define IMGUI_APPLICATION_PLATFORM_GLFW 0
#define IMGUI_APPLICATION_PLATFORM_GLUT 0
#define IMGUI_APPLICATION_PLATFORM_WIN32 0

#ifdef _WIN32
#if IMGUI_SHARED_LIBRARY
#define IMGUI_API __declspec( dllexport )
#else
#define IMGUI_API
#endif
#else
#if IMGUI_SHARED_LIBRARY
#define IMGUI_API __attribute__((visibility("default"))) 
#else
#define IMGUI_API
#endif
#endif

#define IMGUI_ENABLE_WIN32_DEFAULT_IME_FUNCTIONS

#define IMGUI_INCLUDE_IMGUI_USER_H

#define IM_VEC2_CLASS_EXTRA \
    ImVec2 operator*(const float rhs)               { return ImVec2(x * rhs, y * rhs); } \
    ImVec2 operator/(const float rhs)               { return ImVec2(x / rhs, y / rhs); } \
    ImVec2 operator+(const ImVec2& rhs)             { return ImVec2(x + rhs.x, y + rhs.y); } \
    ImVec2 operator-(const ImVec2& rhs)             { return ImVec2(x - rhs.x, y - rhs.y); } \
    float area()                                    { return x * y; } \
    float length()                                  { return sqrt(x * x + y * y); } \
    float cross(const ImVec2& d)                    { return (x * d.y) - (y * d.x); } \
    float dot(const ImVec2& d)                      { return (x * d.x) + (y * d.y); } \
    float norm()                                    { return x * x + y * y; } \
    float distance(const ImVec2& d)                 { return sqrt((d.x - x) * (d.x - x) + (d.y - y) * (d.y - y)); } \
    ImVec2 project(ImVec2& a, ImVec2& b)            { ImVec2 base = b - a; float r = (*this - a).dot(base) / base.norm(); return a + base * r; } \

#define IM_VEC3_CLASS_EXTRA \
    ImVec3 operator+(const float rhs)               { return ImVec3(x + rhs, y + rhs, z + rhs); } \
    ImVec3 operator-(const float rhs)               { return ImVec3(x - rhs, y - rhs, z - rhs); } \
    ImVec3 operator*(const float rhs)               { return ImVec3(x * rhs, y * rhs, z * rhs); } \
    ImVec3 operator/(const float rhs)               { return ImVec3(x / rhs, y / rhs, z / rhs); } \
    ImVec3 operator+(ImVec3& rhs)                   { return ImVec3(x + rhs.x, y + rhs.y, z + rhs.z); } \
    ImVec3 operator-(ImVec3& rhs)                   { return ImVec3(x - rhs.x, y - rhs.y, z - rhs.z); } \
    ImVec3 operator*(ImVec3& rhs)                   { return ImVec3(x * rhs.x, y * rhs.y, z * rhs.z); } \
    ImVec3 operator/(ImVec3& rhs)                   { return ImVec3(x / rhs.x, y / rhs.y, z / rhs.z); } \
    ImVec3& operator*=(const float rhs)             { x *= rhs; y *= rhs; z *= rhs; return *this; } \
    ImVec3& operator/=(const float rhs)             { x /= rhs; y /= rhs; z /= rhs; return *this; } \
    ImVec3& operator+=(const float rhs)             { x += rhs; y += rhs; z += rhs; return *this; } \
    ImVec3& operator-=(const float rhs)             { x -= rhs; y -= rhs; z -= rhs; return *this; } \
    ImVec3& operator+=(const ImVec3& rhs)           { x += rhs.x; y += rhs.y; z += rhs.z; return *this; } \
    ImVec3& operator-=(const ImVec3& rhs)           { x -= rhs.x; y -= rhs.y; z -= rhs.z; return *this; } \
    ImVec3& operator*=(const ImVec3& rhs)           { x *= rhs.x; y *= rhs.y; z *= rhs.z; return *this; } \
    ImVec3& operator/=(const ImVec3& rhs)           { x /= rhs.x; y /= rhs.y; z /= rhs.z; return *this; } \
    bool operator==(const ImVec3& d) const          { return fabs(x - d.x) < 10e-8 && fabs(y - d.y) < 10e-8 && fabs(z - d.z) < 10e-8; } \
    bool operator==(const ImVec3& d)                { return fabs(x - d.x) < 10e-8 && fabs(y - d.y) < 10e-8 && fabs(z - d.z) < 10e-8; } \
    bool operator!=(const ImVec3& d) const          { return fabs(x - d.x) > 10e-8 || fabs(y - d.y) > 10e-8 || fabs(z - d.z) > 10e-8; } \
    bool operator!=(const ImVec3& d)                { return fabs(x - d.x) > 10e-8 || fabs(y - d.y) > 10e-8 || fabs(z - d.z) > 10e-8; } \
    ImVec3 RotY() const                             { return ImVec3(-z, y, x); } \
    ImVec3 RotZ() const                             { return ImVec3(-y, x, z); } \
    ImVec3 Cross(const ImVec3& b) const             { return ImVec3(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x); } \
    float Dot(const ImVec3& b) const                { return x * b.x + y * b.y + z * b.z; } \
    ImVec3 Mult(float val) const                    { return ImVec3(x * val, y * val, z * val); } \
    ImVec3 Div(float val) const                     { return ImVec3(x / val, y / val, z / val); } \
    float Length() const                            { return (float)sqrt(x * x + y * y + z * z); } \
    ImVec3 Normalize()                              { (*this) *= (1.f / ( Length() > FLT_EPSILON ? Length() : FLT_EPSILON ) ); return (*this); } \
    ImVec2 Vec2()                                   { return ImVec2{x, y}; } \

#define IM_VEC4_CLASS_EXTRA \
    ImVec4 operator+(const float rhs)               { return ImVec4(x + rhs, y + rhs, z + rhs, w + rhs); } \
    ImVec4 operator-(const float rhs)               { return ImVec4(x - rhs, y - rhs, z - rhs, w - rhs); } \
    ImVec4 operator*(const float rhs)               { return ImVec4(x * rhs, y * rhs, z * rhs, w * rhs); } \
    ImVec4 operator/(const float rhs)               { return ImVec4(x / rhs, y / rhs, z / rhs, w / rhs); } \
    ImVec4 operator/(const ImVec4& rhs)             { return ImVec4(x / rhs.x, y / rhs.y, z / rhs.z, w / rhs.w); } \
    ImVec4& operator*=(const float rhs)             { x *= rhs; y *= rhs; z *= rhs; w *= rhs; return *this; } \
    ImVec4& operator/=(const float rhs)             { x /= rhs; y /= rhs; z /= rhs; w /= rhs; return *this; } \
    ImVec4& operator+=(const float rhs)             { x += rhs; y += rhs; z += rhs; w += rhs; return *this; } \
    ImVec4& operator-=(const float rhs)             { x -= rhs; y -= rhs; z -= rhs; w -= rhs; return *this; } \
    ImVec4& operator+=(const ImVec4& rhs)           { x += rhs.x; y += rhs.y; z += rhs.z; w += rhs.w; return *this; } \
    ImVec4& operator-=(const ImVec4& rhs)           { x -= rhs.x; y -= rhs.y; z -= rhs.z; w -= rhs.w; return *this; } \
    ImVec4& operator*=(const ImVec4& rhs)           { x *= rhs.x; y *= rhs.y; z *= rhs.z; w *= rhs.w; return *this; } \
    ImVec4& operator/=(const ImVec4& rhs)           { x /= rhs.x; y /= rhs.y; z /= rhs.z; w /= rhs.w; return *this; } \
    float& operator[](size_t index)                 { return ((float*)&x)[index]; } \
    const float& operator[](size_t index) const     { return ((float*)&x)[index]; } \
    ImVec3 rotate(const ImVec3& dir)                { \
        float ps = -x * dir.x - y * dir.y - z * dir.z; \
        float px = w * dir.x + y * dir.z - z * dir.y; \
        float py = w * dir.y + z * dir.x - x * dir.z; \
        float pz = w * dir.z + x * dir.y - y * dir.x; \
        return ImVec3(-ps * x + px * w - py * z + pz * y, -ps * y + py * w - pz * x + px * z, -ps * z + pz * w - px * y + py * x); } \
    ImVec4 mult(const ImVec4& d)                    { \
        ImVec4 out;                                        \
        out.x = w * d.x + x * d.w + y * d.z - z * d.y; \
        out.y = w * d.y + y * d.w + z * d.x - x * d.z; \
        out.z = w * d.z + z * d.w + x * d.y - y * d.x; \
        out.w = w * d.w - (x * d.x + y * d.y + z * d.z); \
        return out;} \
    void Cross(const ImVec4& v) \
    { \
        ImVec4 res; \
        res.x = y * v.z - z * v.y; \
        res.y = z * v.x - x * v.z; \
        res.z = x * v.y - y * v.x; \
        x = res.x; \
        y = res.y; \
        z = res.z; \
        w = 0.f; \
    } \
    void Cross(const ImVec4& v1, const ImVec4& v2) \
    { \
        x = v1.y * v2.z - v1.z * v2.y; \
        y = v1.z * v2.x - v1.x * v2.z; \
        z = v1.x * v2.y - v1.y * v2.x; \
        w = 0.f; \
    } \
    void Set(float v) { x = y = z = w = v; } \
    void Set(float _x, float _y, float _z = 0.f, float _w = 0.f) { x = _x; y = _y; z = _z; w = _w; } \
    void Lerp(const ImVec4& v, float t) { x += (v.x - x) * t; y += (v.y - y) * t; z += (v.z - z) * t; w += (v.w - w) * t; } \
    float Length() const { return sqrtf(x * x + y * y + z * z); }; \
    float LengthSq() const { return (x * x + y * y + z * z); }; \
    ImVec4 Normalize() { (*this) *= (1.f / ( Length() > FLT_EPSILON ? Length() : FLT_EPSILON ) ); return (*this); } \
    ImVec4 Normalize(const ImVec4& v) { x = v.x; y = v.y; z = v.z; w = v.w; this->Normalize(); return (*this); } \
    ImVec4 Abs() const { return ImVec4(fabsf(x), fabsf(y), fabsf(z)); } \
    float Dot(const ImVec4& v) const { return (x * v.x) + (y * v.y) + (z * v.z) + (w * v.w); } \
    float Dot3(const ImVec4& v) const { return (x * v.x) + (y * v.y) + (z * v.z); } \
    void Transform(const ImVec4& s, const ImMat4x4& matrix) { *this = s; Transform(matrix); } \
    void TransformVector(const ImVec4& v, const ImMat4x4& matrix) { (*this) = v; this->TransformVector(matrix); } \
    void TransformPoint(const ImVec4& v, const ImMat4x4& matrix) { (*this) = v; this->TransformPoint(matrix); } \
    void TransformVector(const ImMat4x4& matrix); \
    void TransformPoint(const ImMat4x4& matrix); \
    void Transform(const ImMat4x4& matrix); \

#define IMGUI_DEFINE_MATH_OPERATORS

#define IMGUI_DEFINE_MATH_EXTRA \
    static inline ImVec3 operator+(const ImVec3& lhs, const float rhs)      { return ImVec3(lhs.x + rhs, lhs.y + rhs, lhs.z + rhs); } \
    static inline ImVec3 operator-(const ImVec3& lhs, const float rhs)      { return ImVec3(lhs.x - rhs, lhs.y - rhs, lhs.z - rhs); } \
    static inline ImVec3 operator*(const ImVec3& lhs, const float rhs)      { return ImVec3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs); } \
    static inline ImVec3 operator/(const ImVec3& lhs, const float rhs)      { return ImVec3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs); } \
    static inline ImVec3 operator+(const ImVec3& lhs, const ImVec3& rhs)    { return ImVec3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z); } \
    static inline ImVec3 operator-(const ImVec3& lhs, const ImVec3& rhs)    { return ImVec3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z); } \
    static inline ImVec3 operator*(const ImVec3& lhs, const ImVec3& rhs)    { return ImVec3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z); } \
    static inline ImVec3 operator/(const ImVec3& lhs, const ImVec3& rhs)    { return ImVec3(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z); } \
    static inline ImVec4 operator-(ImVec4 v)                                { return { -v.x, -v.y, -v.z, -v.w }; } \
    static inline ImVec4 operator+(const ImVec4& lhs, const float rhs)      { return ImVec4(lhs.x + rhs, lhs.y + rhs, lhs.z + rhs, lhs.w + rhs); } \
    static inline ImVec4 operator-(const ImVec4& lhs, const float rhs)      { return ImVec4(lhs.x - rhs, lhs.y - rhs, lhs.z - rhs, lhs.w - rhs); } \
    static inline ImVec4 operator*(const ImVec4& lhs, const float rhs)      { return ImVec4(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs, lhs.w * rhs); } \
    static inline ImVec4 operator/(const ImVec4& lhs, const float rhs)      { return ImVec4(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs, lhs.w / rhs); } \
