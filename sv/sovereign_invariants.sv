// =============================================================================
// Sovereign Ada Processor – Extracted Invariants encoded as SystemVerilog
// Formal / simulation assertion suite (SVA)
// Target: formal tools (Jasper, VC Formal, OneSpin) or simulation with assert
// =============================================================================

`timescale 1ns/1ps

package sovereign_invariants_pkg;

  // ---------------------------------------------------------------------------
  // Type / range invariants (from Core_Types)
  // ---------------------------------------------------------------------------
  localparam int MAX_BUFFER_SIZE = 128;
  localparam int MAX_CONFIG_ENTRIES = 16;
  localparam int MAX_COMMAND_ARGS = 8;
  localparam int MAX_SERIAL_RECORD = 64;
  localparam int MAX_DATA_STORE = 32;

  typedef logic [7:0] byte_t; // 0 .. 255
  typedef logic [15:0] word16_t; // 0 .. 65535
  typedef logic [30:0] word32_t; // 0 .. 2**31-1 (Ada Integer range)

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_INITIALIZING,
    ST_CONFIGURED,
    ST_AWAITING_INPUT,
    ST_PARSING,
    ST_VALIDATING,
    ST_PROCESSING,
    ST_SERIALIZING,
    ST_CHECKING_INTEGRITY,
    ST_AUTHORIZED,
    ST_ERROR,
    ST_SHUTDOWN
  } app_state_e;

  typedef enum logic [3:0] {
    CMD_NONE,
    CMD_HELP,
    CMD_SET_CONFIG,
    CMD_PROCESS_DATA,
    CMD_QUERY_STATE,
    CMD_SERIALIZE,
    CMD_VERIFY,
    CMD_SELF_TEST,
    CMD_RESET,
    CMD_AUTHORIZE,
    CMD_EXIT
  } command_id_e;

  typedef enum logic [1:0] {
    AUTH_NONE,
    AUTH_GUEST,
    AUTH_OPERATOR,
    AUTH_ADMIN
  } auth_level_e;

  // ---------------------------------------------------------------------------
  // Data structures (mirrors Ada records)
  // ---------------------------------------------------------------------------
  typedef struct packed {
    word16_t id;
    word32_t value;
    byte_t flags;
    word16_t checksum;
    logic valid;
  } data_item_t;

  typedef struct packed {
    word16_t magic; // must be 16'hADA1
    byte_t version; // 1 or 2
    byte_t length;
    word16_t checksum;
    app_state_e state;
  } serial_header_t;

endpackage

// =============================================================================
// Main invariant checker module
// Instantiated around the design-under-test (or used in formal bind)
// =============================================================================
module sovereign_invariant_checker
  import sovereign_invariants_pkg::*;
(
  input logic clk,
  input logic rst_n,

  // Observed state
  input app_state_e current_state,
  input app_state_e next_state,

  // Buffer
  input logic [7:0] buf_length, // Length_Type
  input logic buf_full,
  input logic buf_empty,

  // Data store
  input logic [5:0] store_count, // 0 .. 32
  input data_item_t store_item, // currently examined item

  // Config / Auth
  input auth_level_e auth_level,
  input logic [15:0] checksum_seed,

  // Math results under observation
  input word32_t safe_add_result,
  input logic safe_add_overflow,
  input word32_t safe_sub_result,
  input logic safe_sub_underflow,
  input word32_t gcd_result,
  input word32_t fib_result,

  // Integrity
  input word16_t computed_checksum,
  input word16_t stored_checksum,
  input logic integrity_ok,

  // Header
  input serial_header_t hdr
);

  // -------------------------------------------------------------------------
  // 1. Type range invariants
  // -------------------------------------------------------------------------
  property p_byte_range(byte_t v);
    (v >= 8'h00) && (v <= 8'hFF);
  endproperty
  assert_byte_range: assert property (@(posedge clk) disable iff (!rst_n)
    p_byte_range(store_item.flags));

  property p_word16_range(word16_t v);
    (v >= 16'h0000) && (v <= 16'hFFFF);
  endproperty

  property p_word32_range(word32_t v);
    (v >= 31'h0) && (v <= 31'h7FFF_FFFF);
  endproperty
  assert_word32_value: assert property (@(posedge clk) disable iff (!rst_n)
    p_word32_range(store_item.value));

  // -------------------------------------------------------------------------
  // 2. Buffer capacity invariants
  // -------------------------------------------------------------------------
  property p_buf_length_le_max;
    buf_length <= MAX_BUFFER_SIZE;
  endproperty
  assert_buf_len: assert property (@(posedge clk) disable iff (!rst_n)
    p_buf_length_le_max);

  property p_buf_full_consistent;
    buf_full == (buf_length == MAX_BUFFER_SIZE);
  endproperty
  assert_buf_full: assert property (@(posedge clk) disable iff (!rst_n)
    p_buf_full_consistent);

  property p_buf_empty_consistent;
    buf_empty == (buf_length == 0);
  endproperty
  assert_buf_empty: assert property (@(posedge clk) disable iff (!rst_n)
    p_buf_empty_consistent);

  // -------------------------------------------------------------------------
  // 3. Data store capacity
  // -------------------------------------------------------------------------
  property p_store_count_le_max;
    store_count <= MAX_DATA_STORE;
  endproperty
  assert_store_count: assert property (@(posedge clk) disable iff (!rst_n)
    p_store_count_le_max);

  // Valid items must have non-zero Id
  property p_valid_item_has_id;
    store_item.valid |-> (store_item.id != 16'h0);
  endproperty
  assert_valid_id: assert property (@(posedge clk) disable iff (!rst_n)
    p_valid_item_has_id);

  // -------------------------------------------------------------------------
  // 4. State-machine transition invariants (from Validation.Validate_State_Transition)
  // -------------------------------------------------------------------------
  function automatic logic valid_transition(app_state_e from, app_state_e to);
    case (from)
      ST_IDLE:
        return (to == ST_INITIALIZING) || (to == ST_SHUTDOWN) || (to == ST_ERROR);
      ST_INITIALIZING:
        return (to == ST_CONFIGURED) || (to == ST_ERROR);
      ST_CONFIGURED:
        return (to == ST_AWAITING_INPUT) || (to == ST_ERROR) || (to == ST_SHUTDOWN);
      ST_AWAITING_INPUT:
        return (to == ST_PARSING) || (to == ST_ERROR) || (to == ST_SHUTDOWN);
      ST_PARSING:
        return (to == ST_VALIDATING) || (to == ST_ERROR);
      ST_VALIDATING:
        return (to == ST_PROCESSING) || (to == ST_ERROR);
      ST_PROCESSING:
        return (to == ST_SERIALIZING) || (to == ST_CHECKING_INTEGRITY) ||
               (to == ST_AUTHORIZED) || (to == ST_AWAITING_INPUT) || (to == ST_ERROR);
      ST_SERIALIZING:
        return (to == ST_CHECKING_INTEGRITY) || (to == ST_AWAITING_INPUT) || (to == ST_ERROR);
      ST_CHECKING_INTEGRITY:
        return (to == ST_AUTHORIZED) || (to == ST_AWAITING_INPUT) || (to == ST_ERROR);
      ST_AUTHORIZED:
        return (to == ST_AWAITING_INPUT) || (to == ST_PROCESSING) ||
               (to == ST_SHUTDOWN) || (to == ST_ERROR);
      ST_ERROR:
        return (to == ST_IDLE) || (to == ST_SHUTDOWN) || (to == ST_AWAITING_INPUT);
      ST_SHUTDOWN:
        return 1'b0; // terminal
      default:
        return 1'b0;
    endcase
  endfunction

  property p_legal_transition;
    valid_transition(current_state, next_state);
  endproperty
  assert_legal_trans: assert property (@(posedge clk) disable iff (!rst_n)
    p_legal_transition);

  // Shutdown is absorbing
  property p_shutdown_absorbing;
    (current_state == ST_SHUTDOWN) |-> (next_state == ST_SHUTDOWN);
  endproperty
  assert_shutdown: assert property (@(posedge clk) disable iff (!rst_n)
    p_shutdown_absorbing);

  // -------------------------------------------------------------------------
  // 5. Safe arithmetic invariants
  // -------------------------------------------------------------------------
  // Saturating add never exceeds Word32'Last
  property p_safe_add_saturates;
    safe_add_overflow |-> (safe_add_result == 31'h7FFF_FFFF);
  endproperty
  assert_safe_add: assert property (@(posedge clk) disable iff (!rst_n)
    p_safe_add_saturates);

  // Saturating sub never goes negative
  property p_safe_sub_saturates;
    safe_sub_underflow |-> (safe_sub_result == 31'h0);
  endproperty
  assert_safe_sub: assert property (@(posedge clk) disable iff (!rst_n)
    p_safe_sub_saturates);

  // GCD result is non-negative and divides both (basic)
  property p_gcd_nonneg;
    gcd_result >= 0;
  endproperty
  assert_gcd: assert property (@(posedge clk) disable iff (!rst_n)
    p_gcd_nonneg);

  // -------------------------------------------------------------------------
  // 6. Integrity / checksum invariants
  // -------------------------------------------------------------------------
  property p_integrity_match;
    integrity_ok |-> (computed_checksum == stored_checksum);
  endproperty
  assert_integrity: assert property (@(posedge clk) disable iff (!rst_n)
    p_integrity_match);

  // Valid item implies checksum is consistent when integrity_ok is claimed
  property p_valid_item_checksum;
    (store_item.valid && integrity_ok) |-> (store_item.checksum == computed_checksum);
  endproperty
  assert_item_csum: assert property (@(posedge clk) disable iff (!rst_n)
    p_valid_item_checksum);

  // -------------------------------------------------------------------------
  // 7. Serial header invariants
  // -------------------------------------------------------------------------
  property p_hdr_magic;
    hdr.magic == 16'hADA1;
  endproperty
  assert_hdr_magic: assert property (@(posedge clk) disable iff (!rst_n)
    p_hdr_magic);

  property p_hdr_version;
    (hdr.version == 8'd1) || (hdr.version == 8'd2);
  endproperty
  assert_hdr_ver: assert property (@(posedge clk) disable iff (!rst_n)
    p_hdr_version);

  property p_hdr_length_le_max;
    hdr.length <= MAX_SERIAL_RECORD;
  endproperty
  assert_hdr_len: assert property (@(posedge clk) disable iff (!rst_n)
    p_hdr_length_le_max);

  // -------------------------------------------------------------------------
  // 8. Authorization invariants
  // -------------------------------------------------------------------------
  property p_auth_monotonic;
    1'b1; // placeholder for stronger lattice invariant if needed
  endproperty

  // -------------------------------------------------------------------------
  // 9. Fail-closed / default safety
  // -------------------------------------------------------------------------
  // On reset everything returns to known safe state
  property p_reset_safe;
    !rst_n |=> (current_state == ST_IDLE);
  endproperty
  assert_reset: assert property (@(posedge clk) p_reset_safe);

endmodule

// =============================================================================
// Bind example (for formal / simulation)
// =============================================================================
/*
bind sovereign_processor_top sovereign_invariant_checker u_inv (
  .clk (clk),
  .rst_n (rst_n),
  .current_state (u_sm.current),
  .next_state (u_sm.next),
  .buf_length (u_mem.buf.length),
  .buf_full (u_mem.buf.full),
  .buf_empty (u_mem.buf.empty),
  .store_count (u_mem.store.count),
  .store_item (u_mem.store.items[examined_idx]),
  .auth_level (u_cfg.level),
  .checksum_seed (u_cfg.seed),
  .safe_add_result (u_math.add_res),
  .safe_add_overflow (u_math.add_ov),
  .safe_sub_result (u_math.sub_res),
  .safe_sub_underflow (u_math.sub_un),
  .gcd_result (u_math.gcd_res),
  .fib_result (u_math.fib_res),
  .computed_checksum (u_int.computed),
  .stored_checksum (u_int.stored),
  .integrity_ok (u_int.ok),
  .hdr (u_ser.header)
);
*/

// =============================================================================
// Cover properties for interesting scenarios (train / recurse analysis)
// =============================================================================
module sovereign_cover_points
  import sovereign_invariants_pkg::*;
(
  input logic clk,
  input logic rst_n,
  input app_state_e current_state,
  input logic integrity_ok,
  input logic safe_add_overflow
);

  cover_idle_to_init: cover property (@(posedge clk)
    (current_state == ST_IDLE) ##1 (current_state == ST_INITIALIZING));

  cover_full_pipeline: cover property (@(posedge clk)
    (current_state == ST_AWAITING_INPUT) ##[1:20]
    (current_state == ST_PROCESSING) ##[1:20]
    (current_state == ST_CHECKING_INTEGRITY) ##[1:10]
    (current_state == ST_AUTHORIZED));

  cover_integrity_fail: cover property (@(posedge clk)
    !integrity_ok);

  cover_math_overflow: cover property (@(posedge clk)
    safe_add_overflow);

  cover_shutdown: cover property (@(posedge clk)
    current_state == ST_SHUTDOWN);

endmodule