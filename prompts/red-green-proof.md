Fix the bug using the red-green-proof discipline. A bug is not fixed because the
tests pass — it is fixed when a test fails without the fix and passes with it,
and you have watched it do both.

PICK THE TARGET. If a target was given after the command, use it. If nothing was
given, take it from this conversation — do not ask what to work on. Scan back and
pick, in this order: (a) a defect just identified but not yet fixed; (b) a fix
applied without a failing test behind it — the most valuable target, since the
test still has to be proven load-bearing; (c) a test written but never verified
red; (d) anything called "still open", "not fixed yet", or "characterization
only". State your pick in one line and start. Only ask if two candidates are
genuinely equal — then give a short numbered choice and stop. Handle related
defects one at a time through the full loop; each needs its own red. If nothing
qualifies, say so rather than inventing a target.

1. VERIFY THE CAUSE. Do not infer it. Establish what happened from evidence you
   can point at: the real record, the real log line, the actual source of the
   function you are blaming. Label every claim Proven / Inferred / Unknown and
   say the label out loud. If it is Unknown, say so and name the one artifact
   that would settle it. Before treating something as a bug, run
   `git log -S '<the exact line>'` — if a test already asserts the current
   behaviour, someone may have intended it; understand why before inverting it.

2. WRITE THE TEST AND WATCH IT FAIL against the code as it is now, before any
   fix exists. Name it after the defect ("reveals bug: stale status shadows a
   terminal event"), not the function. Assert the observable consequence — the
   wrong value, the lost record, the 500 — not that a mock was called. If it
   does not fail, you have not reproduced the bug; go back to step 1.

3. APPLY THE SMALLEST FIX that turns it green.

4. REVERT THE FIX AND CONFIRM IT GOES RED AGAIN, then restore. Back up the file,
   put the buggy code back, run that specific test, watch it fail, restore.
   If it stayed green the test is FAKE — rewrite it and repeat. This step is not
   optional. It catches tests that exercise a path next to the bug rather than
   the bug: a concurrency test whose modelled writers never actually interleave,
   or a fault-isolation test whose injected "failure" returns null instead of
   throwing. Both look correct on the page; only the revert exposes them.

5. RUN THE FULL SUITE AND TYPE CHECKS. If the fix breaks a pre-existing test
   that pinned the old behaviour, that is a finding — go read it and decide
   deliberately, per step 1.

IF THE CODE CANNOT BE INVOKED (a closure inside a huge factory, a route handler):
do not fake a behavioural test. Either extract it into a module with injected
dependencies and test it properly, or write a structural test that scans the
source and asserts the invariant, or a model test that mirrors the real code
field-for-field citing the file:line it models. Label which one it is in the
file header. Models are where fake tests hide — step 4 matters most there.

REPORT: what you proved vs inferred vs still do not know; the actual revert
output showing the failure, not a claim that it failed; which tests are
behavioural, structural, model, or characterization; and anything you got wrong
earlier, corrected explicitly. Never describe a test as revealing a bug unless
you have seen it red.
