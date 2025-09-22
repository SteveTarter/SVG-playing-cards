{
  name = substr($0, 0, length($0) - 4);
  printf "inkscape \"%s.svg\" --export-type=png --export-filename=\"%s.png\" --export-dpi=100 -w 224 -h 224 >& /dev/null;\n", name, name;
  printf "rm  \"%s.svg\"\n", name;
}
