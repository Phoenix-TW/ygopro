-- default global settings

BUILD_LUA = true
BUILD_EVENT = os.istarget("windows")
BUILD_FREETYPE = os.istarget("windows")
BUILD_SQLITE = os.istarget("windows")
BUILD_IRRLICHT = not os.istarget("macosx")
USE_IRRKLANG = true
IRRKLANG_PRO = false
LUA_LIB_NAME = "lua"

-- read settings from command line or environment variables

newoption { trigger = "build-lua", category = "YGOPro - lua", description = "" }
newoption { trigger = "no-build-lua", category = "YGOPro - lua", description = "" }
newoption { trigger = "lua-include-dir", category = "YGOPro - lua", description = "", value = "PATH" }
newoption { trigger = "lua-lib-dir", category = "YGOPro - lua", description = "", value = "PATH" }
newoption { trigger = "lua-lib-name", category = "YGOPro - lua", description = "", value = "NAME", default = "lua" }
newoption { trigger = "lua-deb", category = "YGOPro - lua", description = "" }

newoption { trigger = "build-event", category = "YGOPro - event", description = "" }
newoption { trigger = "no-build-event", category = "YGOPro - event", description = "" }
newoption { trigger = "event-include-dir", category = "YGOPro - event", description = "", value = "PATH" }
newoption { trigger = "event-lib-dir", category = "YGOPro - event", description = "", value = "PATH" }

newoption { trigger = "build-freetype", category = "YGOPro - freetype", description = "" }
newoption { trigger = "no-build-freetype", category = "YGOPro - freetype", description = "" }
newoption { trigger = "freetype-include-dir", category = "YGOPro - freetype", description = "", value = "PATH" }
newoption { trigger = "freetype-lib-dir", category = "YGOPro - freetype", description = "", value = "PATH" }

newoption { trigger = "build-sqlite", category = "YGOPro - sqlite", description = "" }
newoption { trigger = "no-build-sqlite", category = "YGOPro - sqlite", description = "" }
newoption { trigger = "sqlite-include-dir", category = "YGOPro - sqlite", description = "", value = "PATH" }
newoption { trigger = "sqlite-lib-dir", category = "YGOPro - sqlite", description = "", value = "PATH" }

newoption { trigger = "build-irrlicht", category = "YGOPro - irrlicht", description = "" }
newoption { trigger = "no-build-irrlicht", category = "YGOPro - irrlicht", description = "" }
newoption { trigger = "irrlicht-include-dir", category = "YGOPro - irrlicht", description = "", value = "PATH" }
newoption { trigger = "irrlicht-lib-dir", category = "YGOPro - irrlicht", description = "", value = "PATH" }

newoption { trigger = "use-irrklang", category = "YGOPro - irrklang", description = "" }
newoption { trigger = "no-use-irrklang", category = "YGOPro - irrklang", description = "" }
newoption { trigger = "irrklang-include-dir", category = "YGOPro - irrklang", description = "", value = "PATH" }
newoption { trigger = "irrklang-lib-dir", category = "YGOPro - irrklang", description = "", value = "PATH" }

newoption { trigger = "irrklang-pro", category = "YGOPro - irrklang - pro", description = "" }
newoption { trigger = "no-irrklang-pro", category = "YGOPro - irrklang - pro", description = "" }
newoption { trigger = "irrklang-pro-release-lib-dir", category = "YGOPro - irrklang - pro", description = "", value = "PATH" }
newoption { trigger = "irrklang-pro-debug-lib-dir", category = "YGOPro - irrklang - pro", description = "", value = "PATH" }
newoption { trigger = 'build-ikpmp3', category = "YGOPro - irrklang - ikpmp3", description = "" }

newoption { trigger = "winxp-support", category = "YGOPro", description = "" }
newoption { trigger = "mac-arm", category = "YGOPro", description = "M1" }

-- koishipro specific

boolOptions = {
    "compat-mycard",
    "no-lua-safe",
    "message-debug",
    "default-duel-rule",
    "no-side-check",
}

for _, boolOption in ipairs(boolOptions) do
    newoption { trigger = boolOption, category = "YGOPro - Koishi", description = "" }
end

numberOptions = {
    "default-rule",
    "max-deck",
    "min-deck",
    "max-extra",
    "max-side",
}

for _, numberOption in ipairs(numberOptions) do
    newoption { trigger = numberOption, category = "YGOPro - Koishi", description = "", value = "NUMBER" }
end

function GetParam(param)
    return _OPTIONS[param] or os.getenv(string.upper(string.gsub(param,"-","_")))
end

function ApplyBoolean(param)
    if GetParam(param) then
        defines { "YGOPRO_" .. string.upper(string.gsub(param,"-","_")) }
    end
end

function ApplyNumber(param)
    local value = GetParam(param)
    if not value then return end
    local numberValue = tonumber(value)
    if numberValue then
        defines { "YGOPRO_" .. string.upper(string.gsub(param,"-","_")) .. "=" .. numberValue }
    end
end

BUILD_LUA = false
if not BUILD_LUA then
    -- at most times you need to change this if you change BUILD_LUA to false
    -- make sure your lua lib is built with C++ and version >= 5.3
    LUA_INCLUDE_DIR = GetParam("lua-include-dir") or "/usr/include/lua5.3"
    LUA_LIB_DIR = GetParam("lua-lib-dir") or "/usr/lib/x86_64-linux-gnu"
    LUA_LIB_NAME = "lua"
end

if GetParam("lua-deb") then
    BUILD_LUA = false
    LUA_LIB_DIR = "/usr/lib/x86_64-linux-gnu"
    LUA_LIB_NAME = "lua5.3-c++"
    LUA_INCLUDE_DIR = "/usr/include/lua5.3"
end

if GetParam("build-event") then
    BUILD_EVENT = os.istarget("windows") -- only on windows for now
elseif GetParam("no-build-event") then
    BUILD_EVENT = false
end
if not BUILD_EVENT then
    EVENT_INCLUDE_DIR = GetParam("event-include-dir") or "/usr/local/include/event2"
    EVENT_LIB_DIR = GetParam("event-lib-dir") or "/usr/local/lib"
end

if GetParam("build-freetype") then
    BUILD_FREETYPE = true
elseif GetParam("no-build-freetype") then
    BUILD_FREETYPE = false
end
if not BUILD_FREETYPE then
    if os.istarget("linux") then
        FREETYPE_INCLUDE_DIR = "/usr/include/freetype2"
    elseif os.istarget("macosx") then
        FREETYPE_INCLUDE_DIR = "/usr/local/include/freetype2"
    end
    FREETYPE_INCLUDE_DIR = GetParam("freetype-include-dir") or FREETYPE_INCLUDE_DIR
    FREETYPE_LIB_DIR = GetParam("freetype-lib-dir") or "/usr/local/lib"
end

if GetParam("build-sqlite") then
    BUILD_SQLITE = true
elseif GetParam("no-build-sqlite") then
    BUILD_SQLITE = false
end
if not BUILD_SQLITE then
    SQLITE_INCLUDE_DIR = GetParam("sqlite-include-dir") or "/usr/local/include"
    SQLITE_LIB_DIR = GetParam("sqlite-lib-dir") or "/usr/local/lib"
end


BUILD_IRRLICHT = false
if not BUILD_IRRLICHT then
    IRRLICHT_INCLUDE_DIR = GetParam("irrlicht-include-dir") or "../3rdParty/irrlicht_1.8/include"
    IRRLICHT_LIB_DIR = GetParam("irrlicht-lib-dir") or "../3rdParty/irrlicht_1.8/lib/Linux"
end

if GetParam("use-irrklang") then
    USE_IRRKLANG = true
elseif GetParam("no-use-irrklang") then
    USE_IRRKLANG = false
end
if USE_IRRKLANG then
    IRRKLANG_INCLUDE_DIR = GetParam("irrklang-include-dir") or "../3rdParty/irrKlang-64bit-1.6.0/include"
    IRRKLANG_LIB_DIR = "../3rdParty/irrKlang-64bit-1.6.0/bin/linux-gcc-64"
    IRRKLANG_LINK_RPATH = "-Wl,-rpath=../3rdParty/irrKlang-64bit-1.6.0/bin/linux-gcc-64"
end

if GetParam("irrklang-pro") and os.istarget("windows") then
    IRRKLANG_PRO = true
elseif GetParam("no-irrklang-pro") then
    IRRKLANG_PRO = false
end
if IRRKLANG_PRO then
    -- irrklang pro can't use the pro lib to debug
    IRRKLANG_PRO_RELEASE_LIB_DIR = GetParam("irrklang-pro-release-lib-dir") or "../irrklang/lib/Win32-vs2019"
    IRRKLANG_PRO_DEBUG_LIB_DIR = GetParam("irrklang-pro-debug-lib-dir") or "../irrklang/lib/Win32-visualStudio-debug"  
end

BUILD_IKPMP3 = USE_IRRKLANG

if GetParam("winxp-support") and os.istarget("windows") then
    WINXP_SUPPORT = true
end
if os.istarget("macosx") then
    MAC_ARM = false
    if GetParam("mac-arm") then
        MAC_ARM = true
    end
end

workspace "YGOPro"
    location "build"
    language "C++"
    objdir "obj"    

    configurations { "Release", "Debug" }


    for _, numberOption in ipairs(numberOptions) do
        ApplyNumber(numberOption)
    end

    for _, boolOption in ipairs(boolOptions) do
        ApplyBoolean(boolOption)
    end


    filter "system:windows"
        defines { "WIN32", "_WIN32" }
        entrypoint "mainCRTStartup"
        systemversion "latest"
        startproject "YGOPro"
        if WINXP_SUPPORT then
            defines { "WINVER=0x0501" }
            toolset "v141_xp"
        else
            defines { "WINVER=0x0601" } -- WIN7
        end

    filter "system:macosx"
        libdirs { "/usr/local/lib" }
        buildoptions { "-stdlib=libc++" }
        if MAC_ARM then
            buildoptions { "--target=arm64-apple-macos12" }
        end
        links { "OpenGL.framework", "Cocoa.framework", "IOKit.framework" }

    filter "system:linux"
        buildoptions { "-U_FORTIFY_SOURCE" }

    filter "configurations:Release"
        optimize "Speed"
        targetdir "bin/release"

    filter "configurations:Debug"
        symbols "On"
        defines "_DEBUG"
        targetdir "bin/debug"

    filter { "configurations:Release", "action:vs*" }
        flags { "LinkTimeOptimization" }
        staticruntime "On"
        disablewarnings { "4244", "4267", "4838", "4577", "4819", "4018", "4996", "4477", "4091", "4828", "4800", "6011", "6031", "6054", "6262" }

    filter { "configurations:Release", "not action:vs*" }
        symbols "On"
        defines "NDEBUG"
        if not MAC_ARM then
            buildoptions "-march=native"
        end

    filter { "configurations:Debug", "action:vs*" }
        disablewarnings { "4819", "4828", "6011", "6031", "6054", "6262" }

    filter "action:vs*"
        vectorextensions "SSE2"
        buildoptions { "/utf-8" }
        defines { "_CRT_SECURE_NO_WARNINGS" }
    
    filter "not action:vs*"
        buildoptions { "-fno-strict-aliasing", "-Wno-multichar", "-Wno-format-security" }

    filter {}

    include "ocgcore"
    include "gframe"
    if BUILD_LUA then
        include "lua"
    end
    if BUILD_EVENT then
        include "event"
    end
    if BUILD_FREETYPE then
        include "freetype"
    end
    if BUILD_IRRLICHT then
        include "irrlicht"
    end
    if BUILD_SQLITE then
        include "sqlite3"
    end
    if BUILD_IKPMP3 then
        include "ikpmp3"
    end
