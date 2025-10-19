_help() {
  echo "Usage: roremu <words> [--offset | -o] [--custom-text | -c]" >&2
}

roremu() {
  if ! zparseopts -D -E \
    h=opt_help -help=opt_help \
    o:=opt_offset -offset:=opt_offset \
    c:=opt_text -custom-text:=opt_text 2>/dev/null
  then
    _help
    return 1
  fi

  if [[ -n $opt_help ]]; then
    _help
    return 0
  fi

  if [[ -z $1 ]]; then
    echo "roremu: words must be specified" >&2
    _help
    return 1
  fi

  local words=$1
  if ! [ $words -eq $words ] 2>/dev/null; then
    echo "roremu: words must be integer" >&2
    _help
    return 1
  fi

  local offset=${opt_offset[-1]:-0}
  if ! [ $offset -eq $offset ] 2>/dev/null; then
    echo "roremu: offset must be integer" >&2
    _help
    return 1
  fi

  local text_file=${${(%):-%x}:A:h}/neko.txt
  local text=${opt_text[-1]:-$(<$text_file)}
  local clusters=(${(@s::)text})
  local length=${#clusters}
  if [[ $length -eq 0 ]]; then
    echo "roremu: custom-text must not be empty" >&2
    _help
    return 1
  fi

  local times=$(( (offset + words + length - 1) / length ))
  local repeated_text=""
  repeat $times repeated_text+=$text
  local repeated_clusters=(${(@s::)repeated_text})
  local result=${(j::)repeated_clusters[offset+1,offset+words]}
  echo $result
}
