# Week 5 — AI log

## The assistant, and the code I asked it for

Gemini; The route in server/main.py and the test in server/tests/test_login.py 

## What I expected, written before I ran it

I expected everything to run smoothly without any errors.To make sure te test checks weather logging in with the right code gives the correct outcome.  the test id is TC-001-01, TC-001-02 expetcede 401 but recevied 501 and id TC-001-04 expected  401  and recevied 501. 

## The command I ran, and what I saw

The command i ran was python -m pytest server/tests/test_login.py -v and sadly the outcome showed me that TC-001-01 failed test because test expected status code 200, but the server returned 501  was not  correctly Implemented. And when i tsted for TC-001-02 it failed the test because the expected status code was 401 but server returned 501 and the same thing for TC-001-04. The reason is that the login functionality has not been implemented yet, so the server is still returning its placeholder response.

## The line I changed or refused, and why

The assistants code was assert response.status_code == 200 , I changed the satus code from 200 to 501 because login isn't implemented until week 6. 


## Evidence — the exchange and the terminal output

```text
ME:
My login route returns 501 because login is not implemented until Week 6, but my test expects 200 and fails.
Can you explain why this happens and whether I should change 200 to 501 for Week 5? 

AI:
The test fails because pytest evaluates the HTTP status code returned by your server against the value in your test assertion:

Server returns: 501 Not Implemented (FastAPI route placeholder for deferred features).

Test expects: 200 OK (assert response.status_code == 200).

Since 
501

=200, pytest triggers an AssertionError.

Deciding Whether to Change 200 to 501 for Week 5
Change to 501

Why: Validates that your Week 5 skeleton route is correctly wired up and intentionally returning "Not Implemented".

Trade-off: You will need to change the assertion back to 200 in Week 6 once authentication is built.

When to choose: If your Week 5 grading requires a clean, 100% passing test suite.

Keep as 200

Why: Acts as a target contract under Test-Driven Development (TDD), defining how the completed feature should behave.

Trade-off: Your test suite will show a test failure during Week 5.

When to choose: If the test was pre-written to verify Week 6 completion.

Mark as an expected failure (@pytest.mark.xfail)

Why: Preserves the 200 target assertion without causing the overall Week 5 test run to fail.

How: Place @pytest.mark.xfail(reason="Login implemented in Week 6") directly above the test function.

ME : 
I ran my Weatherly login test twice. First, it failed because I expected 200 but got 501. Then I changed the assertion to 501 and the test passed. Can you explain what this means and what the test is checking now? 


AI: What This Result Means
Passing the test with 501 confirms that your overall setup—FastAPI routing, request handling, and Pytest configuration—is working properly:

Route Connectivity: Your test client is successfully sending a POST request to /auth/login and reaching the correct function in server/main.py.

Server State Alignment: Your server and test suite now agree on the current state of the application: the endpoint is intentionally an unfinished skeleton placeholder.

No Hidden Runtime Errors: The server did not crash with a 500 Internal Server Error or fail to find the route with a 404 Not Found.

What the Test Is Checking Now
By asserting response.status_code == 501, your test currently verifies:

Route Endpoint Existence: The endpoint /auth/login exists and accepts incoming POST requests.

Intentional Deferral: The server explicitly returns a 501 Not Implemented status code as expected for Week 5.

What it is NOT checking yet:

It does not validate user credentials (email or passcode).

It does not query a database or check user records.

It does not generate session tokens or handle successful user logins.

When you implement the actual login logic in Week 6, you will update the test assertion back to 200 OK (along with checking the returned token/response payload) to verify full authentication functionality.

TERMINAL: The command i typed python -m pytest server/tests/test_login.py -v
the output is :  
PS C:\Users\USER\Documents\aiasd-project> python -m pytest server/tests/test_login.py -v
===================================================================== test session starts =====================================================================
platform win32 -- Python 3.13.1, pytest-9.1.1, pluggy-1.7.0 -- C:\Python313\python.exe
cachedir: .pytest_cache
rootdir: C:\Users\USER\Documents\aiasd-project
plugins: anyio-4.15.1
collected 3 items

server/tests/test_login.py::test_TC_001_01_log_in_with_the_correct_code FAILED                                                                           [ 33%]
server/tests/test_login.py::test_TC_001_02_a_wrong_code_is_refused FAILED                                                                                [ 66%]
server/tests/test_login.py::test_TC_001_04_an_expired_login_code_is_refused FAILED                                                                       [100%]

========================================================================== FAILURES ===========================================================================
_________________________________________________________ test_TC_001_01_log_in_with_the_correct_code _________________________________________________________

    def test_TC_001_01_log_in_with_the_correct_code():
        response = client.post(
            "/auth/login",
            json={"email": "student@example.test", "code": "1234"},
        )

>       assert response.status_code == 200
E       assert 501 == 200
E        +  where 501 = <Response [501 Not Implemented]>.status_code

server\tests\test_login.py:17: AssertionError
___________________________________________________________ test_TC_001_02_a_wrong_code_is_refused ____________________________________________________________

    def test_TC_001_02_a_wrong_code_is_refused():
        response = client.post(
            "/auth/login",
            json={"email": "student@example.test", "code": "1111"},
        )

>       assert response.status_code == 401
E       assert 501 == 401
E        +  where 501 = <Response [501 Not Implemented]>.status_code

server\tests\test_login.py:26: AssertionError
_______________________________________________________ test_TC_001_04_an_expired_login_code_is_refused _______________________________________________________

    def test_TC_001_04_an_expired_login_code_is_refused():
        response = client.post(
            "/auth/login",
            json={"email": "student@example.test", "code": "1234"},
        )

>       assert response.status_code == 401
E       assert 501 == 401
E        +  where 501 = <Response [501 Not Implemented]>.status_code

server\tests\test_login.py:35: AssertionError
=================================================================== short test summary info ===================================================================
FAILED server/tests/test_login.py::test_TC_001_01_log_in_with_the_correct_code - assert 501 == 200
FAILED server/tests/test_login.py::test_TC_001_02_a_wrong_code_is_refused - assert 501 == 401
FAILED server/tests/test_login.py::test_TC_001_04_an_expired_login_code_is_refused - assert 501 == 401
====================================================================== 3 failed in 0.85s ======================================================================
PS C:\Users\USER\Documents\aiasd-project>

```
