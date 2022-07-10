# Homebrew installs LLVM in a place that is not visible to ffigen.
# This explicitly specifies the place where the LLVM dylibs are kept.
llvm_path := if os() == "macos" {
    "--llvm-path /opt/homebrew/opt/llvm"
} else {
    ""
}

default: gen lint

gen:
    # combine version
    export REPO_DIR="$PWD"; cd /; flutter_rust_bridge_codegen {{llvm_path}} \
        --rust-input \
        "$REPO_DIR/native/src/rule_api.rs" \
        "$REPO_DIR/native/src/ucci_api.rs" \
        "$REPO_DIR/native/src/log_api.rs" \
        --dart-output \
        "$REPO_DIR/lib/gened_rule_api.dart" \
        "$REPO_DIR/lib/gened_ucci_api.dart" \
        "$REPO_DIR/lib/gened_log_api.dart" \
        --rust-output \
        "$REPO_DIR/native/src/gened_rule_api.rs" \
        "$REPO_DIR/native/src/gened_ucci_api.rs" \
        "$REPO_DIR/native/src/gened_log_api.rs" \
        --class-name RuleApi UcciApi LogApi \

    # Uncomment this line to invoke build_runner as well
    # flutter pub get
    # flutter pub run build_runner build --delete-conflicting-outputs

lint:
    cd native && cargo fmt
    dart format .

clean:
    flutter clean
    cd native && cargo clean

# vim:expandtab:sw=4:ts=4