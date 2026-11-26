base_str := m1
if RegExMatch(base_str, i)^m(\d+)$, &m) {
  mid := Integer(m[1])
}
