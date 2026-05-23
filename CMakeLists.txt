cmake_minimum_required(VERSION 3.15)

# Принудительно задаем Android до инициализации проекта
set(ANDROID_ABI "arm64-v8a" CACHE STRING "" FORCE)
set(ANDROID_PLATFORM "android-29" CACHE STRING "" FORCE)
set(ANDROID ON CACHE BOOL "" FORCE)

project(XRayEngine)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

message(STATUS "=== СБОРКА OPENXRAY ПОД ANDROID ARM64 ===")

# Отключаем десктопные графические API и модули
set(XRAY_USE_DX9 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_DX10 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_DX11 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_SDL ON CACHE BOOL "" FORCE)
set(XRAY_USE_GL ON CACHE BOOL "" FORCE)

# Берем внутренний LuaJIT из папки Externals
set(XRAY_USE_LUAJIT ON CACHE BOOL "" FORCE)

# Отключаем тесты и утилиты ПК
set(XRAY_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(XRAY_BUILD_TOOLS OFF CACHE BOOL "" FORCE)

# Глобальные дефайны для совместимости мобильного кода
add_compile_definitions(ANDROID __ANDROID__ _GAPI_GL3_ DISABLE_XRAY_RESOURCES)

# ПОДКУСЫВАЕМ РОДНЫЕ НАСТРОЙКИ ФУНКЦИЙ ДВИЖКА
# Вместо одного файла подключаем главный скрипт настроек, он сам найдет макросы группировки
include(CMake/XRay.Setup.cmake)

# Запускаем сборку зависимостей и исходников
add_subdirectory(Externals)
add_subdirectory(src)