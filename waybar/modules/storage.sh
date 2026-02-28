#!/bin/sh

mount="/"
warning=20
critical=10

df -h -P -l | awk -v mount="$mount" -v warning="$warning" -v critical="$critical" '
BEGIN {
  root_text=""
  root_use="0%"
  tooltip=""
}
NR == 1 { next }
$6 ~ "^/(|home|run/media|mnt|media)($|/)" {
  line = $6 ": " $3 "/" $2 " (" $5 ", free " $4 ")"
  if (tooltip == "") {
    tooltip = line
  } else {
    tooltip = tooltip "\\n" line
  }

  if ($6 == mount) {
    root_text = $4
    root_use = $5
  }
}
END {
  class=""
  use=root_use
  gsub(/%$/,"",use)
  if ((100 - use) < critical) {
    class="critical"
  } else if ((100 - use) < warning) {
    class="warning"
  }

  if (root_text == "") {
    root_text = "?"
  }
  if (tooltip == "") {
    tooltip = "No mounted local filesystems found"
  }

  print "{\"text\":\"" root_text "\", \"percentage\":" use ",\"tooltip\":\"" tooltip "\", \"class\":\"" class "\"}"
}
'
