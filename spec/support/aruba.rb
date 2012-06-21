def start
  @aruba_io_wait_seconds = 5
  run_interactive './../bin/netatlas-test'
end