doc "Enumerates the possible states of a [[TestUnit]]"
shared abstract class TestState(shared actual String string)
        of undefined | running | success | failure | error {}

doc "A test which has not yet started execution."
shared object undefined extends TestState("undefined") {}

doc "A test is running if it has been started, but has not yet completed execution."
shared object running extends TestState("running") {}

doc "A test fails if it complete normally, (that is, does not throw an exception)."
shared object success extends TestState("success") {}

doc "A test fails if it propgates an [[AssertException]]"
shared object failure extends TestState("failure") {}

doc "A test is in error if it propgates any exception which is not an [[AssertException]]"
shared object error extends TestState("error") {}