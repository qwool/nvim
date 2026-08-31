function cc_run
  cc $argv[1] -o /tmp/$argv[1].a && /tmp/$argv[1].a
end
