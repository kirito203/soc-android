cmake_minimum_required(VERSION 3.15)

# Принудительно задаем Android до инициализации проекта
# 1. Жестко настраиваем Android-окружение до инициализации проекта
set(ANDROID_ABI "arm64-v8a" CACHE STRING "" FORCE)
set(ANDROID_PLATFORM "android-29" CACHE STRING "" FORCE)
set(ANDROID ON CACHE BOOL "" FORCE)
set(CMAKE_SYSTEM_NAME Android CACHE STRING "" FORCE)

project(XRayEngine)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

message(STATUS "=== СБОРКА OPENXRAY ПОД ANDROID ARM64 ===")

# Отключаем десктопные графические API и модули
# 2. УЛЬТИМАТИВНЫЙ ХАК ДЛЯ ОБХОДА СИНТАКСИСА СЛЭШЕЙ
# Создаем глобальный переключатель, чтобы знать, какой таргет сейчас собирается
set(CURRENT_XRAY_TARGET "")

macro(add_library TARGET)
    set(CURRENT_XRAY_TARGET ${TARGET})
    _add_library(${TARGET} ${ARGN})
endmacro()

macro(add_executable TARGET)
    set(CURRENT_XRAY_TARGET ${TARGET})
    _add_executable(${TARGET} ${ARGN})
endmacro()

# Переопределяем оригинальный макрос движка. 
# Теперь он берет аргументы НЕ через переменные (что вызывало ошибку \C),
# а парсит встроенное системное свойство текущей запущенной команды!
function(target_sources_grouped TARGET)
    # Нам больше не нужно читать ${ARGN}. Мы просто берем имя текущего таргета,
    # который был объявлен в add_library выше.
    if(CURRENT_XRAY_TARGET)
        # Собираем аргументы в текстовый блок, экранируя опасные символы
        string(CONFIGURE "${ARGN}" SAFE_ARGS ESCAPE_QUOTES)
        
        # Вырезаем регуляркой всё, что связано с виндовыми фильтрами NAME ... FILES
        string(REGEX REPLACE "NAME;[^;]+;FILES;" "" CLEAN_FILES "${SAFE_ARGS}")
        string(REGEX REPLACE "NAME;[^;]+" "" CLEAN_FILES "${CLEAN_FILES}")
        string(REPLACE "FILES;" "" CLEAN_FILES "${CLEAN_FILES}")
        
        # Если после чистки остались файлы, скармливаем их компилятору
        if(CLEAN_FILES)
            target_sources(${CURRENT_XRAY_TARGET} PRIVATE ${CLEAN_FILES})
        endif()
    endif()
endfunction()

# 3. Отключаем десктопную графику ПК и включаем мобильный OpenGL
set(XRAY_USE_DX9 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_DX10 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_DX11 OFF CACHE BOOL "" FORCE)
set(XRAY_USE_SDL ON CACHE BOOL "" FORCE)
set(XRAY_USE_GL ON CACHE BOOL "" FORCE)

# Берем внутренний LuaJIT из папки Externals
set(XRAY_USE_LUAJIT ON CACHE BOOL "" FORCE)

# Отключаем тесты и утилиты ПК
# Отключаем тесты и утилиты SDK
set(XRAY_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(XRAY_BUILD_TOOLS OFF CACHE BOOL "" FORCE)

# Глобальные дефайны для совместимости мобильного кода
# Глобальные дефайны для совместимости мобильного кода C++
add_compile_definitions(ANDROID __ANDROID__ _GAPI_GL3_ DISABLE_XRAY_RESOURCES)

# ПОДКУСЫВАЕМ РОДНЫЕ НАСТРОЙКИ ФУНКЦИЙ ДВИЖКА
# Вместо одного файла подключаем главный скрипт настроек, он сам найдет макросы группировки
include(${PROJECT_SOURCE_DIR}/cmake/XRay.Macro.cmake)

# Запускаем сборку зависимостей и исходников
# 4. Запускаем сборку зависимостей и исходников
add_subdirectory(Externals)
add_subdirectory(src)

