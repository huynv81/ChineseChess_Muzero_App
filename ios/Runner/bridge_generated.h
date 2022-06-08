#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct WireSyncReturnStruct {
  uint8_t *ptr;
  int32_t len;
  bool success;
} WireSyncReturnStruct;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

void wire_platform(int64_t port_);

void wire_rust_release_mode(int64_t port_);

void wire_is_legal_move(int64_t port_,
                        uintptr_t src_row,
                        uintptr_t src_col,
                        uintptr_t dst_row,
                        uintptr_t dst_col);

void wire_update_board_data(int64_t port_, uintptr_t row, uintptr_t col, uintptr_t piece_index);

void wire_update_player_data(int64_t port_, struct wire_uint_8_list *player);

struct wire_uint_8_list *new_uint_8_list(int32_t len);

void free_WireSyncReturnStruct(struct WireSyncReturnStruct val);

void store_dart_post_cobject(DartPostCObjectFnType ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_platform);
    dummy_var ^= ((int64_t) (void*) wire_rust_release_mode);
    dummy_var ^= ((int64_t) (void*) wire_is_legal_move);
    dummy_var ^= ((int64_t) (void*) wire_update_board_data);
    dummy_var ^= ((int64_t) (void*) wire_update_player_data);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturnStruct);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}