#!/usr/bin/env bash
# CPU temperature straight from sysfs hwmon (no lm_sensors dependency).
set -uo pipefail

temp_mC=""
label=""
for h in /sys/class/hwmon/hwmon*; do
  [ -r "$h/name" ] || continue
  name="$(cat "$h/name" 2>/dev/null)"
  case "$name" in
    k10temp|zenpower|coretemp|cpu_thermal|acpitz)
      best=""
      for t in "$h"/temp*_input; do
        [ -r "$t" ] || continue
        lbl=""
        lf="${t%_input}_label"
        [ -r "$lf" ] && lbl="$(cat "$lf" 2>/dev/null)"
        [ -z "$best" ] && best="$t"
        case "$lbl" in
          Tctl|Tdie|Package*) best="$t"; break ;;
        esac
      done
      if [ -n "$best" ]; then
        temp_mC="$(cat "$best" 2>/dev/null)"
        label="$name"
        break
      fi
      ;;
  esac
done

if [ -z "$temp_mC" ]; then
  printf '{"text":" ?","tooltip":"no cpu hwmon temp found"}\n'
  exit 0
fi

temp=$(( (temp_mC + 500) / 1000 ))
printf '{"text":" %s°C","tooltip":"%s: %s°C"}\n' "$temp" "$label" "$temp"
