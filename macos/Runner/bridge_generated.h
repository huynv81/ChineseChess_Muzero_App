#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct WireSyncReturnStruct {
  uint8_t *ptr;
  int32_t len;
  bool success;
} WireSyncReturnStruct;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

void wire_platform(int64_t port_);

void wire_rust_release_mode(int64_t port_);

void wire_add_2_unsigned_value(int64_t port_, uint32_t v1, uint32_t v2);

void free_WireSyncReturnStruct(struct WireSyncReturnStruct val);

void store_dart_post_cobject(DartPostCObjectFnType ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_platform);
    dummy_var ^= ((int64_t) (void*) wire_rust_release_mode);
    dummy_var ^= ((int64_t) (void*) wire_add_2_unsigned_value);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturnStruct);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}