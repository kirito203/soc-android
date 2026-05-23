function(target_sources_grouped)
    set(TARGET_NAME ${ARGV0})
    list(REMOVE_AT ARGV 0)

    if(TARGET ${TARGET_NAME})
        target_sources(${TARGET_NAME} PRIVATE ${ARGV})
    endif()
endfunction()
