#!/usr/bin/env bash
# Backend-detection test harness.
# Verifies the Backend section of SKILL.md by exercising detect_backend.sh
# against a matrix of fixtures and gh-CLI stubs.

set -u

here="$(cd "$(dirname "$0")" && pwd)"
detect="$here/detect_backend.sh"
fixtures="$here/fixtures"
stubs="$here/stubs"

pass=0
fail=0
failed_names=()

run_case() {
  local name="$1"
  local fixture="$2"
  local stub_mode="$3"     # ok | no_remote | absent
  local expected_stdout="$4"
  local expected_exit="$5"
  local expect_warning="$6" # yes | no

  local tmp_path
  tmp_path="$(mktemp -d)"

  # Build a PATH that either contains a stub gh, or strips gh entirely.
  case "$stub_mode" in
    ok)
      cp "$stubs/gh_ok" "$tmp_path/gh"
      chmod +x "$tmp_path/gh"
      local path="$tmp_path:/usr/bin:/bin"
      ;;
    no_remote)
      cp "$stubs/gh_no_remote" "$tmp_path/gh"
      chmod +x "$tmp_path/gh"
      local path="$tmp_path:/usr/bin:/bin"
      ;;
    absent)
      # Sandbox dir only — no gh.
      local path="$tmp_path:/usr/bin:/bin"
      ;;
    *)
      echo "FAIL [$name]: unknown stub_mode '$stub_mode'"
      fail=$((fail+1)); failed_names+=("$name"); return
      ;;
  esac

  local rune_arg="$fixture"
  if [[ "$fixture" == "MISSING" ]]; then
    rune_arg="$tmp_path/does_not_exist.md"
  fi

  local actual_stdout actual_stderr actual_exit
  actual_stdout="$(PATH="$path" bash "$detect" "$rune_arg" 2>"$tmp_path/stderr")"
  actual_exit=$?
  actual_stderr="$(cat "$tmp_path/stderr")"

  local ok=1
  if [[ "$actual_stdout" != "$expected_stdout" ]]; then
    ok=0
    echo "FAIL [$name]: stdout"
    echo "  expected: '$expected_stdout'"
    echo "  actual:   '$actual_stdout'"
  fi
  if [[ "$actual_exit" != "$expected_exit" ]]; then
    ok=0
    echo "FAIL [$name]: exit code"
    echo "  expected: $expected_exit"
    echo "  actual:   $actual_exit"
  fi
  if [[ "$expect_warning" == "yes" && -z "$actual_stderr" ]]; then
    ok=0
    echo "FAIL [$name]: expected a warning on stderr but got none"
  fi
  if [[ "$expect_warning" == "no" && -n "$actual_stderr" ]]; then
    ok=0
    echo "FAIL [$name]: unexpected warning on stderr: $actual_stderr"
  fi

  rm -rf "$tmp_path"

  if [[ $ok -eq 1 ]]; then
    echo "PASS [$name]"
    pass=$((pass+1))
  else
    fail=$((fail+1))
    failed_names+=("$name")
  fi
}

# T1: configured=github, gh ok, remote ok → github, no warning.
run_case "T1 github+gh+remote → github" \
  "$fixtures/RUNE_github.md" ok "github" 0 no

# T2: configured=github, gh absent → file + warning.
run_case "T2 github+no-gh → file" \
  "$fixtures/RUNE_github.md" absent "file" 0 yes

# T3: configured=github, gh present but no remote → file + warning.
run_case "T3 github+gh+no-remote → file" \
  "$fixtures/RUNE_github.md" no_remote "file" 0 yes

# T4: configured=file → file regardless of gh availability (no warning, no gh call).
run_case "T4 file → file (gh ignored)" \
  "$fixtures/RUNE_file.md" ok "file" 0 no
run_case "T4b file → file (no gh installed)" \
  "$fixtures/RUNE_file.md" absent "file" 0 no

# T5: backend field missing → default github → gh ok → github.
run_case "T5 missing-backend → defaults to github" \
  "$fixtures/RUNE_missing_backend.md" ok "github" 0 no

# T6: unknown backend value → warning + default github → gh ok → github.
run_case "T6 invalid-backend → warns + defaults to github" \
  "$fixtures/RUNE_invalid_backend.md" ok "github" 0 yes

# T7: RUNE.md absent → exit 2 (caller runs setup), warning on stderr.
run_case "T7 RUNE.md missing → exit 2" \
  "MISSING" ok "" 2 yes

# T8: backend=github + missing RUNE.md fixture sanity — covered by T7.

# T9: file backend with gh+remote ok still echoes file and never calls gh.
#     (T4 already covers this; explicit duplicate keeps the intent visible.)

echo
echo "Results: $pass passed, $fail failed."
if [[ $fail -gt 0 ]]; then
  printf 'Failed: %s\n' "${failed_names[@]}"
  exit 1
fi
