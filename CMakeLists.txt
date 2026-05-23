cmake_minimum_required(VERSION 3.15)

# 1. Настройки Android-окружения
set(ANDROID_ABI "arm64-v8a" CACHE STRING "" FORCE)
set(ANDROID_PLATFORM "android-29" CACHE STRING "" FORCE)
set(ANDROID ON CACHE BOOL "" FORCE)
set(CMAKE_SYSTEM_NAME Android CACHE STRING "" FORCE)

project(XRayEngine)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

message(STATUS "=== СБОРКА OPENXRAY ПОД ANDROID ARM64 ===")

# 2. УНИВЕРСАЛЬНАЯ И НЕУБИВАЕМАЯ ФУНКЦИЯ ДЛЯ РЕСУРСОВ
function(target_sources_grouped)
    list(GET ARGV 0 FIRST_ARG)
    if(FIRST_ARG STREQUAL "TARGET")
        list(GET ARGV 1 ACTUAL_TARGET)
    else()
        set(ACTUAL_TARGET "${FIRST_ARG}")
    endif()

    set(CLEAN_FILES "")
    foreach(ITEM IN LISTS ARGV)
        if(ITEM MATCHES "\\.(cpp|h|hpp|c|cc|cxx|inline|inl|s|S)$")
            string(REPLACE "\\" "/" SAFE_ITEM "${ITEM}")
            list(APPEND CLEAN_FILES "${SAFE_ITEM}")
        endif()
    endforeach()

    if(CLEAN_FILES)
        target_sources(${ACTUAL_TARGET} PRIVATE ${CLEAN_FILES})
    endif()
endfunction()

# 3. Конфигурация движка (выключаем ПК-рендеры, включаем мобильный OpenGL)
set(XRAY_USE_DX9 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_DX10 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_DX11 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_SDL ON CACHE BOOL "" FORCE)
set(XRAY_USE_GL ON CACHE BOOL "" FORCE)

# Берем внутренний LuaJIT из папки Externals
set(XRAY_USE_LUAJIT ON CACHE BOOL "" FORCE)

# Отключаем тесты и SDK-инструменты ПК
set(XRAY_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(XRAY_BUILD_TOOLS OFF CACHE BOOL "" FORCE)

# Глобальные дефайны компилятора для Android
add_compile_definitions(ANDROID __ANDROID__ _GAPI_GL3_ DISABLE_XRAY_RESOURCES)

# 4. ЗАГЛУШКИ ДЛЯ ВНЕШНИХ ANDROID-ЗАВИСИМОСТЕЙ
# Оживляем цели, чтобы CMake успешно прошел этап генерации дерева проектов

# Системные и аудио подсистемы
add_library(OpenAL::OpenAL INTERFACE IMPORTED)
add_library(SDL2::SDL2 INTERFACE IMPORTED)

# Архивация и сжатие данных (xrCore)
add_library(LZO::LZO INTERFACE IMPORTED)

# Аудио-контейнеры и кодеки (xrSound / xrEngine)
add_library(Ogg::Ogg INTERFACE IMPORTED)
add_library(Vorbis::Vorbis INTERFACE IMPORTED)

# ИСПРАВЛЕНО: Строго соблюдаем регистр (VorbisFile и VorbisEnc)
add_library(Vorbis::VorbisFile INTERFACE IMPORTED)
add_library(Vorbis::VorbisEnc INTERFACE IMPORTED)

# Видео-декодеры для игровых синематиков
add_library(Theora::Theora INTERFACE IMPORTED)
add_library(Theora::Theoradec INTERFACE IMPORTED)

# 5. Запуск генерации подпроектов
add_subdirectory(Externals)
add_subdirectory(src)