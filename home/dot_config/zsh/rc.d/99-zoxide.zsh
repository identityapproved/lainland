# zoxide — deliberately the highest-numbered module so it is the last thing the
# rc.d loop sources. `zoxide init` appends __zoxide_hook to chpwd_functions and
# then warns (its "doctor") on every cd if that hook is missing, so anything
# sourced later that *assigns* chpwd_functions instead of appending would both
# silence the directory tracking and trigger the nag. Keep the 99 prefix free.
#
# The doctor also false-positives in snapshot-restored shells; see the
# _ZO_DOCTOR guard in ../.zshenv for why that lives outside .zshrc.
#
# Guarded on the binary so the config stays portable to hosts where zoxide
# isn't installed — without it, cd falls back to the builtin.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
