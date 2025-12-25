export MallocNanoZone='0'
PATH="/Applications/CMake.app/Contents/bin":"$PATH"

# ==============================================================================
#           Competitive Programming Toolkit (cpt)
#
#   This script provides a flexible function `cpt` to compile, run,
#   generate test cases, and stress-test solutions.
# ==============================================================================

# --- Configuration ---
# Set your Competitive Programming home directory.
# The `:-` syntax uses the value of the environment variable if it exists,
# otherwise it falls back to the default provided here.
export CP_HOME=$HOME/Documents/Competitve-Programming

# Default compiler and flags. You can override these by setting them in your shell.
# -fsanitize=address: Excellent for finding memory bugs like out-of-bounds access.
# -DLOCAL_TEST: Useful for conditional debugging (#ifdef LOCAL_TEST).
export CP_CXX="g++-14"
# FIX: The flags are now defined without surrounding quotes to ensure the shell
# performs word splitting, passing them as separate arguments to the compiler.
export CP_CXXFLAGS="-std=c++20 -O2 -Wall -Wextra -g -fsanitize=address -DLOCAL_TEST"

# --- Main CP Toolkit Function ---
# FIX: Renamed from 'cp' to 'cpt' to avoid conflict with the system's copy command.
# Usage: cpt <command> [arguments...]
cpt() {
  # Ensure base directories exist before doing anything else.
  mkdir -p "$CP_HOME/src" "$CP_HOME/build" "$CP_HOME/io"

  # The first argument is the command (run, gen, etc.).
  local command="$1"
  # 'shift' removes the first argument, so the rest ($@) are the arguments for the subcommand.
  shift

  case "$command" in
    run) _cpt_run "$@" ;;
    gen) _cpt_gen "$@" ;;
    brute) _cpt_brute "$@" ;;
    stress) _cpt_stress "$@" ;;
    *) # If no valid command is given, print help text.
      echo "Usage: cpt <command> [options]"
      echo
      echo "Commands:"
      echo "  run [file.cpp]     Compile and run a solution file with 'io/in' as input."
      echo "                     (Defaults to src/main.cpp)"
      echo "  gen [file.cpp]     Compile and run a generator file, saving output to 'io/in'."
      echo "                     (Defaults to src/gen.cpp)"
      echo "  brute [file.cpp]   Compile and run a brute-force solution with 'io/in'."
      echo "                     (Defaults to src/brute.cpp)"
      echo "  stress             Automatically runs gen, your solution, and a brute-force"
      echo "                     solution in a loop to find a failing test case."
      return 1
      ;;
  esac
}

# ==============================================================================
#   Internal Helper Functions (prefixed with _ to indicate private use)
# ==============================================================================

# Internal function to compile a single C++ file.
_cpt_compile() {
  local source_file="$1"
  local exe_path="$2"

  if [ ! -f "$source_file" ]; then
    echo "Error: Source file not found: '$source_file'"
    return 1
  fi
  g++ -std=c++20 -O2 -g -fsanitize=address -DLOCAL_TEST $source_file -o $exe_path

  return 0
}

# --- Command Implementations ---

_cpt_run() {
  local source_file="${1:-main.cpp}"
  local source_path="$CP_HOME/src/$source_file"
  local exe_path="$CP_HOME/build/${source_file%.cpp}"

  if _cpt_compile "$source_path" "$exe_path"; then
    # Run the executable, redirecting io/in as standard input.
    "$exe_path" <"$CP_HOME/io/in"
  fi
}

_cpt_gen() {
  local source_file="${1:-gen.cpp}"
  local source_path="$CP_HOME/src/$source_file"
  local exe_path="$CP_HOME/build/${source_file%.cpp}"

  if _cpt_compile "$source_path" "$exe_path"; then
    # Run the generator and redirect its output to create the input file.
    "$exe_path" >"$CP_HOME/io/in"
  fi
}

_cpt_brute() {
  local source_file="${1:-brute.cpp}"
  local source_path="$CP_HOME/src/$source_file"
  local exe_path="$CP_HOME/build/${source_file%.cpp}"

  if _cpt_compile "$source_path" "$exe_path"; then
    "$exe_path" <"$CP_HOME/io/in"
  fi
}

# The "killer feature": automated stress testing.
_cpt_stress() {
  # Default filenames
  local sol_file="main.cpp"
  local brute_file="brute.cpp"
  local gen_file="gen.cpp"

  local sol_path="$CP_HOME/src/$sol_file"
  local brute_path="$CP_HOME/src/$brute_file"
  local gen_path="$CP_HOME/src/$gen_file"

  local sol_exe="$CP_HOME/build/${sol_file%.cpp}"
  local brute_exe="$CP_HOME/build/${brute_file%.cpp}"
  local gen_exe="$CP_HOME/build/${gen_file%.cpp}"

  # Compile all three files once at the beginning.
  echo "--- Preparing for Stress Test ---"
  if ! _cpt_compile "$sol_path" "$sol_exe"; then return 1; fi
  if ! _cpt_compile "$brute_path" "$brute_exe"; then return 1; fi
  if ! _cpt_compile "$gen_path" "$gen_exe"; then return 1; fi
  echo "--- All files compiled successfully ---"

  for i in {1..1000}; do
    echo -ne "--- Running Test #$i ---\r"

    # 1. Generate test case
    "$gen_exe" >"$CP_HOME/io/in"

    # 2. Run main solution and save its output
    "$sol_exe" <"$CP_HOME/io/in" >"$CP_HOME/io/main.out" 2>"$CP_HOME/io/main.err"

    # 3. Run brute force solution and save its output
    "$brute_exe" <"$CP_HOME/io/in" >"$CP_HOME/io/brute.out"

    # 4. Compare outputs. diff -w ignores whitespace differences.
    if diff -w "$CP_HOME/io/main.out" "$CP_HOME/io/brute.out" >/dev/null; then
      continue # If they match, continue to the next test case
    else
      # If they differ, report the failure and stop
      echo -e "\n\n--- WA on Test #$i ---"
      echo "Input:"
      cat "$CP_HOME/io/in"
      echo "--------------------"
      echo "Your Output:"
      cat "$CP_HOME/io/main.out"
      echo "--------------------"
      echo "Correct Output:"
      cat "$CP_HOME/io/brute.out"
      echo "--------------------"
      return 1
    fi
  done
  echo -e "\n--- Passed 1000 tests successfully! ---"
}
