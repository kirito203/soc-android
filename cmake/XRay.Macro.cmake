macro(target_sources_grouped TARGET)
    # Защищаем парсер от раскрытия символов \C на Windows.
    # Превращаем аргументы в чистую строку, экранируя кавычки.
    string(CONFIGURE "${ARGN}" SAFE_ARGS ESCAPE_QUOTES)
    
    # Заменяем виндовые бэкслеши на нормальные слэши прямо в тексте
    string(REPLACE "\\" "/" SAFE_ARGS "${SAFE_ARGS}")
    
    # Вырезаем блоки группировки Visual Studio (NAME ... FILES)
    string(REGEX REPLACE "NAME;[^;]+;FILES;" "" CLEAN_FILES "${SAFE_ARGS}")
    string(REGEX REPLACE "NAME;[^;]+" "" CLEAN_FILES "${CLEAN_FILES}")
    string(REPLACE "FILES;" "" CLEAN_FILES "${CLEAN_FILES}")

    # Скармливаем чистые файлы компилятору
    if(CLEAN_FILES)
        target_sources(${TARGET} PRIVATE ${CLEAN_FILES})
    endif()
endmacro()
