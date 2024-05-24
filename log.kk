pub effect log
  fun log(level: string, message: string) : ()

pub fun info(message) log("info", message)
pub fun warn(message) log("warn", message)
pub fun debug(message) log("debug", message)

pub fun basic-logging-print(action)
  with fun log(level, message) println("[" ++ level ++ "] " ++ message)
  action()

fun test-inside-nested()
  log/warn("oh no!")

fun test-inside()
  log/info("hello world!")
  test-inside-nested()

fun main()
  with basic-logging-print
  test-inside()

