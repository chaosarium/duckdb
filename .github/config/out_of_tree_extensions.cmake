#
# This config file holds all out-of-tree extension that are built with DuckDB's CI
#
# to build duckdb with this configuration run:
#   EXTENSION_CONFIGS=.github/config/out_of_tree_extensions.cmake make
#
#  Note that many of these packages require vcpkg, and a merged manifest must be created to
#  compile multiple of them.
#
#  After setting up vcpkg, build using e.g. the following commands:
#  USE_MERGED_VCPKG_MANIFEST=1 BUILD_ALL_EXT=1 make extension_configuration
#  USE_MERGED_VCPKG_MANIFEST=1 BUILD_ALL_EXT=1 make debug
#
#  Make sure the VCPKG_TOOLCHAIN_PATH and VCPKG_TARGET_TRIPLET are set. For example:
#  VCPKG_TOOLCHAIN_PATH=~/vcpkg/scripts/buildsystems/vcpkg.cmake
#  VCPKG_TARGET_TRIPLET=arm64-osx

################# HTTPFS
# Warning: the patching mechanism on windows doesn't work for httpfs somehow.
# To patch httpfs:
#  - add patch file, enable APPLY_PATCHES
#  - disable windows build of httpfs by wrapping in `if (NOT WIN32)`
#  - IMPORTANT: add a comment that tells people to restore the windows build when removing the patches
duckdb_extension_load(httpfs
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-httpfs
    GIT_TAG 85ac4667bcb0d868199e156f8dd918b0278db7b9
    INCLUDE_DIR extension/httpfs/include
    )

################## AWS
if (NOT MINGW AND NOT ${WASM_ENABLED})
    duckdb_extension_load(aws
            LOAD_TESTS
            GIT_URL https://github.com/duckdb/duckdb-aws
            GIT_TAG b3050f35c6e99fa35465230493eeab14a78a0409
            APPLY_PATCHES
            )
endif()

################# AZURE
if (NOT MINGW AND NOT ${WASM_ENABLED})
    duckdb_extension_load(azure
            LOAD_TESTS
            GIT_URL https://github.com/duckdb/duckdb-azure
            GIT_TAG e707cf361d76358743969cddf3acf97cfc87677b
            )
endif()

################# DELTA
# MinGW build is not available, and our current manylinux ci does not have enough storage space to run the rust build
# for Delta
if (FALSE)
if (NOT MINGW AND NOT "${OS_NAME}" STREQUAL "linux" AND NOT ${WASM_ENABLED})
    duckdb_extension_load(delta
            GIT_URL https://github.com/duckdb/duckdb-delta
            GIT_TAG 6d626173e9efa6615c25eb08d979d1372100d5db
            APPLY_PATCHES
    )
endif()
endif()

################# EXCEL
duckdb_extension_load(excel
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-excel
    GIT_TAG f14e7c3beaf379c54b47b996aa896a1d814e1be8
    INCLUDE_DIR src/excel/include
    )

################# ICEBERG
# Windows tests for iceberg currently not working
if(FALSE)
if (NOT WIN32)
    set(LOAD_ICEBERG_TESTS "LOAD_TESTS")
else ()
    set(LOAD_ICEBERG_TESTS "")
endif()

if (NOT MINGW AND NOT ${WASM_ENABLED} AND NOT ${MUSL_ENABLED})
    duckdb_extension_load(iceberg
#            ${LOAD_ICEBERG_TESTS} TODO: re-enable once autoloading test is fixed
            GIT_URL https://github.com/duckdb/duckdb-iceberg
            GIT_TAG 43b4e37f6e859d6c1c67b787ac511659e9e0b6fb
            )
endif()
endif()

################# INET
duckdb_extension_load(inet
    LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-inet
    GIT_TAG a8b361ab5d43f6390d7cb48c9a9f0638e9581cf9
    INCLUDE_DIR src/include
    TEST_DIR test/sql
    APPLY_PATCHES
    )

################# POSTGRES_SCANNER
# Note: tests for postgres_scanner are currently not run. All of them need a postgres server running. One test
#       uses a remote rds server but that's not something we want to run here.
if (NOT MINGW AND NOT ${WASM_ENABLED})
    duckdb_extension_load(postgres_scanner
            DONT_LINK
            GIT_URL https://github.com/duckdb/duckdb-postgres
            GIT_TAG 8461ed8b6f726564934e9c831cdc88d431e3148f
            APPLY_PATCHES
            )
endif()

# mingw CI with all extensions at once is somehow not happy
if (NOT MINGW)
################# SPATIAL
duckdb_extension_load(spatial
    DONT_LINK LOAD_TESTS
    GIT_URL https://github.com/duckdb/duckdb-spatial
    GIT_TAG 2905968a85703e5ca3698976daafd759554e1744
    INCLUDE_DIR spatial/include
    TEST_DIR test/sql
    APPLY_PATCHES
    )
endif()

################# SQLITE_SCANNER
# Static linking on windows does not properly work due to symbol collision
if (WIN32)
    set(STATIC_LINK_SQLITE "DONT_LINK")
else ()
    set(STATIC_LINK_SQLITE "")
endif()

duckdb_extension_load(sqlite_scanner
        ${STATIC_LINK_SQLITE} LOAD_TESTS
        GIT_URL https://github.com/duckdb/duckdb-sqlite
        GIT_TAG 96e451c043afa40ee39b7581009ba0c72a523a12
        APPLY_PATCHES
        )

duckdb_extension_load(sqlsmith
        DONT_LINK LOAD_TESTS
        GIT_URL https://github.com/duckdb/duckdb-sqlsmith
        GIT_TAG e1eb0ae02a258f176d6e06b84c0d6c7a09c6b4da
        )

################# VSS
duckdb_extension_load(vss
        LOAD_TESTS
        DONT_LINK
        GIT_URL https://github.com/duckdb/duckdb-vss
        GIT_TAG 580e8918eb89f478cf2d233ca908ffbd3ec752c5
        TEST_DIR test/sql
        APPLY_PATCHES
    )

################# MYSQL
if (NOT MINGW AND NOT ${WASM_ENABLED} AND NOT ${MUSL_ENABLED})
    duckdb_extension_load(mysql_scanner
            DONT_LINK
            LOAD_TESTS
            GIT_URL https://github.com/duckdb/duckdb-mysql
            GIT_TAG c2a56813a9fe9cb8c24c424be646d41ab2f8e64f
            APPLY_PATCHES
            )
endif()

################# FTS
duckdb_extension_load(fts
        LOAD_TESTS
        DONT_LINK
        GIT_URL https://github.com/duckdb/duckdb-fts
        GIT_TAG 3aa6a180b9c101d78070f5f7214c27552bb091c8
        TEST_DIR test/sql
)
