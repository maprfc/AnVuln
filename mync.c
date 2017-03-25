int
main ()
{
  char *program = "/bin/nc";
  char *args[3] = {"/bin/nc", "-lvvp", "40967"};

  execve(program, args, 0);
  return 0;
}

